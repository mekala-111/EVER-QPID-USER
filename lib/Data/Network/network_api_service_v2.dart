import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:everqpidapp/Data/Exceptions/app_exceptions.dart';
import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Data/Network/base_api_service.dart';
import 'package:everqpidapp/Data/Network/network_logger.dart';
import 'package:everqpidapp/Settings/constants/app_url.dart';
import 'package:everqpidapp/Settings/helper/app_start_router.dart';
import 'package:everqpidapp/Settings/utils/app_navigator.dart';
import 'package:everqpidapp/config/config.dart';
import 'package:everqpidapp/config/environment.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

/// Single shared Dio networking layer used by every repository.
///
/// Prefer [NetworkApiServiceV2.instance]. Calling [NetworkApiServiceV2.new]
/// returns the same singleton.
class NetworkApiServiceV2 implements BaseApiService {
  NetworkApiServiceV2._() {
    _initAdapters();
  }

  static final NetworkApiServiceV2 instance = NetworkApiServiceV2._();

  /// Compatibility factory — every `NetworkApiServiceV2()` shares [instance].
  factory NetworkApiServiceV2() => instance;

  /// Staging/production must never talk plaintext HTTP.
  /// Development may use LAN `http://` for local servers (see docs/SECURITY.md).
  static void _assertHttpsForDeployedEnvs() {
    final env = AppConfig.environment;
    if (env == AppEnvironment.development) return;

    final api = AppConfig.apiUrl;
    final socket = AppConfig.socketUrl;
    final images = AppConfig.imageBaseUrl;
    for (final url in [api, socket, images]) {
      if (!url.startsWith('https://')) {
        throw StateError(
          'Insecure URL blocked for ${env.name}: $url (HTTPS required)',
        );
      }
    }
  }

  late final dio.Dio adapter;

  /// Signed-URL / S3 uploads only — no auth interceptors.
  late final dio.Dio _s3Adapter;

  static Completer<bool>? _refreshCompleter;

  static const _connectTimeout = Duration(seconds: 15);
  static const _receiveTimeout = Duration(seconds: 30);
  static const _sendTimeout = Duration(seconds: 30);

  void _initAdapters() {
    _assertHttpsForDeployedEnvs();

    adapter = dio.Dio(
      dio.BaseOptions(
        baseUrl: AppUrl.baseurl,
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
        sendTimeout: _sendTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _s3Adapter = dio.Dio(
      dio.BaseOptions(
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
        sendTimeout: _sendTimeout,
        validateStatus: (status) => true,
      ),
    );

    // Interceptor order:
    // 1) request timing + auth header
    // 2) response / body-401 refresh
    // 3) error: timeout/connectivity map → 401 refresh → typed exceptions
    adapter.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) {
          options.extra['startedAt'] = DateTime.now();
          options.contentType ??= 'application/json';

          // Access token only. Refresh token is never a Bearer header.
          if (LoggedInUser.accessToken != null &&
              !_isRefreshPath(options.path)) {
            options.headers['Authorization'] =
                'Bearer ${LoggedInUser.accessToken}';
          }

          NetworkLogger.request(
            method: options.method,
            path: options.path,
            headers: Map<String, dynamic>.from(options.headers),
          );
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          _logResponse(response.requestOptions, response.statusCode);

          try {
            if (response.data is Map && response.data?['statusCode'] == 401) {
              NetworkLogger.info(
                  'Session expired, attempting token refresh...');
              if (_isRefreshPath(response.requestOptions.path) ||
                  response.requestOptions.extra['retried'] == true) {
                _handleAuthFailure();
                return handler.next(response);
              }

              final refreshed = await refreshAccessToken();
              if (!refreshed) {
                _handleAuthFailure();
                return handler.next(response);
              }
              return handler.resolve(await _retry(response.requestOptions));
            }

            if (response.data is Map &&
                (response.data?['statusCode'] == 410 ||
                    response.data?['statusCode'] == 403)) {
              if (!_isPublicAuthPath(response.requestOptions.path)) {
                _handleAuthFailure();
              }
            }

            return handler.next(response);
          } catch (e) {
            return handler.reject(
              dio.DioException(
                requestOptions: response.requestOptions,
                error: e,
              ),
            );
          }
        },
        onError: (dio.DioException e, handler) async {
          NetworkLogger.error(
            method: e.requestOptions.method,
            path: e.requestOptions.path,
            error: e,
            statusCode: e.response?.statusCode,
          );

          // Connectivity / timeout — map once, optional single retry.
          if (_isTransientNetworkError(e)) {
            if (e.requestOptions.extra['networkRetried'] != true) {
              e.requestOptions.extra['networkRetried'] = true;
              try {
                final cloned = await adapter.fetch(e.requestOptions);
                return handler.resolve(cloned);
              } catch (_) {
                // fall through to mapped exception
              }
            }
            return handler.reject(
              dio.DioException(
                requestOptions: e.requestOptions,
                error: _mapTransient(e),
                type: e.type,
                response: e.response,
              ),
            );
          }

          // HTTP 401 — single refresh + retry path (Phase 2 contract).
          if (e.response?.statusCode == 401) {
            if (_isRefreshPath(e.requestOptions.path) ||
                e.requestOptions.extra['retried'] == true) {
              _handleAuthFailure();
              return handler.next(e);
            }

            final refreshed = await refreshAccessToken();
            if (!refreshed) {
              _handleAuthFailure();
              return handler.next(e);
            }

            try {
              return handler.resolve(await _retry(e.requestOptions));
            } on dio.DioException catch (cloneErr) {
              return handler.reject(cloneErr);
            } catch (cloneErr) {
              return handler.reject(
                dio.DioException(
                  requestOptions: e.requestOptions,
                  error: cloneErr,
                ),
              );
            }
          }

          if (e.response?.statusCode == 410 || e.response?.statusCode == 403) {
            if (!_isPublicAuthPath(e.requestOptions.path)) {
              _handleAuthFailure();
            }
            return handler.next(e);
          }

          // Do not navigate from the network layer on 5xx — typed exception only.
          if (e.response?.statusCode != null &&
              e.response!.statusCode! >= 500) {
            return handler.reject(
              dio.DioException(
                requestOptions: e.requestOptions,
                error: _mapStatus(
                  e.response!.statusCode!,
                  _messageFrom(e.response?.data),
                ),
                type: e.type,
                response: e.response,
              ),
            );
          }

          return handler.next(e);
        },
      ),
    );
  }

  void _logResponse(dio.RequestOptions options, int? statusCode) {
    final started = options.extra['startedAt'];
    final duration = started is DateTime
        ? DateTime.now().difference(started)
        : Duration.zero;
    NetworkLogger.response(
      method: options.method,
      path: options.path,
      statusCode: statusCode,
      duration: duration,
    );
  }

  bool _isTransientNetworkError(dio.DioException e) =>
      e.type == dio.DioExceptionType.connectionError ||
      e.type == dio.DioExceptionType.connectionTimeout ||
      e.type == dio.DioExceptionType.receiveTimeout ||
      e.type == dio.DioExceptionType.sendTimeout;

  AppExceptions _mapTransient(dio.DioException e) {
    if (e.type == dio.DioExceptionType.connectionTimeout ||
        e.type == dio.DioExceptionType.receiveTimeout ||
        e.type == dio.DioExceptionType.sendTimeout) {
      return NetworkTimeoutException('Request timed out', null);
    }
    return NoInternetException(
      'Network connection failed. Please check your internet connection.',
    );
  }

  void _handleAuthFailure() {
    EasyLoading.dismiss();
    LoggedInUser.clearUserData();
    final ctx = AppNavigator.context;
    if (ctx != null) {
      // Always go to login — no splash re-entry.
      AppNavigator.pushNamedAndRemoveUntil(
        AppStartRouter.loginRoute,
        (route) => false,
      );
    }
  }

  bool _isRefreshPath(String path) => path.contains('refresh-token');

  bool _isPublicAuthPath(String path) {
    final p = path.toLowerCase();
    return p.contains('/auth/') ||
        p.contains('check-user-exists') ||
        p.contains('user-auth') ||
        p.contains('user-email') ||
        p.contains('google-login') ||
        p.contains('login') ||
        p.contains('refresh-token') ||
        p.contains('signed-url') ||
        p.contains('send-otp') ||
        p.contains('verify-otp');
  }

  /// Single refresh implementation. Single-flight across the process.
  Future<bool> refreshAccessToken() async {
    final inFlight = _refreshCompleter;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<bool>();
    _refreshCompleter = completer;
    NetworkLogger.info('Starting token refresh...');

    var success = false;
    try {
      final refreshToken = LoggedInUser.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        NetworkLogger.info('No refresh token available');
      } else {
        final response = await adapter.post(
          AppUrl.refreshToken,
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200 &&
            response.data is Map &&
            response.data['status'] == true) {
          LoggedInUser.tokenUpdate(response.data['data']['tokens']);
          NetworkLogger.info('Token refresh successful');
          success = true;
        } else {
          NetworkLogger.info('Token refresh failed - invalid response');
        }
      }
    } catch (e) {
      NetworkLogger.error(
        method: 'POST',
        path: AppUrl.refreshToken,
        error: e,
      );
    } finally {
      completer.complete(success);
      _refreshCompleter = null;
    }
    return success;
  }

  Future<dio.Response> _retry(dio.RequestOptions options) {
    options.headers['Authorization'] = 'Bearer ${LoggedInUser.accessToken}';
    return adapter.request(
      options.path,
      options: dio.Options(
        method: options.method,
        headers: options.headers,
        contentType: options.contentType,
        responseType: options.responseType,
        extra: {...options.extra, 'retried': true},
      ),
      data: options.data,
      queryParameters: options.queryParameters,
    );
  }

  dio.Options _requestOptions(Map<String, String>? headers) {
    return dio.Options(
      headers: headers,
    );
  }

  String _join(String endPoint, String? append) =>
      append == null ? endPoint : '$endPoint/$append';

  /// Unwraps [AppExceptions] placed on [dio.DioException.error] by interceptors.
  Never _rethrowMapped(Object e) {
    if (e is dio.DioException && e.error is AppExceptions) {
      throw e.error!;
    }
    throw e;
  }

  @override
  Future getGetApiResponse(
    String endPoint, {
    Map<String, String>? headers,
    Object? body,
    Map<String, dynamic>? queryParameters,
    String? token,
    String? appned,
  }) async {
    try {
      final path = _join(endPoint, appned);
      final res = await adapter.get(
        path,
        data: body,
        queryParameters: queryParameters,
        options: _requestOptions(headers),
      );
      return dioReturnResponse(res);
    } catch (e) {
      _rethrowMapped(e);
    }
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
    try {
      final path = _join(endPoint, appned);
      final res = await adapter.post(
        path,
        data: body,
        queryParameters: queryParameters,
        options: _requestOptions(headers),
      );
      return dioReturnResponse(res);
    } catch (e) {
      _rethrowMapped(e);
    }
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
    try {
      final path = _join(endpoint, appned);
      final res = await adapter.put(
        path,
        queryParameters: queryParameters,
        data: body,
        options: _requestOptions(headers),
      );
      return dioReturnResponse(res);
    } catch (e) {
      _rethrowMapped(e);
    }
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
    try {
      final path = _join(endpoint, appned);
      final res = await adapter.delete(
        path,
        queryParameters: queryParameters,
        data: body,
        options: _requestOptions(headers),
      );
      return dioReturnResponse(res);
    } catch (e) {
      _rethrowMapped(e);
    }
  }

  @override
  Future<dynamic> putMethod(
    String url, {
    Object? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      if (url.contains('s3.') || url.contains('amazonaws.com')) {
        final res = await _s3Adapter.put(
          url,
          data: body,
          options: dio.Options(
            headers: headers,
            followRedirects: true,
            maxRedirects: 5,
            validateStatus: (status) => true,
          ),
        );

        if (res.data is String &&
            res.data.contains('<?xml') &&
            res.data.contains('<Error>')) {
          throw dio.DioException(
            requestOptions: res.requestOptions,
            response: res,
            error: 'S3 Error: ${parseS3ErrorMessage(res.data)}',
          );
        }
        return res.data;
      }

      final res = await adapter.put(
        url,
        queryParameters: queryParameters,
        data: body,
        options: _requestOptions(headers),
      );
      return dioReturnResponse(res);
    } catch (e) {
      if (e is dio.DioException &&
          e.response?.data is String &&
          e.response!.data.contains('<?xml')) {
        throw FetchDataException(
          'S3 Upload Error: ${parseS3ErrorMessage(e.response!.data)}',
          e.response?.statusCode,
        );
      }
      rethrow;
    }
  }

  /// Upload bytes to a pre-signed URL (S3). Uses the shared S3 adapter.
  Future<void> uploadToSignedUrl(
    String signedUrl,
    List<int> bytes, {
    String contentType = 'application/octet-stream',
  }) async {
    await putMethod(
      signedUrl,
      body: bytes,
      headers: {'Content-Type': contentType},
    );
  }

  String parseS3ErrorMessage(String xmlResponse) {
    final messageStart = xmlResponse.indexOf('<Message>') + 9;
    final messageEnd = xmlResponse.indexOf('</Message>');
    if (messageStart > 8 && messageEnd > messageStart) {
      return xmlResponse.substring(messageStart, messageEnd);
    }
    return 'Unknown S3 error';
  }

  @override
  Future<Uint8List> fetchImage(String imageLink) {
    throw UnimplementedError();
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
  }) {
    throw UnimplementedError();
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
  }) {
    throw UnimplementedError();
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
  }) {
    throw UnimplementedError();
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
  }) {
    throw UnimplementedError();
  }

  @override
  Future getGetApiResponsewithBody(
    String endpoints, {
    String? domain,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    String? token,
    bool isHttps = false,
  }) {
    throw UnimplementedError();
  }

  dynamic _messageFrom(dynamic data) {
    if (data is Map) return data['message'];
    return null;
  }

  AppExceptions _mapStatus(int statusCode, dynamic message) {
    final msg = message?.toString();
    switch (statusCode) {
      case 400:
        return BadRequestException(msg, statusCode);
      case 401:
      case 403:
        return UnauthorisedException(msg, statusCode);
      case 404:
        return NotFoundException(msg, statusCode);
      case 409:
        return ConflictException(msg, statusCode);
      case 410:
        return GoneException(msg, statusCode);
      case 422:
        return ValidationException(msg, statusCode);
      case 429:
        return RateLimitException(msg, statusCode);
      case 503:
        return ServiceUnavailableException(msg, statusCode);
      case 500:
        return FetchDataException(
          msg ?? 'Something went wrong',
          statusCode,
        );
      default:
        return FetchDataException(msg, statusCode);
    }
  }

  dynamic dioReturnResponse(dio.Response? response) {
    if (response == null) {
      throw NoInternetException();
    }

    final message = _messageFrom(response.data);
    final statusCode = response.statusCode is String
        ? int.parse(response.statusCode.toString())
        : (response.statusCode ?? 500);

    switch (statusCode) {
      case 200:
      case 201:
        return response.data;
      default:
        throw _mapStatus(statusCode, message);
    }
  }
}
