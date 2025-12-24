import 'package:equatable/equatable.dart';

/// Payment Receipt Entity - يمثل إيصال دفع لدورة أو باقة
class PaymentReceiptEntity extends Equatable {
  final int id;
  final int userId;
  final int? courseId;
  final int? packageId;
  final String receiptImageUrl;
  final int amountDzd;
  final String? paymentMethod; // "baridi_mob", "ccp", "other"
  final String? transactionReference;
  final String status; // "pending", "approved", "rejected"
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final int? reviewedBy;
  final String? adminNotes;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional info
  final String? courseName;
  final String? packageName;
  final String? reviewerName;

  const PaymentReceiptEntity({
    required this.id,
    required this.userId,
    this.courseId,
    this.packageId,
    required this.receiptImageUrl,
    required this.amountDzd,
    this.paymentMethod,
    this.transactionReference,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.adminNotes,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    this.courseName,
    this.packageName,
    this.reviewerName,
  });

  /// هل الإيصال قيد المراجعة؟
  bool get isPending => status.toLowerCase() == 'pending';

  /// هل الإيصال مقبول؟
  bool get isApproved => status.toLowerCase() == 'approved';

  /// هل الإيصال مرفوض؟
  bool get isRejected => status.toLowerCase() == 'rejected';

  /// نص الحالة بالعربي
  String get statusText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'قيد المراجعة';
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'غير محدد';
    }
  }

  /// لون شارة الحالة
  String get statusBadgeColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return '#FF9800'; // برتقالي
      case 'approved':
        return '#4CAF50'; // أخضر
      case 'rejected':
        return '#F44336'; // أحمر
      default:
        return '#9E9E9E'; // رمادي
    }
  }

  /// أيقونة الحالة
  String get statusIcon {
    switch (status.toLowerCase()) {
      case 'pending':
        return '⏳';
      case 'approved':
        return '✅';
      case 'rejected':
        return '❌';
      default:
        return '❓';
    }
  }

  /// المبلغ المنسق
  String get formattedAmount => '$amountDzd دج';

  /// طريقة الدفع بالعربي
  String get paymentMethodText {
    switch (paymentMethod?.toLowerCase()) {
      case 'baridi_mob':
        return 'باريدي موب';
      case 'ccp':
        return 'بريد الجزائر (CCP)';
      case 'other':
        return 'أخرى';
      default:
        return 'غير محدد';
    }
  }

  /// اسم الدورة أو الباقة
  String get itemName {
    if (courseName != null) return courseName!;
    if (packageName != null) return packageName!;
    return 'غير محدد';
  }

  /// نص تاريخ التقديم
  String get submittedAtText {
    final now = DateTime.now();
    final difference = now.difference(submittedAt);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inDays < 30) {
      return 'منذ ${(difference.inDays / 7).floor()} أسبوع';
    } else {
      return 'في ${submittedAt.day}/${submittedAt.month}/${submittedAt.year}';
    }
  }

  /// نص تاريخ المراجعة
  String get reviewedAtText {
    if (reviewedAt == null) return 'لم تتم المراجعة بعد';

    final now = DateTime.now();
    final difference = now.difference(reviewedAt!);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return 'في ${reviewedAt!.day}/${reviewedAt!.month}/${reviewedAt!.year}';
    }
  }

  PaymentReceiptEntity copyWith({
    int? id,
    int? userId,
    int? courseId,
    int? packageId,
    String? receiptImageUrl,
    int? amountDzd,
    String? paymentMethod,
    String? transactionReference,
    String? status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    int? reviewedBy,
    String? adminNotes,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? courseName,
    String? packageName,
    String? reviewerName,
  }) {
    return PaymentReceiptEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      packageId: packageId ?? this.packageId,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      amountDzd: amountDzd ?? this.amountDzd,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionReference: transactionReference ?? this.transactionReference,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      adminNotes: adminNotes ?? this.adminNotes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      courseName: courseName ?? this.courseName,
      packageName: packageName ?? this.packageName,
      reviewerName: reviewerName ?? this.reviewerName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    courseId,
    packageId,
    receiptImageUrl,
    amountDzd,
    paymentMethod,
    transactionReference,
    status,
    submittedAt,
    reviewedAt,
    reviewedBy,
    adminNotes,
    rejectionReason,
    createdAt,
    updatedAt,
    courseName,
    packageName,
    reviewerName,
  ];
}
