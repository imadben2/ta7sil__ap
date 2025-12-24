import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

/// Content widget for audio-based flashcard type
/// Note: For full audio playback, integrate with just_audio package
class AudioCardContent extends StatelessWidget {
  final String audioUrl;
  final String? text;
  final bool autoPlay;

  const AudioCardContent({
    super.key,
    required this.audioUrl,
    this.text,
    this.autoPlay = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Audio visualization placeholder
        Container(
          width: 140,
          height: 140,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.overlayWhite20,
          ),
          child: const Center(
            child: Icon(
              Icons.audiotrack_rounded,
              color: AppColors.textOnPrimary,
              size: 64,
            ),
          ),
        ),

        const SizedBox(height: AppSizes.spacingLG),

        // Audio URL info
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          decoration: BoxDecoration(
            color: AppColors.overlayWhite10,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.music_note_rounded,
                color: AppColors.textOnPrimary,
                size: AppSizes.iconSM,
              ),
              const SizedBox(width: AppSizes.spacingSM),
              Text(
                'ملف صوتي',
                style: TextStyle(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Text content if available
        if (text != null && text!.isNotEmpty) ...[
          const SizedBox(height: AppSizes.spacingXL),
          Text(
            text!,
            style: const TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
