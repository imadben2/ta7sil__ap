import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import '../storage/hive_service.dart';
import '../errors/exceptions.dart';

/// Dio HTTP client with interceptors and error handling
class DioClient {
  final Dio dio;
  final SecureStorageService secureStorage;
  final HiveService? hiveService;

  DioClient({
    required this.dio,
    required this.secureStorage,
    this.hiveService,
  }) {
    _configureDio();
  }

  void _configureDio() {
    dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: {
        ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        ApiConstants.headerAccept: ApiConstants.contentTypeJson,
      },
    );

    // Add interceptors
    dio.interceptors.add(_AuthInterceptor(secureStorage, hiveService));
    dio.interceptors.add(_ErrorInterceptor());
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Handle Dio errors
  AppException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'لا يوجد اتصال بالانترنت',
          details: error.message,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode == 401) {
          return AuthenticationException(
            message: data?['message'] ?? 'Unauthorized',
            code: statusCode.toString(),
            details: data,
          );
        } else if (statusCode == 403) {
          return PermissionException(
            message: data?['message'] ?? 'Forbidden',
            code: statusCode.toString(),
            details: data,
          );
        } else if (statusCode == 404) {
          return NotFoundException(
            message: data?['message'] ?? 'Not found',
            code: statusCode.toString(),
            details: data,
          );
        } else if (statusCode == 429) {
          // Rate limit exception
          final retryAfterHeader = error.response?.headers.value('retry-after');
          final retryAfter = retryAfterHeader != null
              ? int.tryParse(retryAfterHeader)
              : null;
          return RateLimitException(
            message: data?['message'] ?? 'Too many requests',
            code: statusCode.toString(),
            retryAfterSeconds: retryAfter,
            details: data,
          );
        } else if (statusCode != null &&
            statusCode >= 400 &&
            statusCode < 500) {
          // Check for device mismatch
          if (data?['error'] == 'device_mismatch') {
            return DeviceMismatchException(
              message: data?['message'] ?? 'Device mismatch',
              code: statusCode.toString(),
              details: data,
            );
          }
          return ClientException(
            message: data?['message'] ?? 'Client error',
            code: statusCode.toString(),
            details: data,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(
            message: data?['message'] ?? 'Server error',
            code: statusCode.toString(),
            details: data,
          );
        }
        return AppException(
          message: 'Unexpected error',
          code: statusCode?.toString(),
          details: data,
        );

      case DioExceptionType.cancel:
        return AppException(message: 'Request cancelled');

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
      default:
        return NetworkException(
          message: 'لا يوجد اتصال بالانترنت',
          details: error.message,
        );
    }
  }
}

/// Auth interceptor to add token to requests
class _AuthInterceptor extends Interceptor {
  final SecureStorageService secureStorage;
  final HiveService? hiveService;

  _AuthInterceptor(this.secureStorage, this.hiveService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add auth token
    final token = await secureStorage.getToken();
    if (token != null) {
      options.headers[ApiConstants.headerAuthorization] = 'Bearer $token';
    }

    // Add device ID
    final deviceId = await secureStorage.getDeviceId();
    if (deviceId != null) {
      options.headers[ApiConstants.headerDeviceId] = deviceId;
    }

    // Add academic profile data from cached user if available
    if (hiveService != null) {
      try {
        final userJson = hiveService!.get(
          ApiConstants.hiveBoxAuth,
          ApiConstants.storageKeyUser,
        );

        if (userJson != null) {
          final Map<String, dynamic> userData =
              jsonDecode(userJson) as Map<String, dynamic>;

          // Add academic profile IDs as query parameters if they exist
          if (userData['academic_year_id'] != null) {
            options.queryParameters['year_id'] = userData['academic_year_id'];
          }
          if (userData['stream_id'] != null) {
            options.queryParameters['stream_id'] = userData['stream_id'];
          }
        }
      } catch (e) {
        // Silently ignore if user data is not available
        // This allows requests to work even without academic profile
      }
    }

    handler.next(options);
  }
}

/// Error interceptor for additional error handling
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Additional error handling can be added here
    handler.next(err);
  }
}
