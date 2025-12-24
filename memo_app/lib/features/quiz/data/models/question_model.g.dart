// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) =>
    QuestionModel(
      id: (json['id'] as num).toInt(),
      questionType: json['question_type'] as String,
      questionTextAr: json['question_text_ar'] as String,
      questionImageUrl: json['question_image_url'] as String?,
      options: json['options'],
      correctAnswer: json['correct_answer'],
      points: (json['points'] as num?)?.toDouble() ?? 1.0,
      explanationAr: json['explanation_ar'] as String?,
      difficulty: json['difficulty'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      questionOrder: (json['question_order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$QuestionModelToJson(QuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question_type': instance.questionType,
      'question_text_ar': instance.questionTextAr,
      'question_image_url': instance.questionImageUrl,
      'options': instance.options,
      'correct_answer': instance.correctAnswer,
      'points': instance.points,
      'explanation_ar': instance.explanationAr,
      'difficulty': instance.difficulty,
      'tags': instance.tags,
      'question_order': instance.questionOrder,
    };
