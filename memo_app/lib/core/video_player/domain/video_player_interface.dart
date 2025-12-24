import 'dart:async';
import 'package:flutter/material.dart';

/// Video player playback state (renamed to avoid collision with bloc state)
enum PlayerPlaybackState {
  idle,
  loading,
  ready,
  playing,
  paused,
  buffering,
  completed,
  error,
}

/// Abstract interface for video players
///
/// This interface defines the contract that all video player implementations
/// must follow. It allows seamless switching between different players
/// (Chewie, Better Player, Media Kit) while maintaining consistent behavior.
abstract class IVideoPlayer {
  /// Initialize the video player with a video URL
  ///
  /// [videoUrl] - The URL of the video to play (HLS, MP4, etc.)
  /// [startPosition] - Optional position to start playback from
  Future<void> initialize(String videoUrl, {Duration? startPosition});

  /// Dispose and clean up all resources
  Future<void> dispose();

  /// Start or resume playback
  Future<void> play();

  /// Pause playback
  Future<void> pause();

  /// Seek to a specific position in the video
  ///
  /// [position] - The target position
  Future<void> seekTo(Duration position);

  /// Set playback speed
  ///
  /// [speed] - Playback speed (0.5 = half speed, 2.0 = double speed, etc.)
  Future<void> setPlaybackSpeed(double speed);

  /// Set video quality (if supported by the player)
  ///
  /// [quality] - Quality identifier (e.g., "360p", "720p", "1080p")
  Future<void> setQuality(String quality);

  /// Enable/disable fullscreen mode
  ///
  /// [fullscreen] - True to enter fullscreen, false to exit
  Future<void> setFullscreen(bool fullscreen);

  // ============ Getters ============

  /// Get current playback position
  Duration get currentPosition;

  /// Get total video duration
  Duration get duration;

  /// Check if video is currently playing
  bool get isPlaying;

  /// Check if video is currently buffering
  bool get isBuffering;

  /// Check if player is in fullscreen mode
  bool get isFullscreen;

  /// Get current playback speed
  double get playbackSpeed;

  /// Get current video quality (if available)
  String? get currentQuality;

  /// Get list of available qualities (if supported)
  List<String> get availableQualities;

  /// Check if player is initialized and ready
  bool get isInitialized;

  // ============ Streams ============

  /// Stream of player state changes
  Stream<PlayerPlaybackState> get stateStream;

  /// Stream of position updates (fires periodically during playback)
  Stream<Duration> get positionStream;

  /// Stream of duration updates
  Stream<Duration> get durationStream;

  /// Stream of buffering state
  Stream<bool> get bufferingStream;

  /// Stream of errors
  Stream<String> get errorStream;

  // ============ UI ============

  /// Build the player widget
  ///
  /// This returns the actual video player widget that can be embedded
  /// in the UI. Each implementation provides its own player UI.
  ///
  /// [context] - Build context
  /// [showControls] - Whether to show player controls (default: true)
  Widget buildPlayer(BuildContext context, {bool showControls = true});

  /// Get player type identifier
  String get playerType;
}
