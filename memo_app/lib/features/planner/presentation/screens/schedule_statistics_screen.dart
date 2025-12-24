import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/study_session.dart';
import '../bloc/planner_bloc.dart';
import '../bloc/planner_event.dart';
import '../bloc/planner_state.dart';
import '../widgets/shared/planner_design_constants.dart';
import '../../../../core/constants/app_colors.dart';

/// Schedule Statistics Screen
/// Shows detailed statistics about the current schedule:
/// - Sessions per subject
/// - Hours per subject
/// - Overall statistics
class ScheduleStatisticsScreen extends StatefulWidget {
  const ScheduleStatisticsScreen({super.key});

  @override
  State<ScheduleStatisticsScreen> createState() => _ScheduleStatisticsScreenState();
}

class _ScheduleStatisticsScreenState extends State<ScheduleStatisticsScreen> {
  bool _hasTriedLoading = false;

  @override
  void initState() {
    super.initState();
    // Only load if we don't already have sessions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasTriedLoading) {
        _hasTriedLoading = true;
        final currentState = context.read<PlannerBloc>().state;

        // Check if we already have sessions in the current state
        final hasExistingSessions = _getSessionsFromState(currentState).isNotEmpty;

        // Only load if we don't have sessions yet
        if (!hasExistingSessions) {
          context.read<PlannerBloc>().add(const LoadFullScheduleEvent());
        }
      }
    });
  }

  /// Extract sessions from any schedule-related state
  List<StudySession> _getSessionsFromState(PlannerState state) {
    if (state is ScheduleLoaded) {
      return state.sessions;
    } else if (state is WeekScheduleLoaded) {
      return state.sessions;
    } else if (state is FullScheduleLoaded) {
      return state.sessions;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlannerDesignConstants.slateBackground,
      appBar: _buildAppBar(context),
      body: BlocBuilder<PlannerBloc, PlannerState>(
        builder: (context, state) {
          // Show loading while fetching schedule
          if (state is PlannerLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    state.message ?? 'جاري التحميل...',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: AppColors.slate600,
                    ),
                  ),
                ],
              ),
            );
          }

          // Get sessions from state
          List<StudySession> sessions = _getSessionsFromState(state);

          // If we have no sessions and state indicates no schedule, show empty state
          if (sessions.isEmpty) {
            return _buildEmptyState();
          }

          return _buildStatisticsContent(context, sessions);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'إحصائيات الجدول',
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bar_chart_rounded,
              size: 64,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا يوجد جدول حالياً',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.slate600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'قم بإنشاء جدول جديد لعرض الإحصائيات',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.slate500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsContent(BuildContext context, List<StudySession> sessions) {
    // Filter out break and prayer sessions
    final studySessions = sessions.where((s) => !s.isBreak && !s.isPrayerTime).toList();

    // Calculate statistics
    final stats = _calculateStatistics(studySessions);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Overview cards
        _buildOverviewSection(stats),
        const SizedBox(height: 24),

        // Sessions per subject
        _buildSubjectSessionsCard(stats.sessionsBySubject),
        const SizedBox(height: 16),

        // Hours per subject
        _buildSubjectHoursCard(stats.hoursBySubject),
        const SizedBox(height: 16),

        // Session types breakdown
        _buildSessionTypesCard(stats.sessionsByType),
        const SizedBox(height: 16),

        // Status breakdown
        _buildStatusBreakdownCard(stats.sessionsByStatus),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildOverviewSection(_ScheduleStatistics stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نظرة عامة',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_today_rounded,
                label: 'إجمالي الجلسات',
                value: '${stats.totalSessions}',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.access_time_rounded,
                label: 'إجمالي الساعات',
                value: _formatHours(stats.totalHours),
                color: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.book_rounded,
                label: 'عدد المواد',
                value: '${stats.subjectCount}',
                color: const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up_rounded,
                label: 'متوسط الجلسة',
                value: '${stats.averageSessionMinutes} د',
                color: const Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
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
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: AppColors.slate500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSessionsCard(Map<String, int> sessionsBySubject) {
    final sortedSubjects = sessionsBySubject.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _buildSectionCard(
      title: 'الجلسات حسب المادة',
      icon: Icons.school_rounded,
      iconColor: const Color(0xFF8B5CF6),
      child: Column(
        children: sortedSubjects.map((entry) {
          final color = PlannerDesignConstants.getSubjectColor(entry.key);
          final maxSessions = sortedSubjects.first.value;
          final progress = entry.value / maxSessions;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildProgressRow(
              label: entry.key,
              value: '${entry.value} جلسة',
              progress: progress,
              color: color,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubjectHoursCard(Map<String, double> hoursBySubject) {
    final sortedSubjects = hoursBySubject.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _buildSectionCard(
      title: 'الساعات حسب المادة',
      icon: Icons.timer_rounded,
      iconColor: const Color(0xFF10B981),
      child: Column(
        children: sortedSubjects.map((entry) {
          final color = PlannerDesignConstants.getSubjectColor(entry.key);
          final maxHours = sortedSubjects.first.value;
          final progress = maxHours > 0 ? entry.value / maxHours : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildProgressRow(
              label: entry.key,
              value: _formatHours(entry.value),
              progress: progress,
              color: color,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSessionTypesCard(Map<String, int> sessionsByType) {
    final sortedTypes = sessionsByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final typeColors = {
      'مراجعة': const Color(0xFF3B82F6),
      'تمارين': const Color(0xFF10B981),
      'اختبار': const Color(0xFFF59E0B),
      'درس': const Color(0xFF8B5CF6),
      'تثبيت': const Color(0xFF6366F1),
      'لغة': const Color(0xFF06B6D4),
      'اختبار شامل': const Color(0xFFEC4899),
    };

    return _buildSectionCard(
      title: 'أنواع الجلسات',
      icon: Icons.category_rounded,
      iconColor: const Color(0xFF3B82F6),
      child: Column(
        children: sortedTypes.map((entry) {
          final color = typeColors[entry.key] ?? AppColors.slate500;
          final total = sessionsByType.values.fold(0, (a, b) => a + b);
          final percentage = total > 0 ? (entry.value / total * 100).toStringAsFixed(0) : '0';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate600,
                    ),
                  ),
                ),
                Text(
                  '${entry.value} ($percentage%)',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBreakdownCard(Map<SessionStatus, int> sessionsByStatus) {
    final total = sessionsByStatus.values.fold(0, (a, b) => a + b);

    return _buildSectionCard(
      title: 'حالة الجلسات',
      icon: Icons.pie_chart_rounded,
      iconColor: const Color(0xFFF59E0B),
      child: Column(
        children: sessionsByStatus.entries.map((entry) {
          final color = PlannerDesignConstants.getStatusColor(entry.key);
          final label = PlannerDesignConstants.getStatusLabel(entry.key);
          final percentage = total > 0 ? (entry.value / total * 100).toStringAsFixed(0) : '0';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    PlannerDesignConstants.getStatusIcon(entry.key),
                    size: 16,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate600,
                    ),
                  ),
                ),
                Text(
                  '${entry.value} ($percentage%)',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: PlannerDesignConstants.modernCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildProgressRow({
    required String label,
    required String value,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.slate600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  String _formatHours(double hours) {
    if (hours < 1) {
      return '${(hours * 60).round()} د';
    }
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    if (m == 0) {
      return '$h س';
    }
    return '$h س $m د';
  }

  _ScheduleStatistics _calculateStatistics(List<StudySession> sessions) {
    final sessionsBySubject = <String, int>{};
    final hoursBySubject = <String, double>{};
    final sessionsByType = <String, int>{};
    final sessionsByStatus = <SessionStatus, int>{};

    double totalHours = 0;

    for (final session in sessions) {
      // Sessions by subject
      sessionsBySubject[session.subjectName] =
          (sessionsBySubject[session.subjectName] ?? 0) + 1;

      // Hours by subject
      final hours = session.duration.inMinutes / 60.0;
      hoursBySubject[session.subjectName] =
          (hoursBySubject[session.subjectName] ?? 0) + hours;
      totalHours += hours;

      // Sessions by type
      String typeName;
      if (session.rawSessionType != null) {
        typeName = _getSessionTypeName(session.rawSessionType!);
      } else {
        typeName = _getSessionTypeNameFromEnum(session.sessionType);
      }
      sessionsByType[typeName] = (sessionsByType[typeName] ?? 0) + 1;

      // Sessions by status
      sessionsByStatus[session.status] =
          (sessionsByStatus[session.status] ?? 0) + 1;
    }

    return _ScheduleStatistics(
      totalSessions: sessions.length,
      totalHours: totalHours,
      subjectCount: sessionsBySubject.length,
      averageSessionMinutes: sessions.isNotEmpty
          ? (sessions.fold<int>(0, (sum, s) => sum + s.duration.inMinutes) / sessions.length).round()
          : 0,
      sessionsBySubject: sessionsBySubject,
      hoursBySubject: hoursBySubject,
      sessionsByType: sessionsByType,
      sessionsByStatus: sessionsByStatus,
    );
  }

  String _getSessionTypeName(String rawType) {
    switch (rawType) {
      case 'lesson_review':
        return 'درس';
      case 'exercises':
        return 'تمارين';
      case 'topic_test':
        return 'اختبار';
      case 'unit_test':
        return 'اختبار الوحدة';
      case 'spaced_review':
        return 'تثبيت';
      case 'language_daily':
        return 'لغة';
      case 'mock_test':
        return 'اختبار شامل';
      default:
        return 'مراجعة';
    }
  }

  String _getSessionTypeNameFromEnum(SessionType type) {
    switch (type) {
      case SessionType.study:
        return 'مراجعة';
      case SessionType.regular:
        return 'مراجعة';
      case SessionType.revision:
        return 'تثبيت';
      case SessionType.practice:
        return 'تمارين';
      case SessionType.exam:
        return 'اختبار';
      case SessionType.longRevision:
        return 'مراجعة مطولة';
    }
  }
}

/// Internal class to hold calculated statistics
class _ScheduleStatistics {
  final int totalSessions;
  final double totalHours;
  final int subjectCount;
  final int averageSessionMinutes;
  final Map<String, int> sessionsBySubject;
  final Map<String, double> hoursBySubject;
  final Map<String, int> sessionsByType;
  final Map<SessionStatus, int> sessionsByStatus;

  _ScheduleStatistics({
    required this.totalSessions,
    required this.totalHours,
    required this.subjectCount,
    required this.averageSessionMinutes,
    required this.sessionsBySubject,
    required this.hoursBySubject,
    required this.sessionsByType,
    required this.sessionsByStatus,
  });
}
