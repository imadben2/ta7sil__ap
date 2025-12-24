import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';
import '../entities/device_session_entity.dart';

/// واجهة مستودع الملف الشخصي
///
/// تحدد العمليات المتاحة للملف الشخصي:
/// - جلب/تحديث الملف الشخصي
/// - تغيير كلمة المرور
/// - رفع صورة الملف الشخصي
/// - تصدير البيانات الشخصية (GDPR)
/// - حذف الحساب
/// - إدارة الأجهزة المتصلة
abstract class ProfileRepository {
  /// جلب الملف الشخصي الحالي
  ///
  /// يحاول الجلب من Cache أولًا (TTL: 30 دقيقة)
  /// إذا لم يكن موجود أو منتهي الصلاحية، يجلب من API
  ///
  /// Returns: [ProfileEntity] في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, ProfileEntity>> getProfile();

  /// تحديث الملف الشخصي
  ///
  /// Parameters:
  /// - [firstName]: الاسم الأول (اختياري)
  /// - [lastName]: الاسم الأخير (اختياري)
  /// - [phone]: رقم الهاتف (اختياري)
  /// - [bio]: السيرة الذاتية (اختياري)
  /// - [dateOfBirth]: تاريخ الميلاد (اختياري)
  /// - [gender]: الجنس ('male', 'female') (اختياري)
  /// - [city]: المدينة (اختياري)
  /// - [country]: الدولة (اختياري)
  ///
  /// Returns: [ProfileEntity] محدث في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, ProfileEntity>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? bio,
    DateTime? dateOfBirth,
    String? gender,
    String? city,
    String? country,
  });

  /// تحديث المعلومات الأكاديمية
  ///
  /// Parameters:
  /// - [phaseId]: معرف المرحلة
  /// - [yearId]: معرف السنة
  /// - [streamId]: معرف الشعبة (اختياري)
  ///
  /// Returns: [ProfileEntity] محدث في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, ProfileEntity>> updateAcademicProfile({
    required int phaseId,
    required int yearId,
    int? streamId,
  });

  /// رفع صورة الملف الشخصي
  ///
  /// Parameters:
  /// - [imageFile]: ملف الصورة
  ///
  /// Validation:
  /// - الحد الأقصى: 2 MB (بعد الضغط)
  /// - الصيغ المدعومة: JPEG, PNG, WEBP
  /// - الأبعاد الدنيا: 100x100 px
  /// - نسبة العرض للارتفاع: 1:1 (مربع)
  ///
  /// Returns: [ProfileEntity] مع URL الصورة الجديد في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, ProfileEntity>> uploadProfilePhoto(File imageFile);

  /// تغيير كلمة المرور
  ///
  /// Parameters:
  /// - [currentPassword]: كلمة المرور الحالية
  /// - [newPassword]: كلمة المرور الجديدة
  /// - [newPasswordConfirmation]: تأكيد كلمة المرور الجديدة
  ///
  /// Validation:
  /// - كلمة المرور الحالية صحيحة
  /// - كلمة المرور الجديدة تطابق قواعد التعقيد:
  ///   * الحد الأدنى: 8 أحرف
  ///   * حرف كبير واحد على الأقل
  ///   * حرف صغير واحد على الأقل
  ///   * رقم واحد على الأقل
  ///   * حرف خاص موصى به
  /// - كلمة المرور الجديدة لا تساوي الحالية
  ///
  /// Rate Limit: 5 محاولات في الساعة
  ///
  /// Returns: [void] في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  ///
  /// Side Effects:
  /// - يتم تحديث Token
  /// - يتم تسجيل خروج من جميع الأجهزة الأخرى
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });

  /// تصدير البيانات الشخصية (GDPR)
  ///
  /// يصدر جميع بيانات المستخدم بتنسيق JSON أو PDF
  ///
  /// Parameters:
  /// - [format]: 'json' أو 'pdf' (افتراضي: 'json')
  ///
  /// Returns: [String] مسار الملف المُصدَّر في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, String>> exportPersonalData({String format = 'json'});

  /// حذف الحساب
  ///
  /// حذف soft delete لمدة 30 يومًا
  ///
  /// Parameters:
  /// - [password]: كلمة المرور للتأكيد
  /// - [reason]: سبب الحذف (اختياري)
  ///
  /// Validation:
  /// - كلمة المرور صحيحة
  /// - لا يوجد اشتراكات نشطة
  ///
  /// Returns: [void] في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  ///
  /// Side Effects:
  /// - تسجيل خروج من جميع الأجهزة
  /// - إيقاف جميع الإشعارات
  /// - الحساب قابل للاسترجاع خلال 30 يوم
  Future<Either<Failure, void>> deleteAccount({
    required String password,
    String? reason,
  });

  /// الحصول على قائمة الأجهزة المتصلة
  ///
  /// Returns: قائمة [DeviceSessionEntity] في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, List<DeviceSessionEntity>>> getDeviceSessions();

  /// تسجيل/تحديث الجهاز الحالي
  ///
  /// Parameters:
  /// - [deviceInfo]: معلومات الجهاز (device_name, device_type, device_os, etc.)
  ///
  /// Returns: [DeviceSessionEntity] في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, DeviceSessionEntity>> registerDeviceSession(Map<String, dynamic> deviceInfo);

  /// تسجيل خروج من جهاز معين
  ///
  /// Parameters:
  /// - [sessionId]: معرف الجلسة
  ///
  /// Returns: [void] في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, void>> logoutDevice(int sessionId);

  /// تسجيل خروج من جميع الأجهزة الأخرى (ماعدا الحالي)
  ///
  /// Returns: [void] في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, void>> logoutAllOtherDevices();

  /// إعادة تحميل الملف الشخصي (تجاوز Cache)
  ///
  /// Returns: [ProfileEntity] في حالة النجاح
  /// Returns: [Failure] في حالة الفشل
  Future<Either<Failure, ProfileEntity>> refreshProfile();
}
