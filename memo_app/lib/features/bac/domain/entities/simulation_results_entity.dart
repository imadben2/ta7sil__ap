import 'package:equatable/equatable.dart';
import 'bac_enums.dart';
import 'chapter_score_entity.dart';

/// Entity representing detailed simulation results and analysis
class SimulationResultsEntity extends Equatable {
  final int simulationId;
  final int bacSubjectId;
  final String subjectNameAr;
  final String? subjectColor;

  // Basic results
  final double score;
  final double percentage;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedQuestions;

  // Time analysis
  final int totalDurationMinutes;
  final int actualTimeSpentSeconds;
  final double averageTimePerQuestion; // In seconds

  // Performance analysis
  final List<ChapterScoreEntity> chapterBreakdown;
  final Map<String, double>
  difficultyBreakdown; // easy/medium/hard -> percentage
  final List<String> strongChapters; // Chapter titles
  final List<String> weakChapters; // Chapter titles
  final List<String> recommendations; // Personalized recommendations

  // Ranking (if available)
  final int? rank;
  final int? totalParticipants;
  final double? percentile;

  // Completion info
  final DateTime completedAt;
  final SimulationMode mode;
  final DifficultyLevel? difficulty;

  const SimulationResultsEntity({
    required this.simulationId,
    required this.bacSubjectId,
    required this.subjectNameAr,
    this.subjectColor,
    required this.score,
    required this.percentage,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.skippedQuestions,
    required this.totalDurationMinutes,
    required this.actualTimeSpentSeconds,
    required this.averageTimePerQuestion,
    this.chapterBreakdown = const [],
    this.difficultyBreakdown = const {},
    this.strongChapters = const [],
    this.weakChapters = const [],
    this.recommendations = const [],
    this.rank,
    this.totalParticipants,
    this.percentile,
    required this.completedAt,
    required this.mode,
    this.difficulty,
  });

  /// Get performance grade
  String get grade {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  /// Get performance message
  String get performanceMessage {
    if (percentage >= 90) return 'أداء ممتاز! استمر في التقدم';
    if (percentage >= 80) return 'أداء جيد جداً! بإمكانك تحسين بعض النقاط';
    if (percentage >= 70) return 'أداء جيد، لكن هناك مجال للتحسين';
    if (percentage >= 60) return 'أداء مقبول، ركز على نقاط الضعف';
    if (percentage >= 50) return 'يحتاج إلى مزيد من المراجعة';
    return 'يتطلب تحسيناً كبيراً، راجع الدروس';
  }

  /// Check if time management was good
  bool get hasGoodTimeManagement {
    final idealTimePerQuestion = (totalDurationMinutes * 60) / totalQuestions;
    return averageTimePerQuestion <= idealTimePerQuestion;
  }

  /// Get time management message
  String get timeManagementMessage {
    if (hasGoodTimeManagement) {
      return 'إدارة ممتازة للوقت';
    } else {
      final overtime =
          averageTimePerQuestion -
          ((totalDurationMinutes * 60) / totalQuestions);
      return 'تحتاج لتحسين إدارة الوقت (${overtime.toStringAsFixed(1)} ث إضافية لكل سؤال)';
    }
  }

  @override
  List<Object?> get props => [
    simulationId,
    bacSubjectId,
    subjectNameAr,
    subjectColor,
    score,
    percentage,
    totalQuestions,
    correctAnswers,
    wrongAnswers,
    skippedQuestions,
    totalDurationMinutes,
    actualTimeSpentSeconds,
    averageTimePerQuestion,
    chapterBreakdown,
    difficultyBreakdown,
    strongChapters,
    weakChapters,
    recommendations,
    rank,
    totalParticipants,
    percentile,
    completedAt,
    mode,
    difficulty,
  ];
}
