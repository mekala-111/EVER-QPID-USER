import 'package:firebase_analytics/firebase_analytics.dart';

import 'logger_service.dart';

/// Centralized Firebase Analytics events for production funnels.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  /// Lazy — Firebase may be absent in unit tests / early startup.
  FirebaseAnalytics? get _fa {
    try {
      return FirebaseAnalytics.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);

  Future<void> _log(String name, [Map<String, Object>? params]) async {
    try {
      final fa = _fa;
      if (fa == null) return;
      await fa.logEvent(name: name, parameters: params);
      LoggerService.instance.debug('analytics:$name $params');
    } catch (e, st) {
      LoggerService.instance.warning('analytics failed: $name', e, st);
    }
  }

  Future<void> logLogin({String method = 'phone'}) =>
      _log('login', {'method': method});

  Future<void> logSignup({String method = 'phone'}) =>
      _log('sign_up', {'method': method});

  Future<void> logOtpVerified({String method = 'phone'}) =>
      _log('otp_verified', {'method': method});

  Future<void> logProfileCompleted() => _log('profile_completed');

  Future<void> logMatchCreated() => _log('match_created');

  Future<void> logChatOpened() => _log('chat_opened');

  Future<void> logMessageSent({String type = 'text'}) =>
      _log('message_sent', {'type': type});

  Future<void> logSubscriptionViewed({String source = 'screen'}) =>
      _log('subscription_viewed', {'source': source});

  Future<void> logSubscriptionPurchased({String? planId}) => _log(
        'subscription_purchased',
        {if (planId != null) 'plan_id': planId},
      );

  Future<void> logLogout() => _log('logout');

  Future<void> logDeleteAccount() => _log('delete_account');

  Future<void> setUserId(String? id) async {
    try {
      final fa = _fa;
      if (fa == null) return;
      await fa.setUserId(id: id);
    } catch (e, st) {
      LoggerService.instance.warning('analytics setUserId failed', e, st);
    }
  }
}
