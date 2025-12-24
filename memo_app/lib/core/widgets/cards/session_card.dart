import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_design_tokens.dart';
import '../../utils/gradient_helper.dart';

/// Study session card with time, subject, and gradient icon
/// Based on the "Today's Sessions" cards from home_page.dart
///
/// Example usage:
/// ```dart
/// SessionCard(
///   subjectIcon: Icons.calculate,
///   subjectGradient: GradientHelper.math,
///   subjectName: 'Mathematics',
///   sessionTitle: 'Algebra - Functions',
///   time: '10:00 - 11:30',
///   duration: '1h 30m',
/// )
/// ```
class SessionCard extends StatelessWidget {
  /// Subject icon
  final IconData subjectIcon;

  /// Gradient for the icon container
  final LinearGradient subjectGradient;

  /// Subject name
  final String subjectName;

  /// Session title/topic
  final String sessionTitle;

  /// Time string (e.g., '10:00 - 11:30')
  final String time;

  /// Optional duration string (e.g., '1h 30m')
  final String? duration;

  /// On tap callback
  final VoidCallback? onTap;

  /// Optional status indicator (e.g., 'Completed', 'In Progress')
  final String? status;

  /// Status color
  final Color? statusColor;

  /// Show border
  final bool showBorder;

  const SessionCard({
    super.key,
    required this.subjectIcon,
    required this.subjectGradient,
    required this.subjectName,
    required this.sessionTitle,
    required this.time,
    this.duration,
    this.onTap,
    this.status,
    this.statusColor,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(AppDesignTokens.borderRadiusMedium),
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
        child: Row(
          children: [
            // Gradient icon container
            Container(
              width: AppDesignTokens.iconContainerXL,
              height: AppDesignTokens.iconContainerXL,
              decoration: BoxDecoration(
                gradient: subjectGradient,
                borderRadius: BorderRadius.circular(
                  AppDesignTokens.borderRadiusIcon,
                ),
              ),
              child: Icon(
                subjectIcon,
                color: Colors.white,
                size: AppDesignTokens.iconSizeLG,
              ),
            ),

            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject name
                  Text(
                    subjectName,
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSizeLabel,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Session title
                  Text(
                    sessionTitle,
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSizeBody,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Time and duration
                  Row(
                    children: [
                      // Time badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(
                            AppDesignTokens.borderRadiusTiny,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: AppDesignTokens.iconSizeXS,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: AppDesignTokens.fontSizeCaption,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (duration != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          duration!,
                          style: TextStyle(
                            fontSize: AppDesignTokens.fontSizeCaption,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],

                      if (status != null) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: (statusColor ?? AppColors.success)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(
                              AppDesignTokens.borderRadiusTiny,
                            ),
                          ),
                          child: Text(
                            status!,
                            style: TextStyle(
                              fontSize: AppDesignTokens.fontSizeTiny,
                              fontWeight: FontWeight.w600,
                              color: statusColor ?? AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ],
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

/// Compact session card for dense lists
class SessionCardCompact extends StatelessWidget {
  final IconData subjectIcon;
  final Color subjectColor;
  final String subjectName;
  final String time;
  final VoidCallback? onTap;

  const SessionCardCompact({
    super.key,
    required this.subjectIcon,
    required this.subjectColor,
    required this.subjectName,
    required this.time,
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
              BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          border: Border.all(
            color: AppColors.borderLight,
            width: AppDesignTokens.borderWidthThin,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon
            Container(
              width: AppDesignTokens.iconContainerMD,
              height: AppDesignTokens.iconContainerMD,
              decoration: BoxDecoration(
                color: subjectColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(
                  AppDesignTokens.borderRadiusSmall,
                ),
              ),
              child: Icon(
                subjectIcon,
                color: subjectColor,
                size: AppDesignTokens.iconSizeMD,
              ),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subjectName,
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSizeBodySmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSizeCaption,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              size: AppDesignTokens.iconSizeMD,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
