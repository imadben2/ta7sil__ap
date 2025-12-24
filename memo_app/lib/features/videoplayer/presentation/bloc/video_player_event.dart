import 'package:equatable/equatable.dart';
import '../../domain/entities/video_config.dart';

/// Base class for all video player events
abstract class VideoPlayerEvent extends Equatable {
  const VideoPlayerEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize video player with configuration
class InitializeVideo extends VideoPlayerEvent {
  final VideoConfig config;

  const InitializeVideo(this.config);

  @override
  List<Object?> get props => [config];
}

/// Start or resume video playback
class PlayVideo extends VideoPlayerEvent {
  const PlayVideo();
}

/// Pause video playback
class PauseVideo extends VideoPlayerEvent {
  const PauseVideo();
}

/// Toggle play/pause state
class TogglePlayPause extends VideoPlayerEvent {
  const TogglePlayPause();
}

/// Seek to a specific position
class SeekTo extends VideoPlayerEvent {
  final Duration position;

  const SeekTo(this.position);

  @override
  List<Object?> get props => [position];
}

/// Seek forward by specified duration
class SeekForward extends VideoPlayerEvent {
  final Duration duration;

  const SeekForward({this.duration = const Duration(seconds: 10)});

  @override
  List<Object?> get props => [duration];
}

/// Seek backward by specified duration
class SeekBackward extends VideoPlayerEvent {
  final Duration duration;

  const SeekBackward({this.duration = const Duration(seconds: 10)});

  @override
  List<Object?> get props => [duration];
}

/// Set playback speed
class SetPlaybackSpeed extends VideoPlayerEvent {
  final double speed;

  const SetPlaybackSpeed(this.speed);

  @override
  List<Object?> get props => [speed];
}

/// Set video quality
class SetVideoQuality extends VideoPlayerEvent {
  final String quality;

  const SetVideoQuality(this.quality);

  @override
  List<Object?> get props => [quality];
}

/// Toggle fullscreen mode
class ToggleFullscreen extends VideoPlayerEvent {
  const ToggleFullscreen();
}

/// Internal event: Update position from stream
class UpdatePosition extends VideoPlayerEvent {
  final Duration position;
  final Duration duration;

  const UpdatePosition({required this.position, required this.duration});

  @override
  List<Object?> get props => [position, duration];
}

/// Internal event: Update buffering state
class UpdateBuffering extends VideoPlayerEvent {
  final bool isBuffering;

  const UpdateBuffering(this.isBuffering);

  @override
  List<Object?> get props => [isBuffering];
}

/// Internal event: Report error
class ReportError extends VideoPlayerEvent {
  final String message;

  const ReportError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Retry loading video after error
class RetryLoad extends VideoPlayerEvent {
  const RetryLoad();
}

/// Video completed playing
class VideoCompleted extends VideoPlayerEvent {
  const VideoCompleted();
}

/// Dispose video player and clean up resources
class DisposePlayer extends VideoPlayerEvent {
  const DisposePlayer();
}

/// Change video source (for playlist support)
class ChangeVideoSource extends VideoPlayerEvent {
  final VideoConfig newConfig;

  const ChangeVideoSource(this.newConfig);

  @override
  List<Object?> get props => [newConfig];
}
