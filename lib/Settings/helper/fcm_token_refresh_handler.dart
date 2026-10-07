import 'package:everqpidapp/Features/FCM/viewmodel/fcm_view_model.dart';
import 'package:everqpidapp/Data/services/logger_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FCMTokenRefreshService {
  static bool _started = false;

  /// Idempotent — safe to call from MainScreen every mount.
  static void initialize(BuildContext context) {
    if (_started) return;
    _started = true;

    if (kIsWeb) {
      // Web FCM token refresh is optional; avoid MissingPlugin / channel noise.
      return;
    }

    try {
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        if (!context.mounted) return;
        try {
          context.read<FCMViewModel>().updateFCMToken(newToken);
        } catch (e, st) {
          LoggerService.instance.warning('FCM token refresh update failed', e, st);
        }
      });
    } catch (e, st) {
      LoggerService.instance.warning('FCM token refresh listener skipped', e, st);
    }
  }
}
