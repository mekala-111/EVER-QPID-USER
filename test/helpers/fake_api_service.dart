import 'dart:async';
import 'dart:typed_data';

import 'package:everqpidapp/Data/Network/base_api_service.dart';
import 'package:mocktail/mocktail.dart';

/// Mocktail fake for [BaseApiService] — use when testing code that accepts
/// an injected API (helpers / future DI). Repositories today use the singleton;
/// prefer [DioTestHarness] for those.
class FakeApiService extends Fake implements BaseApiService {
  final Map<String, dynamic> cannedGet;
  final Map<String, dynamic> cannedPost;
  Object? throwOnCall;

  FakeApiService({
    this.cannedGet = const {'status': true, 'statusCode': 200, 'data': {}},
    this.cannedPost = const {'status': true, 'statusCode': 200, 'data': {}},
    this.throwOnCall,
  });

  void _maybeThrow() {
    if (throwOnCall != null) throw throwOnCall!;
  }

  @override
  Future getGetApiResponse(
    String endPoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    String? token,
    String? appned,
  }) async {
    _maybeThrow();
    return cannedGet;
  }

  @override
  Future getPostApiResponse(
    String endPoint, {
    String? domain,
    Object? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    String? token,
    String? appned,
  }) async {
    _maybeThrow();
    return cannedPost;
  }

  @override
  Future putMethod(
    String url, {
    Object? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    _maybeThrow();
    return null;
  }

  @override
  Future getPutApiResponse(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    String? token,
    String? appned,
  }) async {
    _maybeThrow();
    return cannedPost;
  }

  @override
  Future getDeleteApiResponse(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    String? token,
    String? appned,
  }) async {
    _maybeThrow();
    return cannedPost;
  }

  @override
  Future formData(
    String endpoints, {
    String? domain,
    List<String> fileFields = const [],
    List<String?> filePaths = const [],
    Map<String, dynamic> body = const {},
    Map<String, String>? headers,
    String? token,
    bool isHttps = false,
  }) async {
    _maybeThrow();
    return cannedPost;
  }

  @override
  Future formDataV1(
    String endpoints, {
    String? domain,
    List<String> fileFields = const [],
    List<Uint8List?> filePaths = const [],
    Map<String, dynamic> body = const {},
    Map<String, String>? headers,
    String? token,
    bool isHttps = false,
  }) async {
    _maybeThrow();
    return cannedPost;
  }

  @override
  Future<Uint8List> formDataV2(
    String endpoints, {
    String? domain,
    List<String> fileFields = const [],
    List<String?> filePaths = const [],
    Map<String, dynamic> body = const {},
    Map<String, String>? headers,
    String? token,
    bool isHttps = false,
  }) async {
    _maybeThrow();
    return Uint8List(0);
  }

  @override
  Future<Map<String, dynamic>> formDataMultiFile(
    String endpoints, {
    String? domain,
    List<String?> filePaths = const [],
    List<String> fileFields = const [],
    Map<String, dynamic> body = const {},
    Map<String, String>? headers,
    String? token,
    bool isHttps = false,
  }) async {
    _maybeThrow();
    return Map<String, dynamic>.from(cannedPost);
  }

  @override
  Future getGetApiResponsewithBody(
    String endpoints, {
    String? domain,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    String? token,
    bool isHttps = false,
  }) async {
    _maybeThrow();
    return cannedGet;
  }

  @override
  Future<Uint8List> fetchImage(String imageLink) async {
    _maybeThrow();
    return Uint8List(0);
  }
}
