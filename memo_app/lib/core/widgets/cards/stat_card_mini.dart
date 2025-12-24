import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_design_tokens.dart';

/// Small stat display card with icon, value, and label
/// Based on the fire/study time/coefficient cards from home_page.dart
///
/// Example usage:
/// ```dart
/// StatCardMini(
///   icon: Icons.local_fire_department,
///   iconColor: AppColors.fireRed,
///   value: '7',
///   label: 'Day Streak',
///   backgroundColor: AppColors.fireRed.withOpacity(0.08),
///   borderColor: AppColors.fireRed.withOpacity(0.15),
/// )
/// ```
class StatCardMini extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Icon color
  final Color iconColor;

  /// Main value to display (large text)
  final String value;

  /// Label text below the value
  final String label;

  /// Background color (typically color with 8% opacity)
  final Color? backgroundColor;

  /// Border color (typically color with 15% opacity)
  final Color? borderColor;

  /// Optional suffix for the value (e.g., 'h', 'pts')
  final String? valueSuffix;

  /// On tap callback
  final VoidCallback? onTap;

  /// Custom height
  final double? height;

  /// Show icon in a container with background
  final bool showIconContainer;

  const StatCardMini({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.backgroundColor,
    this.borderColor,
    this.valueSuffix,
    this.onTap,
    this.height,
    this.showIconContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        backgroundColor ?? iconColor.withOpacity(0.08);
    final effectiveBorderColor = borderColor ?? iconColor.withOpacity(0.15);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? AppDesignTokens.miniStatCardHeight,
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius:
              BorderRadius.circular(AppDesignTokens.borderRadiusCard),
          border: Border.all(
            color: effectiveBorderColor,
            width: AppDesignTokens.borderWidthThin,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            if (showIconContainer)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(
                    AppDesignTokens.borderRadiusSmall,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 16,
                ),
              )
            else
              Icon(
                icon,
                color: iconColor,
                size: AppDesignTokens.iconSizeMD,
              ),

            // Value and label
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (valueSuffix != null) ...[
                        const SizedBox(width: 2),
                        Text(
                          valueSuffix!,
                          style: TextStyle(
                            fontSize: AppDesignTokens.fontSizeBodySmall,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal variant of StatCardMini (icon and text side by side)
class StatCardMiniHorizontal extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color? backgroundColor;
  final Color? borderColor;
  final String? valueSuffix;
  final VoidCallback? onTap;

  const StatCardMiniHorizontal({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.backgroundColor,
    this.borderColor,
    this.valueSuffix,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        backgroundColor ?? iconColor.withOpacity(0.08);
    final effectiveBorderColor = borderColor ?? iconColor.withOpacity(0.15);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius:
              BorderRadius.circular(AppDesignTokens.borderRadiusCard),
          border: Border.all(
            color: effectiveBorderColor,
            width: AppDesignTokens.borderWidthThin,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon
            Container(
              width: AppDesignTokens.iconContainerMD,
              height: AppDesignTokens.iconContainerMD,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(
                  AppDesignTokens.borderRadiusSmall,
                ),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: AppDesignTokens.iconSizeMD,
              ),
            ),

            const SizedBox(width: 12),

            // Value and label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSizeTitle,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (valueSuffix != null) ...[
                        const SizedBox(width: 2),
                        Text(
                          valueSuffix!,
                          style: TextStyle(
                            fontSize: AppDesignTokens.fontSizeBodySmall,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSizeLabel,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
