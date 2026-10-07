import 'package:everqpidapp/Features/onboarding/model/sign_up_model.dart';

class LoginRequest {
  final String countryCode;
  final String mobileNumber;

  LoginRequest({required this.countryCode, required this.mobileNumber});

  Map<String, dynamic> toJson() {
    return {'countryCode': countryCode, 'mobileNumber': mobileNumber};
  }
}

class LoginResponse {
  final bool status;
  final int statusCode;
  final String message;
  final SignupData? data; // 🔥 reuse SignupData

  LoginResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? SignupData.fromJson(json['data']) : null,
    );
  }
}
