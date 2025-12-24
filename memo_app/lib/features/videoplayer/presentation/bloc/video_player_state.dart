import 'package:equatable/equatable.dart';
import '../../../../core/video_player/domain/video_player_interface.dart';
import '../../domain/entities/video_config.dart';

/// Base class for all video player states
abstract class VideoPlayerState extends Equatable {
  const VideoPlayerState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any video is loaded
class VideoPlayerInitial extends VideoPlayerState {
  const VideoPlayerInitial();
}

/// Video is loading/initializing
class VideoPlayerLoading extends VideoPlayerState {
  final VideoConfig config;

  const VideoPlayerLoading(this.config);

  @override
  List<Object?> get props => [config];
}

/// Video is ready and can be played
class VideoPlayerReady extends VideoPlayerState {
  /// The underlying video player instance
  final IVideoPlayer player;

  /// Current video configuration
  final VideoConfig config;

  /// Current playback position
  final Duration position;

  /// Total video duration
  final Duration duration;

  /// Whether video is currently playing
  final bool isPlaying;

  /// Whether video is currently buffering
  final bool isBuffering;

  /// Whether video is in fullscreen mode
  final bool isFullscreen;

  /// Current playback speed
  final double playbackSpeed;

  /// Current video quality (if available)
  final String? currentQuality;

  /// Available quality options
  final List<String> availableQualities;

  /// Whether a fallback player was used (for YouTube URLs)
  final bool didFallback;

  /// The actual player type being used
  final String effectivePlayerType;

  const VideoPlayerReady({
    required this.player,
    required this.config,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isBuffering = false,
    this.isFullscreen = false,
    this.playbackSpeed = 1.0,
    this.currentQuality,
    this.availableQualities = const [],
    this.didFallback = false,
    required this.effectivePlayerType,
  });

  /// Get progress as a value between 0.0 and 1.0
  double get progress {
    if (duration.inSeconds == 0) return 0.0;
    return position.inSeconds / duration.inSeconds;
  }

  /// Get progress as a percentage (0-100)
  int get progressPercent => (progress * 100).toInt();

  /// Check if video has completed
  bool get isCompleted => progress >= 0.99;

  VideoPlayerReady copyWith({
    IVideoPlayer? player,
    VideoConfig? config,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isBuffering,
    bool? isFullscreen,
    double? playbackSpeed,
    String? currentQuality,
    List<String>? availableQualities,
    bool? didFallback,
    String? effectivePlayerType,
  }) {
    return VideoPlayerReady(
      player: player ?? this.player,
      config: config ?? this.config,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      currentQuality: currentQuality ?? this.currentQuality,
      availableQualities: availableQualities ?? this.availableQualities,
      didFallback: didFallback ?? this.didFallback,
      effectivePlayerType: effectivePlayerType ?? this.effectivePlayerType,
    );
  }

  @override
  List<Object?> get props => [
        player,
        config,
        position,
        duration,
        isPlaying,
        isBuffering,
        isFullscreen,
        playbackSpeed,
        currentQuality,
        availableQualities,
        didFallback,
        effectivePlayerType,
      ];
}

/// Video playback completed
class VideoPlayerCompleted extends VideoPlayerState {
  final VideoConfig config;

  const VideoPlayerCompleted(this.config);

  @override
  List<Object?> get props => [config];
}

/// Error state with message
class VideoPlayerError extends VideoPlayerState {
  final String message;
  final VideoConfig? config;
  final bool canRetry;
  final String? errorDetails;

  const VideoPlayerError({
    required this.message,
    this.config,
    this.canRetry = true,
    this.errorDetails,
  });

  /// Check if error is network related
  bool get isNetworkError =>
      errorDetails?.contains('SocketException') == true ||
      errorDetails?.contains('Failed host lookup') == true ||
      errorDetails?.contains('noembed.com') == true;

  /// Check if error suggests trying another player
  bool get shouldTryAnotherPlayer =>
      isNetworkError ||
      errorDetails?.contains('Null check operator') == true ||
      errorDetails?.contains('TimeoutException') == true;

  @override
  List<Object?> get props => [message, config, canRetry, errorDetails];
}
