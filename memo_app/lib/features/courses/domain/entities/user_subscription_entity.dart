import 'package:equatable/equatable.dart';

/// User Subscription Entity - يمثل اشتراك المستخدم في دورة أو باقة
class UserSubscriptionEntity extends Equatable {
  final int id;
  final int userId;
  final int? courseId;
  final int? packageId;
  final String? activatedBy; // "code", "receipt", "admin"
  final int? codeId;
  final int? receiptId;
  final DateTime activatedAt;
  final DateTime? expiresAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional info
  final String? courseName;
  final String? packageName;

  const UserSubscriptionEntity({
    required this.id,
    required this.userId,
    this.courseId,
    this.packageId,
    this.activatedBy,
    this.codeId,
    this.receiptId,
    required this.activatedAt,
    this.expiresAt,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.courseName,
    this.packageName,
  });

  /// هل الاشتراك لدورة واحدة؟
  bool get isSingleCourse => courseId != null;

  /// هل الاشتراك لباقة؟
  bool get isPackage => packageId != null;

  /// هل الاشتراك منتهي؟
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// هل الاشتراك ساري؟
  bool get isValid => isActive && !isExpired;

  /// الأيام المتبقية
  int get remainingDays {
    if (expiresAt == null) return 365; // unlimited
    if (isExpired) return 0;
    return expiresAt!.difference(DateTime.now()).inDays;
  }

  /// نص الأيام المتبقية
  String get remainingDaysText {
    if (isExpired) return 'منتهي';
    if (remainingDays == 0) return 'ينتهي اليوم';
    if (remainingDays == 1) return 'ينتهي غداً';
    if (remainingDays < 7) return 'ينتهي خلال $remainingDays أيام';
    if (remainingDays < 30)
      return 'ينتهي خلال ${(remainingDays / 7).ceil()} أسابيع';
    if (remainingDays < 365)
      return 'ينتهي خلال ${(remainingDays / 30).ceil()} شهر';
    return 'ينتهي خلال ${(remainingDays / 365).ceil()} سنة';
  }

  /// حالة الاشتراك كنص
  String get statusText {
    if (!isActive) return 'معلق';
    if (isExpired) return 'منتهي';
    if (remainingDays <= 7) return 'ينتهي قريباً';
    return 'نشط';
  }

  /// لون حالة الاشتراك
  String get statusColor {
    if (!isActive) return '#9E9E9E'; // رمادي
    if (isExpired) return '#F44336'; // أحمر
    if (remainingDays <= 7) return '#FF9800'; // برتقالي
    return '#4CAF50'; // أخضر
  }

  /// طريقة التفعيل كنص
  String get activationMethodText {
    switch (activatedBy?.toLowerCase()) {
      case 'code':
        return 'كود اشتراك';
      case 'receipt':
        return 'إيصال دفع';
      case 'admin':
        return 'من قبل الإدارة';
      default:
        return 'غير محدد';
    }
  }

  /// اسم الدورة أو الباقة
  String get subscriptionName {
    if (courseName != null) return courseName!;
    if (packageName != null) return packageName!;
    return 'اشتراك غير محدد';
  }

  /// Compatibility getters
  String? get packageNameAr => packageName;
  String? get courseNameAr => courseName;
  DateTime get startedAt => activatedAt;

  UserSubscriptionEntity copyWith({
    int? id,
    int? userId,
    int? courseId,
    int? packageId,
    String? activatedBy,
    int? codeId,
    int? receiptId,
    DateTime? activatedAt,
    DateTime? expiresAt,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? courseName,
    String? packageName,
  }) {
    return UserSubscriptionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      packageId: packageId ?? this.packageId,
      activatedBy: activatedBy ?? this.activatedBy,
      codeId: codeId ?? this.codeId,
      receiptId: receiptId ?? this.receiptId,
      activatedAt: activatedAt ?? this.activatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      courseName: courseName ?? this.courseName,
      packageName: packageName ?? this.packageName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    courseId,
    packageId,
    activatedBy,
    codeId,
    receiptId,
    activatedAt,
    expiresAt,
    isActive,
    createdAt,
    updatedAt,
    courseName,
    packageName,
  ];
}
