// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'centralized_subject_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CentralizedSubjectModel _$CentralizedSubjectModelFromJson(
        Map<String, dynamic> json) =>
    CentralizedSubjectModel(
      id: (json['id'] as num).toInt(),
      nameAr: json['name_ar'] as String,
      slug: json['slug'] as String,
      coefficient: (json['coefficient'] as num).toDouble(),
      descriptionAr: json['description_ar'] as String?,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      academicStreamIds: (json['academic_stream_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      academicYearId: (json['academic_year_id'] as num?)?.toInt(),
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$CentralizedSubjectModelToJson(
        CentralizedSubjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_ar': instance.nameAr,
      'slug': instance.slug,
      'description_ar': instance.descriptionAr,
      'color': instance.color,
      'icon': instance.icon,
      'coefficient': instance.coefficient,
      'academic_year_id': instance.academicYearId,
      'is_active': instance.isActive,
      'academic_stream_ids': instance.academicStreamIds,
    };
