class ClanPhoto {
  final String id;
  final String? profileImageUrl;

  ClanPhoto({
    required this.id,
    this.profileImageUrl,
  });

  factory ClanPhoto.fromJson(Map<String, dynamic> json) {
    return ClanPhoto(
      id: json['_id'] ?? '',
      profileImageUrl: json['profileImageUrl'],
    );
  }
}

class ClanPhotosResponse {
  final bool status;
  final int statusCode;
  final String message;
  final List<ClanPhoto> data;

  ClanPhotosResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory ClanPhotosResponse.fromJson(Map<String, dynamic> json) {
    return ClanPhotosResponse(
      status: json['status'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((item) => ClanPhoto.fromJson(item))
              .toList() ??
          [],
    );
  }
}
