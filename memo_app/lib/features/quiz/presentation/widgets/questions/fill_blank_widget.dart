import 'package:flutter/material.dart';
import '../../../domain/entities/fill_blank_question.dart';
import '../../../../../core/constants/app_colors.dart';

/// Fill in the blank question widget
class FillBlankWidget extends StatefulWidget {
  final FillBlankQuestion question;
  final List<String>? answers;
  final Function(List<String>) onAnswersChanged;
  final bool isReviewMode;
  final List<String>? correctAnswers;

  const FillBlankWidget({
    super.key,
    required this.question,
    this.answers,
    required this.onAnswersChanged,
    this.isReviewMode = false,
    this.correctAnswers,
  });

  @override
  State<FillBlankWidget> createState() => _FillBlankWidgetState();
}

class _FillBlankWidgetState extends State<FillBlankWidget> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _controllers = List.generate(
      widget.question.blanksCount,
      (index) => TextEditingController(
        text: widget.answers != null && index < widget.answers!.length
            ? widget.answers![index]
            : '',
      ),
    );
    _focusNodes = List.generate(
      widget.question.blanksCount,
      (_) => FocusNode(),
    );

    for (var controller in _controllers) {
      controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final answers = _controllers.map((c) => c.text).toList();
    widget.onAnswersChanged(answers);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Text(
          'املأ الفراغات التالية:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(widget.question.blanksCount, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildBlankField(index),
          );
        }),
        if (widget.isReviewMode) ...[
          const SizedBox(height: 8),
          _buildHint(
            'ملاحظة: يتم تطبيع النص العربي تلقائياً (إزالة التشكيل والهمزات)',
            Icons.info_outline,
            AppColors.info,
          ),
        ],
      ],
    );
  }

  Widget _buildBlankField(int index) {
    bool? isCorrect;
    if (widget.isReviewMode && widget.correctAnswers != null) {
      final userAnswer =
          widget.answers != null && index < widget.answers!.length
          ? widget.answers![index]
          : '';
      isCorrect = widget.question.isBlankCorrect(index, userAnswer);
    }

    Color? borderColor;
    Color? fillColor;
    Widget? suffix;

    if (widget.isReviewMode && isCorrect != null) {
      if (isCorrect) {
        borderColor = AppColors.success;
        fillColor = AppColors.success.withOpacity(0.05);
        suffix = const Icon(
          Icons.check_circle,
          color: AppColors.success,
          size: 20,
        );
      } else {
        borderColor = AppColors.error;
        fillColor = AppColors.error.withOpacity(0.05);
        suffix = const Icon(Icons.cancel, color: AppColors.error, size: 20);
      }
    } else {
      borderColor = AppColors.border;
      fillColor = AppColors.surfaceVariant;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                enabled: !widget.isReviewMode,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'أدخل الإجابة هنا',
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
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                  suffixIcon: suffix,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onSubmitted: (_) {
                  if (index < _focusNodes.length - 1) {
                    _focusNodes[index + 1].requestFocus();
                  }
                },
              ),
            ),
          ],
        ),
        if (widget.isReviewMode &&
            isCorrect != null &&
            !isCorrect &&
            widget.correctAnswers != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 44),
            child: Text(
              'الإجابة الصحيحة: ${widget.correctAnswers![index]}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHint(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12, color: color)),
          ),
        ],
      ),
    );
  }
}
