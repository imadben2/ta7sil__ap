import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_design_tokens.dart';

/// Level badge for user levels, achievements, and progress tiers
/// Used in profile and gamification features
///
/// Example usage:
/// ```dart
/// LevelBadge(
///   level: 12,
///   color: AppColors.primary,
///   label: 'Expert',
/// )
/// ```
class LevelBadge extends StatelessWidget {
  /// Level number
  final int level;

  /// Badge color
  final Color? color;

  /// Optional label (e.g., 'Beginner', 'Expert')
  final String? label;

  /// On tap callback
  final VoidCallback? onTap;

  /// Badge style
  final LevelBadgeStyle style;

  /// Show icon
  final bool showIcon;

  const LevelBadge({
    super.key,
    required this.level,
    this.color,
    this.label,
    this.onTap,
    this.style = LevelBadgeStyle.filled,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: _getDecoration(effectiveColor),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                Icons.military_tech,
                size: AppDesignTokens.iconSizeSM,
                color: _getTextColor(effectiveColor),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              'Lv.',
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeCaption,
                fontWeight: FontWeight.w600,
                color: _getTextColor(effectiveColor).withOpacity(0.8),
              ),
            ),
            const SizedBox(width: 2),
            Text(
              level.toString(),
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeBody,
                fontWeight: FontWeight.bold,
                color: _getTextColor(effectiveColor),
              ),
            ),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label!,
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSizeCaption,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(effectiveColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  BoxDecoration _getDecoration(Color color) {
    switch (style) {
      case LevelBadgeStyle.filled:
        return BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(
            AppDesignTokens.borderRadiusTiny,
          ),
        );
      case LevelBadgeStyle.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(
            AppDesignTokens.borderRadiusTiny,
          ),
          border: Border.all(
            color: color.withOpacity(0.4),
            width: 1,
          ),
        );
      case LevelBadgeStyle.solid:
        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(
            AppDesignTokens.borderRadiusTiny,
          ),
        );
      case LevelBadgeStyle.gradient:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(
            AppDesignTokens.borderRadiusTiny,
          ),
        );
    }
  }

  Color _getTextColor(Color color) {
    switch (style) {
      case LevelBadgeStyle.filled:
      case LevelBadgeStyle.outlined:
        return color;
      case LevelBadgeStyle.solid:
      case LevelBadgeStyle.gradient:
        return Colors.white;
    }
  }
}

enum LevelBadgeStyle {
  filled,
  outlined,
  solid,
  gradient,
}

/// Circular level badge (just the level number in a circle)
class LevelBadgeCircular extends StatelessWidget {
  final int level;
  final Color? color;
  final VoidCallback? onTap;
  final double size;

  const LevelBadgeCircular({
    super.key,
    required this.level,
    this.color,
    this.onTap,
    this.size = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [effectiveColor, effectiveColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: effectiveColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            level.toString(),
            style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Achievement badge (for milestones and accomplishments)
class AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback? onTap;
  final bool unlocked;

  const AchievementBadge({
    super.key,
    required this.icon,
    required this.title,
    this.color,
    this.onTap,
    this.unlocked = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.warningYellow;
    final displayColor = unlocked ? effectiveColor : Colors.grey;

    return GestureDetector(
      onTap: unlocked ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: unlocked
                  ? LinearGradient(
                      colors: [displayColor, displayColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: unlocked ? null : Colors.grey[300],
              shape: BoxShape.circle,
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: displayColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: AppDesignTokens.iconSizeXL,
              color: unlocked ? Colors.white : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSizeCaption,
              fontWeight: FontWeight.w600,
              color: unlocked ? AppColors.textDark : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Rank badge (for leaderboards and competitions)
class RankBadge extends StatelessWidget {
  final int rank;
  final Color? color;
  final VoidCallback? onTap;

  const RankBadge({
    super.key,
    required this.rank,
    this.color,
    this.onTap,
  });

  Color get _rankColor {
    if (color != null) return color!;

    if (rank == 1) return const Color(0xFFFFD700); // Gold
    if (rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return AppColors.primary;
  }

  IconData get _rankIcon {
    if (rank <= 3) return Icons.emoji_events;
    return Icons.leaderboard;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: rank <= 3
              ? LinearGradient(
                  colors: [_rankColor, _rankColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: rank > 3 ? _rankColor.withOpacity(0.12) : null,
          borderRadius: BorderRadius.circular(
            AppDesignTokens.borderRadiusTiny,
          ),
          boxShadow: rank <= 3
              ? [
                  BoxShadow(
                    color: _rankColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _rankIcon,
              size: AppDesignTokens.iconSizeSM,
              color: rank <= 3 ? Colors.white : _rankColor,
            ),
            const SizedBox(width: 4),
            Text(
              '#$rank',
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeLabel,
                fontWeight: FontWeight.bold,
                color: rank <= 3 ? Colors.white : _rankColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
