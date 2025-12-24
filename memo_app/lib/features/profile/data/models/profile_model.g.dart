// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      name: json['name'] as String?,
      phone: json['phone_number'] as String?,
      avatar: json['photo_url'] as String?,
      bio: json['bio'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      timezone: json['timezone'] as String?,
      phaseId: (json['phase_id'] as num?)?.toInt(),
      phaseName: json['phase_name'] as String?,
      yearId: (json['year_id'] as num?)?.toInt(),
      yearName: json['year_name'] as String?,
      streamId: (json['stream_id'] as num?)?.toInt(),
      streamName: json['stream_name'] as String?,
      points: (json['points'] as num?)?.toInt(),
      level: (json['level'] as num?)?.toInt(),
      streak: (json['streak'] as num?)?.toInt(),
      totalStudyTime: (json['total_study_time'] as num?)?.toInt(),
      emailVerifiedAt: json['email_verified_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'phone_number': instance.phone,
      'photo_url': instance.avatar,
      'bio': instance.bio,
      'date_of_birth': instance.dateOfBirth,
      'gender': instance.gender,
      'city': instance.city,
      'country': instance.country,
      'timezone': instance.timezone,
      'phase_id': instance.phaseId,
      'phase_name': instance.phaseName,
      'year_id': instance.yearId,
      'year_name': instance.yearName,
      'stream_id': instance.streamId,
      'stream_name': instance.streamName,
      'points': instance.points,
      'level': instance.level,
      'streak': instance.streak,
      'total_study_time': instance.totalStudyTime,
      'email_verified_at': instance.emailVerifiedAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
