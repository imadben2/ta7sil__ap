import 'package:equatable/equatable.dart';

/// Entity representing subject progress for dashboard
class SubjectProgressEntity extends Equatable {
  final int id;
  final String name;
  final String nameAr;
  final String color;
  final double coefficient;
  final int totalLessons;
  final int completedLessons;
  final int totalQuizzes;
  final int completedQuizzes;
  final double averageScore; // 0-100
  final DateTime? nextExamDate;
  final String? iconEmoji;

  const SubjectProgressEntity({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.color,
    required this.coefficient,
    required this.totalLessons,
    required this.completedLessons,
    required this.totalQuizzes,
    required this.completedQuizzes,
    required this.averageScore,
    this.nextExamDate,
    this.iconEmoji,
  });

  /// Calculate completion percentage (0-1)
  double get completionPercentage {
    if (totalLessons == 0) return 0.0;
    return (completedLessons / totalLessons).clamp(0.0, 1.0);
  }

  /// Check if exam is soon (< 7 days)
  bool get hasExamSoon {
    if (nextExamDate == null) return false;
    final daysUntilExam = nextExamDate!.difference(DateTime.now()).inDays;
    return daysUntilExam >= 0 && daysUntilExam <= 7;
  }

  /// Get days until exam (null if no exam or exam passed)
  int? get daysUntilExam {
    if (nextExamDate == null) return null;
    final days = nextExamDate!.difference(DateTime.now()).inDays;
    return days >= 0 ? days : null;
  }

  /// Get formatted coefficient label
  String get coefficientLabel {
    return 'معامل ${coefficient.toStringAsFixed(1)}';
  }

  /// Get completion label
  String get completionLabel {
    return '${(completionPercentage * 100).toInt()}%';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    nameAr,
    color,
    coefficient,
    totalLessons,
    completedLessons,
    totalQuizzes,
    completedQuizzes,
    averageScore,
    nextExamDate,
    iconEmoji,
  ];
}
