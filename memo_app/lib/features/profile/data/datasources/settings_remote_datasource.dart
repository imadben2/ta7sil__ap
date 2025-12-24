import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/settings_model.dart';

/// Remote data source for settings from API
abstract class SettingsRemoteDataSource {
  /// Get settings from API
  Future<SettingsModel> getSettings();

  /// Save settings to API
  Future<void> saveSettings(SettingsModel settings);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final Dio dio;

  SettingsRemoteDataSourceImpl({required this.dio});

  @override
  Future<SettingsModel> getSettings() async {
    try {
      final response = await dio.get('${ApiConstants.baseUrl}/settings');

      print('🎬 Remote: GET settings - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('🎬 Remote: Settings retrieved from API');

        // API returns grouped/nested structure, need to flatten it
        final data = response.data['data'];
        print('🎬 Remote: Raw API data = $data');

        // Transform nested structure to flat structure for SettingsModel
        // API returns: notifications.types, prayer_times, app_preferences
        // SettingsModel expects: notifications (with enabled, sessions, etc.), prayer_times, locale, theme_mode, etc.

        final notificationTypes = data['notifications']?['types'] ?? {};
        final prayerTimesData = data['prayer_times'] ?? {};
        final appPreferences = data['app_preferences'] ?? {};

        final flatSettings = {
          'notifications': {
            // Map API notification types to SettingsModel notification fields
            'enabled': notificationTypes['new_memo'] ?? true,  // Use any notification as "enabled" indicator
            'sessions': notificationTypes['memo_due'] ?? true,
            'quizzes': notificationTypes['revision_reminder'] ?? true,
            'achievements': notificationTypes['achievement'] ?? true,
            'prayer_reminders': notificationTypes['prayer_time'] ?? false,
          },
          'prayer_times': {
            'enabled': prayerTimesData['enabled'] ?? false,
            'city': 'Algiers', // Default city (not in API response)
            'reminder_minutes_before': prayerTimesData['notifications']?['before_minutes'] ?? 10,
          },
          'locale': appPreferences['language'] ?? 'ar',
          'theme_mode': appPreferences['theme'] ?? 'system',
          'offline_mode': false, // Not in API response
          'cache_size': 0, // Not in API response
          'preferred_video_player': appPreferences['preferred_video_player'] ?? 'chewie',
        };

        print('🎬 Remote: Flattened settings = $flatSettings');
        return SettingsModel.fromJson(flatSettings);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Token expired or invalid');
      } else {
        throw ServerException(
          message: 'Failed to load settings from server: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ Remote: DioException getting settings: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(message: 'Token expired or invalid');
      }
      throw ServerException(message: 'Failed to connect to server: ${e.message}');
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      print('❌ Remote: Error getting settings: $e');
      throw ServerException(message: 'Failed to connect to server: $e');
    }
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    try {
      final apiData = settings.toApiJson();
      print('🎬 Remote: Saving settings to API...');
      print('🎬 Remote: preferred_video_player = ${settings.preferredVideoPlayer}');
      print('🎬 Remote: API URL = ${ApiConstants.baseUrl}/settings');
      print('🎬 Remote: Data being sent = $apiData');

      final response = await dio.put(
        '${ApiConstants.baseUrl}/settings',
        data: apiData,
      );

      print('🎬 Remote: PUT settings - Status: ${response.statusCode}');
      print('🎬 Remote: Response data = ${response.data}');

      if (response.statusCode == 200) {
        print('🎬 Remote: Settings saved to API successfully');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Token expired or invalid');
      } else {
        throw ServerException(
          message: 'Failed to save settings: ${response.data['message'] ?? response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ Remote: DioException saving settings: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(message: 'Token expired or invalid');
      }
      throw ServerException(message: 'Failed to connect to server: ${e.message}');
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      print('❌ Remote: Error saving settings: $e');
      throw ServerException(message: 'Failed to connect to server: $e');
    }
  }
}
