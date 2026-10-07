abstract class BaseProfile {
  String get id;
  String get fullName;
  int get age;
  String? get profileImageUrl;
  bool get isVerified;
  String? get locationString;

  String? get religion;
  String? get alcoholConsumption;
  String? get smokingHabit;
  String? get workoutFrequency;
  String? get zodiacSign;
  int? get height;
  String? get relationshipStatus;

  List<String>? get interests;
  List<String>? get otherLanguages;
  List<String>? get profilePhotos;

  String? get education;
  String? get aboutMe;
  String? get currentProfession;
}
