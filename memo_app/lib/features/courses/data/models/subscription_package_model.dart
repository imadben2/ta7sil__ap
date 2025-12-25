import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/subscription_package_entity.dart';

part 'subscription_package_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SubscriptionPackageModel {
  final int id;
  @JsonKey(name: 'name_ar')
  final String nameAr;
  @JsonKey(name: 'description_ar')
  final String? descriptionAr;
  @JsonKey(name: 'duration_days')
  final int durationDays;
  @JsonKey(name: 'price_dzd')
  final int priceDzd;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  // Customization fields
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'image_full_url')
  final String? imageFullUrl;
  @JsonKey(name: 'badge_text')
  final String? badgeText;
  @JsonKey(name: 'background_color')
  final String? backgroundColor;
  @JsonKey(name: 'is_featured', defaultValue: false)
  final bool isFeatured;
  @JsonKey(name: 'sort_order', defaultValue: 0)
  final int sortOrder;

  const SubscriptionPackageModel({
    required this.id,
    required this.nameAr,
    this.descriptionAr,
    required this.durationDays,
    required this.priceDzd,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.imageUrl,
    this.imageFullUrl,
    this.badgeText,
    this.backgroundColor,
    this.isFeatured = false,
    this.sortOrder = 0,
  });

  factory SubscriptionPackageModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPackageModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionPackageModelToJson(this);

  SubscriptionPackageEntity toEntity() {
    final now = DateTime.now();
    return SubscriptionPackageEntity(
      id: id,
      nameAr: nameAr,
      nameEn: null,
      nameFr: null,
      descriptionAr: descriptionAr,
      descriptionEn: null,
      descriptionFr: null,
      priceDzd: priceDzd,
      durationDays: durationDays,
      isActive: isActive,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      includedCourseNames: null,
      totalCourses: 0,
      originalPriceDzd: null,
      imageUrl: imageUrl,
      imageFullUrl: imageFullUrl,
      badgeText: badgeText,
      backgroundColor: backgroundColor,
      isFeatured: isFeatured,
      sortOrder: sortOrder,
    );
  }

  factory SubscriptionPackageModel.fromEntity(
    SubscriptionPackageEntity entity,
  ) {
    return SubscriptionPackageModel(
      id: entity.id,
      nameAr: entity.nameAr,
      descriptionAr: entity.descriptionAr,
      durationDays: entity.durationDays,
      priceDzd: entity.priceDzd,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      imageUrl: entity.imageUrl,
      imageFullUrl: entity.imageFullUrl,
      badgeText: entity.badgeText,
      backgroundColor: entity.backgroundColor,
      isFeatured: entity.isFeatured,
      sortOrder: entity.sortOrder,
    );
  }
}
