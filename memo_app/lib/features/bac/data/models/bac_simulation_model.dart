import '../../domain/entities/bac_simulation_entity.dart';
import '../../domain/entities/bac_enums.dart';
import '../../domain/entities/chapter_score_entity.dart';
import 'chapter_score_model.dart';

/// Data model for BacSimulation that extends BacSimulationEntity
class BacSimulationModel extends BacSimulationEntity {
  const BacSimulationModel({
    required super.id,
    required super.userId,
    required super.bacSubjectId,
    super.bacYearSlug,
    super.bacSessionSlug,
    required super.mode,
    super.difficulty,
    super.selectedChapterIds,
    required super.totalQuestions,
    required super.durationMinutes,
    required super.status,
    required super.startedAt,
    super.pausedAt,
    super.completedAt,
    super.elapsedSeconds,
    super.remainingSeconds,
    super.answeredQuestions,
    super.correctAnswers,
    super.wrongAnswers,
    super.skippedQuestions,
    super.score,
    super.percentage,
    super.chapterScores,
    super.notes,
  });

  /// Create BacSimulationModel from JSON
  factory BacSimulationModel.fromJson(Map<String, dynamic> json) {
    // Parse chapter scores if available
    final chapterScoresJson = json['chapter_scores'] as List?;
    final chapterScores =
        chapterScoresJson
            ?.map(
              (score) =>
                  ChapterScoreModel.fromJson(score as Map<String, dynamic>),
            )
            .toList() ??
        [];

    // Parse selected chapter IDs
    final selectedChapterIdsJson = json['selected_chapter_ids'] as List?;
    final selectedChapterIds =
        selectedChapterIdsJson?.map((id) => id as int).toList() ?? [];

    return BacSimulationModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      bacSubjectId: json['bac_subject_id'] as int,
      bacYearSlug: json['bac_year_slug'] as String?,
      bacSessionSlug: json['bac_session_slug'] as String?,
      mode: _parseSimulationMode(json['mode'] as String),
      difficulty: json['difficulty'] != null
          ? _parseDifficultyLevel(json['difficulty'] as String)
          : null,
      selectedChapterIds: selectedChapterIds,
      totalQuestions: json['total_questions'] as int,
      durationMinutes: json['duration_minutes'] as int,
      status: _parseSimulationStatus(json['status'] as String),
      startedAt: DateTime.parse(json['started_at'] as String),
      pausedAt: json['paused_at'] != null
          ? DateTime.parse(json['paused_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      elapsedSeconds: json['elapsed_seconds'] as int? ?? 0,
      remainingSeconds: json['remaining_seconds'] as int? ?? 0,
      answeredQuestions: json['answered_questions'] as int? ?? 0,
      correctAnswers: json['correct_answers'] as int? ?? 0,
      wrongAnswers: json['wrong_answers'] as int? ?? 0,
      skippedQuestions: json['skipped_questions'] as int? ?? 0,
      score: _parseDouble(json['score']),
      percentage: _parseDouble(json['percentage']),
      chapterScores: chapterScores,
      notes: json['notes'] as String?,
    );
  }

  /// Convert BacSimulationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bac_subject_id': bacSubjectId,
      'bac_year_slug': bacYearSlug,
      'bac_session_slug': bacSessionSlug,
      'mode': _simulationModeToString(mode),
      'difficulty': difficulty != null
          ? _difficultyLevelToString(difficulty!)
          : null,
      'selected_chapter_ids': selectedChapterIds,
      'total_questions': totalQuestions,
      'duration_minutes': durationMinutes,
      'status': _simulationStatusToString(status),
      'started_at': startedAt.toIso8601String(),
      'paused_at': pausedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'elapsed_seconds': elapsedSeconds,
      'remaining_seconds': remainingSeconds,
      'answered_questions': answeredQuestions,
      'correct_answers': correctAnswers,
      'wrong_answers': wrongAnswers,
      'skipped_questions': skippedQuestions,
      'score': score,
      'percentage': percentage,
      'chapter_scores': chapterScores
          .map((score) => ChapterScoreModel.fromEntity(score).toJson())
          .toList(),
      'notes': notes,
    };
  }

  /// Create BacSimulationModel from BacSimulationEntity
  factory BacSimulationModel.fromEntity(BacSimulationEntity entity) {
    return BacSimulationModel(
      id: entity.id,
      userId: entity.userId,
      bacSubjectId: entity.bacSubjectId,
      bacYearSlug: entity.bacYearSlug,
      bacSessionSlug: entity.bacSessionSlug,
      mode: entity.mode,
      difficulty: entity.difficulty,
      selectedChapterIds: entity.selectedChapterIds,
      totalQuestions: entity.totalQuestions,
      durationMinutes: entity.durationMinutes,
      status: entity.status,
      startedAt: entity.startedAt,
      pausedAt: entity.pausedAt,
      completedAt: entity.completedAt,
      elapsedSeconds: entity.elapsedSeconds,
      remainingSeconds: entity.remainingSeconds,
      answeredQuestions: entity.answeredQuestions,
      correctAnswers: entity.correctAnswers,
      wrongAnswers: entity.wrongAnswers,
      skippedQuestions: entity.skippedQuestions,
      score: entity.score,
      percentage: entity.percentage,
      chapterScores: entity.chapterScores,
      notes: entity.notes,
    );
  }

  /// Helper methods for enum parsing
  static SimulationStatus _parseSimulationStatus(String value) {
    switch (value.toLowerCase()) {
      case 'not_started':
        return SimulationStatus.notStarted;
      case 'in_progress':
        return SimulationStatus.inProgress;
      case 'paused':
        return SimulationStatus.paused;
      case 'completed':
        return SimulationStatus.completed;
      case 'abandoned':
        return SimulationStatus.abandoned;
      default:
        return SimulationStatus.notStarted;
    }
  }

  static String _simulationStatusToString(SimulationStatus status) {
    switch (status) {
      case SimulationStatus.notStarted:
        return 'not_started';
      case SimulationStatus.inProgress:
        return 'in_progress';
      case SimulationStatus.paused:
        return 'paused';
      case SimulationStatus.completed:
        return 'completed';
      case SimulationStatus.abandoned:
        return 'abandoned';
    }
  }

  static SimulationMode _parseSimulationMode(String value) {
    switch (value.toLowerCase()) {
      case 'practice':
        return SimulationMode.practice;
      case 'exam':
        return SimulationMode.exam;
      case 'quick':
        return SimulationMode.quick;
      default:
        return SimulationMode.practice;
    }
  }

  static String _simulationModeToString(SimulationMode mode) {
    switch (mode) {
      case SimulationMode.practice:
        return 'practice';
      case SimulationMode.exam:
        return 'exam';
      case SimulationMode.quick:
        return 'quick';
    }
  }

  static DifficultyLevel _parseDifficultyLevel(String value) {
    switch (value.toLowerCase()) {
      case 'easy':
        return DifficultyLevel.easy;
      case 'medium':
        return DifficultyLevel.medium;
      case 'hard':
        return DifficultyLevel.hard;
      case 'mixed':
        return DifficultyLevel.mixed;
      default:
        return DifficultyLevel.medium;
    }
  }

  static String _difficultyLevelToString(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.easy:
        return 'easy';
      case DifficultyLevel.medium:
        return 'medium';
      case DifficultyLevel.hard:
        return 'hard';
      case DifficultyLevel.mixed:
        return 'mixed';
    }
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Copy with method
  BacSimulationModel copyWith({
    int? id,
    int? userId,
    int? bacSubjectId,
    String? bacYearSlug,
    String? bacSessionSlug,
    SimulationMode? mode,
    DifficultyLevel? difficulty,
    List<int>? selectedChapterIds,
    int? totalQuestions,
    int? durationMinutes,
    SimulationStatus? status,
    DateTime? startedAt,
    DateTime? pausedAt,
    DateTime? completedAt,
    int? elapsedSeconds,
    int? remainingSeconds,
    int? answeredQuestions,
    int? correctAnswers,
    int? wrongAnswers,
    int? skippedQuestions,
    double? score,
    double? percentage,
    List<ChapterScoreEntity>? chapterScores,
    String? notes,
  }) {
    return BacSimulationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bacSubjectId: bacSubjectId ?? this.bacSubjectId,
      bacYearSlug: bacYearSlug ?? this.bacYearSlug,
      bacSessionSlug: bacSessionSlug ?? this.bacSessionSlug,
      mode: mode ?? this.mode,
      difficulty: difficulty ?? this.difficulty,
      selectedChapterIds: selectedChapterIds ?? this.selectedChapterIds,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      completedAt: completedAt ?? this.completedAt,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      answeredQuestions: answeredQuestions ?? this.answeredQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      skippedQuestions: skippedQuestions ?? this.skippedQuestions,
      score: score ?? this.score,
      percentage: percentage ?? this.percentage,
      chapterScores: chapterScores ?? this.chapterScores,
      notes: notes ?? this.notes,
    );
  }
}
