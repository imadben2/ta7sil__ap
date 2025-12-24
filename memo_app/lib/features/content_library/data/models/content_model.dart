import '../../domain/entities/content_entity.dart';

/// Data model for Content that extends ContentEntity
class ContentModel extends ContentEntity {
  const ContentModel({
    required super.id,
    required super.subjectId,
    super.academicStreamId,
    required super.chapterId,
    required super.contentTypeId,
    required super.titleAr,
    super.titleEn,
    super.titleFr,
    super.descriptionAr,
    super.contentBodyAr,
    required super.slug,
    required super.type,
    super.difficultyLevel,
    super.estimatedDurationMinutes,
    super.hasFile,
    super.filePath,
    super.fileType,
    super.fileSizeBytes,
    super.hasVideo,
    super.videoType,
    super.videoUrl,
    super.videoDurationSeconds,
    super.isPublished,
    super.isPremium,
    super.tags,
    super.viewsCount,
    super.downloadsCount,
    super.averageRating,
    super.ratingsCount,
    super.progressPercentage,
    super.progressStatus,
    super.timeSpentMinutes,
    super.lastAccessedAt,
    super.completedAt,
  });

  /// Create ContentModel from JSON
  factory ContentModel.fromJson(Map<String, dynamic> json) {
    // Parse content type
    final contentType = _parseContentType(json['content_type_id'] as int?);

    // Parse difficulty level
    final difficultyLevel = _parseDifficultyLevel(
      json['difficulty_level'] as String?,
    );

    // Parse progress data if available
    final progress = json['progress'] as Map<String, dynamic>?;

    return ContentModel(
      id: json['id'] as int,
      subjectId: json['subject_id'] as int,
      academicStreamId: json['academic_stream_id'] as int?,
      chapterId: json['chapter_id'] as int,
      contentTypeId: json['content_type_id'] as int,
      titleAr: json['title_ar'] as String,
      titleEn: json['title_en'] as String?,
      titleFr: json['title_fr'] as String?,
      descriptionAr: json['description_ar'] as String?,
      contentBodyAr: json['content_body_ar'] as String?,
      slug: json['slug'] as String,
      type: contentType,
      difficultyLevel: difficultyLevel,
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int?,
      hasFile: json['has_file'] as bool? ?? false,
      filePath: json['file_path'] as String?,
      fileType: json['file_type'] as String?,
      fileSizeBytes: json['file_size_bytes'] as int?,
      hasVideo: json['has_video'] as bool? ?? false,
      videoType: json['video_type'] as String?,
      videoUrl: json['video_url'] as String?,
      videoDurationSeconds: json['video_duration_seconds'] as int?,
      isPublished: json['is_published'] as bool? ?? true,
      isPremium: json['is_premium'] as bool? ?? false,
      tags: _parseTags(json['tags']),
      viewsCount: json['views_count'] as int? ?? 0,
      downloadsCount: json['downloads_count'] as int? ?? 0,
      averageRating: _parseDouble(json['average_rating']),
      ratingsCount: json['ratings_count'] as int?,
      progressPercentage: _parseDouble(progress?['progress_percentage']),
      progressStatus: progress?['status'] as String?,
      timeSpentMinutes: progress?['time_spent_minutes'] as int?,
      lastAccessedAt: _parseDateTime(progress?['last_accessed_at']),
      completedAt: _parseDateTime(progress?['completed_at']),
    );
  }

  /// Convert ContentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'academic_stream_id': academicStreamId,
      'chapter_id': chapterId,
      'content_type_id': contentTypeId,
      'title_ar': titleAr,
      'title_en': titleEn,
      'title_fr': titleFr,
      'description_ar': descriptionAr,
      'content_body_ar': contentBodyAr,
      'slug': slug,
      'content_type': _contentTypeToString(type),
      'difficulty_level': _difficultyLevelToString(difficultyLevel),
      'estimated_duration_minutes': estimatedDurationMinutes,
      'has_file': hasFile,
      'file_path': filePath,
      'file_type': fileType,
      'file_size_bytes': fileSizeBytes,
      'has_video': hasVideo,
      'video_type': videoType,
      'video_url': videoUrl,
      'video_duration_seconds': videoDurationSeconds,
      'is_published': isPublished,
      'is_premium': isPremium,
      'tags': tags,
      'views_count': viewsCount,
      'downloads_count': downloadsCount,
      'average_rating': averageRating,
      'ratings_count': ratingsCount,
      if (progressPercentage != null ||
          progressStatus != null ||
          timeSpentMinutes != null)
        'progress': {
          'progress_percentage': progressPercentage,
          'status': progressStatus,
          'time_spent_minutes': timeSpentMinutes,
          'last_accessed_at': lastAccessedAt?.toIso8601String(),
          'completed_at': completedAt?.toIso8601String(),
        },
    };
  }

  /// Create ContentModel from ContentEntity
  factory ContentModel.fromEntity(ContentEntity entity) {
    return ContentModel(
      id: entity.id,
      subjectId: entity.subjectId,
      academicStreamId: entity.academicStreamId,
      chapterId: entity.chapterId,
      contentTypeId: entity.contentTypeId,
      titleAr: entity.titleAr,
      titleEn: entity.titleEn,
      titleFr: entity.titleFr,
      descriptionAr: entity.descriptionAr,
      contentBodyAr: entity.contentBodyAr,
      slug: entity.slug,
      type: entity.type,
      difficultyLevel: entity.difficultyLevel,
      estimatedDurationMinutes: entity.estimatedDurationMinutes,
      hasFile: entity.hasFile,
      filePath: entity.filePath,
      fileType: entity.fileType,
      fileSizeBytes: entity.fileSizeBytes,
      hasVideo: entity.hasVideo,
      videoType: entity.videoType,
      videoUrl: entity.videoUrl,
      videoDurationSeconds: entity.videoDurationSeconds,
      isPublished: entity.isPublished,
      isPremium: entity.isPremium,
      tags: entity.tags,
      viewsCount: entity.viewsCount,
      downloadsCount: entity.downloadsCount,
      averageRating: entity.averageRating,
      ratingsCount: entity.ratingsCount,
      progressPercentage: entity.progressPercentage,
      progressStatus: entity.progressStatus,
      timeSpentMinutes: entity.timeSpentMinutes,
      lastAccessedAt: entity.lastAccessedAt,
      completedAt: entity.completedAt,
    );
  }

  /// Parse content type from ID
  static ContentType _parseContentType(int? typeId) {
    switch (typeId) {
      case 1:
        return ContentType.lesson;
      case 2:
        return ContentType.summary;
      case 3:
        return ContentType.exercise;
      case 4:
        return ContentType.test;
      default:
        return ContentType.lesson;
    }
  }

  /// Parse difficulty level from string
  static DifficultyLevel? _parseDifficultyLevel(String? level) {
    if (level == null) return null;
    switch (level.toLowerCase()) {
      case 'easy':
      case 'سهل':
        return DifficultyLevel.easy;
      case 'medium':
      case 'متوسط':
        return DifficultyLevel.medium;
      case 'hard':
      case 'صعب':
        return DifficultyLevel.hard;
      default:
        return null;
    }
  }

  /// Convert content type to string
  static String _contentTypeToString(ContentType type) {
    switch (type) {
      case ContentType.lesson:
        return 'lesson';
      case ContentType.summary:
        return 'summary';
      case ContentType.exercise:
        return 'exercise';
      case ContentType.test:
        return 'test';
    }
  }

  /// Convert difficulty level to string
  static String? _difficultyLevelToString(DifficultyLevel? level) {
    if (level == null) return null;
    switch (level) {
      case DifficultyLevel.easy:
        return 'easy';
      case DifficultyLevel.medium:
        return 'medium';
      case DifficultyLevel.hard:
        return 'hard';
    }
  }

  /// Parse tags from various formats
  static List<String> _parseTags(dynamic tags) {
    if (tags == null) return [];
    if (tags is List) {
      return tags.map((e) => e.toString()).toList();
    }
    if (tags is String) {
      // Handle comma-separated string
      return tags
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  /// Helper method to safely parse double values
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Helper method to parse DateTime from string
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Create ContentModel from V1 API response format
  /// This handles the nested object structure from the Laravel V1 API
  factory ContentModel.fromApiJson(Map<String, dynamic> json, {bool detailed = false}) {
    // Extract nested objects
    final subject = json['subject'] as Map<String, dynamic>?;
    final typeObj = json['type'] as Map<String, dynamic>?;
    final chapter = json['chapter'] as Map<String, dynamic>?;
    final files = json['files'] as Map<String, dynamic>?;

    // Parse content type from type object ID or direct field
    final contentTypeId = typeObj?['id'] as int? ?? json['content_type_id'] as int? ?? 1;
    final contentType = _parseContentType(contentTypeId);

    // Parse difficulty level
    final difficultyLevel = _parseDifficultyLevel(
      json['difficulty_level'] as String?,
    );

    // Parse file info
    String? filePath;
    String? fileType;
    int? fileSizeBytes;
    bool hasFile = false;

    if (files != null) {
      // Check for PDF from nested object
      final pdf = files['pdf'] as Map<String, dynamic>?;
      if (pdf != null) {
        filePath = pdf['url'] as String?;
        fileType = pdf['type'] as String? ?? 'pdf';
        fileSizeBytes = pdf['size'] as int?;
        hasFile = true;
      }
      // Also check direct fields in files object
      if (!hasFile && files['has_file'] == true) {
        filePath = files['file_path'] as String?;
        fileType = files['file_type'] as String?;
        hasFile = filePath != null;
      }
    }
    // Fallback to top-level fields
    if (!hasFile && json['has_file'] == true) {
      filePath = json['file_path'] as String?;
      fileType = json['file_type'] as String?;
      fileSizeBytes = json['file_size'] as int?;
      hasFile = filePath != null;
    }

    // Parse video info
    String? videoUrl;
    bool hasVideo = false;

    if (files != null) {
      videoUrl = files['video_url'] as String? ?? files['video_path'] as String?;
      hasVideo = videoUrl != null;
    } else if (json['has_video'] == true || json['video_url'] != null) {
      videoUrl = json['video_url'] as String?;
      hasVideo = true;
    }

    // Parse user progress from API response
    final userProgress = json['user_progress'] as Map<String, dynamic>?;

    // Parse academic_stream_id from response or nested academic_stream object
    int? academicStreamId = json['academic_stream_id'] as int?;
    final academicStream = json['academic_stream'] as Map<String, dynamic>?;
    if (academicStreamId == null && academicStream != null) {
      academicStreamId = academicStream['id'] as int?;
    }

    return ContentModel(
      id: json['id'] as int,
      subjectId: subject?['id'] as int? ?? json['subject_id'] as int? ?? 0,
      academicStreamId: academicStreamId,
      chapterId: chapter?['id'] as int? ?? json['chapter_id'] as int? ?? 0,
      contentTypeId: contentTypeId,
      titleAr: json['title_ar'] as String,
      titleEn: json['title_en'] as String?,
      titleFr: json['title_fr'] as String?,
      descriptionAr: json['description_ar'] as String?,
      contentBodyAr: detailed ? json['content_body_ar'] as String? : null,
      slug: json['slug'] as String? ?? '',
      type: contentType,
      difficultyLevel: difficultyLevel,
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int?,
      hasFile: hasFile,
      filePath: filePath,
      fileType: fileType,
      fileSizeBytes: fileSizeBytes,
      hasVideo: hasVideo,
      videoType: json['video_type'] as String?,
      videoUrl: videoUrl,
      videoDurationSeconds: json['video_duration_seconds'] as int?,
      isPublished: json['is_published'] as bool? ?? true,
      isPremium: json['is_premium'] as bool? ?? false,
      tags: detailed ? _parseTags(json['tags']) : [],
      viewsCount: json['views_count'] as int? ?? 0,
      downloadsCount: json['downloads_count'] as int? ?? 0,
      averageRating: _parseDouble(json['average_rating']),
      ratingsCount: json['total_ratings'] as int? ?? json['ratings_count'] as int?,
      // Parse user progress from API response
      progressPercentage: userProgress != null
          ? _parseDouble(userProgress['progress_percentage'])
          : null,
      progressStatus: userProgress?['status'] as String?,
      timeSpentMinutes: userProgress != null
          ? ((userProgress['time_spent_seconds'] as int?) ?? 0) ~/ 60
          : null,
      lastAccessedAt: _parseDateTime(userProgress?['last_accessed_at']),
      completedAt: _parseDateTime(userProgress?['completed_at']),
    );
  }
}
