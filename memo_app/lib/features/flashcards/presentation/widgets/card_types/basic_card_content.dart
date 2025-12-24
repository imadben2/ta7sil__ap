import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

/// Content widget for basic flashcard type (text front/back)
class BasicCardContent extends StatelessWidget {
  final String text;
  final String? imageUrl;
  final bool isFront;

  const BasicCardContent({
    super.key,
    required this.text,
    this.imageUrl,
    this.isFront = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (imageUrl != null && imageUrl!.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            child: Image.network(
              imageUrl!,
              height: 180,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.overlayWhite10,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textOnPrimary,
                    size: 40,
                  ),
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.overlayWhite10,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.textOnPrimary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSizes.spacingLG),
        ],
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textOnPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
