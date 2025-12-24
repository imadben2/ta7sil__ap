import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/app_colors.dart';

/// Streak calendar widget showing study activity
///
/// Displays a monthly calendar with:
/// - Days with study activity: ✓ (green)
/// - Days without activity: ✗ (red)
/// - Future days: ○ (grey)
/// - Current day highlighted
/// - Swipe to navigate months
/// - Current streak and longest streak stats
///
/// Usage:
/// ```dart
/// StreakCalendar(
///   studyDays: {
///     DateTime(2025, 12, 1): true,
///     DateTime(2025, 12, 2): true,
///     DateTime(2025, 12, 3): false,
///     DateTime(2025, 12, 4): true,
///   },
///   currentStreak: 15,
///   longestStreak: 30,
/// )
/// ```
class StreakCalendar extends StatefulWidget {
  /// Map of dates to study activity (true = studied, false = missed)
  final Map<DateTime, bool> studyDays;

  /// Current streak count (consecutive days)
  final int currentStreak;

  /// Longest streak ever achieved
  final int longestStreak;

  /// Whether to show streak stats
  final bool showStats;

  /// Initial focused day (defaults to today)
  final DateTime? initialFocusedDay;

  const StreakCalendar({
    Key? key,
    required this.studyDays,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.showStats = true,
    this.initialFocusedDay,
  }) : super(key: key);

  @override
  State<StreakCalendar> createState() => _StreakCalendarState();
}

class _StreakCalendarState extends State<StreakCalendar> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialFocusedDay ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Calendar title
        _buildTitle(),
        const SizedBox(height: 16),

        // Calendar
        _buildCalendar(),

        // Legend
        const SizedBox(height: 16),
        _buildLegend(),

        // Streak stats
        if (widget.showStats) ...[
          const SizedBox(height: 24),
          _buildStreakStats(),
        ],
      ],
    );
  }

  /// Build calendar title
  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'سجل النشاط',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
          color: Colors.grey[800],
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  /// Build calendar widget
  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.saturday, // Arabic week starts Saturday
        locale: 'ar',
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
          leftChevronIcon: const Icon(Icons.chevron_right, color: AppColors.primary),
          rightChevronIcon: const Icon(Icons.chevron_left, color: AppColors.primary),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
            color: Colors.red[400],
          ),
        ),
        calendarStyle: CalendarStyle(
          // Today's date
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          todayTextStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
          // Selected date
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
          // Default cell
          defaultTextStyle: const TextStyle(
            fontFamily: 'Cairo',
          ),
          weekendTextStyle: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.red[400],
          ),
          outsideTextStyle: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.grey[400],
          ),
        ),
        calendarBuilders: CalendarBuilders(
          // Custom marker builder for study activity
          markerBuilder: (context, date, events) {
            return _buildDayMarker(date);
          },
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
      ),
    );
  }

  /// Build day marker (✓, ✗, or ○)
  Widget? _buildDayMarker(DateTime date) {
    // Normalize date to compare (ignore time)
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    // Future dates - grey circle
    if (normalizedDate.isAfter(normalizedToday)) {
      return Container(
        margin: const EdgeInsets.only(top: 32),
        child: Icon(
          Icons.circle_outlined,
          size: 16,
          color: Colors.grey[400],
        ),
      );
    }

    // Check study activity
    final hasStudied = widget.studyDays[normalizedDate];

    if (hasStudied == null) {
      // No data for this past date - assume missed
      return Container(
        margin: const EdgeInsets.only(top: 32),
        child: Icon(
          Icons.close,
          size: 16,
          color: Colors.grey[400],
        ),
      );
    }

    // Has data
    if (hasStudied) {
      // Studied - green check
      return Container(
        margin: const EdgeInsets.only(top: 32),
        child: Icon(
          Icons.check_circle,
          size: 16,
          color: Colors.green[600],
        ),
      );
    } else {
      // Missed - red X
      return Container(
        margin: const EdgeInsets.only(top: 32),
        child: Icon(
          Icons.cancel,
          size: 16,
          color: Colors.red[400],
        ),
      );
    }
  }

  /// Build legend explaining icons
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLegendItem(
              icon: Icons.check_circle,
              color: Colors.green[600]!,
              label: 'تمت الدراسة',
            ),
            _buildLegendItem(
              icon: Icons.cancel,
              color: Colors.red[400]!,
              label: 'فاتت',
            ),
            _buildLegendItem(
              icon: Icons.circle_outlined,
              color: Colors.grey[400]!,
              label: 'مستقبلاً',
            ),
          ],
        ),
      ),
    );
  }

  /// Build single legend item
  Widget _buildLegendItem({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Cairo',
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  /// Build streak statistics
  Widget _buildStreakStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            // Current streak
            Expanded(
              child: _buildStreakItem(
                icon: Icons.local_fire_department,
                label: 'السلسلة الحالية',
                value: widget.currentStreak,
                unit: 'يوم',
              ),
            ),

            // Divider
            Container(
              height: 60,
              width: 2,
              color: Colors.white.withOpacity(0.3),
            ),

            // Longest streak
            Expanded(
              child: _buildStreakItem(
                icon: Icons.emoji_events,
                label: 'أطول سلسلة',
                value: widget.longestStreak,
                unit: 'يوم',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build single streak stat item
  Widget _buildStreakItem({
    required IconData icon,
    required String label,
    required int value,
    required String unit,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Cairo',
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Cairo',
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Compact streak calendar (no stats, smaller size)
class CompactStreakCalendar extends StatelessWidget {
  final Map<DateTime, bool> studyDays;

  const CompactStreakCalendar({
    Key? key,
    required this.studyDays,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreakCalendar(
      studyDays: studyDays,
      showStats: false,
    );
  }
}

/// Streak stats card (without calendar)
class StreakStatsCard extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final int totalStudyDays;

  const StreakStatsCard({
    Key? key,
    required this.currentStreak,
    required this.longestStreak,
    this.totalStudyDays = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'إحصائيات السلسلة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  label: 'الحالية',
                  value: currentStreak,
                  icon: Icons.local_fire_department,
                ),
                _buildDivider(),
                _buildStatItem(
                  label: 'الأطول',
                  value: longestStreak,
                  icon: Icons.emoji_events,
                ),
                _buildDivider(),
                _buildStatItem(
                  label: 'المجموع',
                  value: totalStudyDays,
                  icon: Icons.calendar_today,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required int value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Cairo',
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 60,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }
}
