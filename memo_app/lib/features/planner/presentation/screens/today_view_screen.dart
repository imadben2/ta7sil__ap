import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/study_session.dart';
import '../bloc/planner_bloc.dart';
import '../bloc/planner_event.dart';
import '../bloc/planner_state.dart';
import '../widgets/timeline_widget.dart';
import '../widgets/empty_schedule_widget.dart';
import '../widgets/shared/planner_design_constants.dart';
import '../../../../core/constants/app_colors.dart';

/// Today View Screen - Timeline view of today's sessions
///
/// Modern design matching session_detail_screen.dart
/// Features:
/// - Modern stat cards with icons
/// - Vertical timeline with time slots
/// - Current time indicator
/// - Session cards with quick actions
class TodayViewScreen extends StatelessWidget {
  const TodayViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlannerDesignConstants.slateBackground,
      body: BlocBuilder<PlannerBloc, PlannerState>(
        builder: (context, state) {
          // Loading state
          if (state is PlannerLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'جاري التحميل...',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            );
          }

          // Error state
          if (state is PlannerError) {
            return _buildErrorView(context, state);
          }

          // No schedule available
          if (state is NoScheduleAvailable) {
            return EmptyScheduleWidget(
              message: state.message,
            );
          }

          // Schedule deleted - show empty
          if (state is ScheduleDeleted) {
            return const EmptyScheduleWidget(
              message: 'تم حذف الجدول بنجاح.\nقم بإنشاء جدول جديد.',
            );
          }

          // Full schedule loaded - filter for today
          if (state is FullScheduleLoaded) {
            final now = DateTime.now();
            final todaySessions = state.sessions.where((session) {
              return session.scheduledDate.year == now.year &&
                  session.scheduledDate.month == now.month &&
                  session.scheduledDate.day == now.day;
            }).toList();

            if (todaySessions.isEmpty) {
              // Check if there are sessions on other days this week
              // Week starts from Saturday (السبت)
              final daysSinceSaturday = (now.weekday % 7 + 1) % 7;
              final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysSinceSaturday));
              final weekEnd = weekStart.add(const Duration(days: 7));
              final weekSessions = state.sessions.where((session) {
                return session.scheduledDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                       session.scheduledDate.isBefore(weekEnd);
              }).toList();

              if (weekSessions.isNotEmpty) {
                return EmptyScheduleWidget(
                  message: 'لا توجد جلسات مجدولة لهذا اليوم.\n\nلديك ${weekSessions.length} جلسة هذا الأسبوع.\nاطلع على عرض الأسبوع للتفاصيل.',
                );
              }
              return const EmptyScheduleWidget(
                message: 'لا توجد جلسات مجدولة لهذا اليوم.\nاستمتع بيوم راحة!',
              );
            }

            return _buildTimelineView(context, todaySessions);
          }

          // Week schedule loaded - filter for today
          if (state is WeekScheduleLoaded) {
            final now = DateTime.now();
            final todaySessions = state.sessions.where((session) {
              return session.scheduledDate.year == now.year &&
                  session.scheduledDate.month == now.month &&
                  session.scheduledDate.day == now.day;
            }).toList();

            if (todaySessions.isEmpty) {
              // Show helpful message with week session count
              if (state.sessions.isNotEmpty) {
                return EmptyScheduleWidget(
                  message: 'لا توجد جلسات مجدولة لهذا اليوم.\n\nلديك ${state.sessions.length} جلسة هذا الأسبوع.\nاطلع على عرض الأسبوع للتفاصيل.',
                );
              }
              return const EmptyScheduleWidget(
                message: 'لا توجد جلسات مجدولة لهذا اليوم.\nاستمتع بيوم راحة!',
              );
            }

            return _buildTimelineView(context, todaySessions);
          }

          // Schedule loaded
          if (state is ScheduleLoaded) {
            if (state.sessions.isEmpty) {
              return _buildEmptyTodayWithWeekInfo(context);
            }

            return _buildTimelineView(context, state.sessions);
          }

          // Default: Show empty state
          return const EmptyScheduleWidget(
            message: 'لا يوجد جدول دراسي.',
          );
        },
      ),
    );
  }

  /// Build timeline view with sessions
  Widget _buildTimelineView(BuildContext context, List<StudySession> sessions) {
    // Sort sessions by time
    final sortedSessions = List<StudySession>.from(sessions)
      ..sort((a, b) {
        final aMinutes =
            a.scheduledStartTime.hour * 60 + a.scheduledStartTime.minute;
        final bMinutes =
            b.scheduledStartTime.hour * 60 + b.scheduledStartTime.minute;
        return aMinutes.compareTo(bMinutes);
      });

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PlannerBloc>().add(const RefreshScheduleEvent());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: const Color(0xFF6366F1),
      child: CustomScrollView(
        slivers: [
          // Header with date and statistics
          SliverToBoxAdapter(child: _buildHeader(context, sortedSessions)),

          // Timeline with sessions
          SliverToBoxAdapter(child: TimelineWidget(sessions: sortedSessions)),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  /// Build header with date and statistics
  Widget _buildHeader(BuildContext context, List<StudySession> sessions) {
    final now = DateTime.now();
    final completedCount = sessions
        .where((s) => s.status == SessionStatus.completed)
        .length;
    final totalCount = sessions.length;
    final completionRate = totalCount > 0
        ? (completedCount / totalCount * 100).round()
        : 0;
    final inProgressCount = sessions
        .where((s) => s.status == SessionStatus.inProgress)
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: PlannerDesignConstants.modernCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: PlannerDesignConstants.iconContainerDecoration(
                        const Color(0xFF6366F1),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'جدول اليوم',
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Cairo',
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(now),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (inProgressCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_circle_filled,
                              size: 14,
                              color: Color(0xFF10B981),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'جارية',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Refresh menu
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Color(0xFF6B7280),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'force_refresh') {
                          _showForceRefreshConfirmation(context);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem<String>(
                          value: 'force_refresh',
                          child: Row(
                            children: [
                              Icon(
                                Icons.cloud_sync_rounded,
                                size: 20,
                                color: Color(0xFF6366F1),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'تحديث من الخادم',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Statistics row
          Row(
            children: [
              Expanded(
                child: _buildModernStatCard(
                  icon: Icons.check_circle_rounded,
                  label: 'مكتملة',
                  value: '$completedCount/$totalCount',
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernStatCard(
                  icon: Icons.trending_up_rounded,
                  label: 'التقدم',
                  value: '$completionRate%',
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernStatCard(
                  icon: Icons.access_time_rounded,
                  label: 'إجمالي',
                  value: '${_calculateTotalHours(sessions)} س',
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build modern statistic card
  Widget _buildModernStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PlannerDesignConstants.modernCardDecoration(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  /// Build error view
  Widget _buildErrorView(BuildContext context, PlannerError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: PlannerDesignConstants.modernCardDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'حدث خطأ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Cairo',
                  color: Color(0xFF6B7280),
                ),
              ),
              if (state.canRetry) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<PlannerBloc>().add(const RefreshScheduleEvent());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'إعادة المحاولة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Format date in Arabic
  String _formatDate(DateTime date) {
    const arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    const arabicDays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    final dayName = arabicDays[date.weekday - 1];
    final day = date.day;
    final month = arabicMonths[date.month - 1];

    return '$dayName، $day $month';
  }

  /// Calculate total study hours
  String _calculateTotalHours(List<StudySession> sessions) {
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, session) => sum + session.duration.inMinutes,
    );
    final hours = (totalMinutes / 60).toStringAsFixed(1);
    return hours;
  }

  /// Build empty today view with week info
  /// Shows informative message when today has no sessions but week may have sessions
  Widget _buildEmptyTodayWithWeekInfo(BuildContext context) {
    // Get the week sessions count from bloc
    final bloc = context.read<PlannerBloc>();

    return FutureBuilder<int>(
      future: _getWeekSessionsCount(bloc),
      builder: (context, snapshot) {
        final weekCount = snapshot.data ?? 0;

        if (weekCount > 0) {
          return EmptyScheduleWidget(
            message: 'لا توجد جلسات مجدولة لهذا اليوم.\n\nلديك $weekCount جلسة هذا الأسبوع.\nاطلع على عرض الأسبوع للتفاصيل.',
          );
        }

        return const EmptyScheduleWidget(
          message: 'لا توجد جلسات مجدولة لهذا اليوم.\nاستمتع بيوم راحة!',
        );
      },
    );
  }

  /// Show force refresh confirmation dialog
  void _showForceRefreshConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.cloud_sync_rounded,
              color: Color(0xFF6366F1),
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              'تحديث من الخادم',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'سيتم مسح الجدول المحلي وتحميل أحدث بيانات من الخادم.\n\nهذا مفيد إذا كان الجدول المحلي قديماً أو غير متزامن مع الخادم.',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<PlannerBloc>().add(const ForceRefreshFromServerEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'جاري تحديث الجدول من الخادم...',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  backgroundColor: Color(0xFF6366F1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'تحديث',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get week sessions count from local data source
  Future<int> _getWeekSessionsCount(PlannerBloc bloc) async {
    try {
      final allSessions = await bloc.localDataSource.getCachedSessions();
      final now = DateTime.now();
      // Week starts from Saturday (السبت)
      final daysSinceSaturday = (now.weekday % 7 + 1) % 7;
      final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysSinceSaturday));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final weekSessions = allSessions.where((session) {
        return session.scheduledDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
               session.scheduledDate.isBefore(weekEnd);
      }).toList();

      return weekSessions.length;
    } catch (e) {
      return 0;
    }
  }
}
