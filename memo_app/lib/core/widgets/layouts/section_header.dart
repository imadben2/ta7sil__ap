import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_design_tokens.dart';

/// Section header with title and optional "View All" button
/// Used to separate content sections in pages
///
/// Example usage:
/// ```dart
/// SectionHeader(
///   title: 'Today\'s Sessions',
///   onViewAll: () => Navigator.push(...),
/// )
/// ```
class SectionHeader extends StatelessWidget {
  /// Section title
  final String title;

  /// Optional subtitle
  final String? subtitle;

  /// "View All" button callback (if null, button is hidden)
  final VoidCallback? onViewAll;

  /// Custom "View All" text
  final String? viewAllText;

  /// Optional leading icon
  final IconData? icon;

  /// Icon color
  final Color? iconColor;

  /// Title style override
  final TextStyle? titleStyle;

  /// Optional trailing widget (instead of View All button)
  final Widget? trailing;

  /// Padding around the header
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onViewAll,
    this.viewAllText,
    this.icon,
    this.iconColor,
    this.titleStyle,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppDesignTokens.screenPaddingHorizontal,
            vertical: AppDesignTokens.spacingMD,
          ),
      child: Row(
        children: [
          // Leading icon
          if (icon != null) ...[
            Icon(
              icon,
              size: AppDesignTokens.iconSizeMD,
              color: iconColor ?? AppColors.primary,
            ),
            const SizedBox(width: 10),
          ],

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: titleStyle ??
                      TextStyle(
                        fontSize: AppDesignTokens.fontSizeTitle,
                        fontWeight: FontWeight.bold,
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

          // Trailing (View All button or custom widget)
          if (trailing != null)
            trailing!
          else if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    viewAllText ?? 'View All',
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSizeBodySmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: AppDesignTokens.iconSizeXS,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact section header (smaller padding, single line)
class SectionHeaderCompact extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  final String? viewAllText;

  const SectionHeaderCompact({
    super.key,
    required this.title,
    this.onViewAll,
    this.viewAllText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesignTokens.screenPaddingHorizontal,
        vertical: AppDesignTokens.spacingSM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSizeBody,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                viewAllText ?? 'View All',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSizeBodySmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Section divider with optional title
class SectionDivider extends StatelessWidget {
  final String? title;
  final Color? color;
  final double? thickness;
  final EdgeInsetsGeometry? padding;

  const SectionDivider({
    super.key,
    this.title,
    this.color,
    this.thickness,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (title == null) {
      return Padding(
        padding: padding ??
            const EdgeInsets.symmetric(
              vertical: AppDesignTokens.spacingLG,
            ),
        child: Divider(
          color: color ?? AppColors.divider,
          thickness: thickness ?? 1,
        ),
      );
    }

    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppDesignTokens.screenPaddingHorizontal,
            vertical: AppDesignTokens.spacingLG,
          ),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: color ?? AppColors.divider,
              thickness: thickness ?? 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title!,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeLabel,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: color ?? AppColors.divider,
              thickness: thickness ?? 1,
            ),
          ),
        ],
      ),
    );
  }
}
