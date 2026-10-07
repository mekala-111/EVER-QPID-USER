import 'dart:typed_data';

abstract interface class BaseApiService {
  Future<dynamic> getGetApiResponse(
    String endPoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    String? token,
    String? appned,
  });

  Future<dynamic> getPostApiResponse(
    String endPoint, {
    String? domain,
    Object? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    String? token,
    String? appned,
  });

  Future<dynamic> putMethod(
    String url, {
    Object? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    String? token,
  });

  Future<dynamic> getPutApiResponse(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    String? token,
    String? appned,
  });

  Future<dynamic> getDeleteApiResponse(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    String? token,
    String? appned,
  });

  Future formData(
    String endpoints, {
    String? domain,
    List<String> fileFields = const [],
    List<String?> filePaths = const [],
    Map<String, dynamic> body = const {},
    Map<String, String>? headers,
    String? token,
    bool isHttps = false,
  });

  Future formDataV1(
    String endpoints, {
    String? domain,
    List<String> fileFields = const [],
    List<Uint8List?> filePaths = const [],
    Map<String, dynamic> body = const {},
    Map<String, String>? headers,
    String? token,
    bool isHttps = false,
  });

  Future<Uint8List> formDataV2(
    String endpoints, {
    String? domain,
    List<String> fileFields = const [],
    List<String?> filePaths = const [],
    Map<String, dynamic> body = const {},
    Map<String, String>? headers,
    String? token,
    bool isHttps = false,
  });

  Future<Map<String, dynamic>> formDataMultiFile(
    String endpoints, {
    String? domain,
    List<String?> filePaths = const [],
    List<String> fileFields = const [],
    Map<String, dynamic> body = const {},
    Map<String, String>? headers,
    String? token,
    bool isHttps = false,
  });

  Future<dynamic> getGetApiResponsewithBody(
    String endpoints, {
    String? domain,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    String? token,
    bool isHttps = false,
  });

  Future<Uint8List> fetchImage(String imageLink);
}
