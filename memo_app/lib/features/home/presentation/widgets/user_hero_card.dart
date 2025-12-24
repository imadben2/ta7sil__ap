import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../core/utils/gradient_helper.dart';

/// Modern Hero Card with glassmorphism effect
/// Displays user profile info, level, XP progress, and quick stats
class UserHeroCard extends StatelessWidget {
  /// User's first name
  final String firstName;

  /// User's avatar URL (optional)
  final String? avatarUrl;

  /// Academic stream name (e.g., "علوم تجريبية")
  final String? streamName;

  /// Academic year name (e.g., "السنة الثالثة ثانوي")
  final String? yearName;

  /// Current user level
  final int level;

  /// Total XP points
  final int totalPoints;

  /// Points needed to reach next level
  final int pointsToNextLevel;

  /// Current streak (consecutive days)
  final int streak;

  /// Study time today formatted (e.g., "2س 30د")
  final String studyTimeFormatted;

  /// User's rank in leaderboard (optional)
  final int? rank;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when profile avatar is tapped
  final VoidCallback? onAvatarTap;

  const UserHeroCard({
    super.key,
    required this.firstName,
    this.avatarUrl,
    this.streamName,
    this.yearName,
    required this.level,
    required this.totalPoints,
    required this.pointsToNextLevel,
    required this.streak,
    required this.studyTimeFormatted,
    this.rank,
    this.onTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate XP progress
    final currentLevelPoints = totalPoints % pointsToNextLevel;
    final progress = pointsToNextLevel > 0
        ? currentLevelPoints / pointsToNextLevel
        : 1.0;
    final progressPercent = (progress * 100).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: GradientHelper.primaryHero,
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusHero),
          boxShadow: [
            AppDesignTokens.shadowPrimary,
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusHero),
          child: Stack(
            children: [
              // Main content (must be first non-positioned child to establish size)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Avatar + Greeting
                    _buildTopRow(),

                    const SizedBox(height: 16),

                    // Level and XP Progress
                    _buildLevelSection(progress, progressPercent, currentLevelPoints),

                    const SizedBox(height: 16),

                    // Mini stats row
                    _buildMiniStatsRow(),
                  ],
                ),
              ),
              // Decorative circles (positioned, so they overlay the content)
              ..._buildDecorativeCircles(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDecorativeCircles() {
    return [
      Positioned(
        top: -30,
        right: -30,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.overlayWhite10,
          ),
        ),
      ),
      Positioned(
        bottom: -20,
        left: -20,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.overlayWhite5,
          ),
        ),
      ),
      Positioned(
        top: 60,
        right: 20,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.overlayWhite5,
          ),
        ),
      ),
    ];
  }

  Widget _buildTopRow() {
    // Determine greeting based on time of day
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'صباح الخير';
    } else if (hour < 18) {
      greeting = 'مساء الخير';
    } else {
      greeting = 'مساء الخير';
    }

    return Row(
      children: [
        // Avatar with tap action
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildAvatarPlaceholder(),
                    )
                  : _buildAvatarPlaceholder(),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // Greeting and user info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$greeting، $firstName!',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '👋',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              if (yearName != null || streamName != null)
                Text(
                  [yearName, streamName].where((s) => s != null).join(' - '),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.primaryDark,
      child: Center(
        child: Text(
          firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLevelSection(double progress, int progressPercent, int currentLevelPoints) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Level badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      size: 16,
                      color: Color(0xFFFFD700),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'المستوى $level',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Progress percentage
              Text(
                '$progressPercent%',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),

          const SizedBox(height: 8),

          // Points info
          Text(
            '$currentLevelPoints / $pointsToNextLevel نقطة للمستوى التالي',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Streak
        _buildMiniStat(
          icon: Icons.local_fire_department_rounded,
          value: '$streak',
          label: 'يوم',
          iconColor: const Color(0xFFFF6B6B),
        ),

        // Divider
        Container(
          height: 30,
          width: 1,
          color: Colors.white.withValues(alpha: 0.3),
        ),

        // Study time
        _buildMiniStat(
          icon: Icons.timer_outlined,
          value: studyTimeFormatted,
          label: 'اليوم',
          iconColor: const Color(0xFF4ECDC4),
        ),

        // Divider
        Container(
          height: 30,
          width: 1,
          color: Colors.white.withValues(alpha: 0.3),
        ),

        // Rank (if available)
        _buildMiniStat(
          icon: Icons.leaderboard_rounded,
          value: rank != null ? '#$rank' : '-',
          label: 'المرتبة',
          iconColor: const Color(0xFFFFD93D),
        ),
      ],
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}
