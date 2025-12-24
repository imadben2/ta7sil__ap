import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Server-related failures (5xx errors)
class ServerFailure extends Failure {
  const ServerFailure([String message = 'خطأ في الخادم']) : super(message);
}

/// Network-related failures (no connection, timeout)
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'تحقق من اتصالك بالإنترنت'])
    : super(message);
}

/// Client-related failures (4xx errors - invalid request)
class ClientFailure extends Failure {
  const ClientFailure([String message = 'طلب غير صالح']) : super(message);
}

/// Authentication failures (401, 403)
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([
    String message = 'فشل المصادقة. يرجى تسجيل الدخول مرة أخرى',
  ]) : super(message);
}

/// Unauthorized failures (401 - requires authentication)
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String message = 'غير مصرح. يرجى تسجيل الدخول'])
    : super(message);
}

/// Device mismatch failure (account logged in on another device)
class DeviceMismatchFailure extends Failure {
  const DeviceMismatchFailure([String message = 'هذا الحساب مسجل على جهاز آخر'])
    : super(message);
}

/// Cache-related failures (local storage errors)
class CacheFailure extends Failure {
  const CacheFailure([String message = 'خطأ في التخزين المحلي'])
    : super(message);
}

/// Validation failures (form validation errors)
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'بيانات غير صالحة'])
    : super(message);
}

/// Not found failures (404 errors)
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'لم يتم العثور على البيانات'])
    : super(message);
}

/// Permission failures (403 forbidden)
class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'ليس لديك صلاحية لهذا الإجراء'])
    : super(message);
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure([String message = 'انتهت مهلة الطلب']) : super(message);
}

/// Generic failure for unexpected errors
class GenericFailure extends Failure {
  const GenericFailure([String message = 'حدث خطأ ما']) : super(message);
}

// ========== Courses Feature Failures ==========

/// Course access denied (user not subscribed)
class CourseAccessDeniedFailure extends Failure {
  const CourseAccessDeniedFailure([
    String message = 'ليس لديك وصول لهذه الدورة. يرجى الاشتراك أولاً',
  ]) : super(message);
}

/// Course not found
class CourseNotFoundFailure extends Failure {
  const CourseNotFoundFailure([String message = 'لم يتم العثور على الدورة'])
    : super(message);
}

/// Lesson not found
class LessonNotFoundFailure extends Failure {
  const LessonNotFoundFailure([String message = 'لم يتم العثور على الدرس'])
    : super(message);
}

/// Video playback failure
class VideoPlaybackFailure extends Failure {
  const VideoPlaybackFailure([String message = 'فشل تشغيل الفيديو'])
    : super(message);
}

/// Payment receipt validation failure
class ReceiptValidationFailure extends Failure {
  const ReceiptValidationFailure([String message = 'فشل التحقق من الإيصال'])
    : super(message);
}

/// Subscription code invalid
class InvalidSubscriptionCodeFailure extends Failure {
  const InvalidSubscriptionCodeFailure([
    String message = 'كود الاشتراك غير صالح أو منتهي الصلاحية',
  ]) : super(message);
}

/// Certificate generation failure
class CertificateGenerationFailure extends Failure {
  const CertificateGenerationFailure([String message = 'فشل إنشاء الشهادة'])
    : super(message);
}

/// Review submission failure
class ReviewSubmissionFailure extends Failure {
  const ReviewSubmissionFailure([String message = 'فشل إرسال المراجعة'])
    : super(message);
}

/// File upload failure (receipt image)
class FileUploadFailure extends Failure {
  const FileUploadFailure([String message = 'فشل رفع الملف']) : super(message);
}

// ========== Planner Feature Failures ==========

/// Prayer times API failure
class PrayerTimesFailure extends Failure {
  const PrayerTimesFailure([String message = 'فشل تحميل مواقيت الصلاة'])
    : super(message);
}

/// Schedule generation failure
class ScheduleGenerationFailure extends Failure {
  const ScheduleGenerationFailure([String message = 'فشل إنشاء الجدول الدراسي'])
    : super(message);
}

/// Session management failure
class SessionManagementFailure extends Failure {
  const SessionManagementFailure([String message = 'فشل في إدارة الجلسة الدراسية'])
    : super(message);
}
