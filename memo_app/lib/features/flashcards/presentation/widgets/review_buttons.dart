import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// Simple correct/wrong buttons for flashcard review
class ReviewButtons extends StatelessWidget {
  final VoidCallback onCorrect;
  final VoidCallback onWrong;
  final bool enabled;

  const ReviewButtons({
    super.key,
    required this.onCorrect,
    required this.onWrong,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Instruction text
        Text(
          'كيف كان جوابك؟',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSizes.spacingMD),

        // Buttons row - just Correct and Wrong
        Row(
          children: [
            // Wrong button
            Expanded(
              child: _ReviewButton(
                label: 'خاطئة',
                color: AppColors.error,
                icon: Icons.close_rounded,
                onPressed: enabled ? onWrong : null,
              ),
            ),
            const SizedBox(width: AppSizes.spacingLG),
            // Correct button
            Expanded(
              child: _ReviewButton(
                label: 'صحيحة',
                color: AppColors.success,
                icon: Icons.check_rounded,
                onPressed: enabled ? onCorrect : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback? onPressed;

  const _ReviewButton({
    required this.label,
    required this.color,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.paddingLG,
              horizontal: AppSizes.paddingMD,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: AppSizes.iconXL,
                ),
                const SizedBox(height: AppSizes.spacingSM),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact version for smaller screens
class ReviewButtonsCompact extends StatelessWidget {
  final VoidCallback onCorrect;
  final VoidCallback onWrong;
  final bool enabled;

  const ReviewButtonsCompact({
    super.key,
    required this.onCorrect,
    required this.onWrong,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CompactButton(
          icon: Icons.close_rounded,
          color: AppColors.error,
          onPressed: enabled ? onWrong : null,
        ),
        _CompactButton(
          icon: Icons.check_rounded,
          color: AppColors.success,
          onPressed: enabled ? onCorrect : null,
        ),
      ],
    );
  }
}

class _CompactButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _CompactButton({
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: color,
      iconSize: AppSizes.iconXL,
      style: IconButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        padding: const EdgeInsets.all(AppSizes.paddingLG),
      ),
    );
  }
}
