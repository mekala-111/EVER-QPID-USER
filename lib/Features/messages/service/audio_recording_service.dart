import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart' show XFile;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecordingService {
  static AudioRecordingService? _instance;
  AudioRecordingService._();

  static AudioRecordingService get instance {
    _instance ??= AudioRecordingService._();
    return _instance!;
  }

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;
  Timer? _durationTimer;

  // Callback for duration updates
  void Function(Duration duration)? onDurationUpdate;

  bool get isRecording => _isRecording;
  Duration get recordingDuration {
    if (_recordingStartTime == null) return Duration.zero;
    return DateTime.now().difference(_recordingStartTime!);
  }

  /// Start recording audio. Not supported on web (`record` + temp paths).
  Future<bool> startRecording() async {
    if (kIsWeb) {
      log('❌ Audio recording is not supported on web');
      return false;
    }

    try {
      if (!await _recorder.hasPermission()) {
        log('❌ Audio recording permission denied');
        return false;
      }

      final tempDir = await getTemporaryDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      _currentRecordingPath = '${tempDir.path}/audio_$timestamp.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

      _isRecording = true;
      _recordingStartTime = DateTime.now();
      _startDurationTimer();

      log('🎤 Recording started: $_currentRecordingPath');
      return true;
    } catch (e) {
      log('❌ Error starting recording: $e');
      return false;
    }
  }

  /// Stop recording and return audio bytes (web-safe; no `dart:io` [File]).
  Future<Uint8List?> stopRecording() async {
    try {
      if (!_isRecording) {
        log('⚠️ No active recording to stop');
        return null;
      }

      final String? path = await _recorder.stop();
      _isRecording = false;
      _recordingStartTime = null;
      _durationTimer?.cancel();
      _durationTimer = null;

      if (path == null) {
        log('❌ Recording path missing');
        return null;
      }

      final bytes = await XFile(path).readAsBytes();
      log('✅ Recording stopped (${bytes.length / 1024} KB)');
      _currentRecordingPath = null;
      return bytes;
    } catch (e) {
      log('❌ Error stopping recording: $e');
      _isRecording = false;
      _recordingStartTime = null;
      _durationTimer?.cancel();
      return null;
    }
  }

  /// Cancel recording without saving
  Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        await _recorder.stop();
        _isRecording = false;
        _recordingStartTime = null;
        _durationTimer?.cancel();
        _durationTimer = null;
        // ponytail: skip File.delete — OS temp cleanup; avoids dart:io on web
        _currentRecordingPath = null;
        log('🗑️ Recording cancelled');
      }
    } catch (e) {
      log('❌ Error cancelling recording: $e');
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_recordingStartTime != null) {
        final duration = DateTime.now().difference(_recordingStartTime!);
        onDurationUpdate?.call(duration);
      }
    });
  }

  Future<bool> hasPermission() async {
    if (kIsWeb) return false;
    return await _recorder.hasPermission();
  }

  void dispose() {
    _durationTimer?.cancel();
    _recorder.dispose();
    _instance = null;
  }
}
