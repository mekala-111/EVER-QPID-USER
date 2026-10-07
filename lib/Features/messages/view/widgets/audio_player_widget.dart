import 'dart:async';
import 'dart:developer';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final bool isSentByMe;
  final bool darkIncoming;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    required this.isSentByMe,
    this.darkIncoming = false,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() => _isLoading = true);

      // Set audio source
      await _audioPlayer.setUrl(widget.audioUrl);

      // Listen to player state changes
      _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;

            // Auto-reset when playback completes
            if (state.processingState == ProcessingState.completed) {
              _isPlaying = false;
              _position = Duration.zero;
              _audioPlayer.seek(Duration.zero);
              _audioPlayer.pause();
            }
          });
        }
      });

      // Listen to position changes
      _positionSubscription = _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() => _position = position);
        }
      });

      // Listen to duration changes
      _durationSubscription = _audioPlayer.durationStream.listen((duration) {
        if (mounted && duration != null) {
          setState(() => _duration = duration);
        }
      });

      setState(() => _isLoading = false);
      log('✅ Audio player initialized for: ${widget.audioUrl}');
    } catch (e) {
      log('❌ Error initializing audio player: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        // If at the end, restart from beginning
        if (_position >= _duration && _duration > Duration.zero) {
          await _audioPlayer.seek(Duration.zero);
        }
        await _audioPlayer.play();
      }
    } catch (e) {
      log('❌ Error toggling play/pause: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = widget.isSentByMe
        ? Colors.white
        : (widget.darkIncoming ? WelcomeTheme.violetLight : PColors.primaryColor);
    final Color textColor = widget.isSentByMe
        ? Colors.white
        : (widget.darkIncoming ? Colors.white : Colors.black87);
    final Color waveColor = widget.isSentByMe
        ? Colors.white.withOpacity(0.7)
        : (widget.darkIncoming
            ? Colors.white.withOpacity(0.45)
            : Colors.grey[400]!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause Button
          GestureDetector(
            onTap: _isLoading ? null : _togglePlayPause,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.isSentByMe
                    ? Colors.white.withOpacity(0.2)
                    : PColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: _isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                      ),
                    )
                  : Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: iconColor,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Waveform visualization (simplified)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Waveform bars
                SizedBox(
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(30, (index) {
                      // Create varying heights for waveform effect
                      final heights = [
                        0.3,
                        0.5,
                        0.7,
                        0.9,
                        0.6,
                        0.4,
                        0.8,
                        0.5,
                        0.3,
                        0.6,
                      ];
                      final height = heights[index % heights.length];

                      // Calculate if this bar should be highlighted based on progress
                      final progress = _duration.inMilliseconds > 0
                          ? _position.inMilliseconds / _duration.inMilliseconds
                          : 0.0;
                      final isActive = (index / 30) <= progress;

                      return Container(
                        width: 2,
                        height: 30 * height,
                        decoration: BoxDecoration(
                          color: isActive ? iconColor : waveColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 4),

                // Duration text
                Text(
                  _isPlaying || _position > Duration.zero
                      ? '${_formatDuration(_position)} / ${_formatDuration(_duration)}'
                      : _formatDuration(_duration),
                  style: getTextStyle(
                    fontSize: 11,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
