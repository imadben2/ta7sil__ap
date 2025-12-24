import 'package:flutter/material.dart';
import '../../../domain/entities/short_answer_question.dart';
import '../../../../../core/constants/app_colors.dart';

/// Short answer question widget (text area)
class ShortAnswerWidget extends StatefulWidget {
  final ShortAnswerQuestion question;
  final String? answer;
  final Function(String) onAnswerChanged;
  final bool isReviewMode;
  final String? correctAnswer;
  final bool? isCorrect;

  const ShortAnswerWidget({
    super.key,
    required this.question,
    this.answer,
    required this.onAnswerChanged,
    this.isReviewMode = false,
    this.correctAnswer,
    this.isCorrect,
  });

  @override
  State<ShortAnswerWidget> createState() => _ShortAnswerWidgetState();
}

class _ShortAnswerWidgetState extends State<ShortAnswerWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.answer ?? '');
    _focusNode = FocusNode();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onAnswerChanged(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    Color? borderColor;
    Color? fillColor;
    Widget? statusIndicator;

    if (widget.isReviewMode && widget.isCorrect != null) {
      if (widget.isCorrect!) {
        borderColor = AppColors.success;
        fillColor = AppColors.success.withOpacity(0.05);
        statusIndicator = _buildStatusBadge(
          'إجابة صحيحة',
          Icons.check_circle,
          AppColors.success,
        );
      } else {
        borderColor = AppColors.warning;
        fillColor = AppColors.warning.withOpacity(0.05);
        statusIndicator = _buildStatusBadge(
          'يحتاج مراجعة يدوية',
          Icons.info,
          AppColors.warning,
        );
      }
    } else {
      borderColor = AppColors.border;
      fillColor = AppColors.surfaceVariant;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Text(
          'أجب عن السؤال التالي بإجابة مختصرة:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: !widget.isReviewMode,
          maxLines: 5,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'اكتب إجابتك هنا...',
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor!, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        if (!widget.isReviewMode) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.text_fields_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${_controller.text.length} حرف',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                'الحد الأدنى: ${widget.question.minCharacters} حرف',
                style: TextStyle(
                  fontSize: 12,
                  color: _controller.text.length < widget.question.minCharacters
                      ? AppColors.warning
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
        if (statusIndicator != null) ...[
          const SizedBox(height: 12),
          statusIndicator,
        ],
        if (widget.isReviewMode && widget.correctAnswer != null) ...[
          const SizedBox(height: 12),
          _buildCorrectAnswer(),
        ],
      ],
    );
  }

  Widget _buildStatusBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrectAnswer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.key_rounded, color: AppColors.success, size: 18),
              SizedBox(width: 8),
              Text(
                'الكلمات المفتاحية المطلوبة:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.correctAnswer!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
