import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Single achievement badge widget
///
/// Displays an achievement with:
/// - Icon or emoji
/// - Title
/// - Description
/// - Locked/unlocked state
/// - Progress indicator (for partial achievements)
/// - Unlock date
/// - Tap to show details
///
/// Usage:
/// ```dart
/// AchievementBadge(
///   achievement: AchievementModel(
///     id: '1',
///     title: 'المبتدئ',
///     description: 'أكمل 10 دروس',
///     icon: '🎓',
///     isUnlocked: true,
///     unlockedAt: DateTime.now(),
///     progress: 10,
///     goal: 10,
///   ),
///   onTap: () => showAchievementDetails(context),
/// )
/// ```
class AchievementBadge extends StatelessWidget {
  /// Achievement data
  final AchievementModel achievement;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Badge size (default: 80)
  final double size;

  /// Whether to show progress text (default: true)
  final bool showProgress;

  const AchievementBadge({
    Key? key,
    required this.achievement,
    this.onTap,
    this.size = 80,
    this.showProgress = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: achievement.isUnlocked ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: achievement.isUnlocked
                ? AppColors.primary.withOpacity(0.3)
                : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: achievement.isUnlocked
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge icon/emoji
            _buildBadgeIcon(),
            const SizedBox(height: 8),

            // Title
            Text(
              achievement.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: achievement.isUnlocked ? Colors.grey[800] : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Progress indicator (if not fully unlocked)
            if (showProgress && !achievement.isUnlocked && achievement.progress != null)
              _buildProgressIndicator(),

            // Unlock date (if unlocked)
            if (achievement.isUnlocked && achievement.unlockedAt != null)
              _buildUnlockDate(),
          ],
        ),
      ),
    );
  }

  /// Build badge icon/emoji with lock overlay if locked
  Widget _buildBadgeIcon() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: achievement.isUnlocked
                  ? LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        Colors.grey[400]!,
                        Colors.grey[300]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
            ),
          ),

          // Icon or emoji
          if (achievement.isUnlocked)
            Text(
              achievement.icon,
              style: TextStyle(
                fontSize: size * 0.5,
              ),
            )
          else
            Icon(
              Icons.lock,
              color: Colors.grey[600],
              size: size * 0.4,
            ),
        ],
      ),
    );
  }

  /// Build progress indicator for partial achievements
  Widget _buildProgressIndicator() {
    final progress = achievement.progress!;
    final goal = achievement.goal!;
    final percentage = (progress / goal * 100).clamp(0, 100).toInt();

    return Column(
      children: [
        const SizedBox(height: 4),
        Text(
          '$progress/$goal',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Cairo',
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress / goal,
            minHeight: 4,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withOpacity(0.6)),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'Cairo',
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  /// Build unlock date label
  Widget _buildUnlockDate() {
    final date = achievement.unlockedAt!;
    final formattedDate = '${date.year}/${date.month}/${date.day}';

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        'تم الإنجاز: $formattedDate',
        style: TextStyle(
          fontSize: 10,
          fontFamily: 'Cairo',
          color: Colors.grey[500],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Compact achievement badge (icon only, no text)
class CompactAchievementBadge extends StatelessWidget {
  final AchievementModel achievement;
  final VoidCallback? onTap;
  final double size;

  const CompactAchievementBadge({
    Key? key,
    required this.achievement,
    this.onTap,
    this.size = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: achievement.isUnlocked
              ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.grey[400]!,
                    Colors.grey[300]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          boxShadow: achievement.isUnlocked
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: achievement.isUnlocked
              ? Text(
                  achievement.icon,
                  style: TextStyle(fontSize: size * 0.5),
                )
              : Icon(
                  Icons.lock,
                  color: Colors.grey[600],
                  size: size * 0.4,
                ),
        ),
      ),
    );
  }
}

/// Achievement model (simplified for widget usage)
///
/// In production, this should be imported from domain/entities
class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon; // Emoji or icon identifier
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int? progress; // Current progress (e.g., 12 lessons completed)
  final int? goal; // Goal to reach (e.g., 30 lessons total)
  final String? category; // e.g., 'lessons', 'quizzes', 'streak'

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress,
    this.goal,
    this.category,
  });

  /// Calculate progress percentage (0-100)
  int get progressPercentage {
    if (progress == null || goal == null || goal == 0) return 0;
    return ((progress! / goal!) * 100).clamp(0, 100).toInt();
  }

  /// Check if achievement is partially completed
  bool get isPartiallyCompleted {
    return !isUnlocked && progress != null && goal != null && progress! > 0;
  }
}
