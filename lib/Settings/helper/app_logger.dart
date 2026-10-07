import 'package:everqpidapp/Data/services/logger_service.dart';

/// Backward-compatible facade → [LoggerService] (one logging API).
class AppLogger {
  AppLogger._();

  static void d(String message) => LoggerService.instance.debug(message);

  static void i(String message) => LoggerService.instance.info(message);

  static void w(String message, [Object? error, StackTrace? stack]) =>
      LoggerService.instance.warning(message, error, stack);

  static void e(String message, [Object? error, StackTrace? stack]) =>
      LoggerService.instance.error(message, error, stack);
}
