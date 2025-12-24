import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/entities/numeric_question.dart';
import '../../../../../core/constants/app_colors.dart';

/// Numeric question widget
class NumericWidget extends StatefulWidget {
  final NumericQuestion question;
  final double? answer;
  final Function(double) onAnswerChanged;
  final bool isReviewMode;
  final double? correctAnswer;

  const NumericWidget({
    super.key,
    required this.question,
    this.answer,
    required this.onAnswerChanged,
    this.isReviewMode = false,
    this.correctAnswer,
  });

  @override
  State<NumericWidget> createState() => _NumericWidgetState();
}

class _NumericWidgetState extends State<NumericWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.answer != null ? widget.answer.toString() : '',
    );
    _focusNode = FocusNode();
    _controller.addListener(_onTextChanged);

    if (widget.isReviewMode &&
        widget.answer != null &&
        widget.correctAnswer != null) {
      _isCorrect = widget.question.isAnswerCorrect(widget.answer!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final value = double.tryParse(text);
    if (value != null) {
      widget.onAnswerChanged(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color? borderColor;
    Color? fillColor;
    Widget? statusIndicator;

    if (widget.isReviewMode && _isCorrect != null) {
      if (_isCorrect!) {
        borderColor = AppColors.success;
        fillColor = AppColors.success.withOpacity(0.05);
        statusIndicator = _buildStatusBadge(
          'إجابة صحيحة',
          Icons.check_circle,
          AppColors.success,
        );
      } else {
        borderColor = AppColors.error;
        fillColor = AppColors.error.withOpacity(0.05);
        statusIndicator = _buildStatusBadge(
          'إجابة خاطئة',
          Icons.cancel,
          AppColors.error,
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
          'أدخل الإجابة الرقمية:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !widget.isReviewMode,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: '0',
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                ),
              ),
            ),
            if (widget.question.unit != null &&
                widget.question.unit!.isNotEmpty) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(
                  widget.question.unit!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (widget.question.tolerance > 0) ...[
          const SizedBox(height: 12),
          _buildToleranceInfo(),
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

  Widget _buildToleranceInfo() {
    final tolerancePercent = (widget.question.tolerance * 100).toStringAsFixed(
      1,
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'هامش الخطأ المسموح: ±$tolerancePercent%',
              style: const TextStyle(fontSize: 12, color: AppColors.info),
            ),
          ),
        ],
      ),
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
    final range = widget.question.acceptableRange;
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
              Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'الإجابة الصحيحة:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${widget.correctAnswer} ${widget.question.unit}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (widget.question.tolerance > 0) ...[
            const SizedBox(height: 8),
            Text(
              'النطاق المقبول: ${range.min.toStringAsFixed(2)} - ${range.max.toStringAsFixed(2)}${widget.question.unit != null ? " ${widget.question.unit}" : ""}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
