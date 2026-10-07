class SupportCategory {
  final String id;
  final String name;

  SupportCategory({
    required this.id,
    required this.name,
  });

  factory SupportCategory.fromJson(Map<String, dynamic> json) {
    return SupportCategory(
      id: json['_id'] ?? '',
      name: json['categoryName'] ?? '',
    );
  }
}
