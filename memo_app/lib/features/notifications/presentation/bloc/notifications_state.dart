import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_entity.dart';

/// حالات BLoC الإشعارات
abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

/// جاري التحميل
class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

/// تحميل المزيد
class NotificationsLoadingMore extends NotificationsState {
  final List<NotificationEntity> currentNotifications;
  final int unreadCount;

  const NotificationsLoadingMore({
    required this.currentNotifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [currentNotifications, unreadCount];
}

/// تم التحميل بنجاح
class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final int total;
  final int currentPage;
  final int lastPage;
  final bool hasMore;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
    required this.total,
    this.currentPage = 1,
    this.lastPage = 1,
    this.hasMore = false,
  });

  NotificationsLoaded copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    int? total,
    int? currentPage,
    int? lastPage,
    bool? hasMore,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        unreadCount,
        total,
        currentPage,
        lastPage,
        hasMore,
      ];
}

/// خطأ
class NotificationsError extends NotificationsState {
  final String message;
  final List<NotificationEntity>? cachedNotifications;

  const NotificationsError({
    required this.message,
    this.cachedNotifications,
  });

  @override
  List<Object?> get props => [message, cachedNotifications];
}

/// استقبال إشعار جديد
class NewNotificationReceived extends NotificationsState {
  final String title;
  final String body;
  final Map<String, dynamic>? data;

  const NewNotificationReceived({
    required this.title,
    required this.body,
    this.data,
  });

  @override
  List<Object?> get props => [title, body, data];
}

/// التنقل إلى وجهة
class NavigateToDestination extends NotificationsState {
  final String route;
  final Map<String, dynamic>? arguments;

  const NavigateToDestination({
    required this.route,
    this.arguments,
  });

  @override
  List<Object?> get props => [route, arguments];
}
