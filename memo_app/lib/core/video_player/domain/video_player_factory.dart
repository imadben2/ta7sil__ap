import 'video_player_interface.dart';
import '../infrastructure/chewie_player_impl.dart';
import '../infrastructure/media_kit_player_impl.dart';
import '../infrastructure/simple_youtube_player_impl.dart';
import '../infrastructure/omni_video_player_impl.dart';
import '../infrastructure/orax_player_impl.dart';

/// Factory for creating video player instances
///
/// This factory creates the appropriate video player implementation
/// based on user preferences. It provides a fallback chain:
/// - User's preferred player (from settings)
/// - If that fails, fallback to Chewie (default)
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

  /// Get list of available player types
  static List<String> get availablePlayers => [
        'chewie',
        'media_kit',
        'simple_youtube',
        'omni',
        'orax',
      ];

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
    return availablePlayers.contains(playerType.toLowerCase());
  }

  /// Get default player type
  static String get defaultPlayer => 'chewie';
}
