import 'package:equatable/equatable.dart';

/// كيان الملف الشخصي - يحتوي على جميع معلومات المستخدم
///
/// يجمع بين:
/// - المعلومات الأساسية (الاسم، البريد الإلكتروني، الصورة)
/// - المعلومات الأكاديمية (المرحلة، السنة، الشعبة)
/// - الإحصائيات السريعة (النقاط، المستوى، السلسلة)
class ProfileEntity extends Equatable {
  // المعلومات الأساسية
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatar;

  // معلومات إضافية
  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender; // 'male', 'female'
  final String? city;
  final String? country;
  final String? timezone;

  // المعلومات الأكاديمية
  final int? phaseId;
  final String? phaseName;
  final int? yearId;
  final String? yearName;
  final int? streamId;
  final String? streamName;

  // إحصائيات سريعة (Gamification)
  final int points;
  final int level;
  final int streak;
  final int totalStudyTime; // minutes

  // Metadata
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatar,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.city,
    this.country,
    this.timezone,
    this.phaseId,
    this.phaseName,
    this.yearId,
    this.yearName,
    this.streamId,
    this.streamName,
    required this.points,
    required this.level,
    required this.streak,
    required this.totalStudyTime,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// الاسم الكامل
  String get fullName => '$firstName $lastName';

  /// هل الملف الشخصي مكتمل؟
  bool get isProfileComplete =>
      phone != null &&
      bio != null &&
      dateOfBirth != null &&
      gender != null &&
      city != null;

  /// هل الملف الأكاديمي مكتمل؟
  bool get hasAcademicProfile => phaseId != null && yearId != null;

  /// العمر (إذا كان تاريخ الميلاد موجودًا)
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// وقت الدراسة بالساعات
  double get totalStudyHours => totalStudyTime / 60.0;

  /// هل البريد الإلكتروني مؤكد؟
  bool get isEmailVerified => emailVerifiedAt != null;

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    phone,
    avatar,
    bio,
    dateOfBirth,
    gender,
    city,
    country,
    timezone,
    phaseId,
    phaseName,
    yearId,
    yearName,
    streamId,
    streamName,
    points,
    level,
    streak,
    totalStudyTime,
    emailVerifiedAt,
    createdAt,
    updatedAt,
  ];
}
