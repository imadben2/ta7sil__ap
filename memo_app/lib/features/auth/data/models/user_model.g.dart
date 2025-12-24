// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      avatar: json['photo_url'] as String?,
      academicPhaseId: (json['academic_phase_id'] as num?)?.toInt(),
      academicYearId: (json['academic_year_id'] as num?)?.toInt(),
      streamId: (json['stream_id'] as num?)?.toInt(),
      totalPoints: (json['total_points'] as num?)?.toInt(),
      currentLevel: (json['current_level'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'phone': instance.phone,
      'photo_url': instance.avatar,
      'academic_phase_id': instance.academicPhaseId,
      'academic_year_id': instance.academicYearId,
      'stream_id': instance.streamId,
      'total_points': instance.totalPoints,
      'current_level': instance.currentLevel,
    };

AcademicProfileModel _$AcademicProfileModelFromJson(
        Map<String, dynamic> json) =>
    AcademicProfileModel(
      phaseId: (json['phase_id'] as num?)?.toInt(),
      phaseName: json['phase_name'] as String?,
      yearId: (json['year_id'] as num?)?.toInt(),
      yearName: json['year_name'] as String?,
      streamId: (json['stream_id'] as num?)?.toInt(),
      streamName: json['stream_name'] as String?,
    );

Map<String, dynamic> _$AcademicProfileModelToJson(
        AcademicProfileModel instance) =>
    <String, dynamic>{
      'phase_id': instance.phaseId,
      'phase_name': instance.phaseName,
      'year_id': instance.yearId,
      'year_name': instance.yearName,
      'stream_id': instance.streamId,
      'stream_name': instance.streamName,
    };

UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) =>
    UserProfileModel(
      points: (json['points'] as num).toInt(),
      level: (json['level'] as num).toInt(),
      streak: (json['streak'] as num).toInt(),
      totalStudyTime: (json['total_study_time'] as num).toInt(),
    );

Map<String, dynamic> _$UserProfileModelToJson(UserProfileModel instance) =>
    <String, dynamic>{
      'points': instance.points,
      'level': instance.level,
      'streak': instance.streak,
      'total_study_time': instance.totalStudyTime,
    };
