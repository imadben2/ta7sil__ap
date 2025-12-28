/// Video player settings from server
/// Configures which players are enabled and what video types they support
class VideoPlayerSettings {
  /// Whether chewie player is enabled
  final bool chewieEnabled;

  /// Whether media_kit player is enabled
  final bool mediaKitEnabled;

  /// Whether simple_youtube player is enabled
  final bool simpleYoutubeEnabled;

  /// Whether omni player is enabled
  final bool omniEnabled;

  /// Whether orax player is enabled
  final bool oraxEnabled;

  /// Default player for uploaded videos
  final String defaultUploadPlayer;

  /// Default player for YouTube videos
  final String defaultYoutubePlayer;

  /// What chewie player supports: 'youtube', 'upload', 'both'
  final String chewieSupports;

  /// What media_kit player supports: 'youtube', 'upload', 'both'
  final String mediaKitSupports;

  /// What simple_youtube player supports: 'youtube', 'upload', 'both'
  final String simpleYoutubeSupports;

  /// What omni player supports: 'youtube', 'upload', 'both'
  final String omniSupports;

  /// What orax player supports: 'youtube', 'upload', 'both'
  final String oraxSupports;

  const VideoPlayerSettings({
    this.chewieEnabled = true,
    this.mediaKitEnabled = false,
    this.simpleYoutubeEnabled = true,
    this.omniEnabled = false,
    this.oraxEnabled = false,
    this.defaultUploadPlayer = 'chewie',
    this.defaultYoutubePlayer = 'simple_youtube',
    this.chewieSupports = 'upload',
    this.mediaKitSupports = 'upload',
    this.simpleYoutubeSupports = 'youtube',
    this.omniSupports = 'both',
    this.oraxSupports = 'both',
  });

  /// Create from JSON (API response)
  factory VideoPlayerSettings.fromJson(Map<String, dynamic> json) {
    return VideoPlayerSettings(
      chewieEnabled: json['chewie_enabled'] as bool? ?? true,
      mediaKitEnabled: json['media_kit_enabled'] as bool? ?? false,
      simpleYoutubeEnabled: json['simple_youtube_enabled'] as bool? ?? true,
      omniEnabled: json['omni_enabled'] as bool? ?? false,
      oraxEnabled: json['orax_enabled'] as bool? ?? false,
      defaultUploadPlayer: json['default_upload_player'] as String? ?? 'chewie',
      defaultYoutubePlayer: json['default_youtube_player'] as String? ?? 'simple_youtube',
      chewieSupports: json['chewie_supports'] as String? ?? 'upload',
      mediaKitSupports: json['media_kit_supports'] as String? ?? 'upload',
      simpleYoutubeSupports: json['simple_youtube_supports'] as String? ?? 'youtube',
      omniSupports: json['omni_supports'] as String? ?? 'both',
      oraxSupports: json['orax_supports'] as String? ?? 'both',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'chewie_enabled': chewieEnabled,
      'media_kit_enabled': mediaKitEnabled,
      'simple_youtube_enabled': simpleYoutubeEnabled,
      'omni_enabled': omniEnabled,
      'orax_enabled': oraxEnabled,
      'default_upload_player': defaultUploadPlayer,
      'default_youtube_player': defaultYoutubePlayer,
      'chewie_supports': chewieSupports,
      'media_kit_supports': mediaKitSupports,
      'simple_youtube_supports': simpleYoutubeSupports,
      'omni_supports': omniSupports,
      'orax_supports': oraxSupports,
    };
  }

  /// Default settings (hardcoded fallback)
  static const VideoPlayerSettings defaults = VideoPlayerSettings();

  /// Check if a player is enabled
  bool isPlayerEnabled(String playerType) {
    switch (playerType.toLowerCase()) {
      case 'chewie':
        return chewieEnabled;
      case 'media_kit':
        return mediaKitEnabled;
      case 'simple_youtube':
        return simpleYoutubeEnabled;
      case 'omni':
        return omniEnabled;
      case 'orax':
      case 'orax_video_player':
        return oraxEnabled;
      default:
        return false;
    }
  }

  /// Get what video types a player supports: 'youtube', 'upload', or 'both'
  String getPlayerSupports(String playerType) {
    switch (playerType.toLowerCase()) {
      case 'chewie':
        return chewieSupports;
      case 'media_kit':
        return mediaKitSupports;
      case 'simple_youtube':
        return simpleYoutubeSupports;
      case 'omni':
        return omniSupports;
      case 'orax':
      case 'orax_video_player':
        return oraxSupports;
      default:
        return 'both';
    }
  }

  /// Check if a player supports a specific video type
  bool playerSupportsVideoType(String playerType, String videoType) {
    final supports = getPlayerSupports(playerType);
    if (supports == 'both') return true;
    return supports == videoType;
  }

  /// Get list of enabled players that support a video type
  List<String> getEnabledPlayersForVideoType(String videoType) {
    final allPlayers = ['chewie', 'media_kit', 'simple_youtube', 'omni', 'orax'];
    return allPlayers.where((player) {
      return isPlayerEnabled(player) && playerSupportsVideoType(player, videoType);
    }).toList();
  }

  /// Get the default player for a specific video type
  String getDefaultPlayerForVideoType(String videoType) {
    if (videoType == 'youtube') {
      // Check if default youtube player is enabled and supports youtube
      if (isPlayerEnabled(defaultYoutubePlayer) &&
          playerSupportsVideoType(defaultYoutubePlayer, 'youtube')) {
        return defaultYoutubePlayer;
      }
      // Fallback to first enabled player that supports youtube
      final youtubeePlayers = getEnabledPlayersForVideoType('youtube');
      return youtubeePlayers.isNotEmpty ? youtubeePlayers.first : 'simple_youtube';
    } else {
      // For uploaded videos
      if (isPlayerEnabled(defaultUploadPlayer) &&
          playerSupportsVideoType(defaultUploadPlayer, 'upload')) {
        return defaultUploadPlayer;
      }
      // Fallback to first enabled player that supports upload
      final uploadPlayers = getEnabledPlayersForVideoType('upload');
      return uploadPlayers.isNotEmpty ? uploadPlayers.first : 'chewie';
    }
  }

  @override
  String toString() {
    return 'VideoPlayerSettings('
        'defaultUploadPlayer: $defaultUploadPlayer, '
        'defaultYoutubePlayer: $defaultYoutubePlayer, '
        'chewie: $chewieEnabled/$chewieSupports, '
        'mediaKit: $mediaKitEnabled/$mediaKitSupports, '
        'simpleYoutube: $simpleYoutubeEnabled/$simpleYoutubeSupports, '
        'omni: $omniEnabled/$omniSupports, '
        'orax: $oraxEnabled/$oraxSupports)';
  }
}
