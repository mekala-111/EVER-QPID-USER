import 'package:flutter/foundation.dart';

import 'logger_service.dart';

/// Lightweight timing helpers for production visibility.
class PerformanceMonitor {
  PerformanceMonitor._();
  static final PerformanceMonitor instance = PerformanceMonitor._();

  final Map<String, Stopwatch> _watches = {};
  DateTime? _appStart;

  void markAppStart() => _appStart ??= DateTime.now();

  Future<void> recordStartupComplete() async {
    if (_appStart == null) return;
    final ms = DateTime.now().difference(_appStart!).inMilliseconds;
    await LoggerService.instance.setCustomKey('startup_ms', ms);
    LoggerService.instance.info('perf:startup ${ms}ms');
  }

  void start(String name) {
    _watches[name] = Stopwatch()..start();
  }

  Future<int> stop(String name, {bool toCrashlytics = false}) async {
    final sw = _watches.remove(name);
    if (sw == null) return 0;
    sw.stop();
    final ms = sw.elapsedMilliseconds;
    if (!kReleaseMode) {
      LoggerService.instance.debug('perf:$name ${ms}ms');
    }
    if (toCrashlytics || ms >= 2000) {
      await LoggerService.instance.setCustomKey('last_${name}_ms', ms);
    }
    return ms;
  }

  Future<void> recordNetwork(String path, int statusCode, int ms) async {
    if (ms >= 3000) {
      await LoggerService.instance.setCustomKey('slow_net_ms', ms);
      await LoggerService.instance.setCustomKey('slow_net_path', path);
      LoggerService.instance.warning('slow network $path ${ms}ms status=$statusCode');
    } else if (!kReleaseMode) {
      LoggerService.instance.debug('net $path $statusCode ${ms}ms');
    }
  }
}
