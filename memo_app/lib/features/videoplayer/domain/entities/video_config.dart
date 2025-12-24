import 'package:equatable/equatable.dart';

/// Configuration for video player
///
/// This class holds all configuration options for the video player widget.
/// Use factory constructors for common configurations.
class VideoConfig extends Equatable {
  /// The URL of the video to play
  final String videoUrl;

  /// Preferred video player type
  /// Options: 'chewie', 'media_kit', 'simple_youtube', 'omni', 'orax'
  final String preferredPlayer;

  /// Whether to show player controls
  final bool showControls;

  /// Whether to auto-play the video
  final bool autoPlay;

  /// Start position for the video
  final Duration? startPosition;

  /// Accent color for controls and UI elements
  final int? accentColorValue;

  /// Whether to show the player type badge
  final bool showPlayerBadge;

  /// Auto-save progress interval in seconds (0 to disable)
  final int autoSaveIntervalSeconds;

  const VideoConfig({
    required this.videoUrl,
    this.preferredPlayer = 'simple_youtube',
    this.showControls = true,
    this.autoPlay = false,
    this.startPosition,
    this.accentColorValue,
    this.showPlayerBadge = true,
    this.autoSaveIntervalSeconds = 30,
  });

  /// Create configuration for content library videos
  factory VideoConfig.contentLibrary({
    required String videoUrl,
    String preferredPlayer = 'simple_youtube',
    int? accentColorValue,
    Duration? startPosition,
  }) {
    return VideoConfig(
      videoUrl: videoUrl,
      preferredPlayer: preferredPlayer,
      showControls: true,
      autoPlay: false,
      startPosition: startPosition,
      accentColorValue: accentColorValue,
      showPlayerBadge: true,
      autoSaveIntervalSeconds: 30,
    );
  }

  /// Create configuration for course videos
  factory VideoConfig.course({
    required String videoUrl,
    String preferredPlayer = 'simple_youtube',
    int? accentColorValue,
    Duration? startPosition,
  }) {
    return VideoConfig(
      videoUrl: videoUrl,
      preferredPlayer: preferredPlayer,
      showControls: true,
      autoPlay: false,
      startPosition: startPosition,
      accentColorValue: accentColorValue,
      showPlayerBadge: true,
      autoSaveIntervalSeconds: 30,
    );
  }

  /// Create minimal configuration (no badge, no auto-save)
  factory VideoConfig.minimal({
    required String videoUrl,
    String preferredPlayer = 'simple_youtube',
  }) {
    return VideoConfig(
      videoUrl: videoUrl,
      preferredPlayer: preferredPlayer,
      showControls: true,
      autoPlay: false,
      showPlayerBadge: false,
      autoSaveIntervalSeconds: 0,
    );
  }

  /// Check if video URL is a YouTube URL
  bool get isYouTubeUrl =>
      videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be');

  /// Check if video URL is a Vimeo URL
  bool get isVimeoUrl => videoUrl.contains('vimeo.com');

  /// Get list of YouTube-compatible players
  static List<String> get youtubeCompatiblePlayers =>
      ['simple_youtube', 'omni', 'orax', 'orax_video_player'];

  /// Check if preferred player supports YouTube
  bool get isPreferredPlayerYoutubeCompatible =>
      youtubeCompatiblePlayers.contains(preferredPlayer.toLowerCase());

  /// Get the actual player type to use (with fallback logic)
  String get effectivePlayerType {
    if (isYouTubeUrl && !isPreferredPlayerYoutubeCompatible) {
      return 'simple_youtube';
    }
    return preferredPlayer;
  }

  /// Check if fallback was applied
  bool get didFallbackToYoutubePlayer =>
      isYouTubeUrl && !isPreferredPlayerYoutubeCompatible;

  VideoConfig copyWith({
    String? videoUrl,
    String? preferredPlayer,
    bool? showControls,
    bool? autoPlay,
    Duration? startPosition,
    int? accentColorValue,
    bool? showPlayerBadge,
    int? autoSaveIntervalSeconds,
  }) {
    return VideoConfig(
      videoUrl: videoUrl ?? this.videoUrl,
      preferredPlayer: preferredPlayer ?? this.preferredPlayer,
      showControls: showControls ?? this.showControls,
      autoPlay: autoPlay ?? this.autoPlay,
      startPosition: startPosition ?? this.startPosition,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      showPlayerBadge: showPlayerBadge ?? this.showPlayerBadge,
      autoSaveIntervalSeconds: autoSaveIntervalSeconds ?? this.autoSaveIntervalSeconds,
    );
  }

  @override
  List<Object?> get props => [
        videoUrl,
        preferredPlayer,
        showControls,
        autoPlay,
        startPosition,
        accentColorValue,
        showPlayerBadge,
        autoSaveIntervalSeconds,
      ];
}
