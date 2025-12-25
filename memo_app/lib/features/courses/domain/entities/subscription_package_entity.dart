import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Subscription Package Entity - يمثل باقة اشتراك (مجموعة دورات)
class SubscriptionPackageEntity extends Equatable {
  final int id;
  final String nameAr;
  final String? nameEn;
  final String? nameFr;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? descriptionFr;
  final int priceDzd;
  final int durationDays;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional info
  final List<String>? includedCourseNames;
  final int? totalCourses;
  final int? originalPriceDzd;

  // Customization fields
  final String? imageUrl;
  final String? imageFullUrl;
  final String? badgeText;
  final String? backgroundColor;
  final bool isFeatured;
  final int sortOrder;

  const SubscriptionPackageEntity({
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.nameFr,
    this.descriptionAr,
    this.descriptionEn,
    this.descriptionFr,
    required this.priceDzd,
    required this.durationDays,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.includedCourseNames,
    this.totalCourses,
    this.originalPriceDzd,
    this.imageUrl,
    this.imageFullUrl,
    this.badgeText,
    this.backgroundColor,
    this.isFeatured = false,
    this.sortOrder = 0,
  });

  /// Check if package has an image
  bool get hasImage => imageFullUrl != null && imageFullUrl!.isNotEmpty;

  /// Parse background color from hex string
  Color? get backgroundColorValue {
    if (backgroundColor == null || backgroundColor!.isEmpty) return null;
    try {
      String hex = backgroundColor!.replaceFirst('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// المدة بالأشهر
  int get durationMonths => (durationDays / 30).round();

  /// المدة بالسنوات
  int get durationYears => (durationDays / 365).round();

  /// نص المدة المنسق
  String get formattedDuration {
    if (durationDays < 30) {
      return '$durationDays يوم';
    } else if (durationDays < 365) {
      final months = durationMonths;
      return '$months ${months == 1 ? "شهر" : "أشهر"}';
    } else {
      final years = durationYears;
      return '$years ${years == 1 ? "سنة" : "سنوات"}';
    }
  }

  /// السعر المنسق
  String get formattedPrice => '$priceDzd دج';

  /// السعر الأصلي المنسق
  String? get formattedOriginalPrice =>
      originalPriceDzd != null ? '$originalPriceDzd دج' : null;

  /// نسبة الخصم
  double? get discountPercentage {
    if (originalPriceDzd == null || originalPriceDzd == 0) return null;
    return ((originalPriceDzd! - priceDzd) / originalPriceDzd!) * 100;
  }

  /// نص الخصم المنسق
  String? get formattedDiscount {
    final discount = discountPercentage;
    if (discount == null) return null;
    return '${discount.toStringAsFixed(0)}%';
  }

  /// قيمة التوفير
  int? get savingsAmount {
    if (originalPriceDzd == null) return null;
    return originalPriceDzd! - priceDzd;
  }

  /// نص التوفير المنسق
  String? get formattedSavings {
    final savings = savingsAmount;
    if (savings == null) return null;
    return 'وفّر $savings دج';
  }

  /// هل الباقة تحتوي على خصم؟
  bool get hasDiscount => discountPercentage != null && discountPercentage! > 0;

  /// عدد الدورات المتضمنة
  int get coursesCount => totalCourses ?? includedCourseNames?.length ?? 0;

  /// نص عدد الدورات
  String get coursesCountText {
    if (coursesCount == 0) return 'لا توجد دورات';
    if (coursesCount == 1) return 'دورة واحدة';
    if (coursesCount == 2) return 'دورتان';
    return '$coursesCount دورات';
  }

  /// Compatibility getters
  bool get isPopular => isFeatured; // Use isFeatured as isPopular
  int get finalPrice => priceDzd;
  List<String>? get features => includedCourseNames;

  SubscriptionPackageEntity copyWith({
    int? id,
    String? nameAr,
    String? nameEn,
    String? nameFr,
    String? descriptionAr,
    String? descriptionEn,
    String? descriptionFr,
    int? priceDzd,
    int? durationDays,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? includedCourseNames,
    int? totalCourses,
    int? originalPriceDzd,
    String? imageUrl,
    String? imageFullUrl,
    String? badgeText,
    String? backgroundColor,
    bool? isFeatured,
    int? sortOrder,
  }) {
    return SubscriptionPackageEntity(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      nameFr: nameFr ?? this.nameFr,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionFr: descriptionFr ?? this.descriptionFr,
      priceDzd: priceDzd ?? this.priceDzd,
      durationDays: durationDays ?? this.durationDays,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      includedCourseNames: includedCourseNames ?? this.includedCourseNames,
      totalCourses: totalCourses ?? this.totalCourses,
      originalPriceDzd: originalPriceDzd ?? this.originalPriceDzd,
      imageUrl: imageUrl ?? this.imageUrl,
      imageFullUrl: imageFullUrl ?? this.imageFullUrl,
      badgeText: badgeText ?? this.badgeText,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isFeatured: isFeatured ?? this.isFeatured,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nameAr,
    nameEn,
    nameFr,
    descriptionAr,
    descriptionEn,
    descriptionFr,
    priceDzd,
    durationDays,
    isActive,
    createdAt,
    updatedAt,
    includedCourseNames,
    totalCourses,
    originalPriceDzd,
    imageUrl,
    imageFullUrl,
    badgeText,
    backgroundColor,
    isFeatured,
    sortOrder,
  ];
}
