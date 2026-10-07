class PassedProfile {
  final String name;
  final int age;
  final String education;
  final String imageUrl;
  final bool isVerified;

  PassedProfile({
    required this.name,
    required this.age,
    required this.education,
    required this.imageUrl,
    this.isVerified = false,
  });

  factory PassedProfile.fromJson(Map<String, dynamic> json) {
    return PassedProfile(
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      education: json['education'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }
}
