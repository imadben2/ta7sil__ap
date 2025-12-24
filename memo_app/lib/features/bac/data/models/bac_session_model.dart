import '../../domain/entities/bac_session_entity.dart';

/// Data model for BacSession that extends BacSessionEntity
class BacSessionModel extends BacSessionEntity {
  const BacSessionModel({
    required super.id,
    required super.bacYearId,
    required super.nameAr,
    super.nameEn,
    super.nameFr,
    required super.slug,
    super.descriptionAr,
    super.startDate,
    super.endDate,
    required super.isActive,
    required super.order,
    super.totalExams,
    super.totalDownloads,
    super.totalSubjects,
  });

  /// Create BacSessionModel from JSON
  factory BacSessionModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] != null
        ? Map<String, dynamic>.from(json['stats'] as Map)
        : null;

    return BacSessionModel(
      id: json['id'] as int,
      bacYearId: (json['bac_year_id'] ?? json['year_id']) as int,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String?,
      nameFr: json['name_fr'] as String?,
      slug: json['slug'] as String,
      descriptionAr: json['description_ar'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      totalExams: stats?['total_exams'] as int? ?? 0,
      totalSubjects: stats?['total_subjects'] as int? ?? 0,
      totalDownloads: stats?['total_downloads'] as int? ?? 0,
    );
  }

  /// Convert BacSessionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bac_year_id': bacYearId,
      'name_ar': nameAr,
      'name_en': nameEn,
      'name_fr': nameFr,
      'slug': slug,
      'description_ar': descriptionAr,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'order': order,
      'stats': {'total_exams': totalExams, 'total_downloads': totalDownloads},
    };
  }

  /// Create BacSessionModel from BacSessionEntity
  factory BacSessionModel.fromEntity(BacSessionEntity entity) {
    return BacSessionModel(
      id: entity.id,
      bacYearId: entity.bacYearId,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      nameFr: entity.nameFr,
      slug: entity.slug,
      descriptionAr: entity.descriptionAr,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isActive: entity.isActive,
      order: entity.order,
      totalExams: entity.totalExams,
      totalDownloads: entity.totalDownloads,
    );
  }

  /// Copy with method
  BacSessionModel copyWith({
    int? id,
    int? bacYearId,
    String? nameAr,
    String? nameEn,
    String? nameFr,
    String? slug,
    String? descriptionAr,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? order,
    int? totalExams,
    int? totalDownloads,
  }) {
    return BacSessionModel(
      id: id ?? this.id,
      bacYearId: bacYearId ?? this.bacYearId,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      nameFr: nameFr ?? this.nameFr,
      slug: slug ?? this.slug,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      totalExams: totalExams ?? this.totalExams,
      totalDownloads: totalDownloads ?? this.totalDownloads,
    );
  }
}
