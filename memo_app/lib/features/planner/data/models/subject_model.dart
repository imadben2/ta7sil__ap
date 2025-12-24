import '../../domain/entities/subject.dart';

/// Data model for Subject with JSON serialization
class SubjectModel {
  final String id;
  final String name;
  final String nameAr;
  final String colorHex; // "#FF5733"
  final String iconName;
  final int coefficient;
  final int difficultyLevel;
  final double progressPercentage; // 0.0 to 100.0
  final String? lastStudiedAt; // ISO8601 datetime string
  final int totalChapters;
  final int completedChapters;
  final double averageScore; // 0.0 to 100.0
  final double? lastYearAverage; // معدل السنة الماضية (0-20)

  SubjectModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.colorHex,
    required this.iconName,
    required this.coefficient,
    required this.difficultyLevel,
    this.progressPercentage = 0.0,
    this.lastStudiedAt,
    required this.totalChapters,
    this.completedChapters = 0,
    this.averageScore = 0.0,
    this.lastYearAverage,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id']?.toString() ?? '0', // Convert int to String
      name: json['name'] as String? ?? json['name_ar'] as String? ?? '',
      nameAr: json['name_ar'] as String,
      colorHex:
          json['color_hex'] as String? ?? json['color'] as String? ?? '#3B82F6',
      iconName:
          json['icon_name'] as String? ?? json['icon'] as String? ?? 'book',
      coefficient: (json['coefficient'] as num?)?.toInt() ?? 1,
      difficultyLevel: json['difficulty_level'] as int? ?? 3,
      progressPercentage:
          (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      lastStudiedAt: json['last_studied_at'] as String?,
      totalChapters: json['total_chapters'] as int? ?? 0,
      completedChapters: json['completed_chapters'] as int? ?? 0,
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0.0,
      lastYearAverage: (json['last_year_average'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'color_hex': colorHex,
      'icon_name': iconName,
      'coefficient': coefficient,
      'difficulty_level': difficultyLevel,
      'progress_percentage': progressPercentage,
      'last_studied_at': lastStudiedAt,
      'total_chapters': totalChapters,
      'completed_chapters': completedChapters,
      'average_score': averageScore,
      'last_year_average': lastYearAverage,
    };
  }

  Subject toEntity() {
    return Subject(
      id: id,
      name: name,
      nameAr: nameAr,
      coefficient: coefficient,
      difficultyLevel: difficultyLevel,
      colorHex: colorHex,
      iconName: iconName,
      progressPercentage: progressPercentage,
      lastStudiedAt: lastStudiedAt != null
          ? DateTime.parse(lastStudiedAt!)
          : null,
      totalChapters: totalChapters,
      completedChapters: completedChapters,
      averageScore: averageScore,
      lastYearAverage: lastYearAverage,
    );
  }

  factory SubjectModel.fromEntity(Subject entity) {
    return SubjectModel(
      id: entity.id,
      name: entity.name,
      nameAr: entity.nameAr,
      colorHex: entity.colorHex,
      iconName: entity.iconName,
      coefficient: entity.coefficient,
      difficultyLevel: entity.difficultyLevel,
      progressPercentage: entity.progressPercentage,
      lastStudiedAt: entity.lastStudiedAt?.toIso8601String(),
      totalChapters: entity.totalChapters,
      completedChapters: entity.completedChapters,
      averageScore: entity.averageScore,
      lastYearAverage: entity.lastYearAverage,
    );
  }

  /// Calculate performance gap (0.0 to 100.0)
  double get performanceGap {
    return (100 - averageScore).clamp(0.0, 100.0);
  }

  /// Calculate days since last study
  int? get daysSinceLastStudy {
    if (lastStudiedAt == null) return null;
    final lastDate = DateTime.parse(lastStudiedAt!);
    final now = DateTime.now();
    return now.difference(lastDate).inDays;
  }

  /// Get completion rate (0-100)
  double get completionRate {
    if (totalChapters == 0) return 0.0;
    return (completedChapters / totalChapters * 100).clamp(0.0, 100.0);
  }
}
