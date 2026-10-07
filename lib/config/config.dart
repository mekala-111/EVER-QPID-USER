import 'package:everqpidapp/config/development.dart';
import 'package:everqpidapp/config/environment.dart';
import 'package:everqpidapp/config/production.dart';
import 'package:everqpidapp/config/staging.dart';

/// Runtime / compile-time app configuration.
///
/// Override any value at build/run time:
/// ```
/// flutter run --dart-define=ENV=development --dart-define=API_URL=https://dev.api.com
/// ```
///
/// When a `--dart-define` is omitted, the default for the selected [environment]
/// is used (see [DevelopmentConfig], [StagingConfig], [ProductionConfig]).
class AppConfig {
  AppConfig._();

  static const String _envDefine =
      String.fromEnvironment('ENV', defaultValue: 'production');

  static const String _apiUrl = String.fromEnvironment('API_URL');
  static const String _socketUrl = String.fromEnvironment('SOCKET_URL');
  static const String _imageBaseUrl = String.fromEnvironment('IMAGE_BASE_URL');
  static const String _imageUrl = String.fromEnvironment('IMAGE_URL');
  static const String _privacyPolicyUrl =
      String.fromEnvironment('PRIVACY_POLICY_URL');
  static const String _termsUrl = String.fromEnvironment('TERMS_URL');
  static const String _placeholderImageUrl =
      String.fromEnvironment('PLACEHOLDER_IMAGE_URL');
  static const String _contactEmail = String.fromEnvironment('CONTACT_EMAIL');
  static const String _defaultCountry =
      String.fromEnvironment('DEFAULT_COUNTRY');
  static const String _razorpayKey = String.fromEnvironment('RAZORPAY_KEY');
  static const String _googleMapKey = String.fromEnvironment('GOOGLE_MAP_KEY');
  static const String _googleWebClientId =
      String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static const String _facebookAppId =
      String.fromEnvironment('FACEBOOK_APP_ID');
  static const String _appName = String.fromEnvironment('APP_NAME');

  /// Web Push certificate public key (Firebase Console → Cloud Messaging).
  static const String fcmVapidKey = String.fromEnvironment('FCM_VAPID_KEY');

  static AppEnvironment get environment => AppEnvironmentX.fromName(_envDefine);

  static bool get isProduction => environment == AppEnvironment.production;

  static bool get isStaging => environment == AppEnvironment.staging;

  static bool get isDevelopment => environment == AppEnvironment.development;

  static String get appName => _pick(_appName, _d.appName);

  static String get apiUrl => _pick(_apiUrl, _d.apiUrl);

  /// Socket.IO host. Falls back to [apiUrl] when SOCKET_URL is unset.
  static String get socketUrl {
    final fromDefine = _pick(_socketUrl, _d.socketUrl);
    return fromDefine.isNotEmpty ? fromDefine : apiUrl;
  }

  /// Prefer IMAGE_BASE_URL; IMAGE_URL is accepted as an alias.
  static String get imageBaseUrl {
    if (_imageBaseUrl.isNotEmpty) return _imageBaseUrl;
    if (_imageUrl.isNotEmpty) return _imageUrl;
    return _d.imageBaseUrl;
  }

  static String get privacyPolicyUrl =>
      _pick(_privacyPolicyUrl, _d.privacyPolicyUrl);

  static String get termsUrl => _pick(_termsUrl, _d.termsUrl);

  static String get placeholderImageUrl =>
      _pick(_placeholderImageUrl, _d.placeholderImageUrl);

  static String get contactEmail => _pick(_contactEmail, _d.contactEmail);

  static String get defaultCountry => _pick(_defaultCountry, _d.defaultCountry);

  static String get razorpayKey => _pick(_razorpayKey, _d.razorpayKey);

  static String get googleMapKey => _pick(_googleMapKey, _d.googleMapKey);

  static String get googleWebClientId =>
      _pick(_googleWebClientId, _d.googleWebClientId);

  static String get facebookAppId => _pick(_facebookAppId, _d.facebookAppId);

  /// Host-only form of [apiUrl] (no scheme) for legacy HTTP clients.
  static String get httpHost {
    final uri = Uri.tryParse(apiUrl);
    if (uri == null || uri.host.isEmpty) return apiUrl;
    return uri.hasPort ? '${uri.host}:${uri.port}' : uri.host;
  }

  static String get scheme {
    final uri = Uri.tryParse(apiUrl);
    if (uri != null && uri.scheme.isNotEmpty) return uri.scheme;
    return apiUrl.startsWith('http://') ? 'http' : 'https';
  }

  static String _pick(String fromDefine, String fallback) =>
      fromDefine.isNotEmpty ? fromDefine : fallback;

  static _EnvDefaults get _d {
    switch (environment) {
      case AppEnvironment.development:
        return const _EnvDefaults(
          appName: DevelopmentConfig.appName,
          apiUrl: DevelopmentConfig.apiUrl,
          socketUrl: DevelopmentConfig.socketUrl,
          imageBaseUrl: DevelopmentConfig.imageBaseUrl,
          privacyPolicyUrl: DevelopmentConfig.privacyPolicyUrl,
          termsUrl: DevelopmentConfig.termsUrl,
          placeholderImageUrl: DevelopmentConfig.placeholderImageUrl,
          contactEmail: DevelopmentConfig.contactEmail,
          defaultCountry: DevelopmentConfig.defaultCountry,
          razorpayKey: DevelopmentConfig.razorpayKey,
          googleMapKey: DevelopmentConfig.googleMapKey,
          googleWebClientId: DevelopmentConfig.googleWebClientId,
          facebookAppId: DevelopmentConfig.facebookAppId,
        );
      case AppEnvironment.staging:
        return const _EnvDefaults(
          appName: StagingConfig.appName,
          apiUrl: StagingConfig.apiUrl,
          socketUrl: StagingConfig.socketUrl,
          imageBaseUrl: StagingConfig.imageBaseUrl,
          privacyPolicyUrl: StagingConfig.privacyPolicyUrl,
          termsUrl: StagingConfig.termsUrl,
          placeholderImageUrl: StagingConfig.placeholderImageUrl,
          contactEmail: StagingConfig.contactEmail,
          defaultCountry: StagingConfig.defaultCountry,
          razorpayKey: StagingConfig.razorpayKey,
          googleMapKey: StagingConfig.googleMapKey,
          googleWebClientId: StagingConfig.googleWebClientId,
          facebookAppId: StagingConfig.facebookAppId,
        );
      case AppEnvironment.production:
        return const _EnvDefaults(
          appName: ProductionConfig.appName,
          apiUrl: ProductionConfig.apiUrl,
          socketUrl: ProductionConfig.socketUrl,
          imageBaseUrl: ProductionConfig.imageBaseUrl,
          privacyPolicyUrl: ProductionConfig.privacyPolicyUrl,
          termsUrl: ProductionConfig.termsUrl,
          placeholderImageUrl: ProductionConfig.placeholderImageUrl,
          contactEmail: ProductionConfig.contactEmail,
          defaultCountry: ProductionConfig.defaultCountry,
          razorpayKey: ProductionConfig.razorpayKey,
          googleMapKey: ProductionConfig.googleMapKey,
          googleWebClientId: ProductionConfig.googleWebClientId,
          facebookAppId: ProductionConfig.facebookAppId,
        );
    }
  }
}

class _EnvDefaults {
  const _EnvDefaults({
    required this.appName,
    required this.apiUrl,
    required this.socketUrl,
    required this.imageBaseUrl,
    required this.privacyPolicyUrl,
    required this.termsUrl,
    required this.placeholderImageUrl,
    required this.contactEmail,
    required this.defaultCountry,
    required this.razorpayKey,
    required this.googleMapKey,
    required this.googleWebClientId,
    required this.facebookAppId,
  });

  final String appName;
  final String apiUrl;
  final String socketUrl;
  final String imageBaseUrl;
  final String privacyPolicyUrl;
  final String termsUrl;
  final String placeholderImageUrl;
  final String contactEmail;
  final String defaultCountry;
  final String razorpayKey;
  final String googleMapKey;
  final String googleWebClientId;
  final String facebookAppId;
}
