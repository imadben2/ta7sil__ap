import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_subscription_entity.dart';

part 'user_subscription_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserSubscriptionModel {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'package_id')
  final int? packageId;
  @JsonKey(name: 'course_id')
  final int? courseId;
  @JsonKey(name: 'activated_by')
  final String? activatedBy; // 'code', 'receipt', 'admin'
  @JsonKey(name: 'code_id')
  final int? codeId;
  @JsonKey(name: 'receipt_id')
  final int? receiptId;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'activated_at')
  final DateTime? activatedAt;
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  final String? status; // computed: 'active', 'expired', 'suspended'

  // Nested relations from API
  @JsonKey(name: 'package')
  final Map<String, dynamic>? packageData;
  @JsonKey(name: 'course')
  final Map<String, dynamic>? courseData;

  const UserSubscriptionModel({
    required this.id,
    required this.userId,
    this.packageId,
    this.courseId,
    this.activatedBy,
    this.codeId,
    this.receiptId,
    this.isActive = true,
    this.activatedAt,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.packageData,
    this.courseData,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$UserSubscriptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserSubscriptionModelToJson(this);

  /// Extract package name from nested data
  String? get packageName {
    if (packageData == null) return null;
    return packageData!['name_ar'] as String? ??
        packageData!['name'] as String?;
  }

  /// Extract course name from nested data
  String? get courseName {
    if (courseData == null) return null;
    return courseData!['title_ar'] as String? ??
        courseData!['title'] as String?;
  }

  UserSubscriptionEntity toEntity() {
    final now = DateTime.now();
    return UserSubscriptionEntity(
      id: id,
      userId: userId,
      courseId: courseId,
      packageId: packageId,
      activatedBy: activatedBy ?? 'unknown',
      codeId: codeId,
      receiptId: receiptId,
      activatedAt: activatedAt ?? now,
      expiresAt: expiresAt ?? now.add(const Duration(days: 365)),
      isActive: isActive,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      courseName: courseName,
      packageName: packageName,
    );
  }

  factory UserSubscriptionModel.fromEntity(UserSubscriptionEntity entity) {
    return UserSubscriptionModel(
      id: entity.id,
      userId: entity.userId,
      packageId: entity.packageId,
      courseId: entity.courseId,
      activatedBy: entity.activatedBy ?? 'unknown',
      codeId: entity.codeId,
      receiptId: entity.receiptId,
      isActive: entity.isActive,
      activatedAt: entity.activatedAt,
      expiresAt: entity.expiresAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      status: null,
      packageData: null,
      courseData: null,
    );
  }
}
