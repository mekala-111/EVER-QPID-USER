class SupportTicket {
  final String id;
  final String description;
  final String categoryId;
  final List<String> attachments;

  SupportTicket({
    required this.id,
    required this.description,
    required this.categoryId,
    required this.attachments,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['_id'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['category'] ?? '',
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }
}
