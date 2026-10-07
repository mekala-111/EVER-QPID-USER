import 'package:everqpidapp/Settings/utils/app_navigator.dart';
import 'package:everqpidapp/Settings/utils/p_pages.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:everqpidapp/Settings/helper/app_logger.dart';

class NotificationNavigator {
  static void handle(RemoteMessage? message) {
    if (message == null) {
      AppLogger.d('🔕 Notification: message was null');
      return;
    }

    // ─── Full message log ────────────────────────────────────
    AppLogger.d('═══════════ 🔔 NOTIFICATION TAP ═══════════');
    AppLogger.d('📌 Message ID   : ${message.messageId}');
    AppLogger.d('📌 Sent Time    : ${message.sentTime}');
    AppLogger.d('📌 From         : ${message.from}');
    if (message.notification != null) {
      AppLogger.d('── Notification ─────────────────────────');
      AppLogger.d('   Title       : ${message.notification!.title}');
      AppLogger.d('   Body        : ${message.notification!.body}');
    }
    AppLogger.d('── Data Payload ─────────────────────────');
    message.data.isEmpty
        ? AppLogger.d('   (empty)')
        : message.data.forEach((k, v) => AppLogger.d('   $k : $v'));
    AppLogger.d('═════════════════════════════════════════');
    // ─────────────────────────────────────────────────────────

    final data = message.data;
    final type = data['type'];
    final openURL = data['openURL'];
    final navigateTo = data['navigateTo'];
    final senderId = data['senderId'];
    final userId = data['userId'];

    AppLogger.d('🎯 Navigation Info:');
    AppLogger.d('  - Type: $type');
    AppLogger.d('  - OpenURL: $openURL');
    AppLogger.d('  - NavigateTo: $navigateTo');
    AppLogger.d('  - SenderId: $senderId');

    // Handle direct profile navigation
    if (navigateTo == 'otherProfile' && senderId != null) {
      AppLogger.d('👤 Will navigate to Profile screen for user: $senderId');
      // Navigate to MainScreen first, then to profile
      AppNavigator.state?.pushNamedAndRemoveUntil(
        PPages.mainScreen,
        (route) =>
            route.isFirst, // Only remove routes above the first MainScreen
        arguments: {
          'tabIndex': 0, // Home tab first
          'navigationReason': 'profile_navigation',
          'notificationData': data,
          'navigateToProfile': true,
          'profileUserId': senderId,
        },
      );
      return;
    }

    // Handle new_match with userId
    if (type == 'new_match' && userId != null) {
      AppLogger.d('🎉 Will navigate to Profile screen for new match: $userId');
      // Navigate to MainScreen first, then to profile
      AppNavigator.state?.pushNamedAndRemoveUntil(
        PPages.mainScreen,
        (route) =>
            route.isFirst, // Only remove routes above the first MainScreen
        arguments: {
          'tabIndex': 0, // Home tab first
          'navigationReason': 'new_match_profile',
          'notificationData': data,
          'navigateToProfile': true,
          'profileUserId': userId,
        },
      );
      return;
    }

    // Handle message/chat notifications (no userId needed)
    if (type == 'message' || type == 'chat' || openURL == 'message') {
      AppLogger.d('💬 Will navigate to Messages tab (index 3)');
      AppNavigator.state?.pushNamedAndRemoveUntil(
        PPages.mainScreen,
        (route) =>
            route.isFirst, // Only remove routes above the first MainScreen
        arguments: {
          'tabIndex': 3, // Messages tab
          'navigationReason': 'message_notification',
          'notificationData': data,
        },
      );
      return;
    }

    // Determine target tab for fallback cases
    switch (type) {
      case 'new_match':
        AppLogger.d('🎉 Will navigate to Matches tab (index 1)');
        AppNavigator.state?.pushNamedAndRemoveUntil(
          PPages.mainScreen,
          (route) =>
              route.isFirst, // Only remove routes above the first MainScreen
          arguments: {
            'tabIndex': 1, // Matches tab
            'navigationReason': 'new_match_tab',
            'notificationData': data,
          },
        );
        return;
      case 'like':
        AppLogger.d('❤️ Will navigate to Matches tab (index 1) for like');
        AppNavigator.state?.pushNamedAndRemoveUntil(
          PPages.mainScreen,
          (route) =>
              route.isFirst, // Only remove routes above the first MainScreen
          arguments: {
            'tabIndex': 1, // Matches tab
            'navigationReason': 'like_notification',
            'notificationData': data,
          },
        );
        return;
      default:
        if (openURL == 'message') {
          AppLogger.d(
              '💬 Will navigate to Messages tab (index 3) based on openURL');
          AppNavigator.state?.pushNamedAndRemoveUntil(
            PPages.mainScreen,
            (route) =>
                route.isFirst, // Only remove routes above the first MainScreen
            arguments: {
              'tabIndex': 3, // Messages tab
              'navigationReason': 'openURL_message',
              'notificationData': data,
            },
          );
          return;
        } else {
          AppLogger.d('🏠 Will navigate to Home tab (index 0) - unknown type');
          AppNavigator.state?.pushNamedAndRemoveUntil(
            PPages.mainScreen,
            (route) =>
                route.isFirst, // Only remove routes above the first MainScreen
            arguments: {
              'tabIndex': 0, // Home tab
              'navigationReason': 'unknown_type',
              'notificationData': data,
            },
          );
          return;
        }
    }
  }
}
