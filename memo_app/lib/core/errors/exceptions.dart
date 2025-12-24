/// Base class for all exceptions in the application
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException({required this.message, this.code, this.details});

  @override
  String toString() =>
      'AppException: $message ${code != null ? '($code)' : ''}';
}

/// Server exception (5xx errors)
class ServerException extends AppException {
  ServerException({
    String message = 'Server error occurred',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Network exception (connection issues)
class NetworkException extends AppException {
  NetworkException({
    String message = 'Network connection error',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Client exception (4xx errors)
class ClientException extends AppException {
  ClientException({
    String message = 'Client error occurred',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Authentication exception (401, 403)
class AuthenticationException extends AppException {
  AuthenticationException({
    String message = 'Authentication failed',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Unauthorized exception (401 - requires authentication)
class UnauthorizedException extends AppException {
  UnauthorizedException({
    String message = 'Unauthorized access',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Device mismatch exception
class DeviceMismatchException extends AppException {
  DeviceMismatchException({
    String message = 'Device mismatch detected',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Cache exception (local storage errors)
class CacheException extends AppException {
  CacheException({
    String message = 'Cache error occurred',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Validation exception (form validation)
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  ValidationException({
    String message = 'Validation error',
    String? code,
    this.errors,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Not found exception (404)
class NotFoundException extends AppException {
  NotFoundException({
    String message = 'Resource not found',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Timeout exception
class TimeoutException extends AppException {
  TimeoutException({
    String message = 'Request timeout',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Permission exception (403)
class PermissionException extends AppException {
  PermissionException({
    String message = 'Permission denied',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Parse exception (JSON parsing errors)
class ParseException extends AppException {
  ParseException({
    String message = 'Data parsing error',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Rate limit exception (429 - too many requests)
class RateLimitException extends AppException {
  final int? retryAfterSeconds;

  RateLimitException({
    String message = 'Too many requests - rate limit exceeded',
    String? code,
    this.retryAfterSeconds,
    dynamic details,
  }) : super(message: message, code: code, details: details);

  @override
  String toString() {
    if (retryAfterSeconds != null) {
      return 'RateLimitException: $message. Retry after $retryAfterSeconds seconds ${code != null ? '($code)' : ''}';
    }
    return super.toString();
  }
}
