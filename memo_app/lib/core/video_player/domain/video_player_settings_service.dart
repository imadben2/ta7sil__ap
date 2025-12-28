import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'video_player_settings.dart';

/// Global service to store and access video player settings
/// Settings are cached locally and synced from server on app startup
class VideoPlayerSettingsService {
  static final VideoPlayerSettingsService _instance = VideoPlayerSettingsService._internal();
  factory VideoPlayerSettingsService() => _instance;
  VideoPlayerSettingsService._internal();

  static const String _boxName = 'video_player_settings';
  static const String _settingsKey = 'settings';

  VideoPlayerSettings _settings = VideoPlayerSettings.defaults;
  bool _initialized = false;

  /// Get current video player settings
  VideoPlayerSettings get settings => _settings;

  /// Check if service is initialized
  bool get isInitialized => _initialized;

  /// Initialize the service (load cached settings)
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final box = await Hive.openBox(_boxName);
      final cachedJson = box.get(_settingsKey) as Map<dynamic, dynamic>?;

      if (cachedJson != null) {
        final jsonMap = Map<String, dynamic>.from(cachedJson);
        _settings = VideoPlayerSettings.fromJson(jsonMap);
        debugPrint('[VideoPlayerSettingsService] ✓ Loaded cached settings: $_settings');
      } else {
        debugPrint('[VideoPlayerSettingsService] ⚠ No cached settings, using defaults');
      }

      _initialized = true;
    } catch (e) {
      debugPrint('[VideoPlayerSettingsService] ❌ Error loading settings: $e');
      _settings = VideoPlayerSettings.defaults;
      _initialized = true;
    }
  }

  /// Update settings from server response
  Future<void> updateFromServer(Map<String, dynamic>? json) async {
    if (json == null) {
      debugPrint('[VideoPlayerSettingsService] ⚠ No video_player_settings in server response');
      return;
    }

    try {
      _settings = VideoPlayerSettings.fromJson(json);
      debugPrint('[VideoPlayerSettingsService] ✓ Updated from server: $_settings');

      // Cache the settings
      final box = await Hive.openBox(_boxName);
      await box.put(_settingsKey, json);
      debugPrint('[VideoPlayerSettingsService] ✓ Settings cached locally');
    } catch (e) {
      debugPrint('[VideoPlayerSettingsService] ❌ Error updating settings: $e');
    }
  }

  /// Get the recommended player for a video URL
  /// Automatically detects if it's a YouTube video or uploaded video
  String getRecommendedPlayer(String videoUrl, {String? userPreferredPlayer}) {
    final isYouTube = _isYouTubeUrl(videoUrl);
    final videoType = isYouTube ? 'youtube' : 'upload';

    debugPrint('[VideoPlayerSettingsService] Video type: $videoType for URL: ${videoUrl.substring(0, videoUrl.length.clamp(0, 50))}...');

    // If user has a preferred player that supports this video type, use it
    if (userPreferredPlayer != null &&
        _settings.isPlayerEnabled(userPreferredPlayer) &&
        _settings.playerSupportsVideoType(userPreferredPlayer, videoType)) {
      debugPrint('[VideoPlayerSettingsService] ✓ Using user preferred player: $userPreferredPlayer');
      return userPreferredPlayer;
    }

    // Otherwise, use the default player for this video type from server settings
    final defaultPlayer = _settings.getDefaultPlayerForVideoType(videoType);
    debugPrint('[VideoPlayerSettingsService] ✓ Using default player for $videoType: $defaultPlayer');
    return defaultPlayer;
  }

  /// Check if a URL is a YouTube video
  bool _isYouTubeUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('youtube.com') ||
        lowerUrl.contains('youtu.be') ||
        lowerUrl.contains('youtube-nocookie.com');
  }

  /// Get list of available players for settings UI
  /// Only returns enabled players
  List<PlayerOption> getAvailablePlayersForSettings() {
    final allPlayers = [
      PlayerOption(
        id: 'chewie',
        nameAr: 'تشيوي (افتراضي)',
        description: 'بسيط وموثوق',
        enabled: _settings.chewieEnabled,
        supports: _settings.chewieSupports,
      ),
      PlayerOption(
        id: 'media_kit',
        nameAr: 'ميديا كيت (أداء عالي)',
        description: 'أداء عالي للفيديوهات عالية الدقة',
        enabled: _settings.mediaKitEnabled,
        supports: _settings.mediaKitSupports,
      ),
      PlayerOption(
        id: 'simple_youtube',
        nameAr: 'يوتيوب بسيط',
        description: 'مشغل يوتيوب المدمج',
        enabled: _settings.simpleYoutubeEnabled,
        supports: _settings.simpleYoutubeSupports,
      ),
      PlayerOption(
        id: 'omni',
        nameAr: 'أومني',
        description: 'دعم يوتيوب وفيميو مع واجهة مخصصة',
        enabled: _settings.omniEnabled,
        supports: _settings.omniSupports,
      ),
      PlayerOption(
        id: 'orax',
        nameAr: 'أوراكس',
        description: 'دعم يوتيوب، اختيار الجودة، ترجمات، تكبير',
        enabled: _settings.oraxEnabled,
        supports: _settings.oraxSupports,
      ),
    ];

    return allPlayers.where((p) => p.enabled).toList();
  }

  /// Get list of available players for uploaded videos
  List<PlayerOption> getPlayersForUploadedVideos() {
    return getAvailablePlayersForSettings()
        .where((p) => p.supports == 'upload' || p.supports == 'both')
        .toList();
  }

  /// Get list of available players for YouTube videos
  List<PlayerOption> getPlayersForYouTube() {
    return getAvailablePlayersForSettings()
        .where((p) => p.supports == 'youtube' || p.supports == 'both')
        .toList();
  }
}

/// Player option for settings UI
class PlayerOption {
  final String id;
  final String nameAr;
  final String description;
  final bool enabled;
  final String supports;

  const PlayerOption({
    required this.id,
    required this.nameAr,
    required this.description,
    required this.enabled,
    required this.supports,
  });

  String get supportsLabel {
    switch (supports) {
      case 'youtube':
        return 'YouTube فقط';
      case 'upload':
        return 'مرفوع فقط';
      case 'both':
        return 'الكل';
      default:
        return supports;
    }
  }
}
