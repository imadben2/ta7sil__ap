// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSubscriptionModel _$UserSubscriptionModelFromJson(
        Map<String, dynamic> json) =>
    UserSubscriptionModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      packageId: (json['package_id'] as num?)?.toInt(),
      courseId: (json['course_id'] as num?)?.toInt(),
      activatedBy: json['activated_by'] as String?,
      codeId: (json['code_id'] as num?)?.toInt(),
      receiptId: (json['receipt_id'] as num?)?.toInt(),
      isActive: json['is_active'] as bool? ?? true,
      activatedAt: json['activated_at'] == null
          ? null
          : DateTime.parse(json['activated_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      status: json['status'] as String?,
      packageData: json['package'] as Map<String, dynamic>?,
      courseData: json['course'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserSubscriptionModelToJson(
        UserSubscriptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'package_id': instance.packageId,
      'course_id': instance.courseId,
      'activated_by': instance.activatedBy,
      'code_id': instance.codeId,
      'receipt_id': instance.receiptId,
      'is_active': instance.isActive,
      'activated_at': instance.activatedAt?.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'status': instance.status,
      'package': instance.packageData,
      'course': instance.courseData,
    };
