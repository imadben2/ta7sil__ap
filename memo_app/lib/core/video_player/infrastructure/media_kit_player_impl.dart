import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../domain/video_player_interface.dart';
import '../../../core/constants/app_colors.dart';

/// Media Kit video player implementation
///
/// This provides:
/// - Hardware-accelerated rendering
/// - Excellent performance for HD/FHD videos
/// - Superior cross-platform support
/// - Advanced codec support
/// - Best for live streaming and high-quality content
class MediaKitPlayerImpl implements IVideoPlayer {
  Player? _player;
  VideoController? _videoController;

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

  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _bufferingSubscription;
  StreamSubscription? _playingSubscription;
  StreamSubscription? _completedSubscription;
  StreamSubscription? _errorSubscription;

  bool _isInitialized = false;
  bool _isFullscreen = false;
  double _playbackSpeed = 1.0;

  @override
  String get playerType => 'media_kit';

  @override
  Future<void> initialize(String videoUrl, {Duration? startPosition}) async {
    try {
      _stateController.add(PlayerPlaybackState.loading);

      // Create Media Kit player
      _player = Player();

      // Create video controller for rendering
      _videoController = VideoController(_player!);

      // Subscribe to player streams
      _subscribeToPlayerStreams();

      // Open the media source
      await _player!.open(Media(videoUrl));

      // Set initial playback speed
      if (_playbackSpeed != 1.0) {
        await _player!.setRate(_playbackSpeed);
      }

      // Seek to start position if provided
      if (startPosition != null && startPosition.inSeconds > 0) {
        await _player!.seek(startPosition);
      }

      _isInitialized = true;
      _stateController.add(PlayerPlaybackState.ready);
    } catch (e) {
      _stateController.add(PlayerPlaybackState.error);
      _errorController.add('خطأ في تحميل الفيديو: ${e.toString()}');
      rethrow;
    }
  }

  void _subscribeToPlayerStreams() {
    if (_player == null) return;

    // Position stream
    _positionSubscription = _player!.stream.position.listen((position) {
      _positionController.add(position);
    });

    // Duration stream
    _durationSubscription = _player!.stream.duration.listen((duration) {
      _durationController.add(duration);
    });

    // Buffering stream
    _bufferingSubscription = _player!.stream.buffering.listen((buffering) {
      _bufferingController.add(buffering);
      if (buffering) {
        _stateController.add(PlayerPlaybackState.buffering);
      } else if (_player!.state.playing) {
        _stateController.add(PlayerPlaybackState.playing);
      } else {
        _stateController.add(PlayerPlaybackState.paused);
      }
    });

    // Playing state stream
    _playingSubscription = _player!.stream.playing.listen((playing) {
      if (playing) {
        _stateController.add(PlayerPlaybackState.playing);
      } else {
        _stateController.add(PlayerPlaybackState.paused);
      }
    });

    // Completed stream
    _completedSubscription = _player!.stream.completed.listen((completed) {
      if (completed) {
        _stateController.add(PlayerPlaybackState.completed);
      }
    });

    // Error stream
    _errorSubscription = _player!.stream.error.listen((error) {
      _stateController.add(PlayerPlaybackState.error);
      _errorController.add('خطأ: $error');
    });
  }

  @override
  Future<void> play() async {
    if (_player != null && _isInitialized) {
      await _player!.play();
      _stateController.add(PlayerPlaybackState.playing);
    }
  }

  @override
  Future<void> pause() async {
    if (_player != null && _isInitialized) {
      await _player!.pause();
      _stateController.add(PlayerPlaybackState.paused);
    }
  }

  @override
  Future<void> seekTo(Duration position) async {
    if (_player != null && _isInitialized) {
      await _player!.seek(position);
      _positionController.add(position);
    }
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    if (_player != null && _isInitialized) {
      _playbackSpeed = speed;
      await _player!.setRate(speed);
    }
  }

  @override
  Future<void> setQuality(String quality) async {
    // Quality switching would require reopening with different URL
    // Not directly supported without backend providing multiple quality URLs
  }

  @override
  Future<void> setFullscreen(bool fullscreen) async {
    _isFullscreen = fullscreen;
    // Fullscreen handling is typically done at the page level
  }

  @override
  Future<void> dispose() async {
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _bufferingSubscription?.cancel();
    await _playingSubscription?.cancel();
    await _completedSubscription?.cancel();
    await _errorSubscription?.cancel();

    await _player?.dispose();
    await _stateController.close();
    await _positionController.close();
    await _durationController.close();
    await _bufferingController.close();
    await _errorController.close();
  }

  @override
  Duration get currentPosition => _player?.state.position ?? Duration.zero;

  @override
  Duration get duration => _player?.state.duration ?? Duration.zero;

  @override
  bool get isPlaying => _player?.state.playing ?? false;

  @override
  bool get isBuffering => _player?.state.buffering ?? false;

  @override
  bool get isFullscreen => _isFullscreen;

  @override
  double get playbackSpeed => _playbackSpeed;

  @override
  String? get currentQuality => null; // Not directly supported

  @override
  List<String> get availableQualities => []; // Not directly supported

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
    if (_videoController == null || !_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.emerald500),
        ),
      );
    }

    return Video(
      controller: _videoController!,
      controls: showControls ? MaterialVideoControls : NoVideoControls,
    );
  }
}
