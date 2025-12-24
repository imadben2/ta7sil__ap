import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/subject_entity.dart';
import '../entities/chapter_entity.dart';
import '../entities/content_entity.dart';
import '../entities/content_progress_entity.dart';

/// Repository interface for content library operations
abstract class ContentLibraryRepository {
  /// Get all subjects for the current user's academic stream
  /// Pass yearId or streamId from user's academic profile
  /// Set withContentOnly to false to include subjects without content (for BAC archives)
  Future<Either<Failure, List<SubjectEntity>>> getSubjects({
    int? yearId,
    int? streamId,
    bool withContentOnly = true,
  });

  /// Get a specific subject by ID with progress stats
  Future<Either<Failure, SubjectEntity>> getSubjectById(int subjectId);

  /// Get all chapters for a specific subject
  Future<Either<Failure, List<ChapterEntity>>> getChaptersBySubject(
    int subjectId,
  );

  /// Get a specific chapter by ID
  Future<Either<Failure, ChapterEntity>> getChapterById(int chapterId);

  /// Get content by chapter and type
  Future<Either<Failure, List<ContentEntity>>> getContentByChapter({
    required int chapterId,
    required String contentType, // 'lesson', 'summary', 'exercise', 'test'
  });

  /// Get a specific content by ID with user progress
  Future<Either<Failure, ContentEntity>> getContentById(int contentId);

  /// Get user's progress for a specific content
  Future<Either<Failure, ContentProgressEntity>> getContentProgress(
    int contentId,
  );

  /// Update user's progress for a specific content
  Future<Either<Failure, ContentProgressEntity>> updateContentProgress({
    required int contentId,
    required double progressPercentage,
    required int timeSpentMinutes,
  });

  /// Mark content as completed
  Future<Either<Failure, ContentProgressEntity>> markContentAsCompleted(
    int contentId,
  );

  /// Toggle bookmark for a content
  Future<Either<Failure, bool>> toggleBookmark(int contentId);

  /// Check if a content is bookmarked
  Future<Either<Failure, bool>> isContentBookmarked(int contentId);

  /// Get all bookmarked content
  Future<Either<Failure, List<ContentEntity>>> getBookmarkedContent();

  /// Get contents with optional filters (by subject, chapter, type, etc.)
  Future<Either<Failure, List<ContentEntity>>> getContents({
    int? subjectId,
    int? chapterId,
    int? contentTypeId,
    String? difficulty,
    int page = 1,
    int perPage = 50,
  });

  /// Search content by query
  Future<Either<Failure, List<ContentEntity>>> searchContent(String query);

  /// Get recently accessed content
  Future<Either<Failure, List<ContentEntity>>> getRecentContent({
    int limit = 10,
  });

  /// Get in-progress content
  Future<Either<Failure, List<ContentEntity>>> getInProgressContent();

  /// Download content for offline access
  Future<Either<Failure, String>> downloadContent(int contentId);

  /// Check if content is downloaded
  Future<Either<Failure, bool>> isContentDownloaded(int contentId);

  /// Delete downloaded content
  Future<Either<Failure, bool>> deleteDownloadedContent(int contentId);

  /// Record that user viewed a content
  Future<Either<Failure, void>> recordContentView(int contentId);

  /// Record that user downloaded a content
  Future<Either<Failure, void>> recordContentDownload(int contentId);
}
