/// Default values when `ENV=production` (or unset) and a given `--dart-define` is omitted.
class ProductionConfig {
  static const String appName = 'EverQpid';
  static const String apiUrl = 'https://server.everqpid.com';
  static const String socketUrl = 'https://server.everqpid.com';
  static const String imageBaseUrl = 'https://server.everqpid.com';
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
