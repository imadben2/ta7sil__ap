import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings_ar.dart';
import '../constants/app_sizes.dart';

/// Error display widget with retry action
class AppErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const AppErrorWidget({super.key, this.message, this.onRetry, this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon ?? Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSizes.paddingMD),
            Text(
              message ?? AppStringsAr.errorGeneric,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.paddingLG),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text(AppStringsAr.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline error message widget (for forms, etc.)
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry? padding;

  const InlineErrorWidget({super.key, required this.message, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMD,
            vertical: AppSizes.paddingSM,
          ),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: AppSizes.iconSM,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSizes.paddingSM),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 14, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
