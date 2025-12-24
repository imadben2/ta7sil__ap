import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bloc/points_history/points_history_bloc.dart';
import '../bloc/points_history/points_history_event.dart';
import '../bloc/points_history/points_history_state.dart';
import '../../domain/entities/points_history.dart';

/// Screen displaying points history with charts
class PointsHistoryScreen extends StatefulWidget {
  const PointsHistoryScreen({super.key});

  @override
  State<PointsHistoryScreen> createState() => _PointsHistoryScreenState();
}

class _PointsHistoryScreenState extends State<PointsHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PointsHistoryBloc>().add(const LoadPointsHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isRtl ? 'سجل النقاط' : 'Points History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PointsHistoryBloc>().add(const RefreshPointsHistoryEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<PointsHistoryBloc, PointsHistoryState>(
        builder: (context, state) {
          if (state is PointsHistoryLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    state.message ?? (isRtl ? 'جاري التحميل...' : 'Loading...'),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          if (state is PointsHistoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<PointsHistoryBloc>().add(const LoadPointsHistoryEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(isRtl ? 'إعادة المحاولة' : 'Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is PointsHistoryLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PointsHistoryBloc>().add(const RefreshPointsHistoryEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Level & Points Header
                    _buildLevelHeader(context, state),

                    // Points Chart
                    _buildPointsChart(context, state),

                    // Daily Points List
                    _buildDailyPointsList(context, state),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLevelHeader(BuildContext context, PointsHistoryLoaded state) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Level Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                Text(
                  isRtl ? 'المستوى ${state.currentLevel}' : 'Level ${state.currentLevel}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Total Points
          Text(
            '${state.totalPoints}',
            style: theme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            isRtl ? 'إجمالي النقاط' : 'Total Points',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),

          // Level Progress
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isRtl ? 'المستوى ${state.currentLevel}' : 'Level ${state.currentLevel}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    isRtl ? 'المستوى ${state.currentLevel + 1}' : 'Level ${state.currentLevel + 1}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: state.levelProgress / 100,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
              const SizedBox(height: 4),
              Text(
                isRtl
                    ? '${state.pointsToNextLevel} نقطة للمستوى التالي'
                    : '${state.pointsToNextLevel} points to next level',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Period Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                context,
                value: '${state.periodPoints}',
                label: isRtl ? 'نقاط الفترة' : 'Period',
              ),
              _buildStatItem(
                context,
                value: state.averagePointsPerDay.toStringAsFixed(1),
                label: isRtl ? 'المعدل اليومي' : 'Daily Avg',
              ),
              _buildStatItem(
                context,
                value: '${state.dailyPoints.length}',
                label: isRtl ? 'أيام نشطة' : 'Active Days',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsChart(BuildContext context, PointsHistoryLoaded state) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    if (state.dailyPoints.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            isRtl ? 'لا توجد بيانات للعرض' : 'No data to display',
            style: theme.textTheme.bodyLarge,
          ),
        ),
      );
    }

    // Take last 7 days for chart
    final chartData = state.dailyPoints.take(7).toList().reversed.toList();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRtl ? 'آخر 7 أيام' : 'Last 7 Days',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (chartData.map((e) => e.totalPoints).reduce((a, b) => a > b ? a : b) * 1.2).toDouble(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} ${isRtl ? 'نقطة' : 'pts'}',
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                          final date = chartData[value.toInt()].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: theme.textTheme.bodySmall,
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: chartData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.totalPoints.toDouble(),
                        color: theme.colorScheme.primary,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyPointsList(BuildContext context, PointsHistoryLoaded state) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    if (state.dailyPoints.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              isRtl ? 'التفاصيل اليومية' : 'Daily Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...state.dailyPoints.take(10).map((daily) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    '${daily.sessionsCount}',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  _formatDate(daily.date, isRtl),
                  style: theme.textTheme.titleSmall,
                ),
                subtitle: Text(
                  isRtl
                      ? '${daily.sessionsCount} جلسة'
                      : '${daily.sessionsCount} sessions',
                  style: theme.textTheme.bodySmall,
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: daily.totalPoints > 0
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${daily.totalPoints > 0 ? '+' : ''}${daily.totalPoints}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: daily.totalPoints > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, bool isRtl) {
    final days = isRtl
        ? ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت']
        : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return '${days[date.weekday % 7]}, ${date.day}/${date.month}';
  }
}
