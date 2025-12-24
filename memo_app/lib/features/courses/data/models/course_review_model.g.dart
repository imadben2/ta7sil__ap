// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseReviewModel _$CourseReviewModelFromJson(Map<String, dynamic> json) =>
    CourseReviewModel(
      id: (json['id'] as num).toInt(),
      courseId: (json['course_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      rating: (json['rating'] as num).toInt(),
      reviewTextAr: json['review_text_ar'] as String,
      isApproved: json['is_approved'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userName: json['user_name'] as String,
      userAvatar: json['user_avatar'] as String?,
    );

Map<String, dynamic> _$CourseReviewModelToJson(CourseReviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'course_id': instance.courseId,
      'user_id': instance.userId,
      'rating': instance.rating,
      'review_text_ar': instance.reviewTextAr,
      'is_approved': instance.isApproved,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'user_name': instance.userName,
      'user_avatar': instance.userAvatar,
    };
