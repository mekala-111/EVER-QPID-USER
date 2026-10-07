/// Default values when `ENV=development` and a given `--dart-define` is omitted.
///
/// LAN `http://` is allowed only for local/dev servers. Staging and production
/// builds refuse non-HTTPS base URLs (see NetworkApiServiceV2).
class DevelopmentConfig {
  static const String appName = 'EverQpid Dev';
  static const String apiUrl = 'http://15.206.227.36:8000';
  static const String socketUrl = 'http://15.206.227.36:8000';
  static const String imageBaseUrl = 'http://15.206.227.36:8000';
  static const String privacyPolicyUrl =
      'https://web.everqpid.com/privacy-policy';
  static const String termsUrl = 'https://web.everqpid.com/user-agreement';
  static const String placeholderImageUrl = 'https://via.placeholder.com/150';
  static const String contactEmail = 'support@everqpid.com';
  static const String defaultCountry = 'IN';
  static const String razorpayKey = '';
  static const String googleMapKey = '';
  static const String googleWebClientId =
      '514037743080-9nrfjn8cp3aegv8l3j5ln932vgvesm9t.apps.googleusercontent.com';
  static const String facebookAppId = '';
}
