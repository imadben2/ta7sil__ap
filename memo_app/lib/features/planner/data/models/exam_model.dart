import '../../domain/entities/exam.dart';

/// Data model for Exam with JSON serialization
class ExamModel {
  final String id;
  final String userId;
  final String subjectId;
  final String subjectName;
  final String examDate; // "2025-06-15"
  final String examType; // "quiz", "test", "exam", "final_exam"
  final String importanceLevel; // "low", "medium", "high", "critical"
  final int durationMinutes;
  final int preparationDaysBefore;
  final double? targetScore;
  final double? actualScore;
  final List<String>? chaptersCovered;

  ExamModel({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.subjectName,
    required this.examDate,
    required this.examType,
    required this.importanceLevel,
    required this.durationMinutes,
    required this.preparationDaysBefore,
    this.targetScore,
    this.actualScore,
    this.chaptersCovered,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      subjectId: json['subject_id'] as String,
      subjectName: json['subject_name'] as String,
      examDate: json['exam_date'] as String,
      examType: json['exam_type'] as String,
      importanceLevel: json['importance_level'] as String,
      durationMinutes: json['duration_minutes'] as int,
      preparationDaysBefore: json['preparation_days_before'] as int,
      targetScore: json['target_score'] as double?,
      actualScore: json['actual_score'] as double?,
      chaptersCovered: (json['chapters_covered'] as List<dynamic>?)
          ?.map((chapter) => chapter as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subject_id': subjectId,
      'subject_name': subjectName,
      'exam_date': examDate,
      'exam_type': examType,
      'importance_level': importanceLevel,
      'duration_minutes': durationMinutes,
      'preparation_days_before': preparationDaysBefore,
      'target_score': targetScore,
      'actual_score': actualScore,
      'chapters_covered': chaptersCovered,
    };
  }

  Exam toEntity() {
    return Exam(
      id: id,
      userId: userId,
      subjectId: subjectId,
      subjectName: subjectName,
      examDate: DateTime.parse(examDate),
      examType: _parseExamType(examType),
      importanceLevel: _parseImportanceLevel(importanceLevel),
      durationMinutes: durationMinutes,
      preparationDaysBefore: preparationDaysBefore,
      targetScore: targetScore,
      actualScore: actualScore,
      chaptersCovered: chaptersCovered,
    );
  }

  factory ExamModel.fromEntity(Exam entity) {
    return ExamModel(
      id: entity.id,
      userId: entity.userId,
      subjectId: entity.subjectId,
      subjectName: entity.subjectName,
      examDate: entity.examDate.toIso8601String().split('T')[0],
      examType: _formatExamType(entity.examType),
      importanceLevel: _formatImportanceLevel(entity.importanceLevel),
      durationMinutes: entity.durationMinutes,
      preparationDaysBefore: entity.preparationDaysBefore,
      targetScore: entity.targetScore,
      actualScore: entity.actualScore,
      chaptersCovered: entity.chaptersCovered,
    );
  }

  static ExamType _parseExamType(String type) {
    switch (type.toLowerCase()) {
      case 'quiz':
        return ExamType.quiz;
      case 'test':
        return ExamType.test;
      case 'exam':
        return ExamType.exam;
      case 'final_exam':
      case 'finalexam':
        return ExamType.finalExam;
      default:
        return ExamType.test;
    }
  }

  static String _formatExamType(ExamType type) {
    switch (type) {
      case ExamType.quiz:
        return 'quiz';
      case ExamType.test:
        return 'test';
      case ExamType.exam:
        return 'exam';
      case ExamType.finalExam:
        return 'final_exam';
    }
  }

  static ImportanceLevel _parseImportanceLevel(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return ImportanceLevel.low;
      case 'medium':
        return ImportanceLevel.medium;
      case 'high':
        return ImportanceLevel.high;
      case 'critical':
        return ImportanceLevel.critical;
      default:
        return ImportanceLevel.medium;
    }
  }

  static String _formatImportanceLevel(ImportanceLevel level) {
    switch (level) {
      case ImportanceLevel.low:
        return 'low';
      case ImportanceLevel.medium:
        return 'medium';
      case ImportanceLevel.high:
        return 'high';
      case ImportanceLevel.critical:
        return 'critical';
    }
  }

  /// Calculate days until exam
  int get daysUntilExam {
    final examDateTime = DateTime.parse(examDate);
    final now = DateTime.now();
    return examDateTime.difference(now).inDays;
  }

  /// Check if exam is upcoming (within preparation period)
  bool get isUpcoming {
    final days = daysUntilExam;
    return days >= 0 && days <= preparationDaysBefore;
  }

  /// Calculate urgency score (0-100)
  int get urgencyScore {
    final days = daysUntilExam;
    if (days < 0) return 0; // Past exam

    // Base urgency on days remaining vs preparation period
    int baseScore;
    final preparationRatio = days / preparationDaysBefore;

    if (preparationRatio <= 0.25) {
      baseScore = 90; // In final quarter of preparation
    } else if (preparationRatio <= 0.5) {
      baseScore = 75; // In second half
    } else if (preparationRatio <= 0.75) {
      baseScore = 50; // In third quarter
    } else {
      baseScore = 30; // Early preparation
    }

    // Adjust based on importance
    final importance = _parseImportanceLevel(importanceLevel);
    final importanceMultiplier = switch (importance) {
      ImportanceLevel.critical => 1.0,
      ImportanceLevel.high => 0.9,
      ImportanceLevel.medium => 0.7,
      ImportanceLevel.low => 0.5,
    };

    return (baseScore * importanceMultiplier).round().clamp(0, 100);
  }
}
