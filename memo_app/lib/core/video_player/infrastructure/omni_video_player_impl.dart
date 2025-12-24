import 'dart:async';
import 'package:flutter/material.dart';
import 'package:omni_video_player/omni_video_player.dart';
import '../domain/video_player_interface.dart';
import '../../../core/constants/app_colors.dart';

/// Omni Video Player implementation
///
/// This provides:
/// - YouTube video support
/// - Vimeo video support
/// - Network video support
/// - Custom controls with quality selection
class OmniVideoPlayerImpl implements IVideoPlayer {
  OmniPlaybackController? _controller;
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
  Timer? _positionTimer;
  Duration? _startPosition;

  // Track if streams are closed
  bool _isDisposed = false;

  @override
  String get playerType => 'omni';

  @override
  Future<void> initialize(String videoUrl, {Duration? startPosition}) async {
    try {
      _stateController.add(PlayerPlaybackState.loading);
      _videoUrl = videoUrl;
      _startPosition = startPosition;
      _isInitialized = true;
      _stateController.add(PlayerPlaybackState.ready);
    } catch (e) {
      _stateController.add(PlayerPlaybackState.error);
      _errorController.add('خطأ في تحميل الفيديو: ${e.toString()}');
      rethrow;
    }
  }

  /// Controller update handler
  /// Uses addPostFrameCallback for safe UI updates
  void _onControllerUpdate() {
    if (_isDisposed) return;

    // Schedule the update after the current build frame completes
    // This prevents "setState() called during build" errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed || _controller == null) return;

      // Update state based on controller state
      if (_controller!.hasError) {
        _stateController.add(PlayerPlaybackState.error);
        _errorController.add('خطأ في تشغيل الفيديو');
      }
    });
  }

  void _startPositionUpdates() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_isDisposed || _controller == null) return;

      try {
        _positionController.add(_controller!.currentPosition);
        _durationController.add(_controller!.duration);
        _bufferingController.add(_controller!.isBuffering);

        if (_controller!.isPlaying) {
          _stateController.add(PlayerPlaybackState.playing);
        } else if (_controller!.isBuffering) {
          _stateController.add(PlayerPlaybackState.buffering);
        } else if (_controller!.isFinished) {
          _stateController.add(PlayerPlaybackState.completed);
        } else if (_controller!.hasError) {
          _stateController.add(PlayerPlaybackState.error);
        }
      } catch (e) {
        debugPrint('⚠️ Omni position update error: $e');
      }
    });
  }

  @override
  Future<void> play() async {
    _controller?.play();
  }

  @override
  Future<void> pause() async {
    _controller?.pause();
  }

  @override
  Future<void> seekTo(Duration position) async {
    _controller?.seekTo(position);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    if (_controller != null) {
      _controller!.playbackSpeed = speed;
    }
  }

  @override
  Future<void> setQuality(String quality) async {
    // Omni player handles quality through preferredQualities in configuration
  }

  @override
  Future<void> setFullscreen(bool fullscreen) async {
    _isFullscreen = fullscreen;
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    _positionTimer?.cancel();
    _positionTimer = null;
    _controller?.removeListener(_onControllerUpdate);
    _controller = null;

    await _stateController.close();
    await _positionController.close();
    await _durationController.close();
    await _bufferingController.close();
    await _errorController.close();
  }

  @override
  Duration get currentPosition => _controller?.currentPosition ?? Duration.zero;

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
  String? get currentQuality => _controller?.currentVideoQuality?.name;

  @override
  List<String> get availableQualities =>
      _controller?.availableVideoQualities?.map((q) => q.name).toList() ?? [];

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

  /// Detect video source type from URL and create configuration
  /// Based on omni_video_player official example
  VideoSourceConfiguration _getSourceConfiguration(String url) {
    final uri = Uri.parse(url);
    final host = uri.host.toLowerCase();

    if (host.contains('youtube.com') || host.contains('youtu.be')) {
      // YouTube configuration based on official example
      return VideoSourceConfiguration.youtube(
        videoUrl: uri,
        preferredQualities: [
          OmniVideoQuality.high720,
          OmniVideoQuality.low144,
        ],
        availableQualities: [
          OmniVideoQuality.high1080,
          OmniVideoQuality.high720,
          OmniVideoQuality.medium480,
          OmniVideoQuality.medium360,
          OmniVideoQuality.low144,
        ],
        // Enable WebView fallback for when youtube_explode_dart fails
        enableYoutubeWebViewFallback: true,
        // Don't force WebView only - let it try youtube_explode_dart first
        forceYoutubeWebViewOnly: false,
      ).copyWith(
        autoPlay: false,
        initialPosition: _startPosition ?? Duration.zero,
        initialVolume: 1.0,
        initialPlaybackSpeed: 1.0,
        availablePlaybackSpeed: [0.5, 1.0, 1.25, 1.5, 2.0],
        autoMuteOnStart: false,
        allowSeeking: true,
        synchronizeMuteAcrossPlayers: true,
        timeoutDuration: const Duration(seconds: 30),
      );
    } else if (host.contains('vimeo.com')) {
      // Extract video ID from Vimeo URL
      final pathSegments = uri.pathSegments;
      final videoId = pathSegments.isNotEmpty ? pathSegments.last : '';
      return VideoSourceConfiguration.vimeo(
        videoId: videoId,
        preferredQualities: [
          OmniVideoQuality.high720,
          OmniVideoQuality.medium480,
        ],
      ).copyWith(
        autoPlay: false,
        initialPosition: _startPosition ?? Duration.zero,
        initialVolume: 1.0,
        initialPlaybackSpeed: 1.0,
        timeoutDuration: const Duration(seconds: 30),
      );
    } else {
      return VideoSourceConfiguration.network(
        videoUrl: uri,
        preferredQualities: [
          OmniVideoQuality.high720,
          OmniVideoQuality.medium480,
        ],
      ).copyWith(
        autoPlay: false,
        initialPosition: _startPosition ?? Duration.zero,
        initialVolume: 1.0,
        initialPlaybackSpeed: 1.0,
        timeoutDuration: const Duration(seconds: 30),
      );
    }
  }

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

    return OmniVideoPlayer(
      key: ValueKey('omni_player_${_videoUrl.hashCode}'),
      // Callbacks - following the official example pattern
      callbacks: VideoPlayerCallbacks(
        onControllerCreated: (controller) {
          _controller?.removeListener(_onControllerUpdate);
          _controller = controller..addListener(_onControllerUpdate);
          _startPositionUpdates();
        },
        onFullScreenToggled: (isFullScreen) {
          _isFullscreen = isFullScreen;
        },
        onOverlayControlsVisibilityChanged: (areVisible) {},
        onCenterControlsVisibilityChanged: (areVisible) {},
        onMuteToggled: (isMute) {},
        onSeekStart: (pos) {},
        onSeekEnd: (pos) {},
        onSeekRequest: (target) => true,
        onFinished: () {
          _stateController.add(PlayerPlaybackState.completed);
        },
        onReplay: () {
          _controller?.seekTo(Duration.zero);
          _controller?.play();
        },
      ),
      // Full configuration following official example
      configuration: VideoPlayerConfiguration(
        videoSourceConfiguration: _getSourceConfiguration(_videoUrl!),
        playerTheme: OmniVideoPlayerThemeData().copyWith(
          icons: VideoPlayerIconTheme().copyWith(
            error: Icons.warning,
            playbackSpeedButton: Icons.speed,
          ),
          overlays: VideoPlayerOverlayTheme().copyWith(
            backgroundColor: Colors.white,
            alpha: 25,
          ),
        ),
        playerUIVisibilityOptions: PlayerUIVisibilityOptions().copyWith(
          showSeekBar: showControls,
          showCurrentTime: showControls,
          showDurationTime: showControls,
          showRemainingTime: true,
          showLiveIndicator: true,
          showLoadingWidget: true,
          showErrorPlaceholder: true,
          showReplayButton: true,
          showThumbnailAtStart: true,
          showVideoBottomControlsBar: showControls,
          showBottomControlsBarOnEndedFullscreen: true,
          showFullScreenButton: showControls,
          showSwitchVideoQuality: showControls,
          showSwitchWhenOnlyAuto: true,
          showPlaybackSpeedButton: showControls,
          showMuteUnMuteButton: showControls,
          showPlayPauseReplayButton: showControls,
          useSafeAreaForBottomControls: true,
          showGradientBottomControl: true,
          enableForwardGesture: true,
          enableBackwardGesture: true,
          enableExitFullscreenOnVerticalSwipe: true,
          enableOrientationLock: true,
          controlsPersistenceDuration: const Duration(seconds: 3),
          customAspectRatioNormal: null,
          customAspectRatioFullScreen: null,
          fullscreenOrientation: null,
          showBottomControlsBarOnPause: false,
          alwaysShowBottomControlsBar: false,
          fitVideoToBounds: true,
        ),
        customPlayerWidgets: CustomPlayerWidgets().copyWith(
          loadingWidget: const CircularProgressIndicator(color: AppColors.emerald500),
          errorPlaceholder: null,
          bottomControlsBar: null,
          leadingBottomButtons: null,
          trailingBottomButtons: null,
          customSeekBar: null,
          customDurationDisplay: null,
          customRemainingTimeDisplay: null,
          thumbnail: null,
          thumbnailFit: null,
          customOverlayLayers: null,
          fullscreenWrapper: null,
        ),
        liveLabel: "LIVE",
        enableBackgroundOverlayClip: true,
      ),
    );
  }
}
