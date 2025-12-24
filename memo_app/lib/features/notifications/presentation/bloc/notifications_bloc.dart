import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/notification_service.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

/// BLoC الإشعارات
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationRepository _repository;
  final NotificationService _notificationService;

  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

  int _currentPage = 1;
  bool? _filterIsRead;
  String? _filterType;

  NotificationsBloc({
    required NotificationRepository repository,
    required NotificationService notificationService,
  })  : _repository = repository,
        _notificationService = notificationService,
        super(const NotificationsInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadMoreNotifications>(_onLoadMoreNotifications);
    on<RefreshUnreadCount>(_onRefreshUnreadCount);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<NotificationReceived>(_onNotificationReceived);
    on<NotificationTapped>(_onNotificationTapped);

    // الاستماع لإشعارات FCM
    _setupNotificationListener();
  }

  void _setupNotificationListener() {
    _notificationSubscription =
        _notificationService.onNotification.listen((event) {
      final type = event['type'];

      if (type == 'received') {
        add(NotificationReceived(
          title: event['title'] ?? '',
          body: event['body'] ?? '',
          data: event['data'],
        ));

        // تحديث عدد غير المقروءة
        add(const RefreshUnreadCount());
      } else if (type == 'tap' || type == 'open') {
        if (event['data'] != null) {
          add(NotificationTapped(event['data']));
        }
      }
    });
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      if (event.refresh) {
        _currentPage = 1;
      }
      _filterIsRead = event.isRead;
      _filterType = event.type;

      emit(const NotificationsLoading());

      final result = await _repository.getNotifications(
        page: 1,
        perPage: 20,
        isRead: _filterIsRead,
        type: _filterType,
      );

      result.fold(
        (failure) async {
          final cached = await _repository.getCachedNotifications();
          emit(NotificationsError(
            message: failure.message,
            cachedNotifications: cached,
          ));
        },
        (notificationsList) {
          _currentPage = notificationsList.currentPage;
          emit(NotificationsLoaded(
            notifications: notificationsList.notifications,
            unreadCount: notificationsList.unreadCount,
            total: notificationsList.total,
            currentPage: notificationsList.currentPage,
            lastPage: notificationsList.lastPage,
            hasMore: notificationsList.hasMore,
          ));
        },
      );
    } catch (e) {
      debugPrint('[NotificationsBloc] Load error: $e');
      emit(NotificationsError(message: 'خطأ في تحميل الإشعارات'));
    }
  }

  Future<void> _onLoadMoreNotifications(
    LoadMoreNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationsLoaded || !currentState.hasMore) {
      return;
    }

    try {
      emit(NotificationsLoadingMore(
        currentNotifications: currentState.notifications,
        unreadCount: currentState.unreadCount,
      ));

      final nextPage = _currentPage + 1;
      final result = await _repository.getNotifications(
        page: nextPage,
        perPage: 20,
        isRead: _filterIsRead,
        type: _filterType,
      );

      result.fold(
        (failure) {
          // إرجاع الحالة السابقة
          emit(currentState);
        },
        (notificationsList) {
          _currentPage = notificationsList.currentPage;

          final allNotifications = [
            ...currentState.notifications,
            ...notificationsList.notifications,
          ];

          emit(NotificationsLoaded(
            notifications: allNotifications,
            unreadCount: notificationsList.unreadCount,
            total: notificationsList.total,
            currentPage: notificationsList.currentPage,
            lastPage: notificationsList.lastPage,
            hasMore: notificationsList.hasMore,
          ));
        },
      );
    } catch (e) {
      debugPrint('[NotificationsBloc] Load more error: $e');
      emit(currentState);
    }
  }

  Future<void> _onRefreshUnreadCount(
    RefreshUnreadCount event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final result = await _repository.getUnreadCount();
      result.fold(
        (_) {},
        (count) {
          emit(currentState.copyWith(unreadCount: count));
        },
      );
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      // تحديث محلي فوري
      final updatedNotifications = currentState.notifications.map((n) {
        if (n.id == event.notificationId) {
          return n.markAsRead();
        }
        return n;
      }).toList();

      final newUnreadCount =
          updatedNotifications.where((n) => !n.isRead).length;

      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ));

      // ثم إرسال للخادم
      await _repository.markAsRead(event.notificationId);
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      // تحديث محلي فوري
      final updatedNotifications =
          currentState.notifications.map((n) => n.markAsRead()).toList();

      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      ));

      // ثم إرسال للخادم
      await _repository.markAllAsRead();
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      // حذف محلي فوري
      final updatedNotifications = currentState.notifications
          .where((n) => n.id != event.notificationId)
          .toList();

      final newUnreadCount =
          updatedNotifications.where((n) => !n.isRead).length;

      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
        total: currentState.total - 1,
      ));

      // ثم إرسال للخادم
      await _repository.deleteNotification(event.notificationId);
    }
  }

  void _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationsState> emit,
  ) {
    // إظهار إشعار في التطبيق
    emit(NewNotificationReceived(
      title: event.title,
      body: event.body,
      data: event.data,
    ));

    // إعادة تحميل القائمة
    add(const LoadNotifications(refresh: true));
  }

  void _onNotificationTapped(
    NotificationTapped event,
    Emitter<NotificationsState> emit,
  ) {
    final data = event.data;
    final deepLink = data['deep_link'] as String?;
    final actionType = data['action_type'] as String?;

    String? route;
    Map<String, dynamic>? arguments;

    if (deepLink != null) {
      // تحليل الرابط العميق
      final uri = Uri.tryParse(deepLink);
      if (uri != null) {
        route = uri.path;
        arguments = uri.queryParameters.isNotEmpty
            ? Map<String, dynamic>.from(uri.queryParameters)
            : null;
      }
    } else if (actionType != null) {
      // تحويل نوع الإجراء إلى مسار
      route = _actionTypeToRoute(actionType, data);
      arguments = data['action_data'] as Map<String, dynamic>?;
    }

    if (route != null) {
      emit(NavigateToDestination(route: route, arguments: arguments));
    }
  }

  String? _actionTypeToRoute(String actionType, Map<String, dynamic> data) {
    switch (actionType) {
      case 'open_session':
        final sessionId = data['session_id'];
        return sessionId != null ? '/planner/session/$sessionId' : '/planner';
      case 'open_exam':
        final examId = data['exam_id'];
        return examId != null ? '/planner/exam/$examId' : '/planner';
      case 'open_quiz':
        final quizId = data['quiz_id'];
        return quizId != null ? '/quiz/$quizId' : '/quiz';
      case 'open_course':
        final courseId = data['course_id'];
        return courseId != null ? '/courses/$courseId' : '/courses';
      case 'open_achievements':
        return '/profile/achievements';
      case 'open_stats':
        return '/profile/statistics';
      default:
        return null;
    }
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}
