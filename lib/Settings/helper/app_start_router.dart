import 'dart:async';

import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Features/onboarding/model/login_model.dart';
import 'package:everqpidapp/Features/onboarding/repository/auth_api_repository.dart';
import 'package:everqpidapp/Features/onboarding/repository/email_auth_repository.dart';
import 'package:everqpidapp/Settings/helper/fcm_token_refresh_handler.dart';
import 'package:everqpidapp/Settings/utils/p_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

/// Startup auth gate: wait for Firebase restore + backend JWT restore,
/// then Home vs Welcome. No Login flash while [AuthPhase.initializing].
enum AuthPhase { initializing, authenticated, unauthenticated }

/// Single place that decides Home vs Login after session restore.
///
/// Cold start and restart use [resolve] / [resolveForWeb] — no splash screen.
class AppStartRouter {
  AppStartRouter._();

  /// Unauthenticated entry (welcome / login onboarding).
  static const String loginRoute = PPages.welcomePageUi;

  static const String homeRoute = PPages.mainScreen;

  static AuthPhase phase = AuthPhase.initializing;

  static bool get isAuthenticated =>
      LoggedInUser.accessToken != null && LoggedInUser.accessToken!.isNotEmpty;

  /// Restores session from storage and returns [homeRoute] or [loginRoute].
  /// Waits for Firebase Auth persistence before treating null as logged out.
  static Future<String> resolve() async {
    phase = AuthPhase.initializing;
    await _awaitFirebaseAuthReady();
    await LoggedInUser.getUserDetails();

    if (!isAuthenticated) {
      await _trySilentBackendRestore();
    }

    phase =
        isAuthenticated ? AuthPhase.authenticated : AuthPhase.unauthenticated;
    return isAuthenticated ? homeRoute : loginRoute;
  }

  /// Web initial route: Home/Login for `/` and `/splash`; keep deep links
  /// when authenticated, otherwise send to Login.
  static Future<String> resolveForWeb() async {
    final requested =
        WidgetsBinding.instance.platformDispatcher.defaultRouteName;
    final dest = await resolve();

    if (requested == '/' ||
        requested == PPages.splash ||
        requested.isEmpty) {
      return dest;
    }

    return isAuthenticated ? requested : loginRoute;
  }

  /// Side-effects that need a mounted [BuildContext] after landing on Home.
  static void onAuthenticated(BuildContext context) {
    FCMTokenRefreshService.initialize(context);
  }

  /// First [authStateChanges] emission = Firebase finished restoring (or none).
  static Future<void> _awaitFirebaseAuthReady() async {
    try {
      await FirebaseAuth.instance
          .authStateChanges()
          .first
          .timeout(const Duration(seconds: 8));
    } on TimeoutException {
      // Proceed with whatever currentUser / storage already has.
    } catch (_) {
      // Firebase unavailable — fall through to JWT-only restore.
    }
  }

  /// Firebase session exists but backend JWTs missing (e.g. pre-fix web users).
  static Future<bool> _trySilentBackendRestore() async {
    final fb = FirebaseAuth.instance.currentUser;
    if (fb == null) return false;

    try {
      final isGoogle =
          fb.providerData.any((p) => p.providerId == 'google.com');
      if (isGoogle) {
        final email = fb.email;
        final idToken = await fb.getIdToken();
        if (email == null || email.isEmpty || idToken == null || idToken.isEmpty) {
          return false;
        }
        final response = await EmailAuthRepository().googleLogin(
          idToken: idToken,
          email: email,
        );
        if (!response.status || response.data == null) return false;
        LoggedInUser.id = response.data!.user.id;
        LoggedInUser.accessToken = response.data!.tokens.access.token;
        LoggedInUser.refreshToken = response.data!.tokens.refresh.token;
        await LoggedInUser.storeUserLocally();
        return true;
      }

      final cc = LoggedInUser.countryCode;
      final mob = LoggedInUser.mobileNumber;
      if (cc == null || cc.isEmpty || mob == null || mob.isEmpty) {
        return false;
      }
      final response = await AuthApiRepository().login(
        LoginRequest(countryCode: cc, mobileNumber: mob),
      );
      if (!response.status || response.data == null) return false;
      LoggedInUser.id = response.data!.user.id;
      LoggedInUser.accessToken = response.data!.tokens.access.token;
      LoggedInUser.refreshToken = response.data!.tokens.refresh.token;
      await LoggedInUser.storeUserLocally();
      return true;
    } catch (_) {
      return false;
    }
  }
}
