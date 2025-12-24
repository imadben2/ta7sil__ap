import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/subject_model.dart';
import '../models/chapter_model.dart';
import '../models/content_model.dart';
import '../models/content_progress_model.dart';

/// Remote data source for content library using Laravel API V1
class ContentLibraryRemoteDataSource {
  final Dio dio;

  ContentLibraryRemoteDataSource({required this.dio});

  // ==================== SUBJECTS ====================

  /// Get all subjects for current user
  /// Pass yearId or streamId from user's academic profile
  /// Set withContentOnly to false to include subjects without content (for BAC archives)
  Future<List<SubjectModel>> getSubjects({
    int? yearId,
    int? streamId,
    bool withContentOnly = true,
  }) async {
    final queryParams = <String, dynamic>{};
    if (yearId != null) queryParams['year_id'] = yearId;
    if (streamId != null) queryParams['stream_id'] = streamId;
    if (!withContentOnly) queryParams['with_content_only'] = false;

    final response = await dio.get(
      ApiConstants.subjects,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final data = response.data['data'] as List;
    return data.map((json) => SubjectModel.fromJson(json)).toList();
  }

  /// Get subject by ID with chapters
  Future<SubjectModel> getSubjectById(int id) async {
    final response = await dio.get('${ApiConstants.subjects}/$id');
    return SubjectModel.fromJson(response.data['data']);
  }

  // ==================== CHAPTERS ====================

  /// Get chapters by subject with content counts
  /// Uses: GET /v1/contents/chapters?subject_id=X
  Future<List<ChapterModel>> getChaptersBySubject(int subjectId) async {
    final response = await dio.get(
      ApiConstants.contentChapters,
      queryParameters: {'subject_id': subjectId},
    );
    final data = response.data['data'] as List;
    return data.map((json) => ChapterModel.fromApiJson(json)).toList();
  }

  // ==================== CONTENTS ====================

  /// Get content list with optional filters
  /// Uses: GET /v1/contents
  Future<List<ContentModel>> getContents({
    int? subjectId,
    int? chapterId,
    int? contentTypeId,
    String? difficulty,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (subjectId != null) queryParams['subject_id'] = subjectId;
    if (chapterId != null) queryParams['chapter_id'] = chapterId;
    if (contentTypeId != null) queryParams['content_type_id'] = contentTypeId;
    if (difficulty != null) queryParams['difficulty'] = difficulty;

    final response = await dio.get(
      ApiConstants.contents,
      queryParameters: queryParams,
    );
    final data = response.data['data'] as List;
    return data.map((json) => ContentModel.fromApiJson(json)).toList();
  }

  /// Get content by chapter ID
  /// Uses: GET /v1/contents/chapter/{chapterId}
  Future<List<ContentModel>> getContentByChapter({
    required int chapterId,
    String? contentType,
  }) async {
    final response = await dio.get(
      '${ApiConstants.contentByChapter}/$chapterId',
    );
    final contents = response.data['data']['contents'] as List;
    List<ContentModel> result = contents.map((json) => ContentModel.fromApiJson(json)).toList();

    // Client-side filter by content type if specified
    if (contentType != null) {
      final typeId = _getContentTypeId(contentType);
      if (typeId != null) {
        result = result.where((c) => c.contentTypeId == typeId).toList();
      }
    }

    return result;
  }

  /// Get content by ID with full details
  /// Uses: GET /v1/contents/{id}
  Future<ContentModel> getContentById(int id) async {
    final response = await dio.get('${ApiConstants.contentDetail}/$id');
    return ContentModel.fromApiJson(response.data['data'], detailed: true);
  }

  /// Search content
  /// Uses: GET /v1/contents/search?q=X
  Future<List<ContentModel>> searchContent(
    String query, {
    int? subjectId,
    int? contentTypeId,
  }) async {
    final queryParams = <String, dynamic>{'q': query};
    if (subjectId != null) queryParams['subject_id'] = subjectId;
    if (contentTypeId != null) queryParams['content_type_id'] = contentTypeId;

    final response = await dio.get(
      ApiConstants.contentSearch,
      queryParameters: queryParams,
    );
    final data = response.data['data'] as List;
    return data.map((json) => ContentModel.fromApiJson(json)).toList();
  }

  /// Get content types
  /// Uses: GET /v1/contents/types
  Future<List<Map<String, dynamic>>> getContentTypes() async {
    final response = await dio.get(ApiConstants.contentTypes);
    return (response.data['data'] as List).cast<Map<String, dynamic>>();
  }

  /// Get download URL for content
  /// Uses: GET /v1/contents/{id}/download
  Future<String> getDownloadUrl(int contentId) async {
    return '${ApiConstants.baseUrl}${ApiConstants.contentDownload}/$contentId/download';
  }

  // ==================== PROGRESS ====================

  /// Get all progress for current user
  /// Uses: GET /v1/progress/all
  Future<List<Map<String, dynamic>>> getAllProgress() async {
    final response = await dio.get(ApiConstants.progressAll);
    return (response.data['data'] as List).cast<Map<String, dynamic>>();
  }

  /// Get progress for a specific content
  /// Uses: GET /v1/progress/content/{contentId}
  Future<ContentProgressModel> getContentProgress(int contentId) async {
    final response = await dio.get(
      '${ApiConstants.progressContent}/$contentId',
    );
    return ContentProgressModel.fromApiJson(response.data['data'], contentId);
  }

  /// Update content progress
  /// Uses: POST /v1/progress/content/{contentId}
  Future<ContentProgressModel> updateContentProgress({
    required int contentId,
    required double progressPercentage,
    required int timeSpentMinutes,
  }) async {
    final response = await dio.post(
      '${ApiConstants.progressContent}/$contentId',
      data: {
        'progress': progressPercentage.round(),
        'time_spent': timeSpentMinutes * 60, // Convert to seconds
      },
    );
    return ContentProgressModel.fromApiJson(response.data['data'], contentId);
  }

  /// Mark content as completed
  /// Uses: POST /v1/progress/content/{contentId}/complete
  Future<ContentProgressModel> markContentAsCompleted(int contentId) async {
    print('🔵 DATASOURCE: markContentAsCompleted called for content $contentId');

    final fullUrl = '${ApiConstants.progressContent}/$contentId/complete';
    print('   Full URL: ${ApiConstants.baseUrl}$fullUrl');
    print('   Method: POST');

    // Log headers (safely, without exposing token value)
    final hasAuth = dio.options.headers['Authorization'] != null;
    print('   Auth header: ${hasAuth ? "✓ Present" : "❌ Missing"}');

    try {
      final response = await dio.post(fullUrl);

      print('✅ DATASOURCE: Received response');
      print('   Status: ${response.statusCode}');
      print('   Response data: ${response.data}');

      return ContentProgressModel.fromApiJson(response.data['data'], contentId);
    } on DioException catch (e) {
      print('❌ DATASOURCE: DioException');
      print('   Type: ${e.type}');
      print('   Status: ${e.response?.statusCode}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ DATASOURCE: Unexpected error: $e');
      rethrow;
    }
  }

  /// Get subject progress
  /// Uses: GET /v1/progress/subject/{subjectId}
  Future<Map<String, dynamic>> getSubjectProgress(int subjectId) async {
    final response = await dio.get(
      '${ApiConstants.progressSubject}/$subjectId',
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  // ==================== BOOKMARKS ====================

  /// Get all bookmarked content
  /// Uses: GET /v1/bookmarks
  Future<List<ContentModel>> getBookmarkedContent() async {
    final response = await dio.get(ApiConstants.bookmarks);
    final data = response.data['data'] as List;
    return data.map((json) {
      // Bookmark response contains nested content
      final contentJson = json['content'] as Map<String, dynamic>;
      return ContentModel.fromApiJson(contentJson);
    }).toList();
  }

  /// Get bookmarks count
  /// Uses: GET /v1/bookmarks/count
  Future<int> getBookmarkCount() async {
    final response = await dio.get(ApiConstants.bookmarkCount);
    return response.data['data']['count'] as int;
  }

  /// Check if content is bookmarked
  /// Uses: GET /v1/bookmarks/content/{contentId}/check
  Future<bool> isContentBookmarked(int contentId) async {
    final response = await dio.get(
      '${ApiConstants.bookmarkContent}/$contentId/check',
    );
    return response.data['data']['is_bookmarked'] as bool;
  }

  /// Add bookmark
  /// Uses: POST /v1/bookmarks/content/{contentId}
  Future<void> addBookmark(int contentId) async {
    await dio.post('${ApiConstants.bookmarkContent}/$contentId');
  }

  /// Remove bookmark
  /// Uses: DELETE /v1/bookmarks/content/{contentId}
  Future<void> removeBookmark(int contentId) async {
    await dio.delete('${ApiConstants.bookmarkContent}/$contentId');
  }

  /// Toggle bookmark - returns true if now bookmarked, false if removed
  Future<bool> toggleBookmark(int contentId) async {
    final isBookmarked = await isContentBookmarked(contentId);
    if (isBookmarked) {
      await removeBookmark(contentId);
      return false;
    } else {
      await addBookmark(contentId);
      return true;
    }
  }

  // ==================== RATINGS ====================

  /// Rate content
  /// Uses: POST /v1/ratings/content/{contentId}
  Future<void> rateContent(int contentId, int rating, {String? comment}) async {
    await dio.post(
      '${ApiConstants.rateContent}/$contentId',
      data: {
        'rating': rating,
        if (comment != null) 'comment': comment,
      },
    );
  }

  // ==================== VIEW/DOWNLOAD TRACKING ====================

  /// Record content view
  /// Uses: POST /contents/{id}/view
  Future<void> recordContentView(int contentId) async {
    try {
      await dio.post('${ApiConstants.contentDetail}/$contentId/view');
    } catch (e) {
      // Silent fail - view tracking is not critical
      print('⚠️ DATASOURCE: Failed to record view for content $contentId: $e');
    }
  }

  /// Record content download
  /// Uses: POST /v1/contents/{id}/record-download
  Future<void> recordContentDownload(int contentId) async {
    try {
      await dio.post('${ApiConstants.contentDetail}/$contentId/record-download');
    } catch (e) {
      // Silent fail - download tracking is not critical
      print('⚠️ DATASOURCE: Failed to record download for content $contentId: $e');
    }
  }

  // ==================== HELPERS ====================

  /// Map content type string to ID
  int? _getContentTypeId(String type) {
    switch (type.toLowerCase()) {
      case 'lesson':
        return 1;
      case 'summary':
        return 2;
      case 'exercise':
        return 3;
      case 'test':
        return 4;
      default:
        return null;
    }
  }
}
