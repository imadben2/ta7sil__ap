import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/certificate_entity.dart';

part 'certificate_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CertificateModel {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'course_id')
  final int courseId;
  @JsonKey(name: 'certificate_number')
  final String? certificateNumber;
  @JsonKey(name: 'certificate_url')
  final String? certificateUrl;
  @JsonKey(name: 'qr_code_url')
  final String? qrCodeUrl;
  @JsonKey(name: 'issued_at')
  final DateTime? issuedAt;
  @JsonKey(name: 'valid_until')
  final DateTime? validUntil;
  @JsonKey(name: 'verification_code')
  final String? verificationCode;
  @JsonKey(name: 'grade_percentage')
  final double? gradePercentage;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'course_title_ar')
  final String? courseTitleAr;
  @JsonKey(name: 'course_title_en')
  final String? courseTitleEn;
  @JsonKey(name: 'instructor_name')
  final String? instructorName;
  @JsonKey(name: 'student_name')
  final String? studentName;

  const CertificateModel({
    required this.id,
    required this.userId,
    required this.courseId,
    this.certificateNumber,
    this.certificateUrl,
    this.qrCodeUrl,
    this.issuedAt,
    this.validUntil,
    this.verificationCode,
    this.gradePercentage,
    this.createdAt,
    this.updatedAt,
    this.courseTitleAr,
    this.courseTitleEn,
    this.instructorName,
    this.studentName,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) =>
      _$CertificateModelFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateModelToJson(this);

  CertificateEntity toEntity() {
    return CertificateEntity(
      certificateId: certificateNumber ?? id.toString(),
      userId: userId,
      courseId: courseId,
      studentNameAr: studentName ?? '',
      studentNameEn: null,
      courseTitleAr: courseTitleAr ?? '',
      courseTitleEn: courseTitleEn,
      completionDate: issuedAt ?? DateTime.now(),
      averageScore: gradePercentage,
      pdfUrl: certificateUrl ?? '',
      verificationUrl: 'https://memoapp.dz/verify/${certificateNumber ?? id}',
      qrCodeData: qrCodeUrl,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  factory CertificateModel.fromEntity(CertificateEntity entity) {
    return CertificateModel(
      id: int.tryParse(entity.certificateId) ?? 0,
      userId: entity.userId,
      courseId: entity.courseId,
      certificateNumber: entity.certificateId,
      certificateUrl: entity.pdfUrl,
      qrCodeUrl: entity.qrCodeData,
      issuedAt: entity.completionDate,
      validUntil: null,
      verificationCode: entity.certificateId.length >= 8
          ? entity.certificateId.substring(0, 8)
          : entity.certificateId,
      gradePercentage: entity.averageScore,
      createdAt: entity.createdAt,
      updatedAt: null,
      courseTitleAr: entity.courseTitleAr,
      courseTitleEn: entity.courseTitleEn,
      instructorName: null,
      studentName: entity.studentNameAr,
    );
  }
}
