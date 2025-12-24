import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Progress bar showing quiz completion
class QuizProgressBar extends StatelessWidget {
  final int answeredCount;
  final int totalQuestions;
  final bool showLabel;

  const QuizProgressBar({
    super.key,
    required this.answeredCount,
    required this.totalQuestions,
    this.showLabel = true,
  });

  double get progress => answeredCount / totalQuestions;
  int get percentage => (progress * 100).round();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التقدم: $answeredCount من $totalQuestions',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor() {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 50) return AppColors.primary;
    if (percentage >= 25) return AppColors.warning;
    return AppColors.error;
  }
}

/// Circular progress indicator for quiz
class CircularQuizProgress extends StatelessWidget {
  final int answeredCount;
  final int totalQuestions;
  final double size;

  const CircularQuizProgress({
    super.key,
    required this.answeredCount,
    required this.totalQuestions,
    this.size = 80,
  });

  double get progress => answeredCount / totalQuestions;
  int get percentage => (progress * 100).round();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: size * 0.1,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.divider),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: size * 0.1,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
            ),
          ),
          // Center text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$answeredCount',
                style: TextStyle(
                  fontSize: size * 0.25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'من $totalQuestions',
                style: TextStyle(
                  fontSize: size * 0.12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor() {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 50) return AppColors.primary;
    if (percentage >= 25) return AppColors.warning;
    return AppColors.error;
  }
}
