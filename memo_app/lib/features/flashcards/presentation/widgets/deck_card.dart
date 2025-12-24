import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/flashcard_deck_entity.dart';

/// Card widget for displaying a flashcard deck in a list
class DeckCard extends StatelessWidget {
  final FlashcardDeckEntity deck;
  final VoidCallback? onTap;
  final VoidCallback? onStartReview;

  const DeckCard({
    super.key,
    required this.deck,
    this.onTap,
    this.onStartReview,
  });

  @override
  Widget build(BuildContext context) {
    final progress = deck.userProgress;
    final deckColor = _parseColor(deck.color);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and title
              Row(
                children: [
                  // Deck icon/color indicator
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [deckColor, deckColor.withOpacity(0.7)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                    child: Center(
                      child: Icon(
                        _getDeckIcon(deck.icon),
                        color: AppColors.textOnPrimary,
                        size: AppSizes.iconMD,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingMD),

                  // Title and subject
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deck.titleAr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (deck.subject != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            deck.subject!.nameAr,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Cards count badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingSM,
                      vertical: AppSizes.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: deckColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    ),
                    child: Text(
                      '${deck.totalCards} بطاقة',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: deckColor,
                      ),
                    ),
                  ),
                ],
              ),

              // Progress section
              if (progress != null) ...[
                const SizedBox(height: AppSizes.spacingMD),
                _buildProgressSection(progress, deckColor),
              ],

              // Due cards and review button
              const SizedBox(height: AppSizes.spacingMD),
              Row(
                children: [
                  // Stats chips
                  if (progress != null) ...[
                    _StatChip(
                      label: 'جديدة',
                      value: progress.cardsNew,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: AppSizes.spacingSM),
                    _StatChip(
                      label: 'للمراجعة',
                      value: progress.cardsDue,
                      color: AppColors.warning,
                    ),
                  ],
                  const Spacer(),

                  // Review button
                  if (onStartReview != null &&
                      (progress?.cardsDue ?? 0) > 0)
                    ElevatedButton.icon(
                      onPressed: onStartReview,
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text('ابدأ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: deckColor,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMD,
                          vertical: AppSizes.paddingSM,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusSM),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(UserDeckProgress progress, Color deckColor) {
    final percentage = progress.masteryPercentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'التقدم',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: deckColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingXS),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: deckColor.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(deckColor),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(
          int.parse(colorString.substring(1), radix: 16) + 0xFF000000,
        );
      }
    } catch (_) {}
    return AppColors.primary;
  }

  IconData _getDeckIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'math':
        return Icons.functions_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'language':
        return Icons.translate_rounded;
      case 'history':
        return Icons.history_edu_rounded;
      case 'book':
        return Icons.menu_book_rounded;
      default:
        return Icons.style_rounded;
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSM,
        vertical: AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
