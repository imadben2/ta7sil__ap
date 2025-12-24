import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';

/// Reusable selection card for academic selection
class SelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final String? badge;
  final bool isEnabled;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.badge,
    required this.isEnabled,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 130,
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isEnabled ? AppColors.surface : AppColors.background),
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusCard),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isEnabled
                      ? AppColors.border
                      : AppColors.textTertiary.withOpacity(0.3)),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            if (isEnabled && !isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Padding(
            padding: const EdgeInsets.all(AppDesignTokens.spacingMD),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppDesignTokens.borderRadiusMedium,
                    ),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(width: AppDesignTokens.spacingMD),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isEnabled
                                    ? (isSelected
                                          ? AppColors.primary
                                          : AppColors.primary.withOpacity(0.2))
                                    : AppColors.textTertiary.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(
                                  AppDesignTokens.borderRadiusSmall,
                                ),
                              ),
                              child: Text(
                                badge!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : (isEnabled
                                            ? AppColors.primary
                                            : AppColors.textTertiary),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Selection indicator
                if (isSelected)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
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
