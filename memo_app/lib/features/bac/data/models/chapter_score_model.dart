import '../../domain/entities/chapter_score_entity.dart';

/// Data model for ChapterScore that extends ChapterScoreEntity
class ChapterScoreModel extends ChapterScoreEntity {
  const ChapterScoreModel({
    required super.chapterId,
    required super.chapterTitleAr,
    required super.totalQuestions,
    super.answeredQuestions,
    super.correctAnswers,
    super.wrongAnswers,
    super.skippedQuestions,
    super.percentage,
    super.score,
  });

  /// Create ChapterScoreModel from JSON
  factory ChapterScoreModel.fromJson(Map<String, dynamic> json) {
    return ChapterScoreModel(
      chapterId: json['chapter_id'] as int,
      chapterTitleAr: json['chapter_title_ar'] as String,
      totalQuestions: json['total_questions'] as int,
      answeredQuestions: json['answered_questions'] as int? ?? 0,
      correctAnswers: json['correct_answers'] as int? ?? 0,
      wrongAnswers: json['wrong_answers'] as int? ?? 0,
      skippedQuestions: json['skipped_questions'] as int? ?? 0,
      percentage: _parseDouble(json['percentage']) ?? 0.0,
      score: _parseDouble(json['score']),
    );
  }

  /// Convert ChapterScoreModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'chapter_id': chapterId,
      'chapter_title_ar': chapterTitleAr,
      'total_questions': totalQuestions,
      'answered_questions': answeredQuestions,
      'correct_answers': correctAnswers,
      'wrong_answers': wrongAnswers,
      'skipped_questions': skippedQuestions,
      'percentage': percentage,
      'score': score,
    };
  }

  /// Create ChapterScoreModel from ChapterScoreEntity
  factory ChapterScoreModel.fromEntity(ChapterScoreEntity entity) {
    return ChapterScoreModel(
      chapterId: entity.chapterId,
      chapterTitleAr: entity.chapterTitleAr,
      totalQuestions: entity.totalQuestions,
      answeredQuestions: entity.answeredQuestions,
      correctAnswers: entity.correctAnswers,
      wrongAnswers: entity.wrongAnswers,
      skippedQuestions: entity.skippedQuestions,
      percentage: entity.percentage,
      score: entity.score,
    );
  }

  /// Helper method to safely parse double values
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Copy with method
  ChapterScoreModel copyWith({
    int? chapterId,
    String? chapterTitleAr,
    int? totalQuestions,
    int? answeredQuestions,
    int? correctAnswers,
    int? wrongAnswers,
    int? skippedQuestions,
    double? percentage,
    double? score,
  }) {
    return ChapterScoreModel(
      chapterId: chapterId ?? this.chapterId,
      chapterTitleAr: chapterTitleAr ?? this.chapterTitleAr,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      answeredQuestions: answeredQuestions ?? this.answeredQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      skippedQuestions: skippedQuestions ?? this.skippedQuestions,
      percentage: percentage ?? this.percentage,
      score: score ?? this.score,
    );
  }
}
