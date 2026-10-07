class MatchProfile {
  final String name;
  final int age;
  final String education;
  final String imageUrl;
  final bool isVerified;
  final bool isBlurred;

  MatchProfile({
    required this.name,
    required this.age,
    required this.education,
    required this.imageUrl,
    this.isVerified = false,
    this.isBlurred = false,
  });

  factory MatchProfile.fromJson(Map<String, dynamic> json) {
    return MatchProfile(
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      education: json['education'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isVerified: json['isVerified'] ?? false,
      isBlurred: json['isBlurred'] ?? false,
    );
  }
}
