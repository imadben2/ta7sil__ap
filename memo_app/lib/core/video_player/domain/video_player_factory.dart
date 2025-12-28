import 'package:flutter/foundation.dart';
import 'video_player_interface.dart';
import 'video_player_settings_service.dart';
import '../infrastructure/chewie_player_impl.dart';
import '../infrastructure/media_kit_player_impl.dart';
import '../infrastructure/simple_youtube_player_impl.dart';
import '../infrastructure/omni_video_player_impl.dart';
import '../infrastructure/orax_player_impl.dart';

/// Factory for creating video player instances
///
/// This factory creates the appropriate video player implementation
/// based on user preferences and server settings. It provides:
/// - Automatic player selection based on video type (YouTube vs uploaded)
/// - Server-configured default players
/// - User preference override
/// - Fallback chain if preferred player fails
class VideoPlayerFactory {
  /// Create a video player instance based on player type
  ///
  /// [playerType] - The type of player to create ('chewie', 'media_kit', 'simple_youtube', 'omni', 'orax')
  ///
  /// Returns an instance of IVideoPlayer
  ///
  /// Throws ArgumentError if playerType is invalid
  static IVideoPlayer create(String playerType) {
    switch (playerType.toLowerCase()) {
      case 'chewie':
        return ChewiePlayerImpl();

      case 'media_kit':
        return MediaKitPlayerImpl();

      case 'simple_youtube':
        return SimpleYoutubePlayerImpl();

      case 'omni':
        return OmniVideoPlayerImpl();

      case 'orax_video_player':
      case 'orax':
        return OraxPlayerImpl();

      default:
        // Fallback to Chewie for unknown player types
        return ChewiePlayerImpl();
    }
  }

  /// Create the best video player for a specific video URL
  ///
  /// This method automatically:
  /// 1. Detects if the URL is YouTube or uploaded video
  /// 2. Uses server-configured default player for that video type
  /// 3. Falls back to user's preferred player if set
  /// 4. Ensures the player is enabled in server settings
  ///
  /// [videoUrl] - The video URL to play
  /// [userPreferredPlayer] - Optional user override
  ///
  /// Returns an instance of IVideoPlayer optimized for the video type
  static IVideoPlayer createForVideo(
    String videoUrl, {
    String? userPreferredPlayer,
  }) {
    final service = VideoPlayerSettingsService();
    final recommendedPlayer = service.getRecommendedPlayer(
      videoUrl,
      userPreferredPlayer: userPreferredPlayer,
    );

    debugPrint('[VideoPlayerFactory] Creating player: $recommendedPlayer for URL: ${videoUrl.substring(0, videoUrl.length.clamp(0, 50))}...');

    return create(recommendedPlayer);
  }

  /// Create a video player with fallback support
  ///
  /// Tries to create the preferred player, and falls back to Chewie if it fails.
  /// This provides graceful degradation if a player has initialization issues.
  ///
  /// [preferredPlayerType] - The user's preferred player type
  /// [onFallback] - Optional callback when fallback occurs
  ///
  /// Returns an instance of IVideoPlayer
  static IVideoPlayer createWithFallback(
    String preferredPlayerType, {
    void Function(String failedPlayer, String fallbackPlayer)? onFallback,
  }) {
    try {
      return create(preferredPlayerType);
    } catch (e) {
      // Log the error and fallback to Chewie
      if (onFallback != null) {
        onFallback(preferredPlayerType, 'chewie');
      }
      return ChewiePlayerImpl();
    }
  }

  /// Get list of all player types (regardless of server settings)
  static List<String> get allPlayers => [
        'chewie',
        'media_kit',
        'simple_youtube',
        'omni',
        'orax',
      ];

  /// Get list of available player types (only enabled by server)
  static List<String> get availablePlayers {
    final service = VideoPlayerSettingsService();
    return allPlayers.where((player) => service.settings.isPlayerEnabled(player)).toList();
  }

  /// Get list of available players for uploaded videos
  static List<String> get availableUploadPlayers {
    final service = VideoPlayerSettingsService();
    return allPlayers.where((player) {
      return service.settings.isPlayerEnabled(player) &&
          service.settings.playerSupportsVideoType(player, 'upload');
    }).toList();
  }

  /// Get list of available players for YouTube videos
  static List<String> get availableYoutubePlayers {
    final service = VideoPlayerSettingsService();
    return allPlayers.where((player) {
      return service.settings.isPlayerEnabled(player) &&
          service.settings.playerSupportsVideoType(player, 'youtube');
    }).toList();
  }

  /// Get player display name in Arabic
  static String getPlayerDisplayName(String playerType) {
    switch (playerType.toLowerCase()) {
      case 'chewie':
        return 'تشيوي (افتراضي)';
      case 'media_kit':
        return 'ميديا كيت (أداء عالي)';
      case 'simple_youtube':
        return 'يوتيوب بسيط (فيديوهات يوتيوب)';
      case 'omni':
        return 'أومني (يوتيوب + شبكة)';
      case 'orax_video_player':
      case 'orax':
        return 'أوراكس (يوتيوب + جودات)';
      default:
        return playerType;
    }
  }

  /// Get player description in Arabic
  static String getPlayerDescription(String playerType) {
    switch (playerType.toLowerCase()) {
      case 'chewie':
        return 'بسيط وموثوق';
      case 'media_kit':
        return 'أداء عالي للفيديوهات عالية الدقة';
      case 'simple_youtube':
        return 'مشغل يوتيوب المدمج للفيديوهات على يوتيوب';
      case 'omni':
        return 'دعم يوتيوب وفيميو مع واجهة مخصصة';
      case 'orax_video_player':
      case 'orax':
        return 'دعم يوتيوب، اختيار الجودة، ترجمات، تكبير';
      default:
        return '';
    }
  }

  /// Check if a player type is valid
  static bool isValidPlayerType(String playerType) {
    return allPlayers.contains(playerType.toLowerCase());
  }

  /// Check if a player is enabled by server settings
  static bool isPlayerEnabled(String playerType) {
    final service = VideoPlayerSettingsService();
    return service.settings.isPlayerEnabled(playerType);
  }

  /// Get what video types a player supports: 'youtube', 'upload', or 'both'
  static String getPlayerSupports(String playerType) {
    final service = VideoPlayerSettingsService();
    return service.settings.getPlayerSupports(playerType);
  }

  /// Get default player for uploaded videos (from server settings)
  static String get defaultUploadPlayer {
    final service = VideoPlayerSettingsService();
    return service.settings.defaultUploadPlayer;
  }

  /// Get default player for YouTube videos (from server settings)
  static String get defaultYoutubePlayer {
    final service = VideoPlayerSettingsService();
    return service.settings.defaultYoutubePlayer;
  }

  /// Get default player type (fallback)
  static String get defaultPlayer => 'chewie';
}
