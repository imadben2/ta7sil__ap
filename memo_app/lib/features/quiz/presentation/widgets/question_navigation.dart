import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Question navigation grid showing all questions status
class QuestionNavigation extends StatelessWidget {
  final int totalQuestions;
  final int currentQuestionIndex;
  final Set<int> answeredQuestions;
  final Set<int> flaggedQuestions;
  final Function(int) onQuestionTap;

  const QuestionNavigation({
    super.key,
    required this.totalQuestions,
    required this.currentQuestionIndex,
    required this.answeredQuestions,
    required this.flaggedQuestions,
    required this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        const Text(
          'الأسئلة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        _buildLegend(),
        const SizedBox(height: 16),
        // Questions Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: totalQuestions,
          itemBuilder: (context, index) {
            return _buildQuestionButton(index);
          },
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(
          color: AppColors.success,
          label: 'مجاب',
          icon: Icons.check_circle,
        ),
        _buildLegendItem(
          color: AppColors.primary,
          label: 'حالي',
          icon: Icons.radio_button_checked,
        ),
        _buildLegendItem(
          color: AppColors.warning,
          label: 'مميز',
          icon: Icons.flag,
        ),
        _buildLegendItem(
          color: AppColors.divider,
          label: 'بدون إجابة',
          icon: Icons.radio_button_unchecked,
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildQuestionButton(int index) {
    final questionNumber = index + 1;
    final isCurrent = index == currentQuestionIndex;
    final isAnswered = answeredQuestions.contains(questionNumber);
    final isFlagged = flaggedQuestions.contains(questionNumber);

    Color backgroundColor;
    Color textColor;
    IconData? icon;

    if (isCurrent) {
      backgroundColor = AppColors.primary;
      textColor = Colors.white;
      icon = null;
    } else if (isAnswered) {
      backgroundColor = AppColors.success.withOpacity(0.1);
      textColor = AppColors.success;
      icon = Icons.check_circle;
    } else {
      backgroundColor = AppColors.surfaceVariant;
      textColor = AppColors.textPrimary;
      icon = null;
    }

    return InkWell(
      onTap: () => onQuestionTap(index),
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrent
                    ? AppColors.primary
                    : isAnswered
                    ? AppColors.success
                    : AppColors.border,
                width: isCurrent ? 2 : 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) Icon(icon, color: textColor, size: 16),
                  Text(
                    '$questionNumber',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Flag indicator
          if (isFlagged)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.flag, color: Colors.white, size: 12),
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact question navigator for bottom sheet
class CompactQuestionNav extends StatelessWidget {
  final int totalQuestions;
  final int currentQuestionIndex;
  final Set<int> answeredQuestions;
  final VoidCallback onShowNavigation;

  const CompactQuestionNav({
    super.key,
    required this.totalQuestions,
    required this.currentQuestionIndex,
    required this.answeredQuestions,
    required this.onShowNavigation,
  });

  @override
  Widget build(BuildContext context) {
    final answeredCount = answeredQuestions.length;
    final percentage = ((answeredCount / totalQuestions) * 100).round();

    return InkWell(
      onTap: onShowNavigation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'السؤال ${currentQuestionIndex + 1} من $totalQuestions',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$answeredCount مجاب ($percentage%)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.grid_view_rounded, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }
}
