import '../../domain/entities/session_content.dart';

/// Model for SessionContent with JSON serialization
class SessionContentModel extends SessionContent {
  const SessionContentModel({
    required super.id,
    required super.titleAr,
    required super.level,
    super.parentTitle,
    super.requiresUnderstanding,
    super.requiresReview,
    super.requiresTheoryPractice,
    super.requiresExercisePractice,
    super.progress,
  });

  /// Create from JSON response
  factory SessionContentModel.fromJson(Map<String, dynamic> json) {
    return SessionContentModel(
      id: json['id'].toString(),
      titleAr: json['title_ar'] as String? ?? '',
      level: json['level'] as String? ?? 'topic',
      parentTitle: json['parent_title'] as String?,
      requiresUnderstanding: json['requires_understanding'] as bool? ?? true,
      requiresReview: json['requires_review'] as bool? ?? true,
      requiresTheoryPractice: json['requires_theory_practice'] as bool? ?? false,
      requiresExercisePractice: json['requires_exercise_practice'] as bool? ?? false,
      progress: json['progress'] != null
          ? SessionContentProgressModel.fromJson(json['progress'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_ar': titleAr,
      'level': level,
      'parent_title': parentTitle,
      'requires_understanding': requiresUnderstanding,
      'requires_review': requiresReview,
      'requires_theory_practice': requiresTheoryPractice,
      'requires_exercise_practice': requiresExercisePractice,
      'progress': progress != null
          ? (progress as SessionContentProgressModel).toJson()
          : null,
    };
  }

  /// Convert to entity
  SessionContent toEntity() {
    return SessionContent(
      id: id,
      titleAr: titleAr,
      level: level,
      parentTitle: parentTitle,
      requiresUnderstanding: requiresUnderstanding,
      requiresReview: requiresReview,
      requiresTheoryPractice: requiresTheoryPractice,
      requiresExercisePractice: requiresExercisePractice,
      progress: progress,
    );
  }

  /// Create from entity
  factory SessionContentModel.fromEntity(SessionContent entity) {
    return SessionContentModel(
      id: entity.id,
      titleAr: entity.titleAr,
      level: entity.level,
      parentTitle: entity.parentTitle,
      requiresUnderstanding: entity.requiresUnderstanding,
      requiresReview: entity.requiresReview,
      requiresTheoryPractice: entity.requiresTheoryPractice,
      requiresExercisePractice: entity.requiresExercisePractice,
      progress: entity.progress,
    );
  }
}

/// Model for SessionContentProgress with JSON serialization
class SessionContentProgressModel extends SessionContentProgress {
  const SessionContentProgressModel({
    required super.status,
    super.understandingCompleted,
    super.reviewCompleted,
    super.theoryPracticeCompleted,
    super.exercisePracticeCompleted,
    super.completionPercentage,
  });

  /// Create from JSON
  factory SessionContentProgressModel.fromJson(Map<String, dynamic> json) {
    return SessionContentProgressModel(
      status: json['status'] as String? ?? 'not_started',
      understandingCompleted: json['understanding_completed'] as bool? ?? false,
      reviewCompleted: json['review_completed'] as bool? ?? false,
      theoryPracticeCompleted: json['theory_practice_completed'] as bool? ?? false,
      exercisePracticeCompleted: json['exercise_practice_completed'] as bool? ?? false,
      completionPercentage: json['completion_percentage'] as int? ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'understanding_completed': understandingCompleted,
      'review_completed': reviewCompleted,
      'theory_practice_completed': theoryPracticeCompleted,
      'exercise_practice_completed': exercisePracticeCompleted,
      'completion_percentage': completionPercentage,
    };
  }
}

/// Model for SessionContentMeta with JSON serialization
class SessionContentMetaModel extends SessionContentMeta {
  const SessionContentMetaModel({
    required super.sessionType,
    required super.phaseToComplete,
    required super.totalAvailable,
    super.hasContent,
    super.placeholderMessage,
  });

  /// Create from JSON
  factory SessionContentMetaModel.fromJson(Map<String, dynamic> json) {
    return SessionContentMetaModel(
      sessionType: json['session_type'] as String? ?? 'study',
      phaseToComplete: json['phase_to_complete'] as String? ?? 'understanding',
      totalAvailable: json['total_available'] as int? ?? 0,
      hasContent: json['has_content'] as bool? ?? true,
      placeholderMessage: json['placeholder_message'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'session_type': sessionType,
      'phase_to_complete': phaseToComplete,
      'total_available': totalAvailable,
      'has_content': hasContent,
      'placeholder_message': placeholderMessage,
    };
  }

  /// Convert to entity
  SessionContentMeta toEntity() {
    return SessionContentMeta(
      sessionType: sessionType,
      phaseToComplete: phaseToComplete,
      totalAvailable: totalAvailable,
      hasContent: hasContent,
      placeholderMessage: placeholderMessage,
    );
  }
}

/// Response wrapper for session content API
class SessionContentResponse {
  final List<SessionContent> contents;
  final SessionContentMeta meta;

  const SessionContentResponse({
    required this.contents,
    required this.meta,
  });

  /// Create from JSON API response
  factory SessionContentResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    final metaJson = json['meta'] as Map<String, dynamic>? ?? {};

    return SessionContentResponse(
      contents: dataList
          .map((item) => SessionContentModel.fromJson(item as Map<String, dynamic>).toEntity())
          .toList(),
      meta: SessionContentMetaModel.fromJson(metaJson).toEntity(),
    );
  }
}
