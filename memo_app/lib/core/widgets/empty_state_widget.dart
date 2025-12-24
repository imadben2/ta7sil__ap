import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings_ar.dart';
import '../constants/app_sizes.dart';

/// Empty state widget with optional action
class EmptyStateWidget extends StatelessWidget {
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? icon;
  final Widget? illustration;

  const EmptyStateWidget({
    super.key,
    this.message,
    this.actionText,
    this.onAction,
    this.icon,
    this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null)
              illustration!
            else
              Icon(
                icon ?? Icons.inbox_outlined,
                size: 80,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
            const SizedBox(height: AppSizes.paddingLG),
            Text(
              message ?? AppStringsAr.noData,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: AppSizes.paddingLG),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                ),
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
