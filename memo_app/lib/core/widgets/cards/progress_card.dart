import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_design_tokens.dart';

/// Subject or course card with progress bar
/// Based on the subject cards from home_page.dart
///
/// Example usage:
/// ```dart
/// ProgressCard(
///   icon: Icons.calculate,
///   iconColor: AppColors.mathematics,
///   title: 'Mathematics',
///   subtitle: '12 lessons',
///   progress: 0.75,
///   progressLabel: '75%',
/// )
/// ```
class ProgressCard extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Icon color (also used for progress bar)
  final Color iconColor;

  /// Card title
  final String title;

  /// Optional subtitle
  final String? subtitle;

  /// Progress value (0.0 to 1.0)
  final double progress;

  /// Optional progress label (e.g., '75%', '12/16')
  final String? progressLabel;

  /// On tap callback
  final VoidCallback? onTap;

  /// Optional trailing widget (e.g., menu button)
  final Widget? trailing;

  /// Show border
  final bool showBorder;

  /// Custom background color
  final Color? backgroundColor;

  const ProgressCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.progress,
    this.progressLabel,
    this.onTap,
    this.trailing,
    this.showBorder = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surface,
          borderRadius:
              BorderRadius.circular(AppDesignTokens.borderRadiusCard),
          border: showBorder
              ? Border.all(
                  color: AppColors.borderLight,
                  width: AppDesignTokens.borderWidthMedium,
                )
              : null,
          boxShadow: [
            AppDesignTokens.shadowMD,
          ],
        ),
        padding: AppDesignTokens.paddingCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (icon, title, trailing)
            Row(
              children: [
                // Icon container
                Container(
                  width: AppDesignTokens.iconContainerLG,
                  height: AppDesignTokens.iconContainerLG,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(
                      AppDesignTokens.borderRadiusIcon,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: AppDesignTokens.iconSizeLG,
                  ),
                ),

                const SizedBox(width: 12),

                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSizeBody,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: AppDesignTokens.fontSizeLabel,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Trailing widget
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Progress bar with label
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppDesignTokens.borderRadiusTiny,
                    ),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: iconColor.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                      minHeight: AppDesignTokens.progressBarThin,
                    ),
                  ),
                ),
                if (progressLabel != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    progressLabel!,
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSizeLabel,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact variant without subtitle and smaller padding
class ProgressCardCompact extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final double progress;
  final VoidCallback? onTap;

  const ProgressCardCompact({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(AppDesignTokens.borderRadiusCard),
          border: Border.all(
            color: AppColors.borderLight,
            width: AppDesignTokens.borderWidthMedium,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon and title
            Row(
              children: [
                Container(
                  width: AppDesignTokens.iconContainerSM,
                  height: AppDesignTokens.iconContainerSM,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(
                      AppDesignTokens.borderRadiusSmall,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: AppDesignTokens.iconSizeSM,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSizeBodySmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(
                AppDesignTokens.borderRadiusTiny,
              ),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: iconColor.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                minHeight: AppDesignTokens.progressBarThin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
