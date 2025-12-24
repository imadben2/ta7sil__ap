// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudySessionModel _$StudySessionModelFromJson(Map<String, dynamic> json) =>
    StudySessionModel(
      id: (json['id'] as num).toInt(),
      subjectId: (json['subject_id'] as num).toInt(),
      subjectName: json['subject_name'] as String,
      subjectColor: json['subject_color'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      topic: json['topic'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$StudySessionModelToJson(StudySessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject_id': instance.subjectId,
      'subject_name': instance.subjectName,
      'subject_color': instance.subjectColor,
      'type': instance.type,
      'status': instance.status,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'topic': instance.topic,
      'notes': instance.notes,
    };
