import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_design_tokens.dart';

/// Coefficient badge for subject coefficients
/// Used in subject cards and academic info
///
/// Example usage:
/// ```dart
/// CoefficientBadge(
///   coefficient: 7,
///   color: AppColors.warningYellow,
/// )
/// ```
class CoefficientBadge extends StatelessWidget {
  /// Coefficient value
  final int coefficient;

  /// Badge color (defaults to warning yellow)
  final Color? color;

  /// Show label "Coef."
  final bool showLabel;

  /// On tap callback
  final VoidCallback? onTap;

  /// Badge style
  final CoefficientBadgeStyle style;

  const CoefficientBadge({
    super.key,
    required this.coefficient,
    this.color,
    this.showLabel = true,
    this.onTap,
    this.style = CoefficientBadgeStyle.filled,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.warningYellow;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: _getDecoration(effectiveColor),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLabel) ...[
              Text(
                'Coef.',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSizeCaption,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(effectiveColor),
                ),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              coefficient.toString(),
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeLabel,
                fontWeight: FontWeight.bold,
                color: _getTextColor(effectiveColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _getDecoration(Color color) {
    switch (style) {
      case CoefficientBadgeStyle.filled:
        return BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(
            AppDesignTokens.borderRadiusTiny,
          ),
        );
      case CoefficientBadgeStyle.outlined:
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
      case CoefficientBadgeStyle.solid:
        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(
            AppDesignTokens.borderRadiusTiny,
          ),
        );
    }
  }

  Color _getTextColor(Color color) {
    switch (style) {
      case CoefficientBadgeStyle.filled:
      case CoefficientBadgeStyle.outlined:
        return color;
      case CoefficientBadgeStyle.solid:
        return Colors.white;
    }
  }
}

enum CoefficientBadgeStyle {
  filled,
  outlined,
  solid,
}

/// Compact coefficient badge (just the number in a circle)
class CoefficientBadgeCompact extends StatelessWidget {
  final int coefficient;
  final Color? color;
  final VoidCallback? onTap;

  const CoefficientBadgeCompact({
    super.key,
    required this.coefficient,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.warningYellow;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppDesignTokens.badgeSizeSmall,
        height: AppDesignTokens.badgeSizeSmall,
        decoration: BoxDecoration(
          color: effectiveColor.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: effectiveColor.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            coefficient.toString(),
            style: TextStyle(
              fontSize: AppDesignTokens.fontSizeTiny,
              fontWeight: FontWeight.bold,
              color: effectiveColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Grade badge (for displaying student grades)
class GradeBadge extends StatelessWidget {
  final double grade;
  final double maxGrade;
  final Color? color;
  final VoidCallback? onTap;

  const GradeBadge({
    super.key,
    required this.grade,
    this.maxGrade = 20.0,
    this.color,
    this.onTap,
  });

  Color get _badgeColor {
    if (color != null) return color!;

    final percentage = grade / maxGrade;
    if (percentage >= 0.75) return AppColors.successGreen;
    if (percentage >= 0.50) return AppColors.warningYellow;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _badgeColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(
            AppDesignTokens.borderRadiusTiny,
          ),
          border: Border.all(
            color: _badgeColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              grade.toStringAsFixed(1),
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeBody,
                fontWeight: FontWeight.bold,
                color: _badgeColor,
              ),
            ),
            Text(
              ' / ${maxGrade.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeLabel,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
