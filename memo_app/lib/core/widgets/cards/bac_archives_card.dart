import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_design_tokens.dart';
import '../../utils/gradient_helper.dart';

/// BAC Archives card with gradient background and year/stats
/// Based on the BAC archives card from home_page.dart
///
/// Example usage:
/// ```dart
/// BacArchivesCard(
///   year: '2024',
///   title: 'BAC 2024',
///   subtitle: 'All streams & subjects',
///   stats: '125 Exams',
///   gradient: GradientHelper.primary,
///   icon: Icons.archive,
/// )
/// ```
class BacArchivesCard extends StatelessWidget {
  /// Year or identifier
  final String year;

  /// Card title
  final String title;

  /// Optional subtitle
  final String? subtitle;

  /// Stats text (e.g., '125 Exams', '12 Subjects')
  final String? stats;

  /// Gradient for background
  final LinearGradient? gradient;

  /// Optional icon
  final IconData? icon;

  /// On tap callback
  final VoidCallback? onTap;

  /// Custom height
  final double? height;

  const BacArchivesCard({
    super.key,
    required this.year,
    required this.title,
    this.subtitle,
    this.stats,
    this.gradient,
    this.icon,
    this.onTap,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? GradientHelper.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 140,
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius:
              BorderRadius.circular(AppDesignTokens.borderRadiusCard),
          boxShadow: [
            AppDesignTokens.shadowPrimaryLight,
          ],
        ),
        padding: AppDesignTokens.paddingCard,
        child: Stack(
          children: [
            // Decorative circles (optional)
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.overlayWhite10,
                ),
              ),
            ),

            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header with icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Year badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.overlayWhite20,
                        borderRadius: BorderRadius.circular(
                          AppDesignTokens.borderRadiusTiny,
                        ),
                      ),
                      child: Text(
                        year,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Icon container
                    if (icon != null)
                      Container(
                        width: AppDesignTokens.iconContainerXL,
                        height: AppDesignTokens.iconContainerXL,
                        decoration: BoxDecoration(
                          color: AppColors.overlayWhite20,
                          borderRadius: BorderRadius.circular(
                            AppDesignTokens.borderRadiusIcon,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: AppDesignTokens.iconSizeLG,
                        ),
                      ),
                  ],
                ),

                // Title, subtitle, stats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSizeBodySmall,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                    if (stats != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: AppDesignTokens.iconSizeXS,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stats!,
                            style: TextStyle(
                              fontSize: AppDesignTokens.fontSizeLabel,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact BAC card for grid layouts
class BacArchivesCardCompact extends StatelessWidget {
  final String year;
  final String title;
  final String? stats;
  final LinearGradient? gradient;
  final VoidCallback? onTap;

  const BacArchivesCardCompact({
    super.key,
    required this.year,
    required this.title,
    this.stats,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? GradientHelper.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius:
              BorderRadius.circular(AppDesignTokens.borderRadiusCard),
          boxShadow: [
            AppDesignTokens.shadowPrimarySubtle,
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Year badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.overlayWhite20,
                borderRadius: BorderRadius.circular(
                  AppDesignTokens.borderRadiusTiny,
                ),
              ),
              child: Text(
                year,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // Title and stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (stats != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    stats!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.85),
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

/// Horizontal BAC card for list layouts
class BacArchivesCardHorizontal extends StatelessWidget {
  final String year;
  final String title;
  final String? subtitle;
  final String? stats;
  final IconData? icon;
  final LinearGradient? gradient;
  final VoidCallback? onTap;

  const BacArchivesCardHorizontal({
    super.key,
    required this.year,
    required this.title,
    this.subtitle,
    this.stats,
    this.icon,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? GradientHelper.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius:
              BorderRadius.circular(AppDesignTokens.borderRadiusCard),
          boxShadow: [
            AppDesignTokens.shadowPrimaryLight,
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon container
            if (icon != null) ...[
              Container(
                width: AppDesignTokens.iconContainerLG,
                height: AppDesignTokens.iconContainerLG,
                decoration: BoxDecoration(
                  color: AppColors.overlayWhite20,
                  borderRadius: BorderRadius.circular(
                    AppDesignTokens.borderRadiusIcon,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: AppDesignTokens.iconSizeLG,
                ),
              ),
              const SizedBox(width: 14),
            ],

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.overlayWhite20,
                          borderRadius: BorderRadius.circular(
                            AppDesignTokens.borderRadiusTiny,
                          ),
                        ),
                        child: Text(
                          year,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (stats != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          stats!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: AppDesignTokens.iconSizeSM,
              color: Colors.white.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }
}
