import 'dart:async';
import 'package:flutter/material.dart';
import 'package:orax_video_player/orax_video_player.dart';
import '../domain/video_player_interface.dart';

/// Orax Video Player implementation
///
/// This provides:
/// - YouTube video support with quality selection
/// - Subtitles support
/// - Zoom/pinch support
/// - Custom controls
class OraxPlayerImpl implements IVideoPlayer {
  OraxVideoPlayerController? _controller;
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
  double _playbackSpeed = 1.0;

  @override
  String get playerType => 'orax_video_player';

  @override
  Future<void> initialize(String videoUrl, {Duration? startPosition}) async {
    try {
      _stateController.add(PlayerPlaybackState.loading);

      _videoUrl = videoUrl;
      _controller = OraxVideoPlayerController();

      // Listen to controller state changes
      _controller!.addListener(_onControllerChanged);

      // Initialize the controller with the video URL
      await _controller!.initialize(videoUrl);

      // Seek to start position if provided
      if (startPosition != null && startPosition.inSeconds > 0) {
        await _controller!.seekTo(startPosition);
      }

      _isInitialized = true;
      _stateController.add(PlayerPlaybackState.ready);
      _durationController.add(_controller!.duration);
    } catch (e) {
      _stateController.add(PlayerPlaybackState.error);
      _errorController.add('خطأ في تحميل الفيديو: ${e.toString()}');
      rethrow;
    }
  }

  void _onControllerChanged() {
    if (_controller == null) return;

    final state = _controller!.state;
    switch (state) {
      case OraxPlaybackState.idle:
        _stateController.add(PlayerPlaybackState.idle);
        _bufferingController.add(false);
        break;
      case OraxPlaybackState.loading:
        _stateController.add(PlayerPlaybackState.loading);
        _bufferingController.add(true);
        break;
      case OraxPlaybackState.ready:
        _stateController.add(PlayerPlaybackState.ready);
        _bufferingController.add(false);
        break;
      case OraxPlaybackState.playing:
        _stateController.add(PlayerPlaybackState.playing);
        _bufferingController.add(false);
        break;
      case OraxPlaybackState.paused:
        _stateController.add(PlayerPlaybackState.paused);
        _bufferingController.add(false);
        break;
      case OraxPlaybackState.buffering:
        _stateController.add(PlayerPlaybackState.buffering);
        _bufferingController.add(true);
        break;
      case OraxPlaybackState.completed:
        _stateController.add(PlayerPlaybackState.completed);
        _bufferingController.add(false);
        break;
      case OraxPlaybackState.error:
        _stateController.add(PlayerPlaybackState.error);
        _errorController.add(_controller!.errorMessage ?? 'خطأ غير معروف');
        break;
    }

    // Update position and duration
    _positionController.add(_controller!.position);
    _durationController.add(_controller!.duration);
  }

  @override
  Future<void> play() async {
    await _controller?.play();
  }

  @override
  Future<void> pause() async {
    await _controller?.pause();
  }

  @override
  Future<void> seekTo(Duration position) async {
    await _controller?.seekTo(position);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    await _controller?.setPlaybackSpeed(speed);
  }

  @override
  Future<void> setQuality(String quality) async {
    if (_controller == null) return;

    // Find matching VideoQuality from available qualities
    final qualities = _controller!.availableQualities;
    final matchingQuality = qualities.firstWhere(
      (q) => q.label == quality,
      orElse: () => qualities.isNotEmpty ? qualities.first : throw Exception('No qualities available'),
    );
    await _controller!.setQuality(matchingQuality);
  }

  @override
  Future<void> setFullscreen(bool fullscreen) async {
    _isFullscreen = fullscreen;
    // Fullscreen is handled at the page level, not by the controller
  }

  @override
  Future<void> dispose() async {
    _controller?.removeListener(_onControllerChanged);
    _controller?.dispose();
    _controller = null;

    await _stateController.close();
    await _positionController.close();
    await _durationController.close();
    await _bufferingController.close();
    await _errorController.close();
  }

  @override
  Duration get currentPosition => _controller?.position ?? Duration.zero;

  @override
  Duration get duration => _controller?.duration ?? Duration.zero;

  @override
  bool get isPlaying => _controller?.isPlaying ?? false;

  @override
  bool get isBuffering => _controller?.isBuffering ?? false;

  @override
  bool get isFullscreen => _isFullscreen;

  @override
  double get playbackSpeed => _playbackSpeed;

  @override
  String? get currentQuality => _controller?.currentQuality?.label;

  @override
  List<String> get availableQualities =>
      _controller?.availableQualities.map((q) => q.label).toList() ?? [];

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
    if (_controller == null || !_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF10B981), // Emerald 500
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _controller!,
      builder: (context, _) {
        return OraxVideoPlayer(
          controller: _controller!,
          showControls: showControls,
          autoPlay: true,
          controlsColor: const Color(0xFF10B981), // Emerald 500
          backgroundColor: Colors.black,
        );
      },
    );
  }
}
