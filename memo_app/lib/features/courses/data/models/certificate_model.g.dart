// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certificate_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CertificateModel _$CertificateModelFromJson(Map<String, dynamic> json) =>
    CertificateModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      courseId: (json['course_id'] as num).toInt(),
      certificateNumber: json['certificate_number'] as String?,
      certificateUrl: json['certificate_url'] as String?,
      qrCodeUrl: json['qr_code_url'] as String?,
      issuedAt: json['issued_at'] == null
          ? null
          : DateTime.parse(json['issued_at'] as String),
      validUntil: json['valid_until'] == null
          ? null
          : DateTime.parse(json['valid_until'] as String),
      verificationCode: json['verification_code'] as String?,
      gradePercentage: (json['grade_percentage'] as num?)?.toDouble(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      courseTitleAr: json['course_title_ar'] as String?,
      courseTitleEn: json['course_title_en'] as String?,
      instructorName: json['instructor_name'] as String?,
      studentName: json['student_name'] as String?,
    );

Map<String, dynamic> _$CertificateModelToJson(CertificateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'course_id': instance.courseId,
      'certificate_number': instance.certificateNumber,
      'certificate_url': instance.certificateUrl,
      'qr_code_url': instance.qrCodeUrl,
      'issued_at': instance.issuedAt?.toIso8601String(),
      'valid_until': instance.validUntil?.toIso8601String(),
      'verification_code': instance.verificationCode,
      'grade_percentage': instance.gradePercentage,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'course_title_ar': instance.courseTitleAr,
      'course_title_en': instance.courseTitleEn,
      'instructor_name': instance.instructorName,
      'student_name': instance.studentName,
    };
