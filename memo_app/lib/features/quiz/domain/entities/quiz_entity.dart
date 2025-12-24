import 'package:equatable/equatable.dart';

/// Quiz entity representing a quiz assessment
///
/// Contains all metadata about a quiz including:
/// - Basic info (title, description)
/// - Configuration (type, time limit, difficulty)
/// - Statistics (attempts, scores)
/// - Access control (premium status)
class QuizEntity extends Equatable {
  /// Unique identifier
  final int id;

  /// Quiz title in Arabic
  final String titleAr;

  /// Optional description in Arabic
  final String? descriptionAr;

  /// Academic stream ID for filtering quizzes by user's stream
  final int? academicStreamId;

  /// Academic stream information
  final AcademicStreamInfo? academicStream;

  /// Quiz type: practice (تدريب), timed (موقت), exam (امتحان)
  final String quizType;

  /// Time limit in minutes (null for untimed quizzes)
  final int? timeLimitMinutes;

  /// Passing score percentage (default: 70%)
  final double passingScore;

  /// Difficulty level: easy (سهل), medium (متوسط), hard (صعب)
  final String difficultyLevel;

  /// Estimated duration in minutes
  final int estimatedDurationMinutes;

  /// Total number of questions in quiz
  final int totalQuestions;

  /// Average score across all attempts
  final double? averageScore;

  /// Total number of attempts by all users
  final int totalAttempts;

  /// Whether quiz requires premium subscription
  final bool isPremium;

  /// Tags for categorization (e.g., ["دوال", "تطبيقات"])
  final List<String>? tags;

  /// Subject information
  final SubjectInfo? subject;

  /// Chapter information
  final ChapterInfo? chapter;

  /// User-specific statistics
  final UserQuizStats? userStats;

  const QuizEntity({
    required this.id,
    required this.titleAr,
    this.descriptionAr,
    this.academicStreamId,
    this.academicStream,
    required this.quizType,
    this.timeLimitMinutes,
    required this.passingScore,
    required this.difficultyLevel,
    required this.estimatedDurationMinutes,
    required this.totalQuestions,
    this.averageScore,
    required this.totalAttempts,
    required this.isPremium,
    this.tags,
    this.subject,
    this.chapter,
    this.userStats,
  });

  /// Check if quiz is timed
  bool get isTimed => quizType == 'timed' || quizType == 'exam';

  /// Check if quiz is practice mode
  bool get isPractice => quizType == 'practice';

  /// Check if quiz is exam mode
  bool get isExam => quizType == 'exam';

  /// Get difficulty color
  String get difficultyColor {
    switch (difficultyLevel) {
      case 'easy':
        return '#66BB6A'; // Green
      case 'hard':
        return '#EF5350'; // Red
      default:
        return '#FFA726'; // Orange for medium
    }
  }

  /// Get quiz type display name in Arabic
  String get quizTypeAr {
    switch (quizType) {
      case 'practice':
        return 'تدريب';
      case 'timed':
        return 'موقت';
      case 'exam':
        return 'امتحان';
      default:
        return quizType;
    }
  }

  /// Get difficulty display name in Arabic
  String get difficultyAr {
    switch (difficultyLevel) {
      case 'easy':
        return 'سهل';
      case 'hard':
        return 'صعب';
      default:
        return 'متوسط';
    }
  }

  /// Alias for difficultyAr (for backward compatibility)
  String get difficultyLevelAr => difficultyAr;

  /// Calculate total points (placeholder - assumes 1 point per question)
  /// In reality, this should be calculated from actual question points
  double get totalPoints => totalQuestions.toDouble();

  @override
  List<Object?> get props => [
    id,
    titleAr,
    descriptionAr,
    academicStreamId,
    academicStream,
    quizType,
    timeLimitMinutes,
    passingScore,
    difficultyLevel,
    estimatedDurationMinutes,
    totalQuestions,
    averageScore,
    totalAttempts,
    isPremium,
    tags,
    subject,
    chapter,
    userStats,
  ];
}

/// Subject information for a quiz
class SubjectInfo extends Equatable {
  final int id;
  final String nameAr;
  final String? color;
  final String? icon;

  const SubjectInfo({
    required this.id,
    required this.nameAr,
    this.color,
    this.icon,
  });

  /// Alias for nameAr (for backward compatibility)
  String get subjectNameAr => nameAr;

  @override
  List<Object?> get props => [id, nameAr, color, icon];
}

/// Chapter information for a quiz
class ChapterInfo extends Equatable {
  final int id;
  final String nameAr;

  const ChapterInfo({required this.id, required this.nameAr});

  /// Alias for nameAr (for backward compatibility)
  String get chapterNameAr => nameAr;

  @override
  List<Object?> get props => [id, nameAr];
}

/// User-specific quiz statistics
class UserQuizStats extends Equatable {
  /// Number of attempts by this user
  final int attemptsCount;

  /// Best score achieved by this user
  final double? bestScore;

  /// Date of last attempt
  final DateTime? lastAttemptAt;

  /// ID of last completed attempt (for viewing results)
  final int? lastAttemptId;

  /// Whether user has an in-progress attempt
  final bool hasInProgress;

  const UserQuizStats({
    required this.attemptsCount,
    this.bestScore,
    this.lastAttemptAt,
    this.lastAttemptId,
    required this.hasInProgress,
  });

  /// Alias for attemptsCount (for backward compatibility)
  int get attempts => attemptsCount;

  @override
  List<Object?> get props => [
    attemptsCount,
    bestScore,
    lastAttemptAt,
    lastAttemptId,
    hasInProgress,
  ];
}

/// Academic stream information for a quiz
class AcademicStreamInfo extends Equatable {
  final int id;
  final String nameAr;
  final String? slug;

  const AcademicStreamInfo({
    required this.id,
    required this.nameAr,
    this.slug,
  });

  @override
  List<Object?> get props => [id, nameAr, slug];
}
