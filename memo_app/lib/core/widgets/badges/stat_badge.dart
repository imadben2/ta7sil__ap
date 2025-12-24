import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_design_tokens.dart';

/// Circular stat badge with icon and value
/// Used for displaying small statistics with icons
///
/// Example usage:
/// ```dart
/// StatBadge(
///   icon: Icons.star,
///   value: '4.5',
///   color: AppColors.warningYellow,
///   size: BadgeSize.medium,
/// )
/// ```

enum BadgeSize {
  small,
  medium,
  large,
}

class StatBadge extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Value text
  final String value;

  /// Badge color
  final Color color;

  /// Badge size
  final BadgeSize size;

  /// Optional label below the badge
  final String? label;

  /// On tap callback
  final VoidCallback? onTap;

  const StatBadge({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
    this.size = BadgeSize.medium,
    this.label,
    this.onTap,
  });

  double get _badgeSize {
    switch (size) {
      case BadgeSize.small:
        return AppDesignTokens.badgeSizeSmall;
      case BadgeSize.medium:
        return AppDesignTokens.badgeSizeMedium;
      case BadgeSize.large:
        return AppDesignTokens.badgeSizeLarge;
    }
  }

  double get _iconSize {
    switch (size) {
      case BadgeSize.small:
        return AppDesignTokens.iconSizeXS;
      case BadgeSize.medium:
        return AppDesignTokens.iconSizeSM;
      case BadgeSize.large:
        return AppDesignTokens.iconSizeMD;
    }
  }

  double get _fontSize {
    switch (size) {
      case BadgeSize.small:
        return AppDesignTokens.fontSizeTiny;
      case BadgeSize.medium:
        return AppDesignTokens.fontSizeCaption;
      case BadgeSize.large:
        return AppDesignTokens.fontSizeLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final badge = GestureDetector(
      onTap: onTap,
      child: Container(
        width: _badgeSize,
        height: _badgeSize,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: _iconSize,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );

    if (label != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          badge,
          const SizedBox(height: 6),
          Text(
            label!,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSizeCaption,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return badge;
  }
}

/// Horizontal stat badge (icon and value side by side)
class StatBadgeHorizontal extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const StatBadgeHorizontal({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(
            AppDesignTokens.borderRadiusTiny,
          ),
          border: Border.all(
            color: color.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppDesignTokens.iconSizeXS,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeCaption,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
