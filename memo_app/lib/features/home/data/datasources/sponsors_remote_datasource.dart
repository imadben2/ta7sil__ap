import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/sponsor_model.dart';

/// Response from sponsors API
class SponsorsApiResponse {
  final bool sectionEnabled;
  final List<SponsorModel> sponsors;

  const SponsorsApiResponse({
    required this.sectionEnabled,
    required this.sponsors,
  });
}

/// Abstract interface for sponsors remote data source
abstract class SponsorsRemoteDataSource {
  /// Get all active sponsors from API with section enabled status
  Future<SponsorsApiResponse> getSponsors();

  /// Record a click on a sponsor's social link
  /// [platform] can be: youtube, facebook, instagram, telegram, or general
  Future<int> recordSponsorClick(int sponsorId, {String platform = 'general'});
}

/// Implementation of SponsorsRemoteDataSource using Dio
class SponsorsRemoteDataSourceImpl implements SponsorsRemoteDataSource {
  final Dio dio;

  SponsorsRemoteDataSourceImpl({required this.dio});

  @override
  Future<SponsorsApiResponse> getSponsors() async {
    try {
      final response = await dio.get(ApiConstants.sponsors);

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle new response structure with section_enabled flag
        bool sectionEnabled = true;
        List<dynamic> sponsorsJson;

        if (data is Map && data.containsKey('data')) {
          final responseData = data['data'];
          if (responseData is Map) {
            // New format: { section_enabled: bool, sponsors: [] }
            sectionEnabled = responseData['section_enabled'] as bool? ?? true;
            sponsorsJson = responseData['sponsors'] as List<dynamic>? ?? [];
          } else if (responseData is List) {
            // Old format: data is directly the sponsors array
            sponsorsJson = responseData;
          } else {
            throw ParseException(message: 'Unexpected response format');
          }
        } else if (data is List) {
          sponsorsJson = data;
        } else {
          throw ParseException(message: 'Unexpected response format');
        }

        final sponsors = sponsorsJson
            .map((json) => SponsorModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return SponsorsApiResponse(
          sectionEnabled: sectionEnabled,
          sponsors: sponsors,
        );
      }

      throw ServerException(message: 'Failed to load sponsors');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw TimeoutException(message: 'Connection timed out');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'No internet connection');
      }
      throw ServerException(message: e.message ?? 'Failed to load sponsors');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(message: 'Failed to load sponsors: $e');
    }
  }

  @override
  Future<int> recordSponsorClick(int sponsorId, {String platform = 'general'}) async {
    try {
      final response = await dio.post(
        ApiConstants.sponsorClick(sponsorId),
        data: {'platform': platform},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Extract click count from response
        if (data is Map && data.containsKey('data')) {
          final clickData = data['data'] as Map<String, dynamic>;
          // Return total clicks or platform-specific clicks
          return clickData['total_clicks'] as int? ??
                 clickData['click_count'] as int? ?? 0;
        }

        return 0;
      }

      throw ServerException(message: 'Failed to record click');
    } on DioException {
      // For click tracking, we don't want to throw errors
      // Just return 0 silently
      return 0;
    } catch (e) {
      // Silent fail for click tracking
      return 0;
    }
  }
}
