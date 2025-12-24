import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';

/// مصدر البيانات المحلي للإشعارات
abstract class NotificationLocalDataSource {
  /// حفظ قائمة الإشعارات
  Future<void> cacheNotifications(List<NotificationModel> notifications);

  /// جلب الإشعارات المخزنة
  Future<List<NotificationModel>> getCachedNotifications();

  /// حفظ إشعار واحد
  Future<void> cacheNotification(NotificationModel notification);

  /// تحديث إشعار
  Future<void> updateNotification(NotificationModel notification);

  /// حذف إشعار
  Future<void> deleteNotification(String notificationId);

  /// مسح جميع الإشعارات
  Future<void> clearAll();

  /// جلب عدد الإشعارات غير المقروءة
  Future<int> getUnreadCount();

  /// تحديد إشعار كمقروء
  Future<void> markAsRead(String notificationId);

  /// تحديد جميع الإشعارات كمقروءة
  Future<void> markAllAsRead();
}

/// تنفيذ مصدر البيانات المحلي باستخدام Hive
class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  static const String _boxName = 'notifications_cache';
  static const int _maxNotifications = 100;
  static const int _maxAgeDays = 30;

  Box<NotificationModel>? _box;

  /// فتح صندوق Hive
  Future<Box<NotificationModel>> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }

    if (!Hive.isAdapterRegistered(50)) {
      Hive.registerAdapter(NotificationModelAdapter());
    }

    _box = await Hive.openBox<NotificationModel>(_boxName);
    return _box!;
  }

  @override
  Future<void> cacheNotifications(List<NotificationModel> notifications) async {
    try {
      final box = await _getBox();

      // مسح القديم وحفظ الجديد
      await box.clear();

      for (final notification in notifications) {
        await box.put(notification.id, notification);
      }

      // تنظيف الإشعارات القديمة
      await _cleanupOldNotifications();

      debugPrint('[NotificationLocalDS] Cached ${notifications.length} notifications');
    } catch (e) {
      debugPrint('[NotificationLocalDS] Cache error: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getCachedNotifications() async {
    try {
      final box = await _getBox();
      final notifications = box.values.toList();

      // ترتيب حسب التاريخ (الأحدث أولاً)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      debugPrint('[NotificationLocalDS] Retrieved ${notifications.length} cached notifications');
      return notifications;
    } catch (e) {
      debugPrint('[NotificationLocalDS] Get cached error: $e');
      return [];
    }
  }

  @override
  Future<void> cacheNotification(NotificationModel notification) async {
    try {
      final box = await _getBox();
      await box.put(notification.id, notification);

      // تنظيف إذا تجاوز الحد
      if (box.length > _maxNotifications) {
        await _cleanupOldNotifications();
      }

      debugPrint('[NotificationLocalDS] Cached notification: ${notification.id}');
    } catch (e) {
      debugPrint('[NotificationLocalDS] Cache single error: $e');
    }
  }

  @override
  Future<void> updateNotification(NotificationModel notification) async {
    try {
      final box = await _getBox();
      await box.put(notification.id, notification);
      debugPrint('[NotificationLocalDS] Updated notification: ${notification.id}');
    } catch (e) {
      debugPrint('[NotificationLocalDS] Update error: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      final box = await _getBox();
      await box.delete(notificationId);
      debugPrint('[NotificationLocalDS] Deleted notification: $notificationId');
    } catch (e) {
      debugPrint('[NotificationLocalDS] Delete error: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      final box = await _getBox();
      await box.clear();
      debugPrint('[NotificationLocalDS] Cleared all notifications');
    } catch (e) {
      debugPrint('[NotificationLocalDS] Clear error: $e');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final box = await _getBox();
      return box.values.where((n) => n.readAt == null).length;
    } catch (e) {
      debugPrint('[NotificationLocalDS] Unread count error: $e');
      return 0;
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final box = await _getBox();
      final notification = box.get(notificationId);

      if (notification != null) {
        final updated = notification.copyWith(readAt: DateTime.now());
        await box.put(notificationId, updated);
        debugPrint('[NotificationLocalDS] Marked as read: $notificationId');
      }
    } catch (e) {
      debugPrint('[NotificationLocalDS] Mark as read error: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final box = await _getBox();
      final now = DateTime.now();

      for (final key in box.keys) {
        final notification = box.get(key);
        if (notification != null && notification.readAt == null) {
          final updated = notification.copyWith(readAt: now);
          await box.put(key, updated);
        }
      }

      debugPrint('[NotificationLocalDS] Marked all as read');
    } catch (e) {
      debugPrint('[NotificationLocalDS] Mark all as read error: $e');
    }
  }

  /// تنظيف الإشعارات القديمة
  Future<void> _cleanupOldNotifications() async {
    try {
      final box = await _getBox();
      final cutoffDate = DateTime.now().subtract(Duration(days: _maxAgeDays));

      final keysToDelete = <dynamic>[];

      for (final entry in box.toMap().entries) {
        if (entry.value.createdAt.isBefore(cutoffDate)) {
          keysToDelete.add(entry.key);
        }
      }

      // حذف القديمة
      for (final key in keysToDelete) {
        await box.delete(key);
      }

      // إذا لا يزال يتجاوز الحد، حذف الأقدم
      if (box.length > _maxNotifications) {
        final allNotifications = box.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final toRemove = allNotifications.skip(_maxNotifications).toList();
        for (final notification in toRemove) {
          await box.delete(notification.id);
        }
      }

      if (keysToDelete.isNotEmpty) {
        debugPrint('[NotificationLocalDS] Cleaned up ${keysToDelete.length} old notifications');
      }
    } catch (e) {
      debugPrint('[NotificationLocalDS] Cleanup error: $e');
    }
  }
}
