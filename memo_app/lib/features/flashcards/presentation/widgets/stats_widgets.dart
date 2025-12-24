import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/flashcard_stats_entity.dart';

/// Modern widget showing today's flashcard stats summary
class TodayStatsCard extends StatelessWidget {
  final TodaySummary summary;

  const TodayStatsCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8B5CF6), // Violet
            Color(0xFFA78BFA), // Light violet
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.today,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'إحصائيات اليوم',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _ModernStatItem(
                        label: 'للمراجعة',
                        value: '${summary.cardsDue}',
                        icon: Icons.schedule,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: _ModernStatItem(
                        label: 'تمت مراجعتها',
                        value: '${summary.cardsReviewed}',
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: _ModernStatItem(
                        label: 'وقت الدراسة',
                        value: '${summary.studyMinutes} د',
                        icon: Icons.timer_outlined,
                      ),
                    ),
                  ],
                ),

                // Streak badge
                if (summary.streakDays > 0) ...[
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: Color(0xFFFCD34D),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${summary.streakDays} يوم متتالي',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

class _ModernStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ModernStatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Modern widget showing forecast of upcoming reviews
class ForecastWidget extends StatelessWidget {
  final List<DailyForecast> forecast;

  const ForecastWidget({
    super.key,
    required this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) return const SizedBox.shrink();

    final maxCards =
        forecast.map((f) => f.cardsDue).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.date_range_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'المراجعات القادمة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: forecast.take(7).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final day = entry.value;
                final isToday = index == 0;
                return _ModernForecastBar(
                  dayLabel: _getDayLabel(day.date, index),
                  cardsDue: day.cardsDue,
                  maxCards: maxCards,
                  isToday: isToday,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayLabel(DateTime date, int index) {
    if (index == 0) return 'اليوم';
    if (index == 1) return 'غداً';

    final weekdays = ['أحد', 'إثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت'];
    return weekdays[date.weekday % 7];
  }
}

class _ModernForecastBar extends StatelessWidget {
  final String dayLabel;
  final int cardsDue;
  final int maxCards;
  final bool isToday;

  const _ModernForecastBar({
    required this.dayLabel,
    required this.cardsDue,
    required this.maxCards,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final height = maxCards > 0 ? (cardsDue / maxCards) * 70.0 : 0.0;
    final barColor = isToday ? const Color(0xFF8B5CF6) : const Color(0xFFDDD6FE);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Value
        Text(
          '$cardsDue',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isToday ? const Color(0xFF8B5CF6) : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),

        // Bar
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: height.clamp(6.0, 70.0).toDouble(),
          decoration: BoxDecoration(
            gradient: isToday
                ? const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  )
                : null,
            color: isToday ? null : barColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isToday
                ? [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),

        // Label
        Text(
          dayLabel,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
            color: isToday ? const Color(0xFF8B5CF6) : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Modern overall stats summary widget
class OverallStatsWidget extends StatelessWidget {
  final FlashcardStatsEntity stats;

  const OverallStatsWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'إحصائيات شاملة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _ModernStatCard(
                  label: 'إجمالي البطاقات',
                  value: '${stats.totalCards}',
                  icon: Icons.layers_rounded,
                  color: const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModernStatCard(
                  label: 'تم إتقانها',
                  value: '${stats.cardsMastered}',
                  icon: Icons.stars_rounded,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ModernStatCard(
                  label: 'نسبة الاحتفاظ',
                  value: '${stats.averageRetention.toStringAsFixed(0)}%',
                  icon: Icons.psychology_rounded,
                  color: const Color(0xFF0EA5E9),
                  isPercentage: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModernStatCard(
                  label: 'إجمالي المراجعات',
                  value: '${stats.totalReviews}',
                  icon: Icons.repeat_rounded,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModernStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isPercentage;

  const _ModernStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color.withValues(alpha: 0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
