import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/planner_bloc.dart';
import '../bloc/planner_event.dart';
import '../bloc/planner_state.dart';
import '../widgets/empty_schedule_widget.dart';
import '../widgets/session_card.dart';
import '../widgets/shared/planner_design_constants.dart';
import '../../domain/entities/study_session.dart';
import '../../../../core/constants/app_colors.dart';

/// Full Schedule Screen - List view of all sessions organized by week
///
/// Modern design with collapsible weeks to handle 1000+ sessions efficiently
/// Features:
/// - Weekly grouping with expandable sections
/// - Session count per week/day
/// - Lazy loading for performance
///
/// Note: Data loading is handled by PlannerMainScreen when tab changes
class FullScheduleScreen extends StatefulWidget {
  const FullScheduleScreen({super.key});

  @override
  State<FullScheduleScreen> createState() => _FullScheduleScreenState();
}

class _FullScheduleScreenState extends State<FullScheduleScreen> {
  // Track which weeks are expanded
  final Set<String> _expandedWeeks = {};
  // Track which days are expanded within weeks
  final Set<String> _expandedDays = {};

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
                      color: AppColors.primary.withValues(alpha: 0.1),
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

          // Full schedule loaded - show organized by weeks
          if (state is FullScheduleLoaded) {
            return _buildWeeklyScheduleView(context, state.sessions);
          }

          // Schedule loaded (today's sessions) - show loading while full schedule fetches
          if (state is ScheduleLoaded) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Week schedule loaded - show loading while full schedule fetches
          if (state is WeekScheduleLoaded) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Default: Show coming soon message
          return _buildComingSoonView(context);
        },
      ),
    );
  }

  /// Group sessions by week, then by day
  Map<String, Map<String, List<StudySession>>> _groupSessionsByWeekAndDay(
    List<StudySession> sessions,
  ) {
    final grouped = <String, Map<String, List<StudySession>>>{};

    for (final session in sessions) {
      // Get week key (year-week number)
      final weekNumber = _getWeekNumber(session.scheduledDate);
      final weekKey = '${session.scheduledDate.year}-W$weekNumber';

      // Get day key
      final dayKey = DateFormat('yyyy-MM-dd').format(session.scheduledDate);

      grouped.putIfAbsent(weekKey, () => {});
      grouped[weekKey]!.putIfAbsent(dayKey, () => []);
      grouped[weekKey]![dayKey]!.add(session);
    }

    // Sort sessions by start time within each day
    for (final weekData in grouped.values) {
      for (final daySessions in weekData.values) {
        daySessions.sort((a, b) {
          final aMinutes = a.scheduledStartTime.hour * 60 + a.scheduledStartTime.minute;
          final bMinutes = b.scheduledStartTime.hour * 60 + b.scheduledStartTime.minute;
          return aMinutes.compareTo(bMinutes);
        });
      }
    }

    return grouped;
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceStart = date.difference(firstDayOfYear).inDays;
    return ((daysSinceStart + firstDayOfYear.weekday - 1) / 7).ceil() + 1;
  }

  /// Build weekly schedule view with collapsible sections
  Widget _buildWeeklyScheduleView(
    BuildContext context,
    List<StudySession> sessions,
  ) {
    final groupedByWeek = _groupSessionsByWeekAndDay(sessions);

    // Sort weeks
    final sortedWeeks = groupedByWeek.keys.toList()..sort();

    if (sortedWeeks.isEmpty) {
      return const EmptyScheduleWidget(
        message: 'لا توجد جلسات مجدولة',
      );
    }

    // Calculate total stats
    final totalSessions = sessions.length;
    final totalDays = sessions.map((s) =>
      DateFormat('yyyy-MM-dd').format(s.scheduledDate)
    ).toSet().length;
    final totalHours = (sessions.fold<int>(0, (sum, s) =>
      sum + s.duration.inMinutes) / 60).toStringAsFixed(1);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PlannerBloc>().add(const LoadFullScheduleEvent());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: const Color(0xFF6366F1),
      child: CustomScrollView(
        slivers: [
          // Stats header
          SliverToBoxAdapter(
            child: _buildStatsHeader(totalSessions, totalDays, totalHours),
          ),

          // Weeks list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final weekKey = sortedWeeks[index];
                final weekData = groupedByWeek[weekKey]!;
                return _buildWeekSection(weekKey, weekData);
              },
              childCount: sortedWeeks.length,
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  /// Build stats header
  Widget _buildStatsHeader(int totalSessions, int totalDays, String totalHours) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.event_note_rounded,
            value: '$totalSessions',
            label: 'جلسة',
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          _buildStatItem(
            icon: Icons.calendar_today_rounded,
            value: '$totalDays',
            label: 'يوم',
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          _buildStatItem(
            icon: Icons.timer_rounded,
            value: totalHours,
            label: 'ساعة',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  /// Build week section
  Widget _buildWeekSection(
    String weekKey,
    Map<String, List<StudySession>> weekData,
  ) {
    final isExpanded = _expandedWeeks.contains(weekKey);
    final sortedDays = weekData.keys.toList()..sort();

    // Calculate week stats
    final weekSessions = weekData.values.expand((e) => e).length;
    final weekHours = (weekData.values.expand((e) => e).fold<int>(0, (sum, s) =>
      sum + s.duration.inMinutes) / 60).toStringAsFixed(1);

    // Get week date range
    final firstDay = DateTime.parse(sortedDays.first);
    final lastDay = DateTime.parse(sortedDays.last);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Week header (always visible)
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedWeeks.remove(weekKey);
                } else {
                  _expandedWeeks.add(weekKey);
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Week icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.date_range_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Week info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatWeekRange(firstDay, lastDay),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.emerald500.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$weekSessions جلسة',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Cairo',
                                  color: AppColors.emerald500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$weekHours ساعة',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Cairo',
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Expand/collapse arrow
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Days (when expanded)
          if (isExpanded) ...[
            const Divider(height: 1),
            ...sortedDays.map((dayKey) => _buildDaySection(
              weekKey,
              dayKey,
              weekData[dayKey]!,
            )),
          ],
        ],
      ),
    );
  }

  /// Build day section within a week
  Widget _buildDaySection(
    String weekKey,
    String dayKey,
    List<StudySession> sessions,
  ) {
    final fullDayKey = '$weekKey-$dayKey';
    final isDayExpanded = _expandedDays.contains(fullDayKey);
    final date = DateTime.parse(dayKey);
    final sessionCount = sessions.length;
    final dayHours = (sessions.fold<int>(0, (sum, s) =>
      sum + s.duration.inMinutes) / 60).toStringAsFixed(1);

    return Column(
      children: [
        // Day header
        InkWell(
          onTap: () {
            setState(() {
              if (isDayExpanded) {
                _expandedDays.remove(fullDayKey);
              } else {
                _expandedDays.add(fullDayKey);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDayExpanded
                ? const Color(0xFFF8FAFC)
                : Colors.transparent,
            child: Row(
              children: [
                const SizedBox(width: 48), // Indent for nested look

                // Day badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _isToday(date)
                        ? AppColors.primary
                        : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isToday(date)
                              ? Colors.white
                              : const Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        _getArabicDayAbbr(date.weekday),
                        style: TextStyle(
                          fontSize: 10,
                          color: _isToday(date)
                              ? Colors.white.withValues(alpha: 0.8)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Day info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(date),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo',
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        '$sessionCount جلسة • $dayHours س',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Cairo',
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),

                // Expand arrow
                AnimatedRotation(
                  turns: isDayExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Sessions list (when day is expanded)
        if (isDayExpanded)
          Container(
            color: AppColors.slateBackground,
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Column(
              children: sessions.map((session) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SessionCard(
                  session: session,
                  showActions: false,
                  compact: true,
                ),
              )).toList(),
            ),
          ),
      ],
    );
  }

  String _formatWeekRange(DateTime start, DateTime end) {
    const arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'إبريل',
      'مايو', 'يونيو', 'يوليو', 'أغسطس',
      'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];

    if (start.month == end.month) {
      return '${start.day} - ${end.day} ${arabicMonths[start.month - 1]}';
    } else {
      return '${start.day} ${arabicMonths[start.month - 1]} - ${end.day} ${arabicMonths[end.month - 1]}';
    }
  }

  String _formatDate(DateTime date) {
    const arabicDays = [
      'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء',
      'الخميس', 'الجمعة', 'السبت',
    ];

    if (_isToday(date)) {
      return 'اليوم';
    }

    // Always show the actual day name (الأربعاء، الخميس، etc.)
    return arabicDays[date.weekday % 7];
  }

  String _getArabicDayAbbr(int weekday) {
    const abbrs = ['أح', 'إث', 'ثل', 'أر', 'خم', 'جم', 'سب'];
    return abbrs[weekday % 7];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Build coming soon view
  Widget _buildComingSoonView(BuildContext context) {
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.list_alt_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'الجدول الكامل',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'سيتم عرض جميع الجلسات المجدولة للشهر القادم',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Cairo',
                  color: Color(0xFF6B7280),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () {
                  DefaultTabController.of(context).animateTo(0);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.today_rounded, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'العودة إلى جدول اليوم',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                  color: AppColors.red500.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.red500,
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
            ],
          ),
        ),
      ),
    );
  }
}
