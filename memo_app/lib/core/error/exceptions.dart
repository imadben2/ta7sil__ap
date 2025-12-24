/// Base exception class for all custom exceptions
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic data;

  AppException({
    required this.message,
    this.code,
    this.data,
  });

  @override
  String toString() => 'AppException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Exception thrown when server returns an error
class ServerException extends AppException {
  ServerException({
    required super.message,
    super.code,
    super.data,
  });

  @override
  String toString() => 'ServerException: $message';
}

/// Exception thrown when there's a network connectivity issue
class NetworkException extends AppException {
  NetworkException({
    String message = 'لا يوجد اتصال بالإنترنت',
    super.code,
    super.data,
  }) : super(message: message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when client sends invalid data
class ClientException extends AppException {
  ClientException({
    required super.message,
    super.code,
    super.data,
  });

  @override
  String toString() => 'ClientException: $message';
}

/// Exception thrown when authentication fails
class AuthenticationException extends AppException {
  AuthenticationException({
    String message = 'فشلت عملية المصادقة',
    super.code,
    super.data,
  }) : super(message: message);

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Exception thrown when device UUID doesn't match
class DeviceMismatchException extends AppException {
  DeviceMismatchException({
    String message = 'هذا الحساب مرتبط بجهاز آخر',
    super.code,
    super.data,
  }) : super(message: message);

  @override
  String toString() => 'DeviceMismatchException: $message';
}

/// Exception thrown when cache operation fails
class CacheException extends AppException {
  CacheException({
    String message = 'خطأ في التخزين المحلي',
    super.code,
    super.data,
  }) : super(message: message);

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  ValidationException({
    String message = 'بيانات غير صالحة',
    this.errors,
    super.code,
    super.data,
  }) : super(message: message);

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      final errorMessages = errors!.entries
          .map((e) => '${e.key}: ${e.value.join(', ')}')
          .join('; ');
      return 'ValidationException: $message - $errorMessages';
    }
    return 'ValidationException: $message';
  }
}

/// Exception thrown when resource is not found
class NotFoundException extends AppException {
  NotFoundException({
    String message = 'العنصر المطلوب غير موجود',
    super.code,
    super.data,
  }) : super(message: message);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception thrown when request times out
class TimeoutException extends AppException {
  TimeoutException({
    String message = 'انتهت مهلة الطلب',
    super.code,
    super.data,
  }) : super(message: message);

  @override
  String toString() => 'TimeoutException: $message';
}

/// Exception thrown when permission is denied
class PermissionException extends AppException {
  PermissionException({
    String message = 'ليس لديك صلاحية للوصول',
    super.code,
    super.data,
  }) : super(message: message);

  @override
  String toString() => 'PermissionException: $message';
}

/// Exception thrown when parsing data fails
class ParseException extends AppException {
  ParseException({
    String message = 'خطأ في معالجة البيانات',
    super.code,
    super.data,
  }) : super(message: message);

  @override
  String toString() => 'ParseException: $message';
}

/// Exception thrown when prayer times API fails
class PrayerTimesException extends AppException {
  PrayerTimesException({
    String message = 'فشل في جلب أوقات الصلاة',
    super.code,
    super.data,
  }) : super(message: message);

  @override
  String toString() => 'PrayerTimesException: $message';
}

/// Exception thrown when schedule generation fails
class ScheduleGenerationException extends AppException {
  ScheduleGenerationException({
    String message = 'فشل في إنشاء الجدول الدراسي',
    super.code,
    super.data,
  }) : super(message: message);

  @override
  String toString() => 'ScheduleGenerationException: $message';
}

/// Exception thrown when sync fails
class SyncException extends AppException {
  SyncException({
    String message = 'فشل في مزامنة البيانات',
    super.code,
    super.data,
  }) : super(message: message);

  @override
  String toString() => 'SyncException: $message';
}
