import 'dart:async';

import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Data/services/logger_service.dart';
import 'package:everqpidapp/Features/FCM/repository/fcm_repository.dart';
import 'package:everqpidapp/Features/location/view_model/location_view_model.dart';
import 'package:everqpidapp/Features/onboarding/helper/signup_location.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/app_navigator.dart';
import 'package:everqpidapp/Settings/utils/p_pages.dart';
import 'package:everqpidapp/config/config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'permission_platform.dart';

/// Post-login permission prompts for Location + Notifications.
///
/// Mobile Chrome / WebKit require each browser permission prompt to start
/// synchronously inside a user tap. Requesting both APIs from one Continue
/// button often drops the second prompt on mobile, so we use **two separate
/// gesture-gated steps**. The one-shot prefs flag is only set when the user
/// grants what we asked for, or explicitly skips.
class PermissionManager {
  PermissionManager._();

  static const stateKey = 'permission_prompt_completed';
  static bool _showing = false;

  static void _log(String message) {
    if (kDebugMode) debugPrint('[Permissions] $message');
  }

  /// Call immediately after navigating to the authenticated app.
  static void showAfterLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = AppNavigator.key.currentContext;
      if (context != null) unawaited(showIfNeeded(context));
    });
  }

  /// Same location dialog as post-login for existing users.
  /// Starts GPS inside the Allow tap (required on web). If the browser cannot
  /// return a GPS fix (common on desktop Chrome), falls back to city entry.
  static Future<SignupLocation?> promptLocationForSignup(
    BuildContext context,
  ) async {
    if (!context.mounted) return null;

    // Already have a fix from an earlier Allow this session.
    if (LoggedInUser.lat != null && LoggedInUser.long != null) {
      return SignupLocation.fromCoords(
        LoggedInUser.lat!,
        LoggedInUser.long!,
      );
    }

    final locationRequest = await showDialog<Future<SignupLocation?>>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogContext) => _PermissionPromptDialog(
        icon: Icons.location_on_outlined,
        title: 'So, are you from around here?',
        body: "Set your location to see who's in your area or beyond. "
            "You won't be able to match with people otherwise.",
        primaryLabel: 'Allow',
        // Must start the browser API inside this tap — no awaits first.
        onPrimary: () => Navigator.pop(
          dialogContext,
          _acquireSignupLocation(context),
        ),
        secondaryLabel: 'Enter city instead',
        onSecondary: () => Navigator.pop(
          dialogContext,
          _promptManualCity(context),
        ),
      ),
    );

    if (locationRequest == null) return null;
    return locationRequest;
  }

  static Future<SignupLocation?> _acquireSignupLocation(
    BuildContext context,
  ) async {
    final position = await _getPosition(context);
    if (position != null) return SignupLocation.fromPosition(position);
    if (!context.mounted) return null;
    // Desktop Chrome often grants permission but never returns a fix.
    return _promptManualCity(context);
  }

  static Future<SignupLocation?> _promptManualCity(BuildContext context) async {
    final controller = TextEditingController();
    final query = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Enter your city',
            style: getTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (v) => Navigator.pop(ctx, v),
            decoration: const InputDecoration(
              hintText: 'e.g. Bangalore, Karnataka',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              style: FilledButton.styleFrom(backgroundColor: Colors.black),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (query == null || query.trim().isEmpty) return null;

    final loc = await SignupLocation.fromAddressQuery(query);
    if (loc == null) return null;
    LoggedInUser.lat = loc.lat;
    LoggedInUser.long = loc.lng;
    return loc;
  }

  static Future<void> showIfNeeded(BuildContext context) async {
    if (_showing) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(stateKey) == true) {
      _log('prompt already completed on this device — skipping dialog');
      return;
    }
    if (!context.mounted) return;

    _log('platform=$platformDebugDescription '
        'notificationsSupported=$supportsNotificationPermission');

    _showing = true;
    try {
      final optedOutOrDone = await _runPromptFlow(context);
      if (optedOutOrDone) {
        await prefs.setBool(stateKey, true);
        _log('marked prompt completed');
      } else {
        _log('prompt NOT marked completed — user can retry next launch');
      }
    } finally {
      _showing = false;
    }
  }

  /// Returns `true` when we should stop prompting (granted or Skip).
  /// Returns `false` when a required grant failed — keep flag unset for retry.
  static Future<bool> _runPromptFlow(BuildContext context) async {
    var notificationsOk = true;

    if (supportsNotificationPermission) {
      if (!context.mounted) return false;
      final notifRequest = await showDialog<Future<bool>>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        builder: (dialogContext) => _PermissionPromptDialog(
          icon: Icons.notifications_none_rounded,
          title: 'Stay in the loop',
          body: 'Get match alerts and messages. Tap Allow, then confirm in the '
              'browser prompt.',
          primaryLabel: 'Allow',
          // Must start the browser API inside this tap — no awaits first.
          onPrimary: () => Navigator.pop(
            dialogContext,
            _requestNotifications(),
          ),
          secondaryLabel: 'Skip',
          onSecondary: () => Navigator.pop(dialogContext),
        ),
      );

      if (notifRequest == null) {
        _log('notifications skipped by user');
        return true;
      }

      notificationsOk = await notifRequest;
      if (!notificationsOk && context.mounted) {
        _showRetrySnackBar(
          context,
          'Notifications were blocked. You can enable them in browser site '
          'settings, then try again after login.',
        );
      }
    } else {
      _log('notification step skipped — unsupported on this browser/PWA');
    }

    if (!context.mounted) return false;

    final locationRequest = await showDialog<Future<bool>>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogContext) => _PermissionPromptDialog(
        icon: Icons.location_on_outlined,
        title: 'So, are you from around here?',
        body: "Set your location to see who's in your area or beyond. "
            "You won't be able to match with people otherwise.",
        primaryLabel: 'Allow',
        onPrimary: () => Navigator.pop(
          dialogContext,
          _requestLocation(context),
        ),
        secondaryLabel: 'Learn more',
        onSecondary: () {
          Navigator.pushNamed(dialogContext, PPages.privacyPolicyScreen);
        },
      ),
    );

    if (locationRequest == null) {
      _log('location skipped by user');
      return true;
    }

    final locationOk = await locationRequest;
    if (!locationOk && context.mounted) {
      _showRetrySnackBar(
        context,
        'Location was blocked. Open the lock icon in the address bar → '
        'Site settings → Location → Allow, then reopen the app.',
      );
      // Don't mark complete — allow re-prompt on next login / cold start.
      return false;
    }

    // Complete when location succeeded (notifications optional if unsupported
    // or already handled above). If notifications failed but location OK,
    // still complete so we don't nag forever — user got the critical grant.
    return true;
  }

  static void _showRetrySnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            // Clear one-shot so showIfNeeded runs again.
            unawaited(_clearCompletedAndRetry(context));
          },
        ),
      ),
    );
  }

  static Future<void> _clearCompletedAndRetry(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(stateKey);
    if (context.mounted) await showIfNeeded(context);
  }

  /// Starts `requestPermission` before the first await so mobile Chrome keeps
  /// the Continue tap's user activation.
  static Future<bool> _requestNotifications() {
    _log('requesting notification permission (within tap gesture)');
    final request = FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return _finishNotifications(request);
  }

  static Future<bool> _finishNotifications(
    Future<NotificationSettings> request,
  ) async {
    try {
      final settings = await request;
      _log('notification permission result: '
          '${settings.authorizationStatus}');
      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!granted) return false;

      final token = await FirebaseMessaging.instance.getToken(
        vapidKey: kIsWeb && AppConfig.fcmVapidKey.isNotEmpty
            ? AppConfig.fcmVapidKey
            : null,
      );
      _log('FCM token obtained: ${token != null && token.isNotEmpty}');
      if (token == null || token.isEmpty) return true;

      await FCMRepository().saveFCMToken(fcmToken: token);
      LoggerService.instance.info('Notification permission and FCM registered');
      return true;
    } catch (e, st) {
      _log('notification flow failed: $e');
      LoggerService.instance.warning(
        'Notification permission flow failed',
        e,
        st,
      );
      return false;
    }
  }

  /// On web, calls `getCurrentPosition` immediately (no prior checkPermission)
  /// so the browser prompt inherits the Continue tap.
  static Future<bool> _requestLocation(BuildContext context) async {
    final position = await _getPosition(context);
    return position != null || (kIsWeb && _lastLocationWasSoftFail);
  }

  static bool _lastLocationWasSoftFail = false;

  /// Shared GPS acquire used by post-login Allow and signup Allow.
  static Future<Position?> _getPosition(BuildContext context) async {
    _lastLocationWasSoftFail = false;
    try {
      if (!kIsWeb) {
        var permission = await Geolocator.checkPermission();
        _log('location permission before request: $permission');
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        _log('location permission after request: $permission');
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return null;
        }
      }

      // Prefer a cached fix on mobile — web does not support lastKnown.
      if (!kIsWeb) {
        try {
          final last = await Geolocator.getLastKnownPosition();
          if (last != null) {
            _log('location fix from lastKnown: ${last.latitude}, '
                '${last.longitude}');
            LoggedInUser.lat = last.latitude;
            LoggedInUser.long = last.longitude;
            if (context.mounted) {
              await context.read<LocationViewModel>().recheckLocation();
            }
            return last;
          }
        } catch (e) {
          _log('lastKnown unavailable: $e');
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: kIsWeb
            ? WebSettings(
                accuracy: LocationAccuracy.low,
                maximumAge: const Duration(hours: 1),
                timeLimit: const Duration(seconds: 20),
              )
            : const LocationSettings(
                accuracy: LocationAccuracy.medium,
                timeLimit: Duration(seconds: 30),
              ),
      );
      _log('location fix acquired: ${position.latitude}, '
          '${position.longitude}');
      LoggedInUser.lat = position.latitude;
      LoggedInUser.long = position.longitude;
      if (context.mounted) {
        await context.read<LocationViewModel>().recheckLocation();
      }
      LoggerService.instance.info('Location permission granted');
      return position;
    } catch (e, st) {
      if (_isSoftLocationFailure(e)) {
        _lastLocationWasSoftFail = true;
        // Web/desktop often has no GPS fix even after Allow — not a hard deny
        // for existing-user login; signup still needs coords.
        _log('location unavailable (non-fatal): $e');
        if (kIsWeb) {
          LoggerService.instance.info(
            'Location fix unavailable on web; continuing without coords',
          );
        } else {
          LoggerService.instance.info('Location fix unavailable');
        }
        return null;
      }
      _log('location flow failed: $e');
      LoggerService.instance.warning('Location permission flow failed', e, st);
      return null;
    }
  }

  /// GPS timeout / sensor unavailable — not the same as permission denied.
  static bool _isSoftLocationFailure(Object e) {
    final s = e.toString().toLowerCase();
    return s.contains('position update is unavailable') ||
        s.contains('positionupdateexception') ||
        s.contains('timeout') ||
        s.contains('timed out') ||
        s.contains('location services are disabled');
  }
}

/// Tinder-style white permission modal (icon + title + Allow + secondary link).
class _PermissionPromptDialog extends StatelessWidget {
  const _PermissionPromptDialog({
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 12,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: const Color(0xFFD0D0D0), width: 1.5),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 32, color: const Color(0xFF4A4A4A)),
              ),
              const SizedBox(height: 28),
              Text(
                title,
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                body,
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF505050),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: onPrimary,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: Text(
                    primaryLabel,
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: onSecondary,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  secondaryLabel,
                  style: getTextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
