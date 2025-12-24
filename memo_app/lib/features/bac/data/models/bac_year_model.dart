import '../../domain/entities/bac_year_entity.dart';

/// Data model for BacYear that extends BacYearEntity
class BacYearModel extends BacYearEntity {
  const BacYearModel({
    required super.id,
    required super.year,
    required super.slug,
    super.descriptionAr,
    required super.isActive,
    required super.order,
    super.totalSessions,
    super.totalExams,
    super.totalDownloads,
  });

  /// Create BacYearModel from JSON
  factory BacYearModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] != null
        ? Map<String, dynamic>.from(json['stats'] as Map)
        : null;

    return BacYearModel(
      id: json['id'] as int,
      year: json['year'] as int,
      slug: json['slug'] as String,
      descriptionAr:
          json['description_ar'] as String? ?? json['name_ar'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      totalSessions: stats?['total_sessions'] as int? ?? 0,
      totalExams: stats?['total_exams'] as int? ?? 0,
      totalDownloads: stats?['total_downloads'] as int? ?? 0,
    );
  }

  /// Convert BacYearModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'slug': slug,
      'description_ar': descriptionAr,
      'is_active': isActive,
      'order': order,
      'stats': {
        'total_sessions': totalSessions,
        'total_exams': totalExams,
        'total_downloads': totalDownloads,
      },
    };
  }

  /// Create BacYearModel from BacYearEntity
  factory BacYearModel.fromEntity(BacYearEntity entity) {
    return BacYearModel(
      id: entity.id,
      year: entity.year,
      slug: entity.slug,
      descriptionAr: entity.descriptionAr,
      isActive: entity.isActive,
      order: entity.order,
      totalSessions: entity.totalSessions,
      totalExams: entity.totalExams,
      totalDownloads: entity.totalDownloads,
    );
  }

  /// Copy with method
  BacYearModel copyWith({
    int? id,
    int? year,
    String? slug,
    String? descriptionAr,
    bool? isActive,
    int? order,
    int? totalSessions,
    int? totalExams,
    int? totalDownloads,
  }) {
    return BacYearModel(
      id: id ?? this.id,
      year: year ?? this.year,
      slug: slug ?? this.slug,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      totalSessions: totalSessions ?? this.totalSessions,
      totalExams: totalExams ?? this.totalExams,
      totalDownloads: totalDownloads ?? this.totalDownloads,
    );
  }
}
