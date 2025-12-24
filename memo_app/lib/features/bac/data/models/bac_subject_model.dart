import '../../domain/entities/bac_subject_entity.dart';

/// Data model for BacSubject that extends BacSubjectEntity
class BacSubjectModel extends BacSubjectEntity {
  const BacSubjectModel({
    required super.id,
    required super.bacSessionId,
    required super.nameAr,
    super.nameEn,
    super.nameFr,
    required super.slug,
    super.descriptionAr,
    required super.color,
    super.icon,
    required super.coefficient,
    required super.duration,
    required super.isActive,
    required super.order,
    super.totalChapters,
    super.totalExams,
    super.totalDownloads,
    super.averageScore,
    super.completedChapters,
    super.attemptedSimulations,
    super.completionPercentage,
    super.fileUrl,
    super.correctionUrl,
    super.downloadUrl,
    super.correctionDownloadUrl,
    super.hasCorrection,
    super.bacYear,
    super.bacSessionName,
  });

  /// Create BacSubjectModel from JSON
  factory BacSubjectModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] != null
        ? Map<String, dynamic>.from(json['stats'] as Map)
        : null;
    final progress = json['progress'] != null
        ? Map<String, dynamic>.from(json['progress'] as Map)
        : null;
    final subject = json['subject'] != null
        ? Map<String, dynamic>.from(json['subject'] as Map)
        : null;
    final bacSession = json['bac_session'] != null
        ? Map<String, dynamic>.from(json['bac_session'] as Map)
        : null;
    final bacYearData = json['bac_year'] != null
        ? Map<String, dynamic>.from(json['bac_year'] as Map)
        : null;

    // Handle both API formats (regular subjects and BAC exam subjects)
    final nameAr =
        json['title_ar'] as String? ??
        json['name_ar'] as String? ??
        subject?['name_ar'] as String? ??
        '';
    final durationMinutes =
        json['duration_minutes'] as int? ?? json['duration'] as int? ?? 0;

    // Get color from subject if not directly available
    final color = json['color'] as String? ??
        subject?['color'] as String? ??
        '#4CAF50';

    // Get bac_session_id from nested object or direct field
    final bacSessionId = json['bac_session_id'] as int? ??
        bacSession?['id'] as int? ??
        0;

    // Get year from bac_year nested object
    final bacYear = bacYearData?['year'] as int?;
    final bacSessionName = bacSession?['name_ar'] as String?;

    return BacSubjectModel(
      id: json['id'] as int,
      bacSessionId: bacSessionId,
      nameAr: nameAr,
      nameEn: json['name_en'] as String?,
      nameFr: json['name_fr'] as String?,
      slug: json['slug'] as String? ?? '',
      descriptionAr: json['description_ar'] as String?,
      color: color,
      icon: json['icon'] as String?,
      coefficient: json['coefficient'] as int? ?? 1,
      duration: durationMinutes,
      isActive: json['is_active'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      totalChapters: stats?['total_chapters'] as int? ?? 0,
      totalExams: stats?['total_exams'] as int? ?? 0,
      totalDownloads:
          (stats?['total_downloads'] ?? json['downloads_count']) as int? ?? 0,
      averageScore: _parseDouble(progress?['average_score']),
      completedChapters: progress?['completed_chapters'] as int? ?? 0,
      attemptedSimulations: progress?['attempted_simulations'] as int? ?? 0,
      completionPercentage:
          _parseDouble(progress?['completion_percentage']) ?? 0.0,
      fileUrl: json['file_url'] as String?,
      correctionUrl: json['correction_url'] as String?,
      downloadUrl: json['download_url'] as String?,
      correctionDownloadUrl: json['correction_download_url'] as String?,
      hasCorrection: json['has_correction'] as bool? ?? false,
      bacYear: bacYear,
      bacSessionName: bacSessionName,
    );
  }

  /// Convert BacSubjectModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bac_session_id': bacSessionId,
      'name_ar': nameAr,
      'name_en': nameEn,
      'name_fr': nameFr,
      'slug': slug,
      'description_ar': descriptionAr,
      'color': color,
      'icon': icon,
      'coefficient': coefficient,
      'duration': duration,
      'is_active': isActive,
      'order': order,
      'stats': {
        'total_chapters': totalChapters,
        'total_exams': totalExams,
        'total_downloads': totalDownloads,
      },
      'progress': {
        'average_score': averageScore,
        'completed_chapters': completedChapters,
        'attempted_simulations': attemptedSimulations,
        'completion_percentage': completionPercentage,
      },
      'file_url': fileUrl,
      'correction_url': correctionUrl,
      'download_url': downloadUrl,
      'correction_download_url': correctionDownloadUrl,
      'has_correction': hasCorrection,
      'bac_year': bacYear != null ? {'year': bacYear} : null,
      'bac_session': bacSessionName != null ? {'name_ar': bacSessionName} : null,
    };
  }

  /// Create BacSubjectModel from BacSubjectEntity
  factory BacSubjectModel.fromEntity(BacSubjectEntity entity) {
    return BacSubjectModel(
      id: entity.id,
      bacSessionId: entity.bacSessionId,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      nameFr: entity.nameFr,
      slug: entity.slug,
      descriptionAr: entity.descriptionAr,
      color: entity.color,
      icon: entity.icon,
      coefficient: entity.coefficient,
      duration: entity.duration,
      isActive: entity.isActive,
      order: entity.order,
      totalChapters: entity.totalChapters,
      totalExams: entity.totalExams,
      totalDownloads: entity.totalDownloads,
      averageScore: entity.averageScore,
      completedChapters: entity.completedChapters,
      attemptedSimulations: entity.attemptedSimulations,
      completionPercentage: entity.completionPercentage,
      fileUrl: entity.fileUrl,
      correctionUrl: entity.correctionUrl,
      downloadUrl: entity.downloadUrl,
      correctionDownloadUrl: entity.correctionDownloadUrl,
      hasCorrection: entity.hasCorrection,
      bacYear: entity.bacYear,
      bacSessionName: entity.bacSessionName,
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
  BacSubjectModel copyWith({
    int? id,
    int? bacSessionId,
    String? nameAr,
    String? nameEn,
    String? nameFr,
    String? slug,
    String? descriptionAr,
    String? color,
    String? icon,
    int? coefficient,
    int? duration,
    bool? isActive,
    int? order,
    int? totalChapters,
    int? totalExams,
    int? totalDownloads,
    double? averageScore,
    int? completedChapters,
    int? attemptedSimulations,
    double? completionPercentage,
    String? fileUrl,
    String? correctionUrl,
    String? downloadUrl,
    String? correctionDownloadUrl,
    bool? hasCorrection,
    int? bacYear,
    String? bacSessionName,
  }) {
    return BacSubjectModel(
      id: id ?? this.id,
      bacSessionId: bacSessionId ?? this.bacSessionId,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      nameFr: nameFr ?? this.nameFr,
      slug: slug ?? this.slug,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      coefficient: coefficient ?? this.coefficient,
      duration: duration ?? this.duration,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      totalChapters: totalChapters ?? this.totalChapters,
      totalExams: totalExams ?? this.totalExams,
      totalDownloads: totalDownloads ?? this.totalDownloads,
      averageScore: averageScore ?? this.averageScore,
      completedChapters: completedChapters ?? this.completedChapters,
      attemptedSimulations: attemptedSimulations ?? this.attemptedSimulations,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      fileUrl: fileUrl ?? this.fileUrl,
      correctionUrl: correctionUrl ?? this.correctionUrl,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      correctionDownloadUrl: correctionDownloadUrl ?? this.correctionDownloadUrl,
      hasCorrection: hasCorrection ?? this.hasCorrection,
      bacYear: bacYear ?? this.bacYear,
      bacSessionName: bacSessionName ?? this.bacSessionName,
    );
  }
}
