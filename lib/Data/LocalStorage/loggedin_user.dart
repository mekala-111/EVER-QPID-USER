import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoggedInUser {
  static String? id;
  static String? name;
  static String? email;
  static String? countryCode;
  static String? mobileNumber;
  static String? profilePic;
  static String? coverImage;
  static String? accessToken;
  static String? refreshToken;
  static double? lat;
  static double? long;
  static String? userName;
  static String? gender;
  static int? age;
  static String? bio;
  static int? coinBalance;
  static int? earnedBalance;
  static bool? isOnline;
  static bool? isBusy;
  static bool? acceptCalls;
  static bool? isVerified;

  static const _accessKey = 'accessToken';
  static const _refreshKey = 'refreshToken';

  /// Keychain / EncryptedSharedPreferences on mobile; encrypted localStorage on web.
  static FlutterSecureStorage get _secure => const FlutterSecureStorage();

  static String? _emptyToNull(String? v) =>
      (v == null || v.isEmpty) ? null : v;

  LoggedInUser.login(Map<String, dynamic> json) {
    id = json['user']['_id'];
    userName = json['user']['userName'];
    name = json['user']['name'];
    email = json['user']['email'] ?? '';
    countryCode = json['user']['countryCode'];
    mobileNumber = json['user']['mobileNumber'];
    profilePic = json['user']['profileImageUrl'];
    gender = json['user']['gender'];
    age = json['user']['age'];
    bio = json['user']['bio'];
    coinBalance = json['user']['coinBalance'];
    earnedBalance = json['user']['earnedBalance'];
    isOnline = json['user']['isOnline'];
    isBusy = json['user']['isBusy'];
    acceptCalls = json['user']['acceptCalls'];
    isVerified = json['user']['isVerified'];

    accessToken = json['tokens']['access']['token'];
    refreshToken = json['tokens']['refresh']['token'];

    if (json['user']['location'] != null &&
        json['user']['location']["coordinates"] != null) {
      lat = double.tryParse(
          json['user']['location']["coordinates"][0].toString());
      long = double.tryParse(
          json['user']['location']["coordinates"][1].toString());
    }

    storeUserLocally();
  }

  LoggedInUser.profile(Map<String, dynamic> json) {
    id = json['_id'];
    userName = json['userName'];
    name = json['name'];
    email = json['email'] ?? '';
    countryCode = json['countryCode'];
    mobileNumber = json['mobileNumber'];
    profilePic = json['profileImageUrl'];
    gender = json['gender'];
    age = json['age'];
    bio = json['bio'];
    coinBalance = json['coinBalance'];
    earnedBalance = json['earnedBalance'];
    isOnline = json['isOnline'];
    isBusy = json['isBusy'];
    acceptCalls = json['acceptCalls'];
    isVerified = json['isVerified'];

    if (json['location'] != null && json['location']["coordinates"] != null) {
      lat = double.tryParse(json['location']["coordinates"][0].toString());
      long = double.tryParse(json['location']["coordinates"][1].toString());
    }

    storeUserLocally();
  }

  LoggedInUser.tokenUpdate(Map<String, dynamic> json) {
    accessToken = json['access']?['token'] ?? accessToken;
    final newRefresh = json['refresh']?['token'];
    if (newRefresh != null) refreshToken = newRefresh;
    storeUserLocally();
  }

  static Future<void> storeUserLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', id ?? '');
    await prefs.setString('userName', userName ?? '');
    await prefs.setString('email', email ?? '');
    await prefs.setString('name', name ?? '');
    await prefs.setString('countryCode', countryCode ?? '');
    await prefs.setString('mobileNumber', mobileNumber ?? '');
    await prefs.setString('profilePic', profilePic ?? '');
    await prefs.setString('gender', gender ?? '');
    await prefs.setString('bio', bio ?? '');
    await prefs.setInt('age', age ?? 0);
    await prefs.setInt('coinBalance', coinBalance ?? 0);
    await prefs.setInt('earnedBalance', earnedBalance ?? 0);
    await prefs.setBool('isOnline', isOnline ?? false);
    await prefs.setBool('isBusy', isBusy ?? false);
    await prefs.setBool('acceptCalls', acceptCalls ?? true);
    await prefs.setBool('isVerified', isVerified ?? false);

    if (lat != null) await prefs.setDouble('lat', lat!);
    if (long != null) await prefs.setDouble('long', long!);

    // Never persist JWTs in SharedPreferences / plaintext web localStorage.
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
    await _persistTokens();
  }

  /// Mobile: Keystore/Keychain. Web: flutter_secure_storage (encrypted localStorage).
  /// ponytail: prefer httpOnly Secure cookies when the API can set them.
  static Future<void> _persistTokens() async {
    await _secure.write(key: _accessKey, value: accessToken ?? '');
    await _secure.write(key: _refreshKey, value: refreshToken ?? '');
  }

  static Future<void> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    id = _emptyToNull(prefs.getString('id'));
    userName = _emptyToNull(prefs.getString('userName'));
    email = prefs.getString('email');
    name = _emptyToNull(prefs.getString('name'));
    countryCode = _emptyToNull(prefs.getString('countryCode'));
    mobileNumber = _emptyToNull(prefs.getString('mobileNumber'));
    profilePic = _emptyToNull(prefs.getString('profilePic'));
    gender = _emptyToNull(prefs.getString('gender'));
    bio = prefs.getString('bio');
    age = prefs.getInt('age');
    coinBalance = prefs.getInt('coinBalance');
    earnedBalance = prefs.getInt('earnedBalance');
    isOnline = prefs.getBool('isOnline');
    isBusy = prefs.getBool('isBusy');
    acceptCalls = prefs.getBool('acceptCalls');
    isVerified = prefs.getBool('isVerified');

    lat = prefs.getDouble('lat');
    long = prefs.getDouble('long');

    accessToken = _emptyToNull(await _secure.read(key: _accessKey));
    refreshToken = _emptyToNull(await _secure.read(key: _refreshKey));

    // One-time migration from legacy SharedPreferences JWTs.
    final legacyAccess = prefs.getString(_accessKey);
    final legacyRefresh = prefs.getString(_refreshKey);
    if (accessToken == null &&
        legacyAccess != null &&
        legacyAccess.isNotEmpty) {
      accessToken = legacyAccess;
      refreshToken = _emptyToNull(legacyRefresh);
      await _persistTokens();
    }
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
  }

  static Future<void> clearUserData() async {
    try {
      refreshToken = null;
      accessToken = null;
      id = null;

      await _secure.delete(key: _accessKey);
      await _secure.delete(key: _refreshKey);

      final prefs = await SharedPreferences.getInstance();
      final permissionPromptCompleted =
          prefs.getBool('permission_prompt_completed');
      final result = await prefs.clear();
      if (result == false) throw 'Unable to logout';
      if (permissionPromptCompleted == true) {
        await prefs.setBool('permission_prompt_completed', true);
      }
    } catch (e) {
      rethrow;
    }
  }
}
