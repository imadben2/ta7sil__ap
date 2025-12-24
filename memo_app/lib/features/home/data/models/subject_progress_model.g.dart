// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectProgressModel _$SubjectProgressModelFromJson(
        Map<String, dynamic> json) =>
    SubjectProgressModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      nameAr: json['name_ar'] as String,
      color: json['color'] as String,
      coefficient: (json['coefficient'] as num).toDouble(),
      totalLessons: (json['total_lessons'] as num).toInt(),
      completedLessons: (json['completed_lessons'] as num).toInt(),
      totalQuizzes: (json['total_quizzes'] as num).toInt(),
      completedQuizzes: (json['completed_quizzes'] as num).toInt(),
      averageScore: (json['average_score'] as num).toDouble(),
      nextExamDate: json['next_exam_date'] as String?,
      iconEmoji: json['icon_emoji'] as String?,
    );

Map<String, dynamic> _$SubjectProgressModelToJson(
        SubjectProgressModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'name_ar': instance.nameAr,
      'color': instance.color,
      'coefficient': instance.coefficient,
      'total_lessons': instance.totalLessons,
      'completed_lessons': instance.completedLessons,
      'total_quizzes': instance.totalQuizzes,
      'completed_quizzes': instance.completedQuizzes,
      'average_score': instance.averageScore,
      'next_exam_date': instance.nextExamDate,
      'icon_emoji': instance.iconEmoji,
    };
