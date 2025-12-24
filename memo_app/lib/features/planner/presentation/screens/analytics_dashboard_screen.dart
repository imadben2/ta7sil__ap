import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/analytics/planner_analytics_bloc.dart';
import '../bloc/analytics/planner_analytics_event.dart';
import '../bloc/analytics/planner_analytics_state.dart';
import '../../domain/entities/planner_analytics.dart';
import '../widgets/shared/planner_design_constants.dart';
import '../../../../injection_container.dart' as di;

/// Analytics Dashboard Screen - Modern design
///
/// Matches session_detail_screen.dart design patterns
/// Features:
/// - Modern stat cards with gradient icons
/// - Card-based chart containers
/// - Consistent styling
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  String _selectedPeriod = 'last_30_days';
  final List<String> _periods = [
    'last_7_days',
    'last_30_days',
    'last_3_months',
    'all_time',
  ];

  final Map<String, String> _periodLabels = {
    'last_7_days': 'آخر 7 أيام',
    'last_30_days': 'آخر 30 يوم',
    'last_3_months': 'آخر 3 أشهر',
    'all_time': 'كل الوقت',
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<PlannerAnalyticsBloc>()
            ..add(LoadPlannerAnalyticsEvent(period: _selectedPeriod)),
      child: Scaffold(
        backgroundColor: PlannerDesignConstants.slateBackground,
        appBar: _buildModernAppBar(context),
        body: BlocBuilder<PlannerAnalyticsBloc, PlannerAnalyticsState>(
          builder: (context, state) {
            if (state is PlannerAnalyticsLoading) {
              return _buildLoadingView(state);
            }

            if (state is PlannerAnalyticsError) {
              return _buildErrorView(context, state);
            }

            if (state is PlannerAnalyticsLoaded) {
              final analytics = state.analytics;
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Overview cards
                  _buildOverviewCards(analytics),
                  const SizedBox(height: 20),

                  // Study time trend chart
                  _buildStudyTimeTrendCard(analytics),
                  const SizedBox(height: 16),

                  // Subject breakdown pie chart
                  _buildSubjectBreakdownCard(analytics),
                  const SizedBox(height: 16),

                  // Weekly productivity bar chart
                  _buildWeeklyProductivityCard(analytics),
                  const SizedBox(height: 16),

                  // Productivity patterns
                  _buildProductivityPatternsCard(analytics),
                  const SizedBox(height: 16),

                  // AI Recommendations
                  _buildRecommendationsCard(analytics),

                  const SizedBox(height: 80),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'لوحة التحليلات',
        style: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.home_rounded,
            color: Color(0xFF6366F1),
            size: 20,
          ),
        ),
        onPressed: () => context.go('/home'),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.date_range_rounded,
              color: Color(0xFF6366F1),
              size: 20,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onSelected: (period) {
            setState(() {
              _selectedPeriod = period;
            });
            context.read<PlannerAnalyticsBloc>().add(
              LoadPlannerAnalyticsEvent(period: period),
            );
          },
          itemBuilder: (context) => _periods.map((period) {
            final isSelected = period == _selectedPeriod;
            return PopupMenuItem(
              value: period,
              child: Row(
                children: [
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Color(0xFF6366F1),
                    ),
                  if (isSelected) const SizedBox(width: 8),
                  Text(
                    _periodLabels[period] ?? period,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF6366F1) : null,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingView(PlannerAnalyticsLoading state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.message ?? 'جاري التحميل...',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, PlannerAnalyticsError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: PlannerDesignConstants.modernCardDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.read<PlannerAnalyticsBloc>().add(
                    RefreshPlannerAnalyticsEvent(period: _selectedPeriod),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'إعادة المحاولة',
                      style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
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

  Widget _buildOverviewCards(PlannerAnalytics analytics) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.access_time_rounded,
            value: '${analytics.totalHours.toStringAsFixed(1)}',
            label: 'ساعة دراسة',
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.local_fire_department_rounded,
            value: '${analytics.currentStreak}',
            label: 'أيام متتالية',
            color: const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.trending_up_rounded,
            value: '${analytics.completionRate.toStringAsFixed(0)}%',
            label: 'معدل الإتمام',
            color: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String value,
    required String label,
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
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStudyTimeTrendCard(PlannerAnalytics analytics) {
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
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  size: 18,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'وقت الدراسة اليومي',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(_buildStudyTimeLineChartData(analytics)),
          ),
        ],
      ),
    );
  }

  LineChartData _buildStudyTimeLineChartData(PlannerAnalytics analytics) {
    final spots = analytics.dailyStudyTrend.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.hours);
    }).toList();

    if (spots.isEmpty) {
      return LineChartData(lineBarsData: []);
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xFFE5E7EB),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const days = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];
              if (value.toInt() >= 0 && value.toInt() < days.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    days[value.toInt()],
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}س',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  color: Color(0xFF6B7280),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: spots.length > 1 ? (spots.length - 1).toDouble() : 6,
      minY: 0,
      maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: const Color(0xFF3B82F6),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: const Color(0xFF3B82F6),
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF3B82F6).withOpacity(0.2),
                const Color(0xFF3B82F6).withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectBreakdownCard(PlannerAnalytics analytics) {
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
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  size: 18,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'توزيع الوقت حسب المادة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(_buildSubjectPieChartData(analytics)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildSubjectLegend(analytics),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PieChartData _buildSubjectPieChartData(PlannerAnalytics analytics) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
      const Color(0xFF14B8A6),
      const Color(0xFF6366F1),
      const Color(0xFFEC4899),
    ];

    final total = analytics.subjectTimeBreakdown.values.fold(
      0.0,
      (sum, hours) => sum + hours,
    );

    if (total == 0) {
      return PieChartData(sections: []);
    }

    final sections = analytics.subjectTimeBreakdown.entries
        .toList()
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final subject = entry.value;
          final percentage = (subject.value / total * 100).toStringAsFixed(0);

          return PieChartSectionData(
            value: subject.value,
            title: '$percentage%',
            color: colors[index % colors.length],
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
          );
        })
        .toList();

    return PieChartData(
      sections: sections,
      sectionsSpace: 2,
      centerSpaceRadius: 35,
    );
  }

  Widget _buildSubjectLegend(PlannerAnalytics analytics) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
      const Color(0xFF14B8A6),
      const Color(0xFF6366F1),
      const Color(0xFFEC4899),
    ];

    final subjects = analytics.subjectTimeBreakdown.entries
        .toList()
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final subject = entry.value;
          return {
            'name': subject.key,
            'color': colors[index % colors.length],
            'hours': subject.value.toStringAsFixed(1),
          };
        })
        .toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: subjects.map((subject) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: subject['color'] as Color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject['name'] as String,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      '${subject['hours']}س',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeeklyProductivityCard(PlannerAnalytics analytics) {
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
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  size: 18,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'الإنتاجية الأسبوعية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(_buildWeeklyBarChartData(analytics)),
          ),
        ],
      ),
    );
  }

  BarChartData _buildWeeklyBarChartData(PlannerAnalytics analytics) {
    final barGroups = List.generate(7, (dayIndex) {
      final dayOfWeek = dayIndex + 1;
      final hours = analytics.weeklyProductivityHours[dayOfWeek] ?? 0.0;

      Color color;
      if (hours >= 4.0) {
        color = const Color(0xFF10B981);
      } else if (hours >= 3.0) {
        color = const Color(0xFF3B82F6);
      } else if (hours >= 2.0) {
        color = const Color(0xFFF59E0B);
      } else {
        color = const Color(0xFFEF4444);
      }

      return BarChartGroupData(
        x: dayIndex,
        barRods: [
          BarChartRodData(
            toY: hours,
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    });

    final maxHours = analytics.weeklyProductivityHours.values.isEmpty
        ? 5.0
        : analytics.weeklyProductivityHours.values.reduce(
                (a, b) => a > b ? a : b,
              ) *
              1.2;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxHours,
      barTouchData: BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const days = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];
              if (value.toInt() >= 0 && value.toInt() < days.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    days[value.toInt()],
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  color: Color(0xFF6B7280),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: barGroups,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xFFE5E7EB),
            strokeWidth: 1,
          );
        },
      ),
    );
  }

  Widget _buildProductivityPatternsCard(PlannerAnalytics analytics) {
    final patternsData = analytics.patterns;
    if (patternsData == null) {
      return const SizedBox.shrink();
    }

    final patterns = [
      {
        'icon': Icons.wb_sunny_rounded,
        'label': 'أفضل وقت',
        'value': patternsData.bestTimeOfDay,
        'color': const Color(0xFFF59E0B),
      },
      {
        'icon': Icons.calendar_today_rounded,
        'label': 'أفضل يوم',
        'value': patternsData.bestDayOfWeek,
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.timer_rounded,
        'label': 'مدة مثالية',
        'value': '${patternsData.optimalSessionDuration} دقيقة',
        'color': const Color(0xFF10B981),
      },
    ];

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
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  size: 18,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'أنماط الإنتاجية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...patterns.map((pattern) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (pattern['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        pattern['icon'] as IconData,
                        color: pattern['color'] as Color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pattern['label'] as String,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            pattern['value'] as String,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(PlannerAnalytics analytics) {
    // Get recommendations from analytics data
    final recommendationTexts = analytics.recommendations;

    // If no recommendations available, show loading message
    if (recommendationTexts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6366F1).withOpacity(0.1),
              const Color(0xFF8B5CF6).withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6366F1).withOpacity(0.2),
          ),
        ),
        child: const Center(
          child: Text(
            'لا توجد توصيات متاحة حالياً',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    // Map recommendations to display format with smart icon/color selection
    final recommendations = recommendationTexts.map((text) {
      return {
        'text': text,
        'icon': _getRecommendationIcon(text),
        'color': _getRecommendationColor(text),
      };
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'توصيات ذكية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recommendations.map((rec) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: (rec['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      rec['icon'] as IconData,
                      size: 14,
                      color: rec['color'] as Color,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      rec['text'] as String,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: Color(0xFF374151),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Helper method to select appropriate icon based on recommendation content
  IconData _getRecommendationIcon(String text) {
    if (text.contains('فائت') || text.contains('منخفض')) {
      return Icons.warning_amber_rounded;
    } else if (text.contains('ممتاز') || text.contains('رائع') || text.contains('استثنائي')) {
      return Icons.emoji_events_rounded;
    } else if (text.contains('توازن') || text.contains('زد وقت')) {
      return Icons.balance_rounded;
    } else if (text.contains('الصباح') || text.contains('المساء') || text.contains('الظهر') || text.contains('الليل')) {
      return Icons.wb_sunny_rounded;
    } else if (text.contains('سلسلة') || text.contains('متتالي')) {
      return Icons.local_fire_department_rounded;
    } else if (text.contains('جلسات') || text.contains('دقيقة')) {
      return Icons.schedule_rounded;
    } else if (text.contains('أيام')) {
      return Icons.calendar_today_rounded;
    } else if (text.contains('ابدأ') || text.contains('رحلت')) {
      return Icons.rocket_launch_rounded;
    } else {
      return Icons.auto_awesome_rounded;
    }
  }

  // Helper method to select appropriate color based on recommendation content
  Color _getRecommendationColor(String text) {
    if (text.contains('فائت') || text.contains('منخفض') || text.contains('لم تدرس')) {
      return const Color(0xFFEF4444); // Red for warnings
    } else if (text.contains('ممتاز') || text.contains('رائع') || text.contains('استثنائي')) {
      return const Color(0xFF8B5CF6); // Purple for excellence
    } else if (text.contains('توازن') || text.contains('زد وقت')) {
      return const Color(0xFF10B981); // Green for balance
    } else if (text.contains('الصباح') || text.contains('المساء') || text.contains('الظهر') || text.contains('الليل')) {
      return const Color(0xFFF59E0B); // Orange for time insights
    } else if (text.contains('سلسلة') || text.contains('متتالي')) {
      return const Color(0xFFFF6B35); // Fire orange for streaks
    } else if (text.contains('استمر') || text.contains('حافظ')) {
      return const Color(0xFF3B82F6); // Blue for encouragement
    } else {
      return const Color(0xFF6366F1); // Indigo as default
    }
  }
}
