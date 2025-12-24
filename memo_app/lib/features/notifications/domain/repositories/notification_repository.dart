import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/notification_entity.dart';

/// واجهة مستودع الإشعارات
abstract class NotificationRepository {
  /// جلب قائمة الإشعارات
  Future<Either<Failure, NotificationsListEntity>> getNotifications({
    int page = 1,
    int perPage = 20,
    bool? isRead,
    String? type,
  });

  /// جلب عدد الإشعارات غير المقروءة
  Future<Either<Failure, int>> getUnreadCount();

  /// تحديد إشعار كمقروء
  Future<Either<Failure, bool>> markAsRead(String notificationId);

  /// تحديد جميع الإشعارات كمقروءة
  Future<Either<Failure, int>> markAllAsRead();

  /// حذف إشعار
  Future<Either<Failure, bool>> deleteNotification(String notificationId);

  /// تسجيل رمز FCM
  Future<Either<Failure, bool>> registerFcmToken({
    required String token,
    required String deviceUuid,
    required String platform,
  });

  /// إلغاء تسجيل الجهاز
  Future<Either<Failure, bool>> unregisterDevice(String deviceUuid);

  /// جلب الإشعارات المخزنة محليًا
  Future<List<NotificationEntity>> getCachedNotifications();

  /// مسح الذاكرة المؤقتة
  Future<void> clearCache();
}
