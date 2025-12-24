import 'package:equatable/equatable.dart';

/// أحداث BLoC الإشعارات
abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

/// تحميل الإشعارات
class LoadNotifications extends NotificationsEvent {
  final bool refresh;
  final bool? isRead;
  final String? type;

  const LoadNotifications({
    this.refresh = false,
    this.isRead,
    this.type,
  });

  @override
  List<Object?> get props => [refresh, isRead, type];
}

/// تحميل المزيد من الإشعارات
class LoadMoreNotifications extends NotificationsEvent {
  const LoadMoreNotifications();
}

/// تحديث عدد غير المقروءة
class RefreshUnreadCount extends NotificationsEvent {
  const RefreshUnreadCount();
}

/// تحديد إشعار كمقروء
class MarkNotificationAsRead extends NotificationsEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// تحديد جميع الإشعارات كمقروءة
class MarkAllNotificationsAsRead extends NotificationsEvent {
  const MarkAllNotificationsAsRead();
}

/// حذف إشعار
class DeleteNotification extends NotificationsEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// استقبال إشعار جديد (من FCM)
class NotificationReceived extends NotificationsEvent {
  final String title;
  final String body;
  final Map<String, dynamic>? data;

  const NotificationReceived({
    required this.title,
    required this.body,
    this.data,
  });

  @override
  List<Object?> get props => [title, body, data];
}

/// نقرة على إشعار
class NotificationTapped extends NotificationsEvent {
  final Map<String, dynamic> data;

  const NotificationTapped(this.data);

  @override
  List<Object?> get props => [data];
}
