import 'package:dio/dio.dart';
import 'package:everqpidapp/Data/services/logger_service.dart';
import 'package:everqpidapp/Data/services/performance_monitor.dart';

/// Network-layer logging. Verbose in debug; errors only in release.
/// Never logs Authorization headers, tokens, passwords, OTPs, or payment signatures.
class NetworkLogger {
  NetworkLogger._();

  static const _sensitiveHeaderKeys = {
    'authorization',
    'x-razorpay-signature',
    'cookie',
    'set-cookie',
    'fcm-token',
  };

  static const _sensitiveBodyKeys = {
    'password',
    'otp',
    'token',
    'accesstoken',
    'refreshtoken',
    'refresh_token',
    'access_token',
    'authorization',
    'signature',
    'razorpay_signature',
    'razorpay_payment_id',
    'razorpay_order_id',
    'fcmtoken',
    'fcm_token',
    'fcm-token',
  };

  static void request({
    required String method,
    required String path,
    Map<String, dynamic>? headers,
    Object? data,
  }) {
    LoggerService.instance.debug(
      '[NET] → $method $path headers=${_scrubHeaders(headers)}',
    );
  }

  static void response({
    required String method,
    required String path,
    required int? statusCode,
    required Duration duration,
  }) {
    final ms = duration.inMilliseconds;
    LoggerService.instance.debug(
      '[NET] ← $method $path ${statusCode ?? '-'} ${ms}ms',
    );
    unawaitedMetric(path, statusCode ?? 0, ms);
  }

  static void unawaitedMetric(String path, int statusCode, int ms) {
    // ignore: discarded_futures
    PerformanceMonitor.instance.recordNetwork(path, statusCode, ms);
  }

  static void error({
    required String method,
    required String path,
    required Object error,
    int? statusCode,
  }) {
    final type =
        error is DioException ? error.type.name : error.runtimeType.toString();
    final code = statusCode ??
        (error is DioException ? error.response?.statusCode : null);
    final msg = _safeDioMessage(error);
    // Structured line only — avoid passing DioException (toString trips scrubber).
    LoggerService.instance.error(
      '[NET] ✕ $method $path status=${code ?? '-'} type=$type msg=$msg',
    );
  }

  static String _safeDioMessage(Object error) {
    if (error is! DioException) return error.runtimeType.toString();
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      final m = data['message'].toString();
      return m.length > 120 ? '${m.substring(0, 120)}…' : m;
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'timeout';
      case DioExceptionType.connectionError:
        return 'connection_error';
      case DioExceptionType.badResponse:
        return 'bad_response';
      case DioExceptionType.cancel:
        return 'cancelled';
      case DioExceptionType.badCertificate:
        return 'bad_certificate';
      case DioExceptionType.unknown:
        return 'unknown';
    }
  }

  static void info(String message) {
    LoggerService.instance.info('[NET] $message');
  }

  static Map<String, dynamic>? _scrubHeaders(Map<String, dynamic>? headers) {
    if (headers == null) return null;
    return {
      for (final e in headers.entries)
        e.key: _sensitiveHeaderKeys.contains(e.key.toLowerCase())
            ? '***'
            : e.value,
    };
  }

  /// Optional helper if a caller needs to scrub a body map before logging.
  static Object? scrubBody(Object? data) {
    if (data is! Map) return data is String ? '(body)' : data?.runtimeType;
    return {
      for (final e in data.entries)
        e.key: _sensitiveBodyKeys.contains(e.key.toString().toLowerCase())
            ? '***'
            : e.value,
    };
  }
}
