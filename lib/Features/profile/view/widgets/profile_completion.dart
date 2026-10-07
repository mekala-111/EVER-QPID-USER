import 'package:everqpidapp/Features/profile/model/user_profile_model.dart';

/// Profile strength from real fields only — no hardcoded scores.
abstract final class ProfileCompletion {
  static const _weights = <String, int>{
    'image': 1,
    'name': 1,
    'bio': 1,
    'dob': 1,
    'gender': 1,
    'interests': 1,
    'location': 1,
    'education': 1,
    'occupation': 1,
    'photos': 1,
  };

  static int percent(UserProfileModel p) {
    var filled = 0;
    if ((p.profileImageUrl ?? '').isNotEmpty) filled++;
    if (p.fullName.trim().isNotEmpty) filled++;
    if ((p.aboutMe ?? '').trim().isNotEmpty) filled++;
    if ((p.dateOfBirth ?? '').isNotEmpty) filled++;
    if ((p.gender ?? '').isNotEmpty) filled++;
    if (p.interests != null && p.interests!.isNotEmpty) filled++;
    if ((p.locationString ?? '').isNotEmpty || p.location != null) filled++;
    if ((p.education ?? '').isNotEmpty || (p.collegeName ?? '').isNotEmpty) {
      filled++;
    }
    if ((p.currentProfession ?? '').isNotEmpty) filled++;
    if (p.profilePhotos.isNotEmpty) filled++;
    return ((filled / _weights.length) * 100).round();
  }

  static int? ageFromDob(String? dob) {
    if (dob == null || dob.isEmpty) return null;
    final parsed = DateTime.tryParse(dob);
    if (parsed == null) return null;
    final now = DateTime.now();
    var age = now.year - parsed.year;
    if (now.month < parsed.month ||
        (now.month == parsed.month && now.day < parsed.day)) {
      age--;
    }
    return age > 0 ? age : null;
  }

  /// Same weights as [percent], from live edit draft fields.
  static int percentFromDraft({
    required bool hasPhotos,
    required String? fullName,
    required String? aboutMe,
    required String? dateOfBirth,
    required String? gender,
    required List<String> interests,
    required String? locationString,
    required String? education,
    required String? collegeName,
    required String? currentProfession,
  }) {
    var filled = 0;
    if (hasPhotos) filled += 2; // profile image + photos
    if ((fullName ?? '').trim().isNotEmpty) filled++;
    if ((aboutMe ?? '').trim().isNotEmpty) filled++;
    if ((dateOfBirth ?? '').isNotEmpty) filled++;
    if ((gender ?? '').isNotEmpty) filled++;
    if (interests.isNotEmpty) filled++;
    if ((locationString ?? '').isNotEmpty) filled++;
    if ((education ?? '').isNotEmpty || (collegeName ?? '').isNotEmpty) {
      filled++;
    }
    if ((currentProfession ?? '').isNotEmpty) filled++;
    return ((filled / _weights.length) * 100).round();
  }

  static List<String> tipsFromDraft({
    required int photoCount,
    required String? aboutMe,
    required List<String> interests,
    required String? currentProfession,
    required String? education,
  }) {
    final tips = <String>[];
    if ((aboutMe ?? '').trim().isEmpty) {
      tips.add('Add a bio to tell people more about yourself.');
    } else {
      tips.add('Great! You have added a bio.');
    }
    if (photoCount < 2) {
      tips.add('Add more photos to help your profile stand out.');
    }
    if (interests.isEmpty) {
      tips.add('Add interests to discover better matches.');
    }
    if ((currentProfession ?? '').isEmpty && (education ?? '').isEmpty) {
      tips.add('Add work or education to complete your profile.');
    }
    return tips;
  }
}
