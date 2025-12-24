import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/notification_entity.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
import '../widgets/notification_item.dart';
import '../widgets/notification_empty_widget.dart';
import '../widgets/notification_filter_chips.dart';

/// صفحة الإشعارات
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showUnreadOnly = false;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadNotifications() {
    context.read<NotificationsBloc>().add(LoadNotifications(
          refresh: true,
          isRead: _showUnreadOnly ? false : null,
          type: _selectedType,
        ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<NotificationsBloc>().state;
      if (state is NotificationsLoaded && state.hasMore) {
        context.read<NotificationsBloc>().add(const LoadMoreNotifications());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          // زر تحديد الكل كمقروء
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: 'تحديد الكل كمقروء',
                  onPressed: () {
                    context.read<NotificationsBloc>().add(
                          const MarkAllNotificationsAsRead(),
                        );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationsBloc, NotificationsState>(
        listener: (context, state) {
          if (state is NavigateToDestination) {
            context.push(state.route, extra: state.arguments);
          } else if (state is NewNotificationReceived) {
            // عرض snackbar للإشعار الجديد
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(state.body),
                  ],
                ),
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'عرض',
                  onPressed: () {
                    if (state.data != null) {
                      context
                          .read<NotificationsBloc>()
                          .add(NotificationTapped(state.data!));
                    }
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // فلاتر
              _buildFilters(context),

              // المحتوى
              Expanded(
                child: _buildContent(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          // فلتر غير المقروء
          FilterChip(
            label: const Text('غير المقروءة'),
            selected: _showUnreadOnly,
            onSelected: (selected) {
              setState(() {
                _showUnreadOnly = selected;
              });
              _loadNotifications();
            },
          ),
          const SizedBox(width: 8),

          // فلتر النوع
          Expanded(
            child: NotificationFilterChips(
              selectedType: _selectedType,
              onTypeSelected: (type) {
                setState(() {
                  _selectedType = type;
                });
                _loadNotifications();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, NotificationsState state) {
    if (state is NotificationsLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is NotificationsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state is NotificationsLoaded) {
      if (state.notifications.isEmpty) {
        return const NotificationEmptyWidget();
      }

      return RefreshIndicator(
        onRefresh: () async {
          _loadNotifications();
        },
        child: _buildNotificationsList(context, state),
      );
    }

    if (state is NotificationsLoadingMore) {
      return _buildNotificationsListWithLoading(
        context,
        state.currentNotifications,
      );
    }

    return const NotificationEmptyWidget();
  }

  Widget _buildNotificationsList(
    BuildContext context,
    NotificationsLoaded state,
  ) {
    // تجميع الإشعارات حسب التاريخ
    final grouped = _groupNotificationsByDate(state.notifications);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        return _buildDateSection(context, entry.key, entry.value);
      },
    );
  }

  Widget _buildNotificationsListWithLoading(
    BuildContext context,
    List<NotificationEntity> notifications,
  ) {
    final grouped = _groupNotificationsByDate(notifications);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: grouped.length + 1,
      itemBuilder: (context, index) {
        if (index == grouped.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final entry = grouped.entries.elementAt(index);
        return _buildDateSection(context, entry.key, entry.value);
      },
    );
  }

  Widget _buildDateSection(
    BuildContext context,
    String dateLabel,
    List<NotificationEntity> notifications,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان التاريخ
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            dateLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),

        // الإشعارات
        ...notifications.map((notification) => NotificationItem(
              notification: notification,
              onTap: () {
                // تحديد كمقروء
                if (!notification.isRead) {
                  context.read<NotificationsBloc>().add(
                        MarkNotificationAsRead(notification.id),
                      );
                }

                // التنقل إذا وجد رابط
                if (notification.actionData != null) {
                  context.read<NotificationsBloc>().add(
                        NotificationTapped(notification.actionData!),
                      );
                }
              },
              onDismiss: () {
                context.read<NotificationsBloc>().add(
                      DeleteNotification(notification.id),
                    );
              },
            )),
      ],
    );
  }

  Map<String, List<NotificationEntity>> _groupNotificationsByDate(
    List<NotificationEntity> notifications,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final grouped = <String, List<NotificationEntity>>{};

    for (final notification in notifications) {
      final date = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      String label;
      if (date == today) {
        label = 'اليوم';
      } else if (date == yesterday) {
        label = 'أمس';
      } else if (date.isAfter(today.subtract(const Duration(days: 7)))) {
        label = 'هذا الأسبوع';
      } else {
        label = 'أقدم';
      }

      grouped.putIfAbsent(label, () => []).add(notification);
    }

    return grouped;
  }
}
