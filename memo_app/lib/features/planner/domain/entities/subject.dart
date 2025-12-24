import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Subject categories from promt.md algorithm
/// Used for day constraints and priority calculation
enum SubjectCategory {
  hardCore, // HARD_CORE: رياضيات، فيزياء، علوم (max 2/day, no consecutive)
  language, // LANGUAGE: العربية، الفرنسية، الإنجليزية (daily guarantee)
  memorization, // MEMORIZATION: إسلامية، تاريخ-جغرافيا، فلسفة (different spaced review intervals)
  other, // OTHER: default category
}

/// Extension for SubjectCategory utility methods
extension SubjectCategoryExtension on SubjectCategory {
  /// Get API string value (UPPER_SNAKE_CASE)
  String get apiValue {
    switch (this) {
      case SubjectCategory.hardCore:
        return 'HARD_CORE';
      case SubjectCategory.language:
        return 'LANGUAGE';
      case SubjectCategory.memorization:
        return 'MEMORIZATION';
      case SubjectCategory.other:
        return 'OTHER';
    }
  }

  /// Category weight for priority calculation (from promt.md)
  double get weight {
    switch (this) {
      case SubjectCategory.hardCore:
        return 1.10;
      case SubjectCategory.memorization:
        return 1.00;
      case SubjectCategory.language:
        return 0.95;
      case SubjectCategory.other:
        return 1.00;
    }
  }

  /// Preferred energy levels order (from promt.md ENERGY_PREFERENCE)
  List<String> get preferredEnergyOrder {
    switch (this) {
      case SubjectCategory.hardCore:
        return ['HIGH', 'MEDIUM', 'LOW'];
      case SubjectCategory.memorization:
        return ['MEDIUM', 'LOW', 'HIGH'];
      case SubjectCategory.language:
        return ['LOW', 'MEDIUM', 'HIGH'];
      case SubjectCategory.other:
        return ['MEDIUM', 'HIGH', 'LOW'];
    }
  }

  /// Spaced review intervals in days (from promt.md)
  List<int> get spacedReviewIntervals {
    switch (this) {
      case SubjectCategory.memorization:
        return [1, 2, 4, 7, 14]; // REVIEW_INTERVALS_MEMO
      default:
        return [1, 3, 7, 14, 30]; // REVIEW_INTERVALS_DEFAULT
    }
  }

  /// Parse from API string
  static SubjectCategory fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'HARD_CORE':
        return SubjectCategory.hardCore;
      case 'LANGUAGE':
        return SubjectCategory.language;
      case 'MEMORIZATION':
        return SubjectCategory.memorization;
      case 'OTHER':
      default:
        return SubjectCategory.other;
    }
  }

  /// Infer category from subject name (Arabic)
  static SubjectCategory inferFromName(String name) {
    final nameLower = name.toLowerCase();

    // HARD_CORE: رياضيات، فيزياء، علوم
    if (nameLower.contains('رياضيات') ||
        nameLower.contains('فيزياء') ||
        nameLower.contains('علوم') ||
        nameLower.contains('math') ||
        nameLower.contains('physics') ||
        nameLower.contains('science')) {
      return SubjectCategory.hardCore;
    }

    // LANGUAGE: العربية، الفرنسية، الإنجليزية
    if (nameLower.contains('عربية') ||
        nameLower.contains('فرنسية') ||
        nameLower.contains('إنجليزية') ||
        nameLower.contains('انجليزية') ||
        nameLower.contains('لغة') ||
        nameLower.contains('arabic') ||
        nameLower.contains('french') ||
        nameLower.contains('english')) {
      return SubjectCategory.language;
    }

    // MEMORIZATION: إسلامية، تاريخ، جغرافيا، فلسفة
    if (nameLower.contains('إسلامية') ||
        nameLower.contains('اسلامية') ||
        nameLower.contains('تاريخ') ||
        nameLower.contains('جغرافيا') ||
        nameLower.contains('فلسفة') ||
        nameLower.contains('islamic') ||
        nameLower.contains('history') ||
        nameLower.contains('geography') ||
        nameLower.contains('philosophy')) {
      return SubjectCategory.memorization;
    }

    return SubjectCategory.other;
  }
}

/// Domain entity representing a subject (simplified for Planner)
class Subject extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final int coefficient;
  final int difficultyLevel; // 1-10
  final String colorHex;
  final String iconName;
  final double progressPercentage;
  final DateTime? lastStudiedAt;
  final int totalChapters;
  final int completedChapters;
  final double averageScore;
  final bool isActive; // Whether this subject is currently active
  final int totalStudyMinutes; // Total minutes studied for this subject
  final double completionRate; // Overall completion rate (0-100)
  final DateTime? lastStudiedDate; // Last date studied (simplified)
  final SubjectCategory category; // Subject category for promt.md algorithm
  final double? lastYearAverage; // المعدل السنوي في السنة الماضية (0-20)

  const Subject({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.coefficient,
    required this.difficultyLevel,
    required this.colorHex,
    required this.iconName,
    this.progressPercentage = 0,
    this.lastStudiedAt,
    required this.totalChapters,
    this.completedChapters = 0,
    this.averageScore = 0,
    this.isActive = true,
    this.totalStudyMinutes = 0,
    this.completionRate = 0,
    this.lastStudiedDate,
    this.category = SubjectCategory.other,
    this.lastYearAverage,
  });

  @override
  List<Object?> get props => [id, name];

  // Days since last studied
  int get daysSinceLastStudy {
    if (lastStudiedAt == null) return 9999; // Never studied
    return DateTime.now().difference(lastStudiedAt!).inDays;
  }

  // Performance gap (target 100% - current score)
  double get performanceGap {
    return 100 - averageScore;
  }

  /// Spaced repetition intervals based on difficulty (in days)
  ///
  /// Replaces category-based intervals with difficulty-based for finer control.
  /// Fallback to category intervals if difficulty is invalid.
  ///
  /// Intervals:
  /// - difficulty 1-3 (easy): [2, 5, 10, 20, 40] days - slower review
  /// - difficulty 4-6 (medium): [1, 3, 7, 14, 30] days - standard
  /// - difficulty 7-8 (hard): [1, 2, 4, 7, 14] days - fast review
  /// - difficulty 9-10 (extreme): [1, 1, 2, 4, 7] days - very fast review
  List<int> get spacedRepetitionIntervals {
    if (difficultyLevel >= 1 && difficultyLevel <= 10) {
      if (difficultyLevel <= 3) {
        return [2, 5, 10, 20, 40]; // Easy: slower review
      } else if (difficultyLevel <= 6) {
        return [1, 3, 7, 14, 30]; // Medium: standard
      } else if (difficultyLevel <= 8) {
        return [1, 2, 4, 7, 14]; // Hard: fast review
      } else {
        return [1, 1, 2, 4, 7]; // Extreme (9-10): very fast review
      }
    }

    // Fallback to category-based for backward compatibility
    return category.spacedReviewIntervals;
  }

  Color get color => Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

  // Convert icon name to IconData
  IconData get icon {
    switch (iconName.toLowerCase()) {
      case 'calculate':
      case 'calculate_rounded':
        return Icons.calculate_rounded;
      case 'science':
      case 'science_rounded':
        return Icons.science_rounded;
      case 'menu_book':
      case 'menu_book_rounded':
        return Icons.menu_book_rounded;
      case 'mosque':
      case 'mosque_rounded':
        return Icons.mosque_rounded;
      case 'language':
      case 'language_rounded':
        return Icons.language_rounded;
      case 'public':
      case 'public_rounded':
        return Icons.public_rounded;
      case 'psychology':
      case 'psychology_rounded':
        return Icons.psychology_rounded;
      case 'sports_soccer':
      case 'sports_soccer_rounded':
        return Icons.sports_soccer_rounded;
      case 'palette':
      case 'palette_rounded':
        return Icons.palette_rounded;
      case 'computer':
      case 'computer_rounded':
        return Icons.computer_rounded;
      default:
        return Icons.book_rounded;
    }
  }

  Subject copyWith({
    String? name,
    String? nameAr,
    int? coefficient,
    int? difficultyLevel,
    String? colorHex,
    String? iconName,
    double? progressPercentage,
    DateTime? lastStudiedAt,
    int? totalChapters,
    int? completedChapters,
    double? averageScore,
    bool? isActive,
    int? totalStudyMinutes,
    double? completionRate,
    DateTime? lastStudiedDate,
    SubjectCategory? category,
    double? lastYearAverage,
  }) {
    return Subject(
      id: id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      coefficient: coefficient ?? this.coefficient,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      totalChapters: totalChapters ?? this.totalChapters,
      completedChapters: completedChapters ?? this.completedChapters,
      averageScore: averageScore ?? this.averageScore,
      isActive: isActive ?? this.isActive,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
      completionRate: completionRate ?? this.completionRate,
      lastStudiedDate: lastStudiedDate ?? this.lastStudiedDate,
      category: category ?? this.category,
      lastYearAverage: lastYearAverage ?? this.lastYearAverage,
    );
  }
}
