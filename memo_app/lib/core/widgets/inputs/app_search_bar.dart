import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_design_tokens.dart';

/// Styled search bar component
/// Used for searching content across the app
///
/// Example usage:
/// ```dart
/// AppSearchBar(
///   hintText: 'Search subjects...',
///   onChanged: (query) => print(query),
/// )
/// ```
class AppSearchBar extends StatelessWidget {
  /// Hint text
  final String hintText;

  /// On text changed callback
  final ValueChanged<String>? onChanged;

  /// On submit callback
  final ValueChanged<String>? onSubmitted;

  /// Text controller
  final TextEditingController? controller;

  /// Auto focus
  final bool autofocus;

  /// Show clear button
  final bool showClearButton;

  /// Custom suffix icon
  final Widget? suffixIcon;

  /// Custom prefix icon
  final Widget? prefixIcon;

  /// Background color
  final Color? backgroundColor;

  /// Border color
  final Color? borderColor;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.autofocus = false,
    this.showClearButton = true,
    this.suffixIcon,
    this.prefixIcon,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
        border: Border.all(
          color: borderColor ?? AppColors.borderLight,
          width: AppDesignTokens.borderWidthMedium,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        autofocus: autofocus,
        style: TextStyle(
          fontSize: AppDesignTokens.fontSizeBody,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.textHint,
            fontSize: AppDesignTokens.fontSizeBody,
          ),
          prefixIcon: prefixIcon ??
              Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: AppDesignTokens.iconSizeMD,
              ),
          suffixIcon: showClearButton && controller != null
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                    size: AppDesignTokens.iconSizeSM,
                  ),
                  onPressed: () {
                    controller!.clear();
                    if (onChanged != null) onChanged!('');
                  },
                )
              : suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

/// Compact search bar for dense layouts
class AppSearchBarCompact extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const AppSearchBarCompact({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: AppDesignTokens.fontSizeBodySmall,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.textHint,
            fontSize: AppDesignTokens.fontSizeBodySmall,
          ),
          prefixIcon: Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: AppDesignTokens.iconSizeSM,
              ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
      ),
    );
  }
}
