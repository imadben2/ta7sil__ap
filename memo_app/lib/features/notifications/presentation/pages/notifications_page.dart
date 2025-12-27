import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/notification_entity.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
import '../widgets/modern_notification_card.dart';

/// صفحة الإشعارات بتصميم حديث
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // Tab definitions with gradients
  static const List<_TabData> _tabs = [
    _TabData(
      label: 'الكل',
      icon: Icons.notifications_rounded,
      type: null,
      isUnreadFilter: false,
      gradientColors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    ),
    _TabData(
      label: 'غير مقروءة',
      icon: Icons.mark_email_unread_rounded,
      type: null,
      isUnreadFilter: true,
      gradientColors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    ),
    _TabData(
      label: 'النظام',
      icon: Icons.settings_rounded,
      type: 'system',
      isUnreadFilter: false,
      gradientColors: [Color(0xFF11998E), Color(0xFF38EF7D)],
    ),
    _TabData(
      label: 'الدراسة',
      icon: Icons.school_rounded,
      type: 'study_reminder',
      isUnreadFilter: false,
      gradientColors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    ),
  ];

  int _selectedTabIndex = 0;
  bool _showUnreadOnly = false;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    setState(() {
      _selectedTabIndex = _tabController.index;
      final tab = _tabs[_selectedTabIndex];
      _showUnreadOnly = tab.isUnreadFilter;
      _selectedType = tab.type;
    });
    _loadNotifications();
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocConsumer<NotificationsBloc, NotificationsState>(
        listener: _handleBlocListener,
        builder: (context, state) {
          return NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildModernAppBar(context, state),
              _buildTabBarSliver(context),
            ],
            body: _buildContent(context, state),
          );
        },
      ),
    );
  }

  void _handleBlocListener(BuildContext context, NotificationsState state) {
    if (state is NavigateToDestination) {
      context.push(state.route, extra: state.arguments);
    } else if (state is NewNotificationReceived) {
      _showNewNotificationSnackbar(context, state);
    }
  }

  void _showNewNotificationSnackbar(
      BuildContext context, NewNotificationReceived state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    state.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF667EEA),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        action: SnackBarAction(
          label: 'عرض',
          textColor: Colors.white,
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

  Widget _buildModernAppBar(BuildContext context, NotificationsState state) {
    int unreadCount = 0;
    if (state is NotificationsLoaded) {
      unreadCount = state.unreadCount;
    }

    final currentGradient = _tabs[_selectedTabIndex].gradientColors;

    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: currentGradient[0],
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: currentGradient,
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: _CirclePatternPainter(),
                ),
              ),
              // Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'الإشعارات',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$unreadCount إشعار جديد',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            else
                              const Text(
                                'لا توجد إشعارات جديدة',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Notification icon with badge
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.notifications_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                top: -8,
                                right: -8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 22,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    unreadCount > 99 ? '99+' : '$unreadCount',
                                    style: TextStyle(
                                      color: currentGradient[0],
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
      actions: [
        if (state is NotificationsLoaded && state.unreadCount > 0)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                context
                    .read<NotificationsBloc>()
                    .add(const MarkAllNotificationsAsRead());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.done_all_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'قراءة الكل',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTabBarSliver(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _ModernTabBarDelegate(
        tabController: _tabController,
        tabs: _tabs,
        selectedIndex: _selectedTabIndex,
      ),
    );
  }

  Widget _buildContent(BuildContext context, NotificationsState state) {
    if (state is NotificationsLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _tabs[_selectedTabIndex].gradientColors.map(
                    (c) => c.withOpacity(0.1),
                  ).toList(),
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: CircularProgressIndicator(
                color: _tabs[_selectedTabIndex].gradientColors[0],
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'جاري تحميل الإشعارات...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (state is NotificationsError) {
      return _buildErrorState(context, state);
    }

    if (state is NotificationsLoaded) {
      if (state.notifications.isEmpty) {
        return _buildEmptyState(context);
      }

      return _buildNotificationsList(context, state);
    }

    if (state is NotificationsLoadingMore) {
      return _buildNotificationsListWithLoading(
        context,
        state.currentNotifications,
      );
    }

    return _buildEmptyState(context);
  }

  Widget _buildErrorState(BuildContext context, NotificationsError state) {
    final gradient = _tabs[_selectedTabIndex].gradientColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.shade100,
                    Colors.red.shade50,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 56,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _loadNotifications,
                  borderRadius: BorderRadius.circular(14),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'إعادة المحاولة',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final tab = _tabs[_selectedTabIndex];
    final gradient = tab.gradientColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.9, end: 1.0),
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient.map((c) => c.withOpacity(0.15)).toList(),
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  tab.isUnreadFilter
                      ? Icons.mark_email_read_rounded
                      : Icons.notifications_off_outlined,
                  size: 60,
                  color: gradient[0],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              tab.isUnreadFilter
                  ? 'لا توجد إشعارات غير مقروءة'
                  : 'لا توجد إشعارات',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tab.isUnreadFilter
                  ? 'أحسنت! لقد قرأت جميع إشعاراتك 🎉'
                  : 'ستظهر هنا الإشعارات الجديدة',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(
      BuildContext context, NotificationsLoaded state) {
    final grouped = _groupNotificationsByDate(state.notifications);

    return RefreshIndicator(
      onRefresh: () async => _loadNotifications(),
      color: _tabs[_selectedTabIndex].gradientColors[0],
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: grouped.length,
        itemBuilder: (context, index) {
          final entry = grouped.entries.elementAt(index);
          return _buildDateSection(context, entry.key, entry.value);
        },
      ),
    );
  }

  Widget _buildNotificationsListWithLoading(
    BuildContext context,
    List<NotificationEntity> notifications,
  ) {
    final grouped = _groupNotificationsByDate(notifications);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: grouped.length + 1,
      itemBuilder: (context, index) {
        if (index == grouped.length) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _tabs[_selectedTabIndex].gradientColors.map(
                      (c) => c.withOpacity(0.1),
                    ).toList(),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _tabs[_selectedTabIndex].gradientColors[0],
                  ),
                ),
              ),
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
    final gradient = _tabs[_selectedTabIndex].gradientColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient.map((c) => c.withOpacity(0.15)).toList(),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: gradient[0].withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  dateLabel,
                  style: TextStyle(
                    color: gradient[0],
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradient[0].withOpacity(0.3),
                        gradient[1].withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ...notifications.asMap().entries.map((entry) {
          final index = entry.key;
          final notification = entry.value;
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 200 + (index * 40)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 15 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ModernNotificationCard(
                notification: notification,
                accentGradient: gradient,
                onTap: () {
                  if (!notification.isRead) {
                    context.read<NotificationsBloc>().add(
                          MarkNotificationAsRead(notification.id),
                        );
                  }
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
              ),
            ),
          );
        }),
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
        label = 'سابقاً';
      }

      grouped.putIfAbsent(label, () => []).add(notification);
    }

    return grouped;
  }
}

// Tab data class with gradient
class _TabData {
  final String label;
  final IconData icon;
  final String? type;
  final bool isUnreadFilter;
  final List<Color> gradientColors;

  const _TabData({
    required this.label,
    required this.icon,
    this.type,
    required this.isUnreadFilter,
    required this.gradientColors,
  });
}

// Modern tab bar delegate
class _ModernTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final List<_TabData> tabs;
  final int selectedIndex;

  _ModernTabBarDelegate({
    required this.tabController,
    required this.tabs,
    required this.selectedIndex,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          Container(
            height: 64,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isSelected = tabController.index == index;

                return GestureDetector(
                  onTap: () => tabController.animateTo(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(colors: tab.gradientColors)
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? null
                          : Border.all(color: Colors.grey.shade200),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: tab.gradientColors[0].withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          size: 18,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tab.label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: 1,
            color: Colors.grey.shade100,
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 73;

  @override
  double get minExtent => 73;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

// Circle pattern painter for background
class _CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.2),
      80,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.8),
      60,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.9),
      40,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
