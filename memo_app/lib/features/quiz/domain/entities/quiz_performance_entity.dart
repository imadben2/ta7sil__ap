import 'package:equatable/equatable.dart';

/// Quiz performance entity tracking user's overall quiz statistics
///
/// Provides insights into:
/// - Overall performance across all quizzes
/// - Subject-specific performance
/// - Weak question types
/// - Improvement trends
class QuizPerformanceEntity extends Equatable {
  /// Overall statistics
  final OverallStats overall;

  /// Performance by subject
  final List<SubjectPerformance> bySubject;

  /// Performance by question type
  final Map<String, QuestionTypeStats> byQuestionType;

  const QuizPerformanceEntity({
    required this.overall,
    required this.bySubject,
    required this.byQuestionType,
  });

  /// Get weak question types (accuracy < 60%)
  List<String> get weakQuestionTypes {
    return byQuestionType.entries
        .where((entry) => entry.value.accuracy < 60.0)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get strong question types (accuracy >= 80%)
  List<String> get strongQuestionTypes {
    return byQuestionType.entries
        .where((entry) => entry.value.accuracy >= 80.0)
        .map((entry) => entry.key)
        .toList();
  }

  @override
  List<Object?> get props => [overall, bySubject, byQuestionType];
}

/// Overall quiz statistics
class OverallStats extends Equatable {
  /// Total number of quiz attempts
  final int totalAttempts;

  /// Total number of unique quizzes taken
  final int totalQuizzes;

  /// Average score percentage
  final double averageScore;

  /// Best score achieved
  final double bestScore;

  /// Pass rate percentage
  final double passRate;

  /// Total time spent in hours
  final double totalTimeSpentHours;

  const OverallStats({
    required this.totalAttempts,
    required this.totalQuizzes,
    required this.averageScore,
    required this.bestScore,
    required this.passRate,
    required this.totalTimeSpentHours,
  });

  @override
  List<Object?> get props => [
    totalAttempts,
    totalQuizzes,
    averageScore,
    bestScore,
    passRate,
    totalTimeSpentHours,
  ];
}

/// Performance for a specific subject
class SubjectPerformance extends Equatable {
  /// Subject ID
  final int subjectId;

  /// Subject name in Arabic
  final String subjectNameAr;

  /// Number of attempts in this subject
  final int attempts;

  /// Average score in this subject
  final double averageScore;

  /// Best score in this subject
  final double bestScore;

  /// Weak concepts in this subject
  final List<WeakConcept> weakConcepts;

  const SubjectPerformance({
    required this.subjectId,
    required this.subjectNameAr,
    required this.attempts,
    required this.averageScore,
    required this.bestScore,
    required this.weakConcepts,
  });

  @override
  List<Object?> get props => [
    subjectId,
    subjectNameAr,
    attempts,
    averageScore,
    bestScore,
    weakConcepts,
  ];
}

/// Weak concept in a subject
class WeakConcept extends Equatable {
  /// Concept name
  final String concept;

  /// Error rate percentage
  final double errorRate;

  const WeakConcept({required this.concept, required this.errorRate});

  @override
  List<Object?> get props => [concept, errorRate];
}

/// Statistics for a question type
class QuestionTypeStats extends Equatable {
  /// Question type
  final String questionType;

  /// Total questions of this type
  final int total;

  /// Correct answers
  final int correct;

  /// Accuracy percentage
  final double accuracy;

  const QuestionTypeStats({
    required this.questionType,
    required this.total,
    required this.correct,
    required this.accuracy,
  });

  /// Get question type name in Arabic
  String get questionTypeAr {
    switch (questionType) {
      case 'single_choice':
        return 'اختيار واحد';
      case 'multiple_choice':
        return 'اختيار متعدد';
      case 'true_false':
        return 'صح أم خطأ';
      case 'matching':
        return 'المطابقة';
      case 'ordering':
        return 'الترتيب';
      case 'fill_blank':
        return 'املأ الفراغ';
      case 'short_answer':
        return 'إجابة قصيرة';
      case 'numeric':
        return 'رقمية';
      default:
        return questionType;
    }
  }

  @override
  List<Object?> get props => [questionType, total, correct, accuracy];
}
