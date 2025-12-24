import 'package:flutter/material.dart';
import '../../../domain/entities/single_choice_question.dart';
import '../../../../../core/constants/app_colors.dart';

/// Single choice question widget (radio buttons)
class SingleChoiceWidget extends StatefulWidget {
  final SingleChoiceQuestion question;
  final int? selectedAnswer;
  final Function(int) onAnswerSelected;
  final bool isReviewMode;
  final int? correctAnswer;

  const SingleChoiceWidget({
    super.key,
    required this.question,
    this.selectedAnswer,
    required this.onAnswerSelected,
    this.isReviewMode = false,
    this.correctAnswer,
  });

  @override
  State<SingleChoiceWidget> createState() => _SingleChoiceWidgetState();
}

class _SingleChoiceWidgetState extends State<SingleChoiceWidget> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedAnswer;
  }

  @override
  void didUpdateWidget(SingleChoiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAnswer != oldWidget.selectedAnswer) {
      setState(() {
        _selectedIndex = widget.selectedAnswer;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Text(
          'اختر الإجابة الصحيحة:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(widget.question.options.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOption(index),
          );
        }),
      ],
    );
  }

  Widget _buildOption(int index) {
    final isSelected = _selectedIndex == index;
    final option = widget.question.options[index];

    // Review mode colors
    Color? backgroundColor;
    Color? borderColor;
    Color? textColor;
    IconData? icon;

    if (widget.isReviewMode) {
      final isCorrect = widget.correctAnswer == index;
      final isUserAnswer = widget.selectedAnswer == index;

      if (isCorrect) {
        backgroundColor = AppColors.success.withOpacity(0.1);
        borderColor = AppColors.success;
        textColor = AppColors.success;
        icon = Icons.check_circle;
      } else if (isUserAnswer) {
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
      onTap: widget.isReviewMode ? null : () => _handleSelect(index),
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
            // Radio button or status icon
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isReviewMode && icon != null
                    ? Colors.transparent
                    : (isSelected ? borderColor : Colors.transparent),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: widget.isReviewMode && icon != null
                  ? Icon(icon, color: borderColor, size: 20)
                  : (isSelected
                        ? Icon(Icons.circle, color: Colors.white, size: 12)
                        : null),
            ),
            const SizedBox(width: 12),
            // Option text
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

  void _handleSelect(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onAnswerSelected(index);
  }
}
