import '../../domain/entities/simulation_results_entity.dart';
import '../../domain/entities/bac_enums.dart';
import '../../domain/entities/chapter_score_entity.dart';
import 'chapter_score_model.dart';

/// Data model for SimulationResults that extends SimulationResultsEntity
class SimulationResultsModel extends SimulationResultsEntity {
  const SimulationResultsModel({
    required super.simulationId,
    required super.bacSubjectId,
    required super.subjectNameAr,
    super.subjectColor,
    required super.score,
    required super.percentage,
    required super.totalQuestions,
    required super.correctAnswers,
    required super.wrongAnswers,
    required super.skippedQuestions,
    required super.totalDurationMinutes,
    required super.actualTimeSpentSeconds,
    required super.averageTimePerQuestion,
    super.chapterBreakdown,
    super.difficultyBreakdown,
    super.strongChapters,
    super.weakChapters,
    super.recommendations,
    super.rank,
    super.totalParticipants,
    super.percentile,
    required super.completedAt,
    required super.mode,
    super.difficulty,
  });

  /// Create SimulationResultsModel from JSON
  factory SimulationResultsModel.fromJson(Map<String, dynamic> json) {
    // Parse chapter breakdown
    final chapterBreakdownJson = json['chapter_breakdown'] as List?;
    final chapterBreakdown =
        chapterBreakdownJson
            ?.map(
              (score) =>
                  ChapterScoreModel.fromJson(score as Map<String, dynamic>),
            )
            .toList() ??
        [];

    // Parse difficulty breakdown
    final difficultyBreakdownJson =
        json['difficulty_breakdown'] as Map<String, dynamic>?;
    final difficultyBreakdown = <String, double>{};
    if (difficultyBreakdownJson != null) {
      difficultyBreakdownJson.forEach((key, value) {
        difficultyBreakdown[key] = _parseDouble(value) ?? 0.0;
      });
    }

    // Parse strong/weak chapters
    final strongChaptersJson = json['strong_chapters'] as List?;
    final strongChapters =
        strongChaptersJson?.map((chapter) => chapter as String).toList() ?? [];

    final weakChaptersJson = json['weak_chapters'] as List?;
    final weakChapters =
        weakChaptersJson?.map((chapter) => chapter as String).toList() ?? [];

    // Parse recommendations
    final recommendationsJson = json['recommendations'] as List?;
    final recommendations =
        recommendationsJson?.map((rec) => rec as String).toList() ?? [];

    // Parse ranking info
    final rankingJson = json['ranking'] as Map<String, dynamic>?;

    return SimulationResultsModel(
      simulationId: json['simulation_id'] as int,
      bacSubjectId: json['bac_subject_id'] as int,
      subjectNameAr: json['subject_name_ar'] as String,
      subjectColor: json['subject_color'] as String?,
      score: _parseDouble(json['score'])!,
      percentage: _parseDouble(json['percentage'])!,
      totalQuestions: json['total_questions'] as int,
      correctAnswers: json['correct_answers'] as int,
      wrongAnswers: json['wrong_answers'] as int,
      skippedQuestions: json['skipped_questions'] as int,
      totalDurationMinutes: json['total_duration_minutes'] as int,
      actualTimeSpentSeconds: json['actual_time_spent_seconds'] as int,
      averageTimePerQuestion: _parseDouble(json['average_time_per_question'])!,
      chapterBreakdown: chapterBreakdown,
      difficultyBreakdown: difficultyBreakdown,
      strongChapters: strongChapters,
      weakChapters: weakChapters,
      recommendations: recommendations,
      rank: rankingJson?['rank'] as int?,
      totalParticipants: rankingJson?['total_participants'] as int?,
      percentile: _parseDouble(rankingJson?['percentile']),
      completedAt: DateTime.parse(json['completed_at'] as String),
      mode: _parseSimulationMode(json['mode'] as String),
      difficulty: json['difficulty'] != null
          ? _parseDifficultyLevel(json['difficulty'] as String)
          : null,
    );
  }

  /// Convert SimulationResultsModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'simulation_id': simulationId,
      'bac_subject_id': bacSubjectId,
      'subject_name_ar': subjectNameAr,
      'subject_color': subjectColor,
      'score': score,
      'percentage': percentage,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'wrong_answers': wrongAnswers,
      'skipped_questions': skippedQuestions,
      'total_duration_minutes': totalDurationMinutes,
      'actual_time_spent_seconds': actualTimeSpentSeconds,
      'average_time_per_question': averageTimePerQuestion,
      'chapter_breakdown': chapterBreakdown
          .map((score) => ChapterScoreModel.fromEntity(score).toJson())
          .toList(),
      'difficulty_breakdown': difficultyBreakdown,
      'strong_chapters': strongChapters,
      'weak_chapters': weakChapters,
      'recommendations': recommendations,
      'ranking': {
        'rank': rank,
        'total_participants': totalParticipants,
        'percentile': percentile,
      },
      'completed_at': completedAt.toIso8601String(),
      'mode': _simulationModeToString(mode),
      'difficulty': difficulty != null
          ? _difficultyLevelToString(difficulty!)
          : null,
    };
  }

  /// Create SimulationResultsModel from SimulationResultsEntity
  factory SimulationResultsModel.fromEntity(SimulationResultsEntity entity) {
    return SimulationResultsModel(
      simulationId: entity.simulationId,
      bacSubjectId: entity.bacSubjectId,
      subjectNameAr: entity.subjectNameAr,
      subjectColor: entity.subjectColor,
      score: entity.score,
      percentage: entity.percentage,
      totalQuestions: entity.totalQuestions,
      correctAnswers: entity.correctAnswers,
      wrongAnswers: entity.wrongAnswers,
      skippedQuestions: entity.skippedQuestions,
      totalDurationMinutes: entity.totalDurationMinutes,
      actualTimeSpentSeconds: entity.actualTimeSpentSeconds,
      averageTimePerQuestion: entity.averageTimePerQuestion,
      chapterBreakdown: entity.chapterBreakdown,
      difficultyBreakdown: entity.difficultyBreakdown,
      strongChapters: entity.strongChapters,
      weakChapters: entity.weakChapters,
      recommendations: entity.recommendations,
      rank: entity.rank,
      totalParticipants: entity.totalParticipants,
      percentile: entity.percentile,
      completedAt: entity.completedAt,
      mode: entity.mode,
      difficulty: entity.difficulty,
    );
  }

  /// Helper methods for enum parsing
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
  SimulationResultsModel copyWith({
    int? simulationId,
    int? bacSubjectId,
    String? subjectNameAr,
    String? subjectColor,
    double? score,
    double? percentage,
    int? totalQuestions,
    int? correctAnswers,
    int? wrongAnswers,
    int? skippedQuestions,
    int? totalDurationMinutes,
    int? actualTimeSpentSeconds,
    double? averageTimePerQuestion,
    List<ChapterScoreEntity>? chapterBreakdown,
    Map<String, double>? difficultyBreakdown,
    List<String>? strongChapters,
    List<String>? weakChapters,
    List<String>? recommendations,
    int? rank,
    int? totalParticipants,
    double? percentile,
    DateTime? completedAt,
    SimulationMode? mode,
    DifficultyLevel? difficulty,
  }) {
    return SimulationResultsModel(
      simulationId: simulationId ?? this.simulationId,
      bacSubjectId: bacSubjectId ?? this.bacSubjectId,
      subjectNameAr: subjectNameAr ?? this.subjectNameAr,
      subjectColor: subjectColor ?? this.subjectColor,
      score: score ?? this.score,
      percentage: percentage ?? this.percentage,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      skippedQuestions: skippedQuestions ?? this.skippedQuestions,
      totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
      actualTimeSpentSeconds:
          actualTimeSpentSeconds ?? this.actualTimeSpentSeconds,
      averageTimePerQuestion:
          averageTimePerQuestion ?? this.averageTimePerQuestion,
      chapterBreakdown: chapterBreakdown ?? this.chapterBreakdown,
      difficultyBreakdown: difficultyBreakdown ?? this.difficultyBreakdown,
      strongChapters: strongChapters ?? this.strongChapters,
      weakChapters: weakChapters ?? this.weakChapters,
      recommendations: recommendations ?? this.recommendations,
      rank: rank ?? this.rank,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      percentile: percentile ?? this.percentile,
      completedAt: completedAt ?? this.completedAt,
      mode: mode ?? this.mode,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
