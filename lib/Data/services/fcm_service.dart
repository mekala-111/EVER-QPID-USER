import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCM {
  /// 🔒 Singleton (VERY IMPORTANT)
  static final FCM _instance = FCM._internal();
  factory FCM() => _instance;
  FCM._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Callback for token refresh
  Function(String token)? onTokenRefresh;

  /// Passive startup setup. Does not request permission or obtain a token.
  Future<void> initFCM() async {
    // flutter_local_notifications has no web implementation.
    if (!kIsWeb) {
      await _initLocalNotifications();
    }

    _listenTokenRefresh();
    _listenForegroundMessages();
    _listenNotificationTap();
    _listenInitialMessage(); // ✅ Handle app launch from terminated state

    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    }
  }

  void _listenInitialMessage() {
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        log('🚀 App launched from terminated state via notification');
        _handleNotificationTap(message);
      }
    });
  }

  void _listenTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      log('🔄 FCM token refreshed');
      onTokenRefresh?.call(newToken);
    });
  }

  /// Returns an FCM token when available. Never blocks login for long —
  /// on web (especially mobile Chrome) `getToken()` can hang without VAPID
  /// or notification permission. Callers should treat `null` as empty header.
  Future<String?> getFCMToken() async {
    try {
      if (kIsWeb) {
        const vapidKey = String.fromEnvironment('FCM_VAPID_KEY');
        if (vapidKey.isEmpty) {
          log('⚠️ Web FCM: no VAPID key — skipping getToken (login continues)');
          return null;
        }
        return await _firebaseMessaging
            .getToken(vapidKey: vapidKey)
            .timeout(const Duration(seconds: 5));
      }
      return await _firebaseMessaging
          .getToken()
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      log('⚠️ getFCMToken failed (non-blocking): $e');
      return null;
    }
  }

  Future<void> deleteToken() async {
    await _firebaseMessaging.deleteToken();
    log('🗑️ FCM token deleted');
  }

  // ================== LOCAL NOTIFICATIONS ==================

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        log('🔘 Local notification tapped: ${response.payload}');
      },
    );

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Important notifications',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Important notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  // ================== MESSAGE HANDLING ==================

  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((message) {
      log('📥 Foreground notification: ${message.notification?.title}');
      if (!kIsWeb) {
        _showLocalNotification(message);
      }
    });
  }

  void _listenNotificationTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log('📲 Notification tapped (background)');
      _handleNotificationTap(message);
    });
  }

  void _handleNotificationTap(RemoteMessage message) {
    log('➡️ Notification data: ${message.data}');

    // Detailed logging of notification components
    log('📋 Notification Details:');
    log('  - Title: ${message.notification?.title ?? 'No title'}');
    log('  - Body: ${message.notification?.body ?? 'No body'}');
    log('  - Data payload: ${message.data}');
    log('  - Message ID: ${message.messageId}');
    log('  - From: ${message.from}');
    log('  - Sent time: ${message.sentTime}');
    log('  - TTL: ${message.ttl}');

    // Log each data field individually for better debugging
    if (message.data.isNotEmpty) {
      log('📦 Data fields:');
      message.data.forEach((key, value) {
        log('  - $key: $value');
      });
    } else {
      log('📦 No data fields present');
    }

    // Navigation handled elsewhere using navigatorKey if needed
  }

  // ================== TOPICS ==================

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    log('✅ Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    log('❌ Unsubscribed from topic: $topic');
  }
}

/// ⚠️ Must be TOP-LEVEL (Do not move inside class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('🌙 Background notification: ${message.notification?.title}');
  log('📦 Data: ${message.data}');
}
