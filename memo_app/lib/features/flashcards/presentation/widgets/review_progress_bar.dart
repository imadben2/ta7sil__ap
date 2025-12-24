import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// Progress bar widget for flashcard review sessions
class ReviewProgressBar extends StatelessWidget {
  final int currentCard;
  final int totalCards;
  final int correctCount;
  final int incorrectCount;
  final Duration? elapsedTime;

  const ReviewProgressBar({
    super.key,
    required this.currentCard,
    required this.totalCards,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.elapsedTime,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCards > 0 ? (currentCard / totalCards) : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Card counter
            Text(
              '$currentCard / $totalCards',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            // Score display
            Row(
              children: [
                _ScoreChip(
                  icon: Icons.check_circle_rounded,
                  value: correctCount,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppSizes.spacingSM),
                _ScoreChip(
                  icon: Icons.cancel_rounded,
                  value: incorrectCount,
                  color: AppColors.error,
                ),
              ],
            ),

            // Timer
            if (elapsedTime != null)
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(elapsedTime!),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),

        const SizedBox(height: AppSizes.spacingSM),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _ScoreChip extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;

  const _ScoreChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 2),
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Circular progress indicator for review completion
class ReviewProgressCircle extends StatelessWidget {
  final double percentage;
  final int correctCount;
  final int totalCards;
  final double size;

  const ReviewProgressCircle({
    super.key,
    required this.percentage,
    required this.correctCount,
    required this.totalCards,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = totalCards > 0 ? (correctCount / totalCards) * 100 : 0.0;
    final color = _getColorForAccuracy(accuracy);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background circle
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 8,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.divider,
            ),
          ),
          // Progress circle
          CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: 8,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeCap: StrokeCap.round,
          ),
          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: size * 0.25,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  '$correctCount/$totalCards',
                  style: TextStyle(
                    fontSize: size * 0.12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForAccuracy(double accuracy) {
    if (accuracy >= 80) return AppColors.success;
    if (accuracy >= 60) return AppColors.primary;
    if (accuracy >= 40) return AppColors.warning;
    return AppColors.error;
  }
}
