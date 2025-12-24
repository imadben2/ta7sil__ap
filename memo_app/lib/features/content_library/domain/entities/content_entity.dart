import 'package:equatable/equatable.dart';

/// Content type enum
enum ContentType {
  lesson, // درس
  summary, // ملخص
  exercise, // تمارين
  test, // فرض
}

/// Difficulty level enum
enum DifficultyLevel {
  easy, // سهل
  medium, // متوسط
  hard, // صعب
}

/// Entity representing educational content (lesson, summary, exercise, test)
class ContentEntity extends Equatable {
  final int id;
  final int subjectId;
  final int? academicStreamId; // Stream-specific content, null = shared
  final int chapterId;
  final int contentTypeId;
  final String titleAr;
  final String? titleEn;
  final String? titleFr;
  final String? descriptionAr;
  final String? contentBodyAr;
  final String slug;

  // Type and difficulty
  final ContentType type;
  final DifficultyLevel? difficultyLevel;
  final int? estimatedDurationMinutes;

  // File information
  final bool hasFile;
  final String? filePath;
  final String? fileType; // pdf, doc, etc
  final int? fileSizeBytes;

  // Video information
  final bool hasVideo;
  final String? videoType; // youtube, vimeo, direct
  final String? videoUrl;
  final int? videoDurationSeconds;

  // Metadata
  final bool isPublished;
  final bool isPremium;
  final List<String> tags;
  final int viewsCount;
  final int downloadsCount;
  final double? averageRating;
  final int? ratingsCount;

  // User progress (if available)
  final double? progressPercentage;
  final String? progressStatus; // not_started, in_progress, completed
  final int? timeSpentMinutes;
  final DateTime? lastAccessedAt;
  final DateTime? completedAt;

  const ContentEntity({
    required this.id,
    required this.subjectId,
    this.academicStreamId,
    required this.chapterId,
    required this.contentTypeId,
    required this.titleAr,
    this.titleEn,
    this.titleFr,
    this.descriptionAr,
    this.contentBodyAr,
    required this.slug,
    required this.type,
    this.difficultyLevel,
    this.estimatedDurationMinutes,
    this.hasFile = false,
    this.filePath,
    this.fileType,
    this.fileSizeBytes,
    this.hasVideo = false,
    this.videoType,
    this.videoUrl,
    this.videoDurationSeconds,
    this.isPublished = true,
    this.isPremium = false,
    this.tags = const [],
    this.viewsCount = 0,
    this.downloadsCount = 0,
    this.averageRating,
    this.ratingsCount,
    this.progressPercentage,
    this.progressStatus,
    this.timeSpentMinutes,
    this.lastAccessedAt,
    this.completedAt,
  });

  /// Get type label in Arabic
  String get typeLabel {
    switch (type) {
      case ContentType.lesson:
        return 'درس';
      case ContentType.summary:
        return 'ملخص';
      case ContentType.exercise:
        return 'تمارين';
      case ContentType.test:
        return 'فرض';
    }
  }

  /// Get difficulty label in Arabic
  String? get difficultyLabel {
    if (difficultyLevel == null) return null;
    switch (difficultyLevel!) {
      case DifficultyLevel.easy:
        return 'سهل';
      case DifficultyLevel.medium:
        return 'متوسط';
      case DifficultyLevel.hard:
        return 'صعب';
    }
  }

  /// Format duration as "Xس Yد" or "Yد"
  String get formattedDuration {
    if (estimatedDurationMinutes == null) return '';

    final hours = estimatedDurationMinutes! ~/ 60;
    final minutes = estimatedDurationMinutes! % 60;

    if (hours > 0) {
      return '${hours}س ${minutes}د';
    }
    return '${minutes}د';
  }

  /// Format video duration as "HH:MM:SS" or "MM:SS"
  String get formattedVideoDuration {
    if (videoDurationSeconds == null) return '';

    final duration = Duration(seconds: videoDurationSeconds!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format file size as "X MB" or "X KB"
  String get formattedFileSize {
    if (fileSizeBytes == null) return '';

    final mb = fileSizeBytes! / (1024 * 1024);
    if (mb >= 1) {
      return '${mb.toStringAsFixed(1)} MB';
    }

    final kb = fileSizeBytes! / 1024;
    return '${kb.toStringAsFixed(0)} KB';
  }

  /// Check if content is completed
  bool get isCompleted => progressStatus == 'completed';

  /// Check if content is in progress
  bool get isInProgress => progressStatus == 'in_progress';

  /// Check if content is not started
  bool get isNotStarted =>
      progressStatus == null || progressStatus == 'not_started';

  @override
  List<Object?> get props => [
    id,
    subjectId,
    academicStreamId,
    chapterId,
    contentTypeId,
    titleAr,
    titleEn,
    titleFr,
    descriptionAr,
    contentBodyAr,
    slug,
    type,
    difficultyLevel,
    estimatedDurationMinutes,
    hasFile,
    filePath,
    fileType,
    fileSizeBytes,
    hasVideo,
    videoType,
    videoUrl,
    videoDurationSeconds,
    isPublished,
    isPremium,
    tags,
    viewsCount,
    downloadsCount,
    averageRating,
    ratingsCount,
    progressPercentage,
    progressStatus,
    timeSpentMinutes,
    lastAccessedAt,
    completedAt,
  ];
}
