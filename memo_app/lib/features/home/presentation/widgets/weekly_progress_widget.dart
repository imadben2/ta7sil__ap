import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';

/// Data model for daily study progress
class DailyProgress {
  final String dayNameAr; // Arabic day name (السبت, الأحد, etc.)
  final String dayNameShort; // Short name (س, أ, ث, etc.)
  final int studyMinutes;
  final bool isToday;
  final DateTime date;

  const DailyProgress({
    required this.dayNameAr,
    required this.dayNameShort,
    required this.studyMinutes,
    required this.isToday,
    required this.date,
  });

  /// Generate a week's worth of data from a map of dates to minutes
  static List<DailyProgress> generateWeek(Map<DateTime, int> studyData) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Arabic day names (starting from Saturday for Arabic week)
    const dayNamesAr = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
    const dayNamesShort = ['س', 'أ', 'ث', 'ر', 'خ', 'ج', 'ج'];

    // Find the start of the week (Saturday)
    final daysFromSaturday = (now.weekday % 7);
    final saturday = today.subtract(Duration(days: daysFromSaturday));

    return List.generate(7, (index) {
      final date = saturday.add(Duration(days: index));
      final dateKey = DateTime(date.year, date.month, date.day);

      return DailyProgress(
        dayNameAr: dayNamesAr[index],
        dayNameShort: dayNamesShort[index],
        studyMinutes: studyData[dateKey] ?? 0,
        isToday: dateKey == today,
        date: date,
      );
    });
  }
}

/// Weekly progress chart widget
/// Displays a bar chart of study time for the past 7 days
class WeeklyProgressWidget extends StatefulWidget {
  /// List of 7 days of progress data
  final List<DailyProgress> weekData;

  /// Total study minutes this week
  final int totalMinutesThisWeek;

  /// Target minutes per week (optional, for goal indicator)
  final int? targetMinutesPerWeek;

  /// Callback when a day is tapped
  final Function(DailyProgress)? onDayTap;

  const WeeklyProgressWidget({
    super.key,
    required this.weekData,
    required this.totalMinutesThisWeek,
    this.targetMinutesPerWeek,
    this.onDayTap,
  });

  @override
  State<WeeklyProgressWidget> createState() => _WeeklyProgressWidgetState();
}

class _WeeklyProgressWidgetState extends State<WeeklyProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate max value for scaling
    final maxMinutes = widget.weekData
        .map((d) => d.studyMinutes)
        .reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxMinutes > 0 ? maxMinutes : 60; // Default to 1 hour if no data

    // Format total time
    final totalHours = widget.totalMinutesThisWeek ~/ 60;
    final totalMinutes = widget.totalMinutesThisWeek % 60;
    final formattedTotal = totalHours > 0
        ? '${totalHours}س ${totalMinutes}د'
        : '${totalMinutes}د';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'تقدمك هذا الأسبوع',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  formattedTotal,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Bar chart
          SizedBox(
            height: 100,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: widget.weekData.map((day) {
                    return _buildBar(day, effectiveMax, _animation.value);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(DailyProgress day, int maxMinutes, double animationValue) {
    // Calculate bar height (min 4px, max 70px)
    final ratio = maxMinutes > 0 ? day.studyMinutes / maxMinutes : 0.0;
    final barHeight = (ratio * 70).clamp(4.0, 70.0);
    final animatedHeight = barHeight * animationValue;

    // Format time for tooltip
    final hours = day.studyMinutes ~/ 60;
    final minutes = day.studyMinutes % 60;
    final timeStr = hours > 0 ? '${hours}س ${minutes}د' : '${minutes}د';

    return GestureDetector(
      onTap: () {
        if (widget.onDayTap != null) {
          widget.onDayTap!(day);
        }
        // Show tooltip
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${day.dayNameAr}: $timeStr',
              style: const TextStyle(fontFamily: 'Cairo'),
              textAlign: TextAlign.center,
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28,
            height: animatedHeight + 4, // Minimum height
            decoration: BoxDecoration(
              gradient: day.isToday
                  ? LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    )
                  : LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.3),
                        AppColors.primaryLight.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: day.isToday
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),

          const SizedBox(height: 8),

          // Day label
          Text(
            day.dayNameShort,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: day.isToday ? FontWeight.bold : FontWeight.w500,
              color: day.isToday ? AppColors.primary : Colors.grey[500],
            ),
          ),

          // Today indicator dot
          if (day.isToday)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(height: 6),
        ],
      ),
    );
  }
}
