import 'dart:async';
import 'package:flutter/material.dart';
import 'package:simple_youtube_player/simple_youtube_player.dart';
import '../domain/video_player_interface.dart';
import '../../../core/constants/app_colors.dart';

/// Simple YouTube Player implementation using WebView
///
/// This provides:
/// - Native YouTube player experience via WebView
/// - Automatic YouTube URL parsing
/// - Support for various YouTube URL formats
/// - Best for YouTube-hosted content
///
/// Limitations:
/// - No programmatic control (play/pause/seek) due to WebView nature
/// - No position/duration tracking
/// - Progress tracking not supported
class SimpleYoutubePlayerImpl implements IVideoPlayer {
  String? _videoUrl;

  final StreamController<PlayerPlaybackState> _stateController =
      StreamController<PlayerPlaybackState>.broadcast();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();
  final StreamController<bool> _bufferingController =
      StreamController<bool>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  bool _isInitialized = false;
  bool _isFullscreen = false;

  @override
  String get playerType => 'simple_youtube';

  @override
  Future<void> initialize(String videoUrl, {Duration? startPosition}) async {
    try {
      _stateController.add(PlayerPlaybackState.loading);

      _videoUrl = videoUrl;

      _isInitialized = true;
      _stateController.add(PlayerPlaybackState.ready);

      debugPrint('✅ SimpleYoutubePlayer initialized with URL: $videoUrl');
    } catch (e) {
      _stateController.add(PlayerPlaybackState.error);
      _errorController.add('خطأ في تحميل فيديو يوتيوب: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<void> play() async {
    // Not supported - WebView controls playback natively
  }

  @override
  Future<void> pause() async {
    // Not supported - WebView controls playback natively
  }

  @override
  Future<void> seekTo(Duration position) async {
    // Not supported - WebView controls playback natively
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    // Not supported - WebView controls playback natively
  }

  @override
  Future<void> setQuality(String quality) async {
    // Not supported - YouTube handles quality automatically
  }

  @override
  Future<void> setFullscreen(bool fullscreen) async {
    _isFullscreen = fullscreen;
    // Fullscreen handling is typically done at the page level
  }

  @override
  Future<void> dispose() async {
    await _stateController.close();
    await _positionController.close();
    await _durationController.close();
    await _bufferingController.close();
    await _errorController.close();
  }

  @override
  Duration get currentPosition => Duration.zero; // Not available

  @override
  Duration get duration => Duration.zero; // Not available

  @override
  bool get isPlaying => false; // Not trackable with WebView

  @override
  bool get isBuffering => false; // Not trackable with WebView

  @override
  bool get isFullscreen => _isFullscreen;

  @override
  double get playbackSpeed => 1.0; // Not controllable

  @override
  String? get currentQuality => null; // Not available

  @override
  List<String> get availableQualities => []; // Not available

  @override
  bool get isInitialized => _isInitialized;

  @override
  Stream<PlayerPlaybackState> get stateStream => _stateController.stream;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration> get durationStream => _durationController.stream;

  @override
  Stream<bool> get bufferingStream => _bufferingController.stream;

  @override
  Stream<String> get errorStream => _errorController.stream;

  @override
  Widget buildPlayer(BuildContext context, {bool showControls = true}) {
    if (_videoUrl == null || !_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.emerald500),
        ),
      );
    }

    // Use LayoutBuilder to get available size for the player
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dimensions maintaining 16:9 aspect ratio
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        // If height is infinite (inside ScrollView), calculate from width
        if (height == double.infinity) {
          height = width * 9 / 16;
        }

        // If width is infinite, calculate from height
        if (width == double.infinity) {
          width = height * 16 / 9;
        }

        // Ensure minimum dimensions
        width = width.clamp(200.0, double.infinity);
        height = height.clamp(150.0, double.infinity);

        return Center(
          child: SimpleYoutubePlayer(
            key: ValueKey('youtube_player_${_videoUrl.hashCode}_${width.toInt()}_${height.toInt()}'),
            url: _videoUrl!,
            width: width,
            height: height,
            autoPlay: true,
            showControls: showControls,
          ),
        );
      },
    );
  }
}
