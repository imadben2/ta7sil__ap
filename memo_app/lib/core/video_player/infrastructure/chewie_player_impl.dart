import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../domain/video_player_interface.dart';
import '../../../core/constants/app_colors.dart';

/// Chewie video player implementation
///
/// This wraps the video_player package with Chewie for enhanced UI controls.
/// Chewie is the default player - simple, reliable, and well-tested.
class ChewiePlayerImpl implements IVideoPlayer {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

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

  Timer? _positionTimer;
  bool _isInitialized = false;
  bool _isFullscreen = false;
  double _playbackSpeed = 1.0;

  @override
  String get playerType => 'chewie';

  @override
  Future<void> initialize(String videoUrl, {Duration? startPosition}) async {
    try {
      _stateController.add(PlayerPlaybackState.loading);

      // Initialize video player controller
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );

      // Add listener for player state changes
      _videoController!.addListener(_onPlayerPlaybackStateChanged);

      // Initialize the controller
      await _videoController!.initialize();

      // Set initial playback speed
      await _videoController!.setPlaybackSpeed(_playbackSpeed);

      // Seek to start position if provided
      if (startPosition != null && startPosition.inSeconds > 0) {
        await _videoController!.seekTo(startPosition);
      }

      // Initialize Chewie controller with custom configuration
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.emerald500,
          handleColor: AppColors.emerald500,
          backgroundColor: Colors.grey[700]!,
          bufferedColor: Colors.grey[600]!,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.emerald500,
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      _isInitialized = true;
      _stateController.add(PlayerPlaybackState.ready);
      _durationController.add(_videoController!.value.duration);

      // Start position tracking timer
      _startPositionTimer();
    } catch (e) {
      _stateController.add(PlayerPlaybackState.error);
      _errorController.add('خطأ في تحميل الفيديو: ${e.toString()}');
      rethrow;
    }
  }

  void _onPlayerPlaybackStateChanged() {
    if (_videoController == null) return;

    final value = _videoController!.value;

    // Handle buffering
    if (value.isBuffering) {
      _stateController.add(PlayerPlaybackState.buffering);
      _bufferingController.add(true);
    } else {
      _bufferingController.add(false);
      if (value.isPlaying) {
        _stateController.add(PlayerPlaybackState.playing);
      } else if (value.position >= value.duration && value.duration.inSeconds > 0) {
        _stateController.add(PlayerPlaybackState.completed);
      } else {
        _stateController.add(PlayerPlaybackState.paused);
      }
    }

    // Handle errors
    if (value.hasError) {
      _stateController.add(PlayerPlaybackState.error);
      _errorController.add(value.errorDescription ?? 'خطأ غير معروف');
    }
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_videoController != null && _videoController!.value.isPlaying) {
        _positionController.add(_videoController!.value.position);
      }
    });
  }

  @override
  Future<void> play() async {
    if (_videoController != null && _isInitialized) {
      await _videoController!.play();
      _stateController.add(PlayerPlaybackState.playing);
    }
  }

  @override
  Future<void> pause() async {
    if (_videoController != null && _isInitialized) {
      await _videoController!.pause();
      _stateController.add(PlayerPlaybackState.paused);
    }
  }

  @override
  Future<void> seekTo(Duration position) async {
    if (_videoController != null && _isInitialized) {
      await _videoController!.seekTo(position);
      _positionController.add(position);
    }
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    if (_videoController != null && _isInitialized) {
      _playbackSpeed = speed;
      await _videoController!.setPlaybackSpeed(speed);
    }
  }

  @override
  Future<void> setQuality(String quality) async {
    // Quality switching not supported in basic Chewie implementation
    // Would need HLS manifest parsing or backend support for multiple URLs
  }

  @override
  Future<void> setFullscreen(bool fullscreen) async {
    _isFullscreen = fullscreen;
    // Fullscreen handling is typically done at the page level with SystemChrome
  }

  @override
  Future<void> dispose() async {
    _positionTimer?.cancel();
    _chewieController?.dispose();
    await _videoController?.dispose();
    await _stateController.close();
    await _positionController.close();
    await _durationController.close();
    await _bufferingController.close();
    await _errorController.close();
  }

  @override
  Duration get currentPosition =>
      _videoController?.value.position ?? Duration.zero;

  @override
  Duration get duration => _videoController?.value.duration ?? Duration.zero;

  @override
  bool get isPlaying => _videoController?.value.isPlaying ?? false;

  @override
  bool get isBuffering => _videoController?.value.isBuffering ?? false;

  @override
  bool get isFullscreen => _isFullscreen;

  @override
  double get playbackSpeed => _playbackSpeed;

  @override
  String? get currentQuality => null; // Not supported

  @override
  List<String> get availableQualities => []; // Not supported

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
    if (_chewieController == null || !_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.emerald500),
        ),
      );
    }

    return Chewie(controller: _chewieController!);
  }
}
