import 'package:equatable/equatable.dart';
import 'bac_enums.dart';
import 'chapter_score_entity.dart';

/// Entity representing a BAC simulation session
class BacSimulationEntity extends Equatable {
  final int id;
  final int userId;
  final int bacSubjectId;
  final String? bacYearSlug;
  final String? bacSessionSlug;

  // Simulation configuration
  final SimulationMode mode;
  final DifficultyLevel? difficulty;
  final List<int> selectedChapterIds; // Empty = all chapters
  final int totalQuestions;
  final int durationMinutes;

  // Simulation state
  final SimulationStatus status;
  final DateTime startedAt;
  final DateTime? pausedAt;
  final DateTime? completedAt;
  final int elapsedSeconds; // Time actually spent (excluding pauses)
  final int remainingSeconds;

  // Results
  final int answeredQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedQuestions;
  final double? score; // Final score (out of 100 or 20)
  final double? percentage;

  // Chapter breakdown
  final List<ChapterScoreEntity> chapterScores;

  // User notes
  final String? notes;

  const BacSimulationEntity({
    required this.id,
    required this.userId,
    required this.bacSubjectId,
    this.bacYearSlug,
    this.bacSessionSlug,
    required this.mode,
    this.difficulty,
    this.selectedChapterIds = const [],
    required this.totalQuestions,
    required this.durationMinutes,
    required this.status,
    required this.startedAt,
    this.pausedAt,
    this.completedAt,
    this.elapsedSeconds = 0,
    this.remainingSeconds = 0,
    this.answeredQuestions = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.skippedQuestions = 0,
    this.score,
    this.percentage,
    this.chapterScores = const [],
    this.notes,
  });

  /// Check if simulation is currently running
  bool get isRunning => status == SimulationStatus.inProgress;

  /// Check if simulation is paused
  bool get isPaused => status == SimulationStatus.paused;

  /// Check if simulation is completed
  bool get isCompleted => status == SimulationStatus.completed;

  /// Get progress percentage (0-100)
  double get progressPercentage {
    if (totalQuestions == 0) return 0.0;
    return (answeredQuestions / totalQuestions) * 100;
  }

  /// Formatted elapsed time (HH:MM:SS)
  String get formattedElapsedTime {
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formatted remaining time (HH:MM:SS)
  String get formattedRemainingTime {
    final hours = remainingSeconds ~/ 3600;
    final minutes = (remainingSeconds % 3600) ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get appropriate timer alert based on remaining time
  TimerAlert? get currentAlert {
    if (remainingSeconds <= 0) return TimerAlert.timeUp;
    if (remainingSeconds <= 60) return TimerAlert.oneMinute;
    if (remainingSeconds <= 300) return TimerAlert.fiveMinutes;
    if (remainingSeconds <= 600) return TimerAlert.tenMinutes;
    if (remainingSeconds <= 1800) return TimerAlert.thirtyMinutes;
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    bacSubjectId,
    bacYearSlug,
    bacSessionSlug,
    mode,
    difficulty,
    selectedChapterIds,
    totalQuestions,
    durationMinutes,
    status,
    startedAt,
    pausedAt,
    completedAt,
    elapsedSeconds,
    remainingSeconds,
    answeredQuestions,
    correctAnswers,
    wrongAnswers,
    skippedQuestions,
    score,
    percentage,
    chapterScores,
    notes,
  ];
}
