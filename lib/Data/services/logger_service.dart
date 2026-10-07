import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Single app logging API.
///
/// Debug/profile: debug / info / warning print to console.
/// Release: errors (+ optional warnings) only; fatal/non-fatal go to Crashlytics
/// on mobile (Crashlytics is unsupported on web).
///
/// Never pass JWTs, refresh tokens, OTPs, passwords, or payment signatures.
class LoggerService {
  LoggerService._();
  static final LoggerService instance = LoggerService._();

  static const _sensitiveHints = [
    'authorization',
    'bearer ',
    'accessToken',
    'refreshToken',
    'refresh_token',
    'access_token',
    'otp',
    'password',
    'razorpay_signature',
    'x-razorpay-signature',
    'fcm-token',
    'fcmtoken',
  ];

  bool get _crashlyticsReady => !kIsWeb;

  String _scrub(String message) {
    var out = message;
    for (final hint in _sensitiveHints) {
      if (out.toLowerCase().contains(hint.toLowerCase())) {
        return '[redacted: possible secret in log message]';
      }
    }
    return out;
  }

  void debug(String message) {
    if (kReleaseMode) return;
    debugPrint('[D] ${_scrub(message)}');
  }

  void info(String message) {
    if (kReleaseMode) return;
    debugPrint('[I] ${_scrub(message)}');
  }

  void warning(String message, [Object? error, StackTrace? stack]) {
    final msg = _scrub(message);
    if (!kReleaseMode) {
      debugPrint('[W] $msg${error != null ? ' (${error.runtimeType})' : ''}');
    }
    if (_crashlyticsReady && kReleaseMode) {
      try {
        FirebaseCrashlytics.instance.recordError(
          error ?? Exception(msg),
          stack,
          reason: msg,
          fatal: false,
        );
      } catch (_) {}
    }
  }

  void error(
    String message, [
    Object? error,
    StackTrace? stack,
    bool fatal = false,
  ]) {
    final msg = _scrub(message);
    debugPrint('[E] $msg${error != null ? ' (${error.runtimeType})' : ''}');

    if (!_crashlyticsReady) return;
    try {
      FirebaseCrashlytics.instance.recordError(
        error ?? Exception(msg),
        stack ?? StackTrace.current,
        reason: msg,
        fatal: fatal,
      );
    } catch (_) {
      // Firebase may be uninitialized in tests / early startup.
    }
  }

  /// Non-fatal breadcrumb / custom key for Crashlytics dashboards.
  Future<void> setCustomKey(String key, Object value) async {
    if (!_crashlyticsReady) return;
    try {
      await FirebaseCrashlytics.instance.setCustomKey(key, value);
    } catch (_) {}
  }

  Future<void> setUserId(String? id) async {
    if (!_crashlyticsReady) return;
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(id ?? '');
    } catch (_) {}
  }
}
