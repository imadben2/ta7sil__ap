import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_design_tokens.dart';

/// General information card with optional icon, title, subtitle, and trailing
/// Versatile card for lists, settings, options, etc.
///
/// Example usage:
/// ```dart
/// InfoCard(
///   icon: Icons.quiz,
///   iconColor: AppColors.primary,
///   title: 'Chapter 1 Quiz',
///   subtitle: '10 questions · 15 min',
///   trailing: Icon(Icons.chevron_right),
///   onTap: () {},
/// )
/// ```
class InfoCard extends StatelessWidget {
  /// Optional leading icon
  final IconData? icon;

  /// Icon color
  final Color? iconColor;

  /// Card title
  final String title;

  /// Optional subtitle
  final String? subtitle;

  /// Optional trailing widget
  final Widget? trailing;

  /// On tap callback
  final VoidCallback? onTap;

  /// Show border
  final bool showBorder;

  /// Custom background color
  final Color? backgroundColor;

  /// Show icon in colored container
  final bool showIconContainer;

  /// Optional badge (top-right corner)
  final Widget? badge;

  const InfoCard({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showBorder = true,
    this.backgroundColor,
    this.showIconContainer = true,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primary;

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
        child: Stack(
          children: [
            Row(
              children: [
                // Leading icon
                if (icon != null) ...[
                  if (showIconContainer)
                    Container(
                      width: AppDesignTokens.iconContainerLG,
                      height: AppDesignTokens.iconContainerLG,
                      decoration: BoxDecoration(
                        color: effectiveIconColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(
                          AppDesignTokens.borderRadiusIcon,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: effectiveIconColor,
                        size: AppDesignTokens.iconSizeLG,
                      ),
                    )
                  else
                    Icon(
                      icon,
                      color: effectiveIconColor,
                      size: AppDesignTokens.iconSizeLG,
                    ),
                  const SizedBox(width: 12),
                ],

                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSizeBody,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: AppDesignTokens.fontSizeLabel,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Trailing widget
                if (trailing != null) ...[
                  const SizedBox(width: 12),
                  trailing!,
                ],
              ],
            ),

            // Badge (top-right)
            if (badge != null)
              Positioned(
                top: 0,
                right: 0,
                child: badge!,
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact info card with smaller padding and no shadow
class InfoCardCompact extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const InfoCardCompact({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primary;

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
            if (icon != null) ...[
              Icon(
                icon,
                color: effectiveIconColor,
                size: AppDesignTokens.iconSizeMD,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSizeBodySmall,
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
                        fontSize: AppDesignTokens.fontSizeCaption,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// List tile variant (horizontal layout, similar to Material ListTile)
class InfoCardListTile extends StatelessWidget {
  final IconData? leadingIcon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const InfoCardListTile({
    super.key,
    this.leadingIcon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primary;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (leadingIcon != null) ...[
                  Icon(
                    leadingIcon,
                    color: effectiveIconColor,
                    size: AppDesignTokens.iconSizeMD,
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSizeBody,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: AppDesignTokens.fontSizeLabel,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 12),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 56,
          ),
      ],
    );
  }
}
