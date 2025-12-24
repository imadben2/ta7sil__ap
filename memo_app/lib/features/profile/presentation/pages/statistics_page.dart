import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../bloc/statistics/statistics_bloc.dart';
import '../bloc/statistics/statistics_event.dart';
import '../bloc/statistics/statistics_state.dart';
import '../widgets/weekly_study_chart.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/achievements_grid.dart';
import '../widgets/streak_calendar.dart';

/// صفحة الإحصائيات التفصيلية - تصميم حديث مطابق لصفحة دوراتي
///
/// تعرض:
/// - نظرة عامة على الإحصائيات (4 بطاقات)
/// - رسم بياني أسبوعي لساعات الدراسة
/// - توزيع المواد الدراسية
/// - شبكة الإنجازات
/// - تقويم السلسلة (heatmap)
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  // ثوابت الألوان - مطابقة لصفحة دوراتي
  static const _primaryPurple = AppColors.primary;
  static const _secondaryPurple = AppColors.primaryDark;
  static const _bgColor = AppColors.slateBackground;

  @override
  void initState() {
    super.initState();
    context.read<StatisticsBloc>().add(const LoadStatistics());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: BlocBuilder<StatisticsBloc, StatisticsState>(
          builder: (context, state) {
            if (state is StatisticsLoading) {
              return _buildLoadingState();
            }

            if (state is StatisticsError) {
              return _buildErrorState(state.message);
            }

            if (state is StatisticsLoaded) {
              final stats = state.statistics;
              return _buildContent(stats);
            }

            return _buildEmptyState();
          },
        ),
      ),
    );
  }

  /// الهيدر مع gradient بنفسجي
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryPurple, _secondaryPurple],
        ),
      ),
      child: Column(
        children: [
          // محتوى الهيدر
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // زر الرجوع
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // الأيقونة
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // العنوان
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الإحصائيات',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'تتبع تقدمك الدراسي',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                // زر التحديث
                GestureDetector(
                  onTap: () {
                    context.read<StatisticsBloc>().add(const RefreshStatistics());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // القاع المنحني
          Container(
            height: 24,
            decoration: const BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// حالة التحميل
  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryPurple),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'جاري تحميل الإحصائيات...',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// حالة الخطأ
  Widget _buildErrorState(String message) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 56,
                      color: AppColors.error.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      color: AppColors.slate600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<StatisticsBloc>().add(const LoadStatistics());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text(
                      'إعادة المحاولة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// حالة فارغة
  Widget _buildEmptyState() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _primaryPurple.withOpacity(0.1),
                        _secondaryPurple.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    Icons.bar_chart_rounded,
                    size: 56,
                    color: _primaryPurple.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'لا توجد بيانات إحصائية',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ابدأ الدراسة لتظهر إحصائياتك هنا',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// المحتوى الرئيسي
  Widget _buildContent(stats) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<StatisticsBloc>().add(const RefreshStatistics());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: _primaryPurple,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // نظرة عامة - Overview Cards
                  _buildOverviewCards(
                    totalStudyHours: stats.totalStudyHours,
                    currentStreak: stats.currentStreak,
                    completedSessions: stats.completedSessions,
                    averageQuizScore: stats.averageQuizScore,
                  ),

                  const SizedBox(height: 32),

                  // الرسم البياني الأسبوعي
                  _buildSectionTitle('الدراسة الأسبوعية', Icons.show_chart_rounded),
                  const SizedBox(height: 16),
                  _buildWeeklyChartSection(stats.weeklyHours),

                  const SizedBox(height: 32),

                  // توزيع المواد
                  _buildSectionTitle('توزيع المواد', Icons.pie_chart_rounded),
                  const SizedBox(height: 16),
                  _buildSubjectBreakdown(stats.subjectBreakdown),

                  const SizedBox(height: 32),

                  // الإنجازات
                  _buildSectionTitle('الإنجازات', Icons.emoji_events_rounded),
                  const SizedBox(height: 16),
                  _buildAchievementsSection(stats.achievements),

                  const SizedBox(height: 32),

                  // تقويم السلسلة
                  _buildSectionTitle('تقويم الدراسة', Icons.calendar_month_rounded),
                  const SizedBox(height: 16),
                  _buildStreakCalendarSection(
                    stats.streakCalendar,
                    currentStreak: stats.currentStreak,
                    longestStreak: stats.longestStreak,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// عنوان القسم بتصميم حديث
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_primaryPurple, _secondaryPurple],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          icon,
          size: 20,
          color: _primaryPurple,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.slate900,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCards({
    required double totalStudyHours,
    required int currentStreak,
    required int completedSessions,
    required double? averageQuizScore,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '${totalStudyHours.toStringAsFixed(1)}',
                  'ساعات الدراسة',
                  Icons.access_time_rounded,
                  _primaryPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '$currentStreak',
                  'سلسلة الأيام',
                  Icons.local_fire_department_rounded,
                  AppColors.fireRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '$completedSessions',
                  'جلسات منجزة',
                  Icons.check_circle_rounded,
                  AppColors.emerald500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  averageQuizScore != null
                      ? '${averageQuizScore.toStringAsFixed(1)}/20'
                      : '--',
                  'متوسط الاختبارات',
                  Icons.star_rounded,
                  AppColors.amber500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: AppColors.slate600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Build weekly chart section
  Widget _buildWeeklyChartSection(List weeklyData) {
    if (weeklyData.isEmpty) {
      return _buildEmptyCard('لا توجد بيانات أسبوعية');
    }

    final Map<String, double> weeklyDataMap = {};
    for (var point in weeklyData) {
      final dayName = point.dayNameShortAr;
      weeklyDataMap[dayName] = point.hours;
    }

    return WeeklyStudyChart(
      weeklyData: weeklyDataMap,
      maxHours: 8.0,
      height: 220,
      showSummary: true,
    );
  }

  Widget _buildSubjectBreakdown(List subjects) {
    if (subjects.isEmpty) {
      return _buildEmptyCard('لا توجد مواد');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: subjects.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: AppColors.slate500.withOpacity(0.1)),
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final color = _parseColor(subject.color);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  subject.subjectNameAr.isNotEmpty
                      ? subject.subjectNameAr.substring(0, 1)
                      : '؟',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            title: Text(
              subject.subjectNameAr,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.slate900,
              ),
            ),
            subtitle: Text(
              '${subject.sessions} جلسة',
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.slate500,
                fontSize: 13,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${subject.hours.toStringAsFixed(1)} ساعة',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${subject.percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build achievements section
  Widget _buildAchievementsSection(List achievements) {
    if (achievements.isEmpty) {
      return _buildEmptyCard('لا توجد إنجازات');
    }

    final List<AchievementModel> achievementModels = achievements.map((a) {
      return AchievementModel(
        id: a.id?.toString() ?? '',
        title: a.titleAr ?? 'إنجاز',
        description: a.descriptionAr ?? '',
        icon: '🏆',
        isUnlocked: a.isUnlocked ?? false,
        unlockedAt: a.unlockedAt,
        progress: a.progress,
        goal: a.goal,
        category: a.category,
      );
    }).toList();

    return AchievementsGrid(
      achievements: achievementModels,
      crossAxisCount: 3,
      spacing: 12,
      showHeaders: false,
    );
  }

  /// Build streak calendar section
  Widget _buildStreakCalendarSection(
    streakCalendar, {
    required int currentStreak,
    required int longestStreak,
  }) {
    final Map<DateTime, bool> studyDaysMap = {};

    final today = DateTime.now();
    for (int i = 0; i < 49; i++) {
      final date = today.subtract(Duration(days: 48 - i));
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final isActive = streakCalendar.activeDays?.contains(date.day) ?? false;
      studyDaysMap[normalizedDate] = isActive;
    }

    return StreakCalendar(
      studyDays: studyDaysMap,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      showStats: true,
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 48,
              color: AppColors.slate500.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        final hex = colorString.substring(1);
        return Color(int.parse(hex, radix: 16) + 0xFF000000);
      }
      return Color(int.parse(colorString));
    } catch (e) {
      return _primaryPurple;
    }
  }
}
