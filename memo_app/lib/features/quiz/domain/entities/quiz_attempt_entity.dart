import 'package:equatable/equatable.dart';
import 'question_entity.dart';

/// Quiz attempt entity representing a user's quiz session
///
/// Tracks the entire lifecycle of taking a quiz:
/// - Start time and status
/// - Questions presented
/// - Answers given
/// - Time spent
/// - Final score (after submission)
class QuizAttemptEntity extends Equatable {
  /// Unique identifier
  final int id;

  /// Quiz ID being attempted
  final int quizId;

  /// User ID taking the quiz
  final int userId;

  /// When the attempt started
  final DateTime startedAt;

  /// When the attempt was completed/submitted
  final DateTime? completedAt;

  /// Current status
  final QuizAttemptStatus status;

  /// Time limit for this attempt (seconds)
  final int? timeLimitSeconds;

  /// When the attempt expires (for timed quizzes)
  final DateTime? expiresAt;

  /// Time spent so far (seconds)
  final int timeSpentSeconds;

  /// Questions in this attempt (with shuffled order if applicable)
  final List<QuestionEntity> questions;

  /// Answers given so far (question_id → answer)
  final Map<int, dynamic> answers;

  /// Score information (null until submitted)
  final QuizScore? score;

  const QuizAttemptEntity({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.startedAt,
    this.completedAt,
    required this.status,
    this.timeLimitSeconds,
    this.expiresAt,
    required this.timeSpentSeconds,
    required this.questions,
    required this.answers,
    this.score,
  });

  /// Check if attempt is in progress
  bool get isInProgress => status == QuizAttemptStatus.inProgress;

  /// Check if attempt is completed
  bool get isCompleted => status == QuizAttemptStatus.completed;

  /// Check if attempt is abandoned
  bool get isAbandoned => status == QuizAttemptStatus.abandoned;

  /// Check if attempt has expired
  bool get hasExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get time remaining (seconds)
  int? get timeRemainingSeconds {
    if (expiresAt == null) return null;
    final remaining = expiresAt!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Get progress (answered / total questions)
  double get progress {
    if (questions.isEmpty) return 0.0;
    return answers.length / questions.length;
  }

  /// Get number of answered questions
  int get answeredCount => answers.length;

  /// Get number of unanswered questions
  int get unansweredCount => questions.length - answers.length;

  /// Check if all questions are answered
  bool get allQuestionsAnswered => answeredCount == questions.length;

  /// Copy with method for immutability
  QuizAttemptEntity copyWith({
    int? id,
    int? quizId,
    int? userId,
    DateTime? startedAt,
    DateTime? completedAt,
    QuizAttemptStatus? status,
    int? timeLimitSeconds,
    DateTime? expiresAt,
    int? timeSpentSeconds,
    List<QuestionEntity>? questions,
    Map<int, dynamic>? answers,
    QuizScore? score,
  }) {
    return QuizAttemptEntity(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      expiresAt: expiresAt ?? this.expiresAt,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      score: score ?? this.score,
    );
  }

  @override
  List<Object?> get props => [
    id,
    quizId,
    userId,
    startedAt,
    completedAt,
    status,
    timeLimitSeconds,
    expiresAt,
    timeSpentSeconds,
    questions,
    answers,
    score,
  ];
}

/// Quiz attempt status enum
enum QuizAttemptStatus {
  /// Attempt is in progress
  inProgress,

  /// Attempt is completed and submitted
  completed,

  /// Attempt was abandoned
  abandoned,
}

/// Quiz score information
class QuizScore extends Equatable {
  /// Final score percentage
  final double percentage;

  /// Total points possible
  final double totalPoints;

  /// Points earned
  final double earnedPoints;

  /// Whether user passed
  final bool passed;

  /// Number of correct answers
  final int correctAnswers;

  /// Number of incorrect answers
  final int incorrectAnswers;

  /// Number of skipped answers
  final int skippedAnswers;

  const QuizScore({
    required this.percentage,
    required this.totalPoints,
    required this.earnedPoints,
    required this.passed,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.skippedAnswers,
  });

  @override
  List<Object?> get props => [
    percentage,
    totalPoints,
    earnedPoints,
    passed,
    correctAnswers,
    incorrectAnswers,
    skippedAnswers,
  ];
}
