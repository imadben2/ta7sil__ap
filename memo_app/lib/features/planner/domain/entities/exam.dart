import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Domain entity representing an upcoming exam
class Exam extends Equatable {
  final String id;
  final String userId;
  final String subjectId;
  final String subjectName;
  final ExamType examType;
  final DateTime examDate;
  final TimeOfDay? examTime;
  final int durationMinutes;
  final ImportanceLevel importanceLevel;
  final int preparationDaysBefore; // Days to prepare in advance
  final double? targetScore;
  final double? actualScore;
  final List<String>? chaptersCovered;

  const Exam({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.subjectName,
    required this.examType,
    required this.examDate,
    this.examTime,
    required this.durationMinutes,
    required this.importanceLevel,
    this.preparationDaysBefore = 7,
    this.targetScore,
    this.actualScore,
    this.chaptersCovered,
  });

  @override
  List<Object?> get props => [id, examDate, subjectId];

  // Days until exam
  int get daysUntilExam {
    return examDate.difference(DateTime.now()).inDays;
  }

  // Is exam upcoming (within preparation window)?
  bool get isUpcoming {
    return daysUntilExam >= 0 && daysUntilExam <= preparationDaysBefore;
  }

  // Urgency score (0-100)
  int get urgencyScore {
    if (daysUntilExam < 0) return 0; // Past exam
    if (daysUntilExam == 0) return 100; // Today!
    if (daysUntilExam == 1) return 90;
    if (daysUntilExam <= 3) return 75;
    if (daysUntilExam <= 7) return 50;
    if (daysUntilExam <= 14) return 25;
    return 10;
  }

  Exam copyWith({
    ExamType? examType,
    DateTime? examDate,
    TimeOfDay? examTime,
    int? durationMinutes,
    ImportanceLevel? importanceLevel,
    int? preparationDaysBefore,
    double? targetScore,
    double? actualScore,
    List<String>? chaptersCovered,
  }) {
    return Exam(
      id: id,
      userId: userId,
      subjectId: subjectId,
      subjectName: subjectName,
      examType: examType ?? this.examType,
      examDate: examDate ?? this.examDate,
      examTime: examTime ?? this.examTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      importanceLevel: importanceLevel ?? this.importanceLevel,
      preparationDaysBefore:
          preparationDaysBefore ?? this.preparationDaysBefore,
      targetScore: targetScore ?? this.targetScore,
      actualScore: actualScore ?? this.actualScore,
      chaptersCovered: chaptersCovered ?? this.chaptersCovered,
    );
  }
}

enum ExamType {
  quiz, // Small test
  test, // Mid-term
  exam, // End of term
  finalExam, // BAC exam
}

enum ImportanceLevel {
  low,
  medium,
  high,
  critical, // BAC
}
