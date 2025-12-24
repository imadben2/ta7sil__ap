import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payment_receipt_entity.dart';

part 'payment_receipt_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PaymentReceiptModel {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'package_id')
  final int? packageId;
  @JsonKey(name: 'course_id')
  final int? courseId;
  @JsonKey(name: 'receipt_image_url')
  final String receiptImageUrl;
  @JsonKey(name: 'receipt_image_full_url')
  final String? receiptImageFullUrl;
  @JsonKey(name: 'amount_dzd')
  final int amountDzd;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @JsonKey(name: 'transaction_reference')
  final String? transactionReference;
  @JsonKey(name: 'user_notes')
  final String? userNotes;
  final String? status;
  @JsonKey(name: 'submitted_at')
  final DateTime? submittedAt;
  @JsonKey(name: 'reviewed_by')
  final int? reviewedBy;
  @JsonKey(name: 'admin_notes')
  final String? adminNotes;
  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;
  @JsonKey(name: 'reviewed_at')
  final DateTime? reviewedAt;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'package_title_ar')
  final String? packageTitleAr;
  @JsonKey(name: 'course_title_ar')
  final String? courseTitleAr;
  @JsonKey(name: 'user_name')
  final String? userName;
  @JsonKey(name: 'reviewer_name')
  final String? reviewerName;

  // Nested package data from API
  @JsonKey(name: 'package')
  final Map<String, dynamic>? packageData;

  const PaymentReceiptModel({
    required this.id,
    required this.userId,
    this.packageId,
    this.courseId,
    required this.receiptImageUrl,
    this.receiptImageFullUrl,
    required this.amountDzd,
    this.paymentMethod,
    this.transactionReference,
    this.userNotes,
    this.status = 'pending',
    this.submittedAt,
    this.reviewedBy,
    this.adminNotes,
    this.rejectionReason,
    this.reviewedAt,
    this.createdAt,
    this.updatedAt,
    this.packageTitleAr,
    this.courseTitleAr,
    this.userName,
    this.reviewerName,
    this.packageData,
  });

  factory PaymentReceiptModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentReceiptModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentReceiptModelToJson(this);

  /// Extract package name from nested data or packageTitleAr
  String? get packageName {
    if (packageTitleAr != null) return packageTitleAr;
    if (packageData == null) return null;
    return packageData!['name_ar'] as String? ??
        packageData!['name'] as String?;
  }

  PaymentReceiptEntity toEntity() {
    final now = DateTime.now();
    return PaymentReceiptEntity(
      id: id,
      userId: userId,
      courseId: courseId,
      packageId: packageId,
      receiptImageUrl: receiptImageFullUrl ?? receiptImageUrl,
      amountDzd: amountDzd,
      paymentMethod: paymentMethod,
      transactionReference: transactionReference,
      status: status ?? 'pending',
      submittedAt: submittedAt ?? now,
      reviewedAt: reviewedAt,
      reviewedBy: reviewedBy,
      adminNotes: adminNotes,
      rejectionReason: rejectionReason,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      courseName: courseTitleAr,
      packageName: packageName,
      reviewerName: reviewerName,
    );
  }

  factory PaymentReceiptModel.fromEntity(PaymentReceiptEntity entity) {
    return PaymentReceiptModel(
      id: entity.id,
      userId: entity.userId,
      packageId: entity.packageId,
      courseId: entity.courseId,
      receiptImageUrl: entity.receiptImageUrl,
      amountDzd: entity.amountDzd,
      paymentMethod: entity.paymentMethod,
      transactionReference: entity.transactionReference,
      userNotes: null,
      status: entity.status,
      submittedAt: entity.submittedAt,
      reviewedBy: entity.reviewedBy,
      adminNotes: entity.adminNotes,
      rejectionReason: entity.rejectionReason,
      reviewedAt: entity.reviewedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      packageTitleAr: entity.packageName,
      courseTitleAr: entity.courseName,
      userName: null,
      reviewerName: entity.reviewerName,
      packageData: null,
    );
  }
}
