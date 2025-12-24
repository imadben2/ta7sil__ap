import 'package:equatable/equatable.dart';

/// Entity representing curriculum content assigned to a study session
///
/// This is a simplified view of SubjectPlannerContent for display in sessions
class SessionContent extends Equatable {
  /// Unique identifier (from subject_planner_content table)
  final String id;

  /// Arabic title of the content
  final String titleAr;

  /// Hierarchy level: 'topic', 'subtopic', or 'learning_objective'
  final String level;

  /// Parent context for display (e.g., "Unit Name > Topic Name")
  final String? parentTitle;

  /// Study phase requirements
  final bool requiresUnderstanding;
  final bool requiresReview;
  final bool requiresTheoryPractice;
  final bool requiresExercisePractice;

  /// User progress for this content item (null if not started)
  final SessionContentProgress? progress;

  const SessionContent({
    required this.id,
    required this.titleAr,
    required this.level,
    this.parentTitle,
    this.requiresUnderstanding = true,
    this.requiresReview = true,
    this.requiresTheoryPractice = false,
    this.requiresExercisePractice = false,
    this.progress,
  });

  /// Check if a specific phase is completed
  bool isPhaseCompleted(String phase) {
    if (progress == null) return false;
    return switch (phase) {
      'understanding' => progress!.understandingCompleted,
      'review' => progress!.reviewCompleted,
      'theory_practice' => progress!.theoryPracticeCompleted,
      'exercise_practice' => progress!.exercisePracticeCompleted,
      _ => false,
    };
  }

  /// Check if content requires a specific phase
  bool requiresPhase(String phase) {
    return switch (phase) {
      'understanding' => requiresUnderstanding,
      'review' => requiresReview,
      'theory_practice' => requiresTheoryPractice,
      'exercise_practice' => requiresExercisePractice,
      _ => false,
    };
  }

  @override
  List<Object?> get props => [
    id,
    titleAr,
    level,
    parentTitle,
    requiresUnderstanding,
    requiresReview,
    requiresTheoryPractice,
    requiresExercisePractice,
    progress,
  ];
}

/// User progress for a session content item
class SessionContentProgress extends Equatable {
  final String status; // 'not_started', 'in_progress', 'completed', 'mastered'
  final bool understandingCompleted;
  final bool reviewCompleted;
  final bool theoryPracticeCompleted;
  final bool exercisePracticeCompleted;
  final int completionPercentage;

  const SessionContentProgress({
    required this.status,
    this.understandingCompleted = false,
    this.reviewCompleted = false,
    this.theoryPracticeCompleted = false,
    this.exercisePracticeCompleted = false,
    this.completionPercentage = 0,
  });

  @override
  List<Object?> get props => [
    status,
    understandingCompleted,
    reviewCompleted,
    theoryPracticeCompleted,
    exercisePracticeCompleted,
    completionPercentage,
  ];
}

/// Metadata about the session content response
class SessionContentMeta extends Equatable {
  final String sessionType;
  final String phaseToComplete;
  final int totalAvailable;

  /// Whether content exists for user's stream
  final bool hasContent;

  /// Placeholder message when no content exists (Arabic)
  final String? placeholderMessage;

  const SessionContentMeta({
    required this.sessionType,
    required this.phaseToComplete,
    required this.totalAvailable,
    this.hasContent = true,
    this.placeholderMessage,
  });

  /// Get Arabic name for the phase
  String get phaseNameAr {
    return switch (phaseToComplete) {
      'understanding' => 'الفهم',
      'review' => 'المراجعة',
      'theory_practice' => 'الحل النظري',
      'exercise_practice' => 'حل التمارين',
      _ => 'الفهم',
    };
  }

  @override
  List<Object?> get props => [
        sessionType,
        phaseToComplete,
        totalAvailable,
        hasContent,
        placeholderMessage,
      ];
}
