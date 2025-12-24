// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_package_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionPackageModel _$SubscriptionPackageModelFromJson(
        Map<String, dynamic> json) =>
    SubscriptionPackageModel(
      id: (json['id'] as num).toInt(),
      nameAr: json['name_ar'] as String,
      descriptionAr: json['description_ar'] as String?,
      durationDays: (json['duration_days'] as num).toInt(),
      priceDzd: (json['price_dzd'] as num).toInt(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SubscriptionPackageModelToJson(
        SubscriptionPackageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_ar': instance.nameAr,
      'description_ar': instance.descriptionAr,
      'duration_days': instance.durationDays,
      'price_dzd': instance.priceDzd,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
