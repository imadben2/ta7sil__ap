import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../domain/entities/flashcard_entity.dart';

/// Content widget for cloze (fill-in-the-blank) flashcard type
class ClozeCardContent extends StatelessWidget {
  final String template;
  final List<ClozeItem>? deletions;
  final bool showAnswers;

  const ClozeCardContent({
    super.key,
    required this.template,
    this.deletions,
    this.showAnswers = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildClozeText(),
        if (showAnswers && deletions != null && deletions!.isNotEmpty) ...[
          const SizedBox(height: AppSizes.spacingXL),
          _buildAnswersSection(),
        ],
      ],
    );
  }

  Widget _buildClozeText() {
    // Parse cloze template: "Text {{c1::answer::hint}} more text"
    final regex = RegExp(r'\{\{c(\d+)::([^:}]+)(?:::([^}]+))?\}\}');
    final parts = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in regex.allMatches(template)) {
      // Add text before the cloze
      if (match.start > lastEnd) {
        parts.add(TextSpan(
          text: template.substring(lastEnd, match.start),
          style: const TextStyle(
            color: AppColors.textOnPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w500,
            height: 1.6,
          ),
        ));
      }

      final clozeNumber = match.group(1);
      final answer = match.group(2);
      final hint = match.group(3);

      if (showAnswers) {
        // Show the answer highlighted
        parts.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            child: Text(
              answer ?? '',
              style: const TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ));
      } else {
        // Show blank with optional hint
        parts.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.overlayWhite20,
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              border: Border.all(
                color: AppColors.textOnPrimary.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '[$clozeNumber]',
                  style: TextStyle(
                    color: AppColors.textOnPrimary.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  hint ?? '______',
                  style: TextStyle(
                    color: AppColors.textOnPrimary.withOpacity(0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontStyle: hint != null ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ));
      }

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < template.length) {
      parts.add(TextSpan(
        text: template.substring(lastEnd),
        style: const TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w500,
          height: 1.6,
        ),
      ));
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: parts),
    );
  }

  Widget _buildAnswersSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.overlayWhite10,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: AppColors.textOnPrimary.withOpacity(0.8),
                size: AppSizes.iconSM,
              ),
              const SizedBox(width: AppSizes.spacingSM),
              Text(
                'الإجابات:',
                style: TextStyle(
                  color: AppColors.textOnPrimary.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSM),
          Wrap(
            spacing: AppSizes.spacingSM,
            runSpacing: AppSizes.spacingSM,
            children: (deletions ?? []).map((item) {
              return Chip(
                label: Text(item.answer),
                backgroundColor: AppColors.success.withOpacity(0.2),
                labelStyle: const TextStyle(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w500,
                ),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
