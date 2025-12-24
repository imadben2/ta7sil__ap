import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_datasource.dart';
import '../datasources/notification_remote_datasource.dart';

/// تنفيذ مستودع الإشعارات
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  final NotificationLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  NotificationRepositoryImpl({
    required NotificationRemoteDataSource remoteDataSource,
    required NotificationLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, NotificationsListEntity>> getNotifications({
    int page = 1,
    int perPage = 20,
    bool? isRead,
    String? type,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        // جلب من الخادم
        final response = await _remoteDataSource.getNotifications(
          page: page,
          perPage: perPage,
          isRead: isRead,
          type: type,
        );

        // تخزين محليًا (الصفحة الأولى فقط)
        if (page == 1) {
          await _localDataSource.cacheNotifications(response.notifications);
        }

        return Right(response.toEntity());
      } else {
        // جلب من الذاكرة المؤقتة
        final cached = await _localDataSource.getCachedNotifications();
        final unreadCount = await _localDataSource.getUnreadCount();

        return Right(NotificationsListEntity(
          notifications: cached.map((n) => n.toEntity()).toList(),
          unreadCount: unreadCount,
          total: cached.length,
          currentPage: 1,
          lastPage: 1,
        ));
      }
    } on ServerException catch (e) {
      debugPrint('[NotificationRepo] Server error: ${e.message}');

      // محاولة جلب من الذاكرة المؤقتة
      final cached = await _localDataSource.getCachedNotifications();
      if (cached.isNotEmpty) {
        final unreadCount = await _localDataSource.getUnreadCount();
        return Right(NotificationsListEntity(
          notifications: cached.map((n) => n.toEntity()).toList(),
          unreadCount: unreadCount,
          total: cached.length,
        ));
      }

      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('[NotificationRepo] Error: $e');
      return const Left(ServerFailure('خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      if (await _networkInfo.isConnected) {
        final count = await _remoteDataSource.getUnreadCount();
        return Right(count);
      } else {
        final count = await _localDataSource.getUnreadCount();
        return Right(count);
      }
    } catch (e) {
      debugPrint('[NotificationRepo] Unread count error: $e');
      return const Right(0);
    }
  }

  @override
  Future<Either<Failure, bool>> markAsRead(String notificationId) async {
    try {
      // تحديث محلي أولاً
      await _localDataSource.markAsRead(notificationId);

      // ثم الخادم إذا متصل
      if (await _networkInfo.isConnected) {
        await _remoteDataSource.markAsRead(notificationId);
      }

      return const Right(true);
    } catch (e) {
      debugPrint('[NotificationRepo] Mark as read error: $e');
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, int>> markAllAsRead() async {
    try {
      // تحديث محلي أولاً
      await _localDataSource.markAllAsRead();

      // ثم الخادم إذا متصل
      if (await _networkInfo.isConnected) {
        final count = await _remoteDataSource.markAllAsRead();
        return Right(count);
      }

      return const Right(0);
    } catch (e) {
      debugPrint('[NotificationRepo] Mark all as read error: $e');
      return const Right(0);
    }
  }

  @override
  Future<Either<Failure, bool>> deleteNotification(String notificationId) async {
    try {
      // حذف محلي
      await _localDataSource.deleteNotification(notificationId);

      // ثم الخادم إذا متصل
      if (await _networkInfo.isConnected) {
        await _remoteDataSource.deleteNotification(notificationId);
      }

      return const Right(true);
    } catch (e) {
      debugPrint('[NotificationRepo] Delete error: $e');
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, bool>> registerFcmToken({
    required String token,
    required String deviceUuid,
    required String platform,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final success = await _remoteDataSource.registerFcmToken(
          token: token,
          deviceUuid: deviceUuid,
          platform: platform,
        );
        return Right(success);
      }
      return const Right(false);
    } catch (e) {
      debugPrint('[NotificationRepo] Register token error: $e');
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, bool>> unregisterDevice(String deviceUuid) async {
    try {
      if (await _networkInfo.isConnected) {
        final success = await _remoteDataSource.unregisterDevice(deviceUuid);
        return Right(success);
      }
      return const Right(false);
    } catch (e) {
      debugPrint('[NotificationRepo] Unregister error: $e');
      return const Right(false);
    }
  }

  @override
  Future<List<NotificationEntity>> getCachedNotifications() async {
    try {
      final cached = await _localDataSource.getCachedNotifications();
      return cached.map((n) => n.toEntity()).toList();
    } catch (e) {
      debugPrint('[NotificationRepo] Get cached error: $e');
      return [];
    }
  }

  @override
  Future<void> clearCache() async {
    await _localDataSource.clearAll();
  }
}
