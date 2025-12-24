import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/entities/chapter_entity.dart';
import '../../domain/entities/content_entity.dart';
import '../../domain/entities/content_progress_entity.dart';
import '../../domain/repositories/content_library_repository.dart';
import '../datasources/content_library_remote_datasource.dart';
import '../datasources/content_library_local_datasource.dart';
import '../models/content_model.dart';
import '../models/content_progress_model.dart';

/// Implementation of ContentLibraryRepository
class ContentLibraryRepositoryImpl implements ContentLibraryRepository {
  final ContentLibraryRemoteDataSource remoteDataSource;
  final ContentLibraryLocalDataSource? localDataSource;

  ContentLibraryRepositoryImpl({
    required this.remoteDataSource,
    this.localDataSource,
  });

  // ==================== SUBJECTS ====================

  @override
  Future<Either<Failure, List<SubjectEntity>>> getSubjects({
    int? yearId,
    int? streamId,
    bool withContentOnly = true,
  }) async {
    try {
      final subjects = await remoteDataSource.getSubjects(
        yearId: yearId,
        streamId: streamId,
        withContentOnly: withContentOnly,
      );
      return Right(subjects);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubjectEntity>> getSubjectById(int subjectId) async {
    try {
      final subject = await remoteDataSource.getSubjectById(subjectId);
      return Right(subject);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ==================== CHAPTERS ====================

  @override
  Future<Either<Failure, List<ChapterEntity>>> getChaptersBySubject(
    int subjectId,
  ) async {
    try {
      final chapters = await remoteDataSource.getChaptersBySubject(subjectId);
      return Right(chapters);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChapterEntity>> getChapterById(int chapterId) async {
    // Not directly available via API, would need to fetch from content's chapter
    return Left(ServerFailure('Not implemented - use getChaptersBySubject instead'));
  }

  // ==================== CONTENTS ====================

  @override
  Future<Either<Failure, List<ContentEntity>>> getContentByChapter({
    required int chapterId,
    required String contentType,
  }) async {
    try {
      final contents = await remoteDataSource.getContentByChapter(
        chapterId: chapterId,
        contentType: contentType,
      );
      return Right(contents);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ContentEntity>> getContentById(int contentId) async {
    try {
      final content = await remoteDataSource.getContentById(contentId);
      return Right(content);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ContentEntity>>> getContents({
    int? subjectId,
    int? chapterId,
    int? contentTypeId,
    String? difficulty,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final contents = await remoteDataSource.getContents(
        subjectId: subjectId,
        chapterId: chapterId,
        contentTypeId: contentTypeId,
        difficulty: difficulty,
        page: page,
        perPage: perPage,
      );
      return Right(contents);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ContentEntity>>> searchContent(
    String query,
  ) async {
    try {
      final contents = await remoteDataSource.searchContent(query);
      return Right(contents);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ==================== PROGRESS ====================

  @override
  Future<Either<Failure, ContentProgressEntity>> getContentProgress(
    int contentId,
  ) async {
    try {
      final progress = await remoteDataSource.getContentProgress(contentId);
      return Right(progress);
    } catch (e) {
      // Return empty progress if not found (404)
      if (e.toString().contains('404')) {
        return Right(ContentProgressModel.empty(contentId));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ContentProgressEntity>> updateContentProgress({
    required int contentId,
    required double progressPercentage,
    required int timeSpentMinutes,
  }) async {
    try {
      final progress = await remoteDataSource.updateContentProgress(
        contentId: contentId,
        progressPercentage: progressPercentage,
        timeSpentMinutes: timeSpentMinutes,
      );
      return Right(progress);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ContentProgressEntity>> markContentAsCompleted(
    int contentId,
  ) async {
    try {
      print('🔵 REPO: markContentAsCompleted called for content $contentId');

      final progress = await remoteDataSource.markContentAsCompleted(contentId);
      print('✅ REPO: API call succeeded');
      print('   Progress: is_completed=${progress.isCompleted}, percentage=${progress.progressPercentage}');
      return Right(progress);
    } on DioException catch (e) {
      print('❌ REPO: DioException caught');
      print('   Status: ${e.response?.statusCode}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        return const Left(AuthenticationFailure('فشل المصادقة. يرجى تسجيل الدخول مرة أخرى'));
      } else if (e.response?.statusCode == 404) {
        return const Left(NotFoundFailure('المحتوى غير موجود'));
      } else if (e.response?.statusCode == 403) {
        return const Left(PermissionFailure('ليس لديك صلاحية للوصول لهذا المحتوى'));
      }
      return Left(ServerFailure(e.message ?? 'خطأ غير معروف'));
    } catch (e) {
      print('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ContentEntity>>> getRecentContent({
    int limit = 10,
  }) async {
    try {
      final allProgress = await remoteDataSource.getAllProgress();

      // Filter items with last_accessed_at and sort by most recent
      final recentItems = allProgress
          .where((p) => p['last_accessed_at'] != null)
          .toList()
        ..sort((a, b) {
          final aDate = DateTime.parse(a['last_accessed_at'] as String);
          final bDate = DateTime.parse(b['last_accessed_at'] as String);
          return bDate.compareTo(aDate); // Most recent first
        });

      // Extract content from progress items
      final contents = recentItems.take(limit).map((p) {
        final contentJson = p['content'] as Map<String, dynamic>;
        return ContentModel.fromApiJson(contentJson);
      }).toList();

      return Right(contents);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ContentEntity>>> getInProgressContent() async {
    try {
      final allProgress = await remoteDataSource.getAllProgress();

      // Filter items that are in progress (not completed and progress > 0)
      final inProgressItems = allProgress.where((p) {
        final isCompleted = p['is_completed'] as bool? ?? false;
        final progress = p['progress'] as int? ?? 0;
        return !isCompleted && progress > 0;
      }).toList();

      // Extract content from progress items
      final contents = inProgressItems.map((p) {
        final contentJson = p['content'] as Map<String, dynamic>;
        return ContentModel.fromApiJson(contentJson);
      }).toList();

      return Right(contents);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ==================== BOOKMARKS ====================

  @override
  Future<Either<Failure, bool>> toggleBookmark(int contentId) async {
    try {
      final isNowBookmarked = await remoteDataSource.toggleBookmark(contentId);
      return Right(isNowBookmarked);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isContentBookmarked(int contentId) async {
    try {
      final isBookmarked = await remoteDataSource.isContentBookmarked(contentId);
      return Right(isBookmarked);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ContentEntity>>> getBookmarkedContent() async {
    try {
      final contents = await remoteDataSource.getBookmarkedContent();
      return Right(contents);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ==================== DOWNLOADS (Local) ====================

  @override
  Future<Either<Failure, String>> downloadContent(int contentId) async {
    if (localDataSource == null) {
      // Fallback: return download URL for manual handling
      try {
        final downloadUrl = await remoteDataSource.getDownloadUrl(contentId);
        return Right(downloadUrl);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }

    try {
      final downloadUrl = await remoteDataSource.getDownloadUrl(contentId);
      final localPath = await localDataSource!.downloadContent(
        contentId: contentId,
        downloadUrl: downloadUrl,
      );
      return Right(localPath);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isContentDownloaded(int contentId) async {
    if (localDataSource == null) {
      return const Right(false);
    }

    try {
      final isDownloaded = await localDataSource!.isContentDownloaded(contentId);
      return Right(isDownloaded);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteDownloadedContent(int contentId) async {
    if (localDataSource == null) {
      return const Right(false);
    }

    try {
      final deleted = await localDataSource!.deleteDownloadedContent(contentId);
      return Right(deleted);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Get local file path for downloaded content
  Future<Either<Failure, String?>> getDownloadedContentPath(int contentId) async {
    if (localDataSource == null) {
      return const Right(null);
    }

    try {
      final path = await localDataSource!.getDownloadedContentPath(contentId);
      return Right(path);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Get all downloaded content IDs
  Future<Either<Failure, List<int>>> getDownloadedContentIds() async {
    if (localDataSource == null) {
      return const Right([]);
    }

    try {
      final ids = await localDataSource!.getDownloadedContentIds();
      return Right(ids);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Clear all downloaded content
  Future<Either<Failure, void>> clearAllDownloads() async {
    if (localDataSource == null) {
      return const Right(null);
    }

    try {
      await localDataSource!.clearAllDownloads();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ==================== VIEW/DOWNLOAD TRACKING ====================

  @override
  Future<Either<Failure, void>> recordContentView(int contentId) async {
    try {
      await remoteDataSource.recordContentView(contentId);
      return const Right(null);
    } catch (e) {
      // Silent fail for view tracking - not critical
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> recordContentDownload(int contentId) async {
    try {
      await remoteDataSource.recordContentDownload(contentId);
      return const Right(null);
    } catch (e) {
      // Silent fail for download tracking - not critical
      return const Right(null);
    }
  }
}
