import '../../domain/entities/bac_chapter_info_entity.dart';

/// Data model for BacChapterInfo that extends BacChapterInfoEntity
class BacChapterInfoModel extends BacChapterInfoEntity {
  const BacChapterInfoModel({
    required super.id,
    required super.bacSubjectId,
    required super.titleAr,
    super.titleEn,
    super.titleFr,
    required super.slug,
    super.descriptionAr,
    required super.order,
    required super.isActive,
    super.totalExamsWithThis,
    super.importanceWeight,
    super.totalQuestions,
    super.practiceAttempts,
    super.correctAnswers,
    super.averageScore,
    super.isPracticed,
  });

  /// Create BacChapterInfoModel from JSON
  factory BacChapterInfoModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>?;
    final progress = json['progress'] as Map<String, dynamic>?;

    return BacChapterInfoModel(
      id: json['id'] as int,
      bacSubjectId: json['bac_subject_id'] as int,
      titleAr: json['title_ar'] as String,
      titleEn: json['title_en'] as String?,
      titleFr: json['title_fr'] as String?,
      slug: json['slug'] as String,
      descriptionAr: json['description_ar'] as String?,
      order: json['order'] as int,
      isActive: json['is_active'] as bool,
      totalExamsWithThis: stats?['total_exams_with_this'] as int? ?? 0,
      importanceWeight: _parseDouble(stats?['importance_weight']) ?? 0.0,
      totalQuestions: stats?['total_questions'] as int? ?? 0,
      practiceAttempts: progress?['practice_attempts'] as int? ?? 0,
      correctAnswers: progress?['correct_answers'] as int? ?? 0,
      averageScore: _parseDouble(progress?['average_score']),
      isPracticed: progress?['is_practiced'] as bool? ?? false,
    );
  }

  /// Convert BacChapterInfoModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bac_subject_id': bacSubjectId,
      'title_ar': titleAr,
      'title_en': titleEn,
      'title_fr': titleFr,
      'slug': slug,
      'description_ar': descriptionAr,
      'order': order,
      'is_active': isActive,
      'stats': {
        'total_exams_with_this': totalExamsWithThis,
        'importance_weight': importanceWeight,
        'total_questions': totalQuestions,
      },
      'progress': {
        'practice_attempts': practiceAttempts,
        'correct_answers': correctAnswers,
        'average_score': averageScore,
        'is_practiced': isPracticed,
      },
    };
  }

  /// Create BacChapterInfoModel from BacChapterInfoEntity
  factory BacChapterInfoModel.fromEntity(BacChapterInfoEntity entity) {
    return BacChapterInfoModel(
      id: entity.id,
      bacSubjectId: entity.bacSubjectId,
      titleAr: entity.titleAr,
      titleEn: entity.titleEn,
      titleFr: entity.titleFr,
      slug: entity.slug,
      descriptionAr: entity.descriptionAr,
      order: entity.order,
      isActive: entity.isActive,
      totalExamsWithThis: entity.totalExamsWithThis,
      importanceWeight: entity.importanceWeight,
      totalQuestions: entity.totalQuestions,
      practiceAttempts: entity.practiceAttempts,
      correctAnswers: entity.correctAnswers,
      averageScore: entity.averageScore,
      isPracticed: entity.isPracticed,
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
  BacChapterInfoModel copyWith({
    int? id,
    int? bacSubjectId,
    String? titleAr,
    String? titleEn,
    String? titleFr,
    String? slug,
    String? descriptionAr,
    int? order,
    bool? isActive,
    int? totalExamsWithThis,
    double? importanceWeight,
    int? totalQuestions,
    int? practiceAttempts,
    int? correctAnswers,
    double? averageScore,
    bool? isPracticed,
  }) {
    return BacChapterInfoModel(
      id: id ?? this.id,
      bacSubjectId: bacSubjectId ?? this.bacSubjectId,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      titleFr: titleFr ?? this.titleFr,
      slug: slug ?? this.slug,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      totalExamsWithThis: totalExamsWithThis ?? this.totalExamsWithThis,
      importanceWeight: importanceWeight ?? this.importanceWeight,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      practiceAttempts: practiceAttempts ?? this.practiceAttempts,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      averageScore: averageScore ?? this.averageScore,
      isPracticed: isPracticed ?? this.isPracticed,
    );
  }
}
