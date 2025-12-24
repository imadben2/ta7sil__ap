import 'package:equatable/equatable.dart';

/// Certificate Entity - يمثل شهادة إتمام دورة
class CertificateEntity extends Equatable {
  final String certificateId; // Unique ID (UUID)
  final int userId;
  final int courseId;
  final String studentNameAr;
  final String? studentNameEn;
  final String courseTitleAr;
  final String? courseTitleEn;
  final DateTime completionDate;
  final double? averageScore; // 0.0 - 100.0
  final String pdfUrl;
  final String verificationUrl;
  final String? qrCodeData;
  final DateTime createdAt;

  const CertificateEntity({
    required this.certificateId,
    required this.userId,
    required this.courseId,
    required this.studentNameAr,
    this.studentNameEn,
    required this.courseTitleAr,
    this.courseTitleEn,
    required this.completionDate,
    this.averageScore,
    required this.pdfUrl,
    required this.verificationUrl,
    this.qrCodeData,
    required this.createdAt,
  });

  /// تاريخ الإكمال المنسق (مثال: "15 نوفمبر 2025")
  String get formattedCompletionDate {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${completionDate.day} ${months[completionDate.month - 1]} ${completionDate.year}';
  }

  /// المعدل المنسق (مثال: "95%")
  String? get formattedScore {
    if (averageScore == null) return null;
    return '${averageScore!.toStringAsFixed(0)}%';
  }

  /// تقدير المعدل
  String? get gradeText {
    if (averageScore == null) return null;
    if (averageScore! >= 90) return 'ممتاز';
    if (averageScore! >= 80) return 'جيد جداً';
    if (averageScore! >= 70) return 'جيد';
    if (averageScore! >= 60) return 'مقبول';
    return 'ضعيف';
  }

  /// رمز التحقق المختصر (أول 8 أحرف من certificateId)
  String get shortVerificationCode {
    if (certificateId.length <= 8) return certificateId;
    return certificateId.substring(0, 8).toUpperCase();
  }

  /// رابط المشاركة
  String get shareText =>
      '''
شهادة إتمام دورة 🎓

الطالب: $studentNameAr
الدورة: $courseTitleAr
التاريخ: $formattedCompletionDate
${averageScore != null ? 'المعدل: ${formattedScore!}' : ''}

للتحقق من الشهادة:
$verificationUrl
''';

  CertificateEntity copyWith({
    String? certificateId,
    int? userId,
    int? courseId,
    String? studentNameAr,
    String? studentNameEn,
    String? courseTitleAr,
    String? courseTitleEn,
    DateTime? completionDate,
    double? averageScore,
    String? pdfUrl,
    String? verificationUrl,
    String? qrCodeData,
    DateTime? createdAt,
  }) {
    return CertificateEntity(
      certificateId: certificateId ?? this.certificateId,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      studentNameAr: studentNameAr ?? this.studentNameAr,
      studentNameEn: studentNameEn ?? this.studentNameEn,
      courseTitleAr: courseTitleAr ?? this.courseTitleAr,
      courseTitleEn: courseTitleEn ?? this.courseTitleEn,
      completionDate: completionDate ?? this.completionDate,
      averageScore: averageScore ?? this.averageScore,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      verificationUrl: verificationUrl ?? this.verificationUrl,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    certificateId,
    userId,
    courseId,
    studentNameAr,
    studentNameEn,
    courseTitleAr,
    courseTitleEn,
    completionDate,
    averageScore,
    pdfUrl,
    verificationUrl,
    qrCodeData,
    createdAt,
  ];
}
