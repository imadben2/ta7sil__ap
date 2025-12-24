import 'package:flutter/material.dart';
import '../../../domain/entities/true_false_question.dart';
import '../../../../../core/constants/app_colors.dart';

/// True/False question widget
class TrueFalseWidget extends StatefulWidget {
  final TrueFalseQuestion question;
  final bool? selectedAnswer;
  final Function(bool) onAnswerSelected;
  final bool isReviewMode;
  final bool? correctAnswer;

  const TrueFalseWidget({
    super.key,
    required this.question,
    this.selectedAnswer,
    required this.onAnswerSelected,
    this.isReviewMode = false,
    this.correctAnswer,
  });

  @override
  State<TrueFalseWidget> createState() => _TrueFalseWidgetState();
}

class _TrueFalseWidgetState extends State<TrueFalseWidget> {
  bool? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedAnswer;
  }

  @override
  void didUpdateWidget(TrueFalseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAnswer != oldWidget.selectedAnswer) {
      setState(() {
        _selectedValue = widget.selectedAnswer;
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
          'حدد صحة أو خطأ العبارة التالية:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildButton(true, 'صحيح')),
            const SizedBox(width: 16),
            Expanded(child: _buildButton(false, 'خطأ')),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(bool value, String label) {
    final isSelected = _selectedValue == value;

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? icon;

    if (widget.isReviewMode && widget.correctAnswer != null) {
      final isCorrect = widget.correctAnswer == value;
      final isUserAnswer = widget.selectedAnswer == value;

      if (isCorrect && isUserAnswer) {
        backgroundColor = AppColors.success;
        borderColor = AppColors.success;
        textColor = Colors.white;
        icon = Icons.check_circle_rounded;
      } else if (isCorrect) {
        backgroundColor = AppColors.warning.withOpacity(0.1);
        borderColor = AppColors.warning;
        textColor = AppColors.warning;
        icon = Icons.info_rounded;
      } else if (isUserAnswer) {
        backgroundColor = AppColors.error;
        borderColor = AppColors.error;
        textColor = Colors.white;
        icon = Icons.cancel_rounded;
      } else {
        backgroundColor = AppColors.surfaceVariant;
        borderColor = AppColors.border;
        textColor = AppColors.textSecondary;
      }
    } else {
      backgroundColor = isSelected ? AppColors.primary : Colors.white;
      borderColor = isSelected ? AppColors.primary : AppColors.border;
      textColor = isSelected ? Colors.white : AppColors.textPrimary;
    }

    return InkWell(
      onTap: widget.isReviewMode ? null : () => _handleSelect(value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 3 : 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ??
                  (value
                      ? Icons.check_circle_outline_rounded
                      : Icons.cancel_outlined),
              size: 48,
              color: textColor,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSelect(bool value) {
    setState(() {
      _selectedValue = value;
    });
    widget.onAnswerSelected(value);
  }
}
