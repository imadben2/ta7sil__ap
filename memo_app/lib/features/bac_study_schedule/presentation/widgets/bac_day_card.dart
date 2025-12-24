import 'package:flutter/material.dart';
import '../../domain/entities/bac_study_day.dart';

/// Modern card widget for displaying a day in the week grid
class BacDayCard extends StatelessWidget {
  final BacStudyDay day;
  final VoidCallback? onTap;

  const BacDayCard({
    super.key,
    required this.day,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayConfig = _getDayConfig();
    final bool isCompleted = day.isFullyCompleted;
    final bool hasProgress = day.progressPercentage > 0;
    final bool isRestDay = day.totalTopicsCount == 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isCompleted
                ? [
                    Colors.white,
                    const Color(0xFF10B981).withOpacity(0.08),
                  ]
                : [
                    Colors.white,
                    dayConfig.lightColor.withOpacity(0.6),
                  ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: isCompleted
              ? Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.5),
                  width: 2,
                )
              : Border.all(
                  color: dayConfig.color.withOpacity(0.15),
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: dayConfig.color.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background gradient overlay - very light
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        dayConfig.lightColor.withOpacity(0.8),
                        dayConfig.lightColor.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Day icon container - lighter style
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: dayConfig.lightColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            dayConfig.icon,
                            color: dayConfig.color,
                            size: 20,
                          ),
                        ),
                        // Status badge
                        if (isCompleted)
                          _buildCompletedBadge()
                        else if (hasProgress)
                          _buildProgressBadge(day.progressPercentage),
                      ],
                    ),
                    const Spacer(),
                    // Day number with modern typography
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          'اليوم',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${day.dayNumber}',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Day type badge - lighter style
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: dayConfig.lightColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        day.dayTypeDisplayAr,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: dayConfig.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Bottom section - Progress or rest indicator
                    if (!isRestDay)
                      _buildProgressSection(dayConfig, isCompleted, hasProgress)
                    else
                      _buildRestDaySection(dayConfig),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedBadge() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 14,
      ),
    );
  }

  Widget _buildProgressBadge(double progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${(progress * 100).toInt()}%',
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFFF59E0B),
        ),
      ),
    );
  }

  Widget _buildProgressSection(_DayConfig config, bool isCompleted, bool hasProgress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Topics count
        Row(
          children: [
            const Icon(
              Icons.menu_book_rounded,
              size: 14,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(width: 6),
            Text(
              '${day.completedTopicsCount}/${day.totalTopicsCount} درس',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Modern progress bar
        Stack(
          children: [
            // Background
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // Progress
            FractionallySizedBox(
              widthFactor: day.progressPercentage,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isCompleted
                        ? [
                            const Color(0xFF10B981),
                            const Color(0xFF34D399),
                          ]
                        : hasProgress
                            ? [
                                config.color,
                                config.color.withOpacity(0.7),
                              ]
                            : [
                                const Color(0xFFCBD5E1),
                                const Color(0xFFE2E8F0),
                              ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRestDaySection(_DayConfig config) {
    final isReward = day.dayType == 'reward';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: config.lightColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isReward ? '🎬' : '☕',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 6),
          Text(
            isReward ? 'وقت المكافأة' : 'يوم راحة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }

  _DayConfig _getDayConfig() {
    switch (day.dayType) {
      case 'review':
        return _DayConfig(
          color: const Color(0xFFA78BFA), // Lighter purple
          lightColor: const Color(0xFFEDE9FE),
          icon: Icons.replay_rounded,
        );
      case 'reward':
        return _DayConfig(
          color: const Color(0xFFFBBF24), // Lighter amber
          lightColor: const Color(0xFFFEF3C7),
          icon: Icons.card_giftcard_rounded,
        );
      default:
        return _DayConfig(
          color: const Color(0xFF60A5FA), // Lighter blue
          lightColor: const Color(0xFFDBEAFE),
          icon: Icons.auto_stories_rounded,
        );
    }
  }
}

class _DayConfig {
  final Color color;
  final Color lightColor;
  final IconData icon;

  const _DayConfig({
    required this.color,
    required this.lightColor,
    required this.icon,
  });
}
