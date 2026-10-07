class SuperLikeResponse {
  final bool status;
  final int statusCode;
  final String message;
  final dynamic data;

  SuperLikeResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory SuperLikeResponse.fromJson(Map<String, dynamic> json) {
    return SuperLikeResponse(
      status: json['status'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }

  bool get isSuccess => status && statusCode == 200;
  bool get needsSubscription =>
      statusCode == 400 && message.toLowerCase().contains('subscribe');
}
