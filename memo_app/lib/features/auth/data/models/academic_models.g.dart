// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcademicPhaseModel _$AcademicPhaseModelFromJson(Map<String, dynamic> json) =>
    AcademicPhaseModel(
      id: (json['id'] as num).toInt(),
      nameAr: json['name_ar'] as String,
      slug: json['slug'] as String?,
      order: (json['order'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AcademicPhaseModelToJson(AcademicPhaseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_ar': instance.nameAr,
      'slug': instance.slug,
      'order': instance.order,
    };

AcademicYearModel _$AcademicYearModelFromJson(Map<String, dynamic> json) =>
    AcademicYearModel(
      id: (json['id'] as num).toInt(),
      nameAr: json['name_ar'] as String,
      levelNumber: (json['level_number'] as num?)?.toInt(),
      order: (json['order'] as num?)?.toInt(),
      academicPhaseId: (json['academic_phase_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AcademicYearModelToJson(AcademicYearModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_ar': instance.nameAr,
      'level_number': instance.levelNumber,
      'order': instance.order,
      'academic_phase_id': instance.academicPhaseId,
    };

AcademicStreamModel _$AcademicStreamModelFromJson(Map<String, dynamic> json) =>
    AcademicStreamModel(
      id: (json['id'] as num).toInt(),
      nameAr: json['name_ar'] as String,
      slug: json['slug'] as String?,
      descriptionAr: json['description_ar'] as String?,
      order: (json['order'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AcademicStreamModelToJson(
        AcademicStreamModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_ar': instance.nameAr,
      'slug': instance.slug,
      'description_ar': instance.descriptionAr,
      'order': instance.order,
    };

AcademicPhasesResponseModel _$AcademicPhasesResponseModelFromJson(
        Map<String, dynamic> json) =>
    AcademicPhasesResponseModel(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => AcademicPhaseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AcademicPhasesResponseModelToJson(
        AcademicPhasesResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };

AcademicYearsResponseModel _$AcademicYearsResponseModelFromJson(
        Map<String, dynamic> json) =>
    AcademicYearsResponseModel(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => AcademicYearModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AcademicYearsResponseModelToJson(
        AcademicYearsResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };

AcademicStreamsResponseModel _$AcademicStreamsResponseModelFromJson(
        Map<String, dynamic> json) =>
    AcademicStreamsResponseModel(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => AcademicStreamModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AcademicStreamsResponseModelToJson(
        AcademicStreamsResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };
