import 'package:everqpidapp/config/config.dart';

/// Legacy API route + URL facade.
///
/// Hosts and environment flags come from [AppConfig] so existing repositories
/// that import [AppUrl] keep working without changes.
class AppUrl {
  /// Scheme derived from [AppConfig.apiUrl] (`https` or `http`).
  static String get scurity => AppConfig.scheme;

  static bool get isProduction => AppConfig.isProduction;

  /// Dio base URL — delegates to [AppConfig.apiUrl].
  static String get baseurl => AppConfig.apiUrl;

  /// Host without scheme — for legacy HTTP clients.
  static String get httpBaseUrl => AppConfig.httpHost;

  /// Socket.IO URL — delegates to [AppConfig.socketUrl].
  static String get socketUrl => AppConfig.socketUrl;

  // API Routes
  static const String getAllProfiles = '/api/v1/profile/users/get-all-profiles';

  static const String auth = 'api/v1/auth/user-auth';
  static const String refreshToken = 'api/v1/auth/refresh-tokens';
  static const String checkUserExist = 'api/v1/auth/check-user-exists';
  static const String userLogout = 'api/v1/auth/log-out';
  static const String getProfile = 'api/v1/profile/get-profile';
  static const String getReceivedLikes = '/api/v1/matching/get-received-likes';
  static const String getMyMatches = '/api/v1/matching/get-my-matches';
  static const String getMyLikedProfiles =
      "/api/v1/matching/get-my-liked-profiles";
}
