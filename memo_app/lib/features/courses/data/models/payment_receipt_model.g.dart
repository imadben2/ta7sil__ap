// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_receipt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentReceiptModel _$PaymentReceiptModelFromJson(Map<String, dynamic> json) =>
    PaymentReceiptModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      packageId: (json['package_id'] as num?)?.toInt(),
      courseId: (json['course_id'] as num?)?.toInt(),
      receiptImageUrl: json['receipt_image_url'] as String,
      receiptImageFullUrl: json['receipt_image_full_url'] as String?,
      amountDzd: (json['amount_dzd'] as num).toInt(),
      paymentMethod: json['payment_method'] as String?,
      transactionReference: json['transaction_reference'] as String?,
      userNotes: json['user_notes'] as String?,
      status: json['status'] as String? ?? 'pending',
      submittedAt: json['submitted_at'] == null
          ? null
          : DateTime.parse(json['submitted_at'] as String),
      reviewedBy: (json['reviewed_by'] as num?)?.toInt(),
      adminNotes: json['admin_notes'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      reviewedAt: json['reviewed_at'] == null
          ? null
          : DateTime.parse(json['reviewed_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      packageTitleAr: json['package_title_ar'] as String?,
      courseTitleAr: json['course_title_ar'] as String?,
      userName: json['user_name'] as String?,
      reviewerName: json['reviewer_name'] as String?,
      packageData: json['package'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PaymentReceiptModelToJson(
        PaymentReceiptModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'package_id': instance.packageId,
      'course_id': instance.courseId,
      'receipt_image_url': instance.receiptImageUrl,
      'receipt_image_full_url': instance.receiptImageFullUrl,
      'amount_dzd': instance.amountDzd,
      'payment_method': instance.paymentMethod,
      'transaction_reference': instance.transactionReference,
      'user_notes': instance.userNotes,
      'status': instance.status,
      'submitted_at': instance.submittedAt?.toIso8601String(),
      'reviewed_by': instance.reviewedBy,
      'admin_notes': instance.adminNotes,
      'rejection_reason': instance.rejectionReason,
      'reviewed_at': instance.reviewedAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'package_title_ar': instance.packageTitleAr,
      'course_title_ar': instance.courseTitleAr,
      'user_name': instance.userName,
      'reviewer_name': instance.reviewerName,
      'package': instance.packageData,
    };
