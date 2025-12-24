import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/notification_model.dart';

/// مصدر البيانات البعيد للإشعارات
abstract class NotificationRemoteDataSource {
  /// جلب قائمة الإشعارات
  Future<NotificationsResponse> getNotifications({
    int page = 1,
    int perPage = 20,
    bool? isRead,
    String? type,
  });

  /// جلب عدد الإشعارات غير المقروءة
  Future<int> getUnreadCount();

  /// تحديد إشعار كمقروء
  Future<bool> markAsRead(String notificationId);

  /// تحديد جميع الإشعارات كمقروءة
  Future<int> markAllAsRead();

  /// حذف إشعار
  Future<bool> deleteNotification(String notificationId);

  /// تسجيل رمز FCM
  Future<bool> registerFcmToken({
    required String token,
    required String deviceUuid,
    required String platform,
  });

  /// إلغاء تسجيل الجهاز
  Future<bool> unregisterDevice(String deviceUuid);
}

/// تنفيذ مصدر البيانات البعيد
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio _dio;

  NotificationRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<NotificationsResponse> getNotifications({
    int page = 1,
    int perPage = 20,
    bool? isRead,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (isRead != null) {
        queryParams['is_read'] = isRead ? 1 : 0;
      }
      if (type != null) {
        queryParams['type'] = type;
      }

      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.notifications}',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return NotificationsResponse.fromJson(response.data);
      }

      throw ServerException(
        message: 'فشل في جلب الإشعارات',
        code: '${response.statusCode}',
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'خطأ في الاتصال',
        code: e.response?.statusCode?.toString(),
      );
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.notifications}/unread-count',
      );

      if (response.statusCode == 200) {
        return response.data['unread_count'] ?? 0;
      }

      return 0;
    } on DioException {
      return 0;
    }
  }

  @override
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.notifications}/$notificationId/read',
      );

      return response.statusCode == 200;
    } on DioException {
      return false;
    }
  }

  @override
  Future<int> markAllAsRead() async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.notificationsReadAll}',
      );

      if (response.statusCode == 200) {
        return response.data['marked_count'] ?? 0;
      }

      return 0;
    } on DioException {
      return 0;
    }
  }

  @override
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await _dio.delete(
        '${ApiConstants.baseUrl}${ApiConstants.notifications}/$notificationId',
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException {
      return false;
    }
  }

  @override
  Future<bool> registerFcmToken({
    required String token,
    required String deviceUuid,
    required String platform,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.notificationsFcmToken}',
        data: {
          'token': token,
          'device_uuid': deviceUuid,
          'device_platform': platform,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException {
      return false;
    }
  }

  @override
  Future<bool> unregisterDevice(String deviceUuid) async {
    try {
      final response = await _dio.delete(
        '${ApiConstants.baseUrl}/v1/notifications/unregister-device',
        data: {'device_uuid': deviceUuid},
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException {
      return false;
    }
  }
}
