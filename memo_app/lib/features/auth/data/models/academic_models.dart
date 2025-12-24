import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/academic_entities.dart';

part 'academic_models.g.dart';

/// Academic Phase Model
@JsonSerializable()
class AcademicPhaseModel {
  final int id;
  @JsonKey(name: 'name_ar')
  final String nameAr;
  final String? slug;
  final int? order;

  const AcademicPhaseModel({
    required this.id,
    required this.nameAr,
    this.slug,
    this.order,
  });

  factory AcademicPhaseModel.fromJson(Map<String, dynamic> json) =>
      _$AcademicPhaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AcademicPhaseModelToJson(this);

  AcademicPhase toEntity() {
    return AcademicPhase(id: id, nameAr: nameAr, slug: slug, order: order);
  }
}

/// Academic Year Model
@JsonSerializable()
class AcademicYearModel {
  final int id;
  @JsonKey(name: 'name_ar')
  final String nameAr;
  @JsonKey(name: 'level_number')
  final int? levelNumber;
  final int? order;
  @JsonKey(name: 'academic_phase_id')
  final int? academicPhaseId;

  const AcademicYearModel({
    required this.id,
    required this.nameAr,
    this.levelNumber,
    this.order,
    this.academicPhaseId,
  });

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) =>
      _$AcademicYearModelFromJson(json);

  Map<String, dynamic> toJson() => _$AcademicYearModelToJson(this);

  AcademicYear toEntity() {
    return AcademicYear(
      id: id,
      nameAr: nameAr,
      levelNumber: levelNumber,
      order: order,
      academicPhaseId: academicPhaseId,
    );
  }
}

/// Academic Stream Model
@JsonSerializable()
class AcademicStreamModel {
  final int id;
  @JsonKey(name: 'name_ar')
  final String nameAr;
  final String? slug;
  @JsonKey(name: 'description_ar')
  final String? descriptionAr;
  final int? order;

  const AcademicStreamModel({
    required this.id,
    required this.nameAr,
    this.slug,
    this.descriptionAr,
    this.order,
  });

  factory AcademicStreamModel.fromJson(Map<String, dynamic> json) =>
      _$AcademicStreamModelFromJson(json);

  Map<String, dynamic> toJson() => _$AcademicStreamModelToJson(this);

  AcademicStream toEntity() {
    return AcademicStream(
      id: id,
      nameAr: nameAr,
      slug: slug,
      descriptionAr: descriptionAr,
      order: order,
    );
  }
}

/// API Response wrapper for phases
@JsonSerializable()
class AcademicPhasesResponseModel {
  final bool success;
  final List<AcademicPhaseModel> data;

  const AcademicPhasesResponseModel({
    required this.success,
    required this.data,
  });

  factory AcademicPhasesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AcademicPhasesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AcademicPhasesResponseModelToJson(this);

  AcademicPhasesResponse toEntity() {
    return AcademicPhasesResponse(
      phases: data.map((model) => model.toEntity()).toList(),
    );
  }
}

/// API Response wrapper for years
@JsonSerializable()
class AcademicYearsResponseModel {
  final bool success;
  final List<AcademicYearModel> data;

  const AcademicYearsResponseModel({required this.success, required this.data});

  factory AcademicYearsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AcademicYearsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AcademicYearsResponseModelToJson(this);

  AcademicYearsResponse toEntity() {
    // Extract phase from first year if available
    final firstYear = data.isNotEmpty ? data.first : null;
    final phase = firstYear != null && firstYear.academicPhaseId != null
        ? AcademicPhase(
            id: firstYear.academicPhaseId!,
            nameAr: '', // Will be populated if needed
          )
        : AcademicPhase(id: 0, nameAr: '');

    return AcademicYearsResponse(
      phase: phase,
      years: data.map((model) => model.toEntity()).toList(),
    );
  }
}

/// API Response wrapper for streams
@JsonSerializable()
class AcademicStreamsResponseModel {
  final bool success;
  final List<AcademicStreamModel> data;

  const AcademicStreamsResponseModel({
    required this.success,
    required this.data,
  });

  factory AcademicStreamsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AcademicStreamsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AcademicStreamsResponseModelToJson(this);

  AcademicStreamsResponse toEntity() {
    // Extract year from first stream if available
    final firstStream = data.isNotEmpty ? data.first : null;
    final year = AcademicYear(
      id: 0,
      nameAr: '', // Will be populated if needed
    );

    return AcademicStreamsResponse(
      year: year,
      streams: data.map((model) => model.toEntity()).toList(),
    );
  }
}
