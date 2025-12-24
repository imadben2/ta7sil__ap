import 'package:flutter/material.dart';
import '../../../domain/entities/multiple_choice_question.dart';
import '../../../../../core/constants/app_colors.dart';

/// Multiple choice question widget (checkboxes with partial credit)
class MultipleChoiceWidget extends StatefulWidget {
  final MultipleChoiceQuestion question;
  final List<int>? selectedAnswers;
  final Function(List<int>) onAnswersSelected;
  final bool isReviewMode;
  final List<int>? correctAnswers;

  const MultipleChoiceWidget({
    super.key,
    required this.question,
    this.selectedAnswers,
    required this.onAnswersSelected,
    this.isReviewMode = false,
    this.correctAnswers,
  });

  @override
  State<MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    _selectedIndices = widget.selectedAnswers?.toSet() ?? {};
  }

  @override
  void didUpdateWidget(MultipleChoiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAnswers != oldWidget.selectedAnswers) {
      setState(() {
        _selectedIndices = widget.selectedAnswers?.toSet() ?? {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(
              child: Text(
                'اختر جميع الإجابات الصحيحة:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (!widget.isReviewMode)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 14, color: AppColors.info),
                    const SizedBox(width: 4),
                    Text(
                      'متعدد الاختيار',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(widget.question.options.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOption(index),
          );
        }),
        if (widget.isReviewMode && widget.correctAnswers != null) ...[
          const SizedBox(height: 16),
          _buildPartialCreditInfo(),
        ],
      ],
    );
  }

  Widget _buildOption(int index) {
    final isSelected = _selectedIndices.contains(index);
    final option = widget.question.options[index];

    Color? backgroundColor;
    Color? borderColor;
    Color? textColor;
    IconData? icon;

    if (widget.isReviewMode && widget.correctAnswers != null) {
      final isCorrect = widget.correctAnswers!.contains(index);
      final isUserAnswer = widget.selectedAnswers?.contains(index) ?? false;

      if (isCorrect && isUserAnswer) {
        backgroundColor = AppColors.success.withOpacity(0.1);
        borderColor = AppColors.success;
        textColor = AppColors.success;
        icon = Icons.check_circle;
      } else if (isCorrect && !isUserAnswer) {
        backgroundColor = AppColors.warning.withOpacity(0.1);
        borderColor = AppColors.warning;
        textColor = AppColors.warning;
        icon = Icons.info;
      } else if (!isCorrect && isUserAnswer) {
        backgroundColor = AppColors.error.withOpacity(0.1);
        borderColor = AppColors.error;
        textColor = AppColors.error;
        icon = Icons.cancel;
      } else {
        backgroundColor = AppColors.surfaceVariant;
        borderColor = AppColors.border;
        textColor = AppColors.textSecondary;
      }
    } else {
      backgroundColor = isSelected
          ? AppColors.primary.withOpacity(0.1)
          : AppColors.surfaceVariant;
      borderColor = isSelected ? AppColors.primary : AppColors.border;
      textColor = isSelected ? AppColors.primary : AppColors.textPrimary;
    }

    return InkWell(
      onTap: widget.isReviewMode ? null : () => _handleToggle(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor!, width: isSelected ? 2 : 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: widget.isReviewMode && icon != null
                    ? Colors.transparent
                    : (isSelected ? borderColor : Colors.transparent),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: widget.isReviewMode && icon != null
                  ? Icon(icon, color: borderColor, size: 20)
                  : (isSelected
                        ? Icon(Icons.check, color: Colors.white, size: 16)
                        : null),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: textColor,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartialCreditInfo() {
    final pointsEarned = widget.question.calculatePointsEarned(
      widget.selectedAnswers ?? [],
    );
    final percentage = (pointsEarned / widget.question.points * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.calculate_rounded, color: AppColors.info, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'علامة جزئية',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'حصلت على ${pointsEarned.toStringAsFixed(1)} من ${widget.question.points} ($percentage%)',
                  style: const TextStyle(
                    fontSize: 12,
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

  void _handleToggle(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
    widget.onAnswersSelected(_selectedIndices.toList());
  }
}
