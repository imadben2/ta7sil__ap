import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Weekly study hours bar chart widget
///
/// Displays a 7-day bar chart showing study hours per day.
/// Features:
/// - Arabic day names (Saturday-Friday)
/// - Gradient blue bars
/// - Touch to show exact value tooltip
/// - Weekly summary stats
/// - Empty state handling
/// - RTL support
///
/// Usage:
/// ```dart
/// WeeklyStudyChart(
///   weeklyData: {
///     'السبت': 2.5,
///     'الأحد': 3.0,
///     'الاثنين': 1.5,
///     'الثلاثاء': 4.0,
///     'الأربعاء': 2.0,
///     'الخميس': 3.5,
///     'الجمعة': 1.0,
///   },
/// )
/// ```
class WeeklyStudyChart extends StatefulWidget {
  /// Map of day names (Arabic) to study hours
  final Map<String, double> weeklyData;

  /// Maximum hours to display on Y-axis (default: 8)
  final double maxHours;

  /// Chart height (default: 220)
  final double height;

  /// Whether to show summary stats below chart
  final bool showSummary;

  const WeeklyStudyChart({
    Key? key,
    required this.weeklyData,
    this.maxHours = 8.0,
    this.height = 220,
    this.showSummary = true,
  }) : super(key: key);

  @override
  State<WeeklyStudyChart> createState() => _WeeklyStudyChartState();
}

class _WeeklyStudyChartState extends State<WeeklyStudyChart> {
  int _touchedIndex = -1;

  /// Arabic day names in order (Saturday-Friday)
  static const List<String> _dayNames = [
    'السبت',
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];

  @override
  Widget build(BuildContext context) {
    // Check if data is empty
    if (widget.weeklyData.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Chart title
        _buildTitle(),
        const SizedBox(height: 16),

        // Bar chart
        SizedBox(
          height: widget.height,
          child: Directionality(
            textDirection: TextDirection.ltr, // Keep chart LTR for proper bar display
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 16),
              child: BarChart(
                _buildBarChartData(),
              ),
            ),
          ),
        ),

        // Summary stats
        if (widget.showSummary) ...[
          const SizedBox(height: 24),
          _buildSummaryStats(),
        ],
      ],
    );
  }

  /// Build chart title
  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'ساعات الدراسة الأسبوعية',
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

  /// Build bar chart data
  BarChartData _buildBarChartData() {
    return BarChartData(
      maxY: widget.maxHours,
      minY: 0,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final dayName = _dayNames[group.x.toInt()];
            final hours = rod.toY;
            return BarTooltipItem(
              '$dayName\n${hours.toStringAsFixed(1)} ساعة',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Cairo',
              ),
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              _touchedIndex = -1;
              return;
            }
            _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: _buildBottomTitles,
            reservedSize: 42,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 2,
            getTitlesWidget: _buildLeftTitles,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 2,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
          );
        },
      ),
      barGroups: _buildBarGroups(),
    );
  }

  /// Build bar groups from weekly data
  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(_dayNames.length, (index) {
      final dayName = _dayNames[index];
      final hours = widget.weeklyData[dayName] ?? 0.0;
      final isTouched = index == _touchedIndex;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: hours,
            width: isTouched ? 28 : 24,
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.6),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: widget.maxHours,
              color: Colors.grey[200],
            ),
          ),
        ],
      );
    });
  }

  /// Build bottom axis titles (day names)
  Widget _buildBottomTitles(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= _dayNames.length) {
      return const SizedBox.shrink();
    }

    // Show abbreviated day names (first 2 letters)
    final dayName = _dayNames[index];
    final abbreviation = dayName.length >= 2 ? dayName.substring(0, 2) : dayName;

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(
        abbreviation,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Cairo',
          color: Colors.grey[700],
        ),
      ),
    );
  }

  /// Build left axis titles (hours)
  Widget _buildLeftTitles(double value, TitleMeta meta) {
    if (value == meta.max || value == meta.min) {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(
        '${value.toInt()}',
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'Cairo',
          color: Colors.grey[600],
        ),
      ),
    );
  }

  /// Build summary statistics
  Widget _buildSummaryStats() {
    final totalHours = widget.weeklyData.values.fold<double>(
      0.0,
      (sum, hours) => sum + hours,
    );
    final averageHours = widget.weeklyData.isNotEmpty
        ? totalHours / widget.weeklyData.length
        : 0.0;
    final maxDayHours = widget.weeklyData.values.isEmpty
        ? 0.0
        : widget.weeklyData.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              label: 'المجموع',
              value: '${totalHours.toStringAsFixed(1)}',
              unit: 'ساعة',
              icon: Icons.schedule,
            ),
            _buildVerticalDivider(),
            _buildStatItem(
              label: 'المتوسط',
              value: '${averageHours.toStringAsFixed(1)}',
              unit: 'ساعة/يوم',
              icon: Icons.trending_up,
            ),
            _buildVerticalDivider(),
            _buildStatItem(
              label: 'الأعلى',
              value: '${maxDayHours.toStringAsFixed(1)}',
              unit: 'ساعة',
              icon: Icons.star,
            ),
          ],
        ),
      ),
    );
  }

  /// Build a single stat item
  Widget _buildStatItem({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build vertical divider
  Widget _buildVerticalDivider() {
    return Container(
      height: 50,
      width: 1,
      color: Colors.grey[300],
    );
  }

  /// Build empty state when no data
  Widget _buildEmptyState() {
    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد بيانات دراسية هذا الأسبوع',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بالدراسة لرؤية إحصائياتك هنا',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact version of weekly study chart (no summary)
class CompactWeeklyStudyChart extends StatelessWidget {
  final Map<String, double> weeklyData;
  final double maxHours;

  const CompactWeeklyStudyChart({
    Key? key,
    required this.weeklyData,
    this.maxHours = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WeeklyStudyChart(
      weeklyData: weeklyData,
      maxHours: maxHours,
      height: 180,
      showSummary: false,
    );
  }
}
