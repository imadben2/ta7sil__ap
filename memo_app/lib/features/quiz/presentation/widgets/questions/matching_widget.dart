import 'package:flutter/material.dart';
import '../../../domain/entities/matching_question.dart';
import '../../../../../core/constants/app_colors.dart';

/// Matching question widget (simplified tap-to-match interface)
class MatchingWidget extends StatefulWidget {
  final MatchingQuestion question;
  final Map<String, String>? pairs;
  final Function(Map<String, String>) onPairsChanged;
  final bool isReviewMode;
  final Map<String, String>? correctPairs;

  const MatchingWidget({
    super.key,
    required this.question,
    this.pairs,
    required this.onPairsChanged,
    this.isReviewMode = false,
    this.correctPairs,
  });

  @override
  State<MatchingWidget> createState() => _MatchingWidgetState();
}

class _MatchingWidgetState extends State<MatchingWidget> {
  Map<String, String> _selectedPairs = {};
  String? _selectedLeftItem;

  @override
  void initState() {
    super.initState();
    _selectedPairs = Map.from(widget.pairs ?? {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Text(
          'طابق العناصر التالية:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (!widget.isReviewMode) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.touch_app_rounded, color: AppColors.info, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'انقر على عنصر من اليمين ثم عنصر من اليسار للمطابقة',
                    style: TextStyle(fontSize: 12, color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.question.leftColumn.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildLeftItem(item),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.question.rightColumn.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildRightItem(item),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeftItem(String item) {
    final isSelected = _selectedLeftItem == item;
    final pairedRight = _selectedPairs[item];

    Color backgroundColor;
    Color borderColor;

    if (widget.isReviewMode && widget.correctPairs != null) {
      final isCorrect = widget.correctPairs![item] == pairedRight;
      backgroundColor = isCorrect
          ? AppColors.success.withOpacity(0.1)
          : AppColors.error.withOpacity(0.1);
      borderColor = isCorrect ? AppColors.success : AppColors.error;
    } else {
      backgroundColor = isSelected
          ? AppColors.primary.withOpacity(0.2)
          : (pairedRight != null
                ? AppColors.success.withOpacity(0.1)
                : AppColors.surfaceVariant);
      borderColor = isSelected
          ? AppColors.primary
          : (pairedRight != null ? AppColors.success : AppColors.border);
    }

    return InkWell(
      onTap: widget.isReviewMode ? null : () => _selectLeftItem(item),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (pairedRight != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      pairedRight,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRightItem(String item) {
    final isPaired = _selectedPairs.values.contains(item);

    Color backgroundColor;
    Color borderColor;

    if (widget.isReviewMode) {
      backgroundColor = AppColors.surfaceVariant;
      borderColor = AppColors.border;
    } else {
      backgroundColor = isPaired ? AppColors.divider : AppColors.surfaceVariant;
      borderColor = isPaired ? AppColors.textHint : AppColors.border;
    }

    return InkWell(
      onTap: widget.isReviewMode || _selectedLeftItem == null
          ? null
          : () => _selectRightItem(item),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Text(
          item,
          style: TextStyle(
            fontSize: 14,
            color: isPaired && !widget.isReviewMode
                ? AppColors.textHint
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  void _selectLeftItem(String item) {
    setState(() {
      if (_selectedLeftItem == item) {
        _selectedLeftItem = null;
      } else {
        _selectedLeftItem = item;
      }
    });
  }

  void _selectRightItem(String item) {
    if (_selectedLeftItem == null) return;

    setState(() {
      // Remove old pairing
      _selectedPairs.removeWhere((key, value) => value == item);

      // Add new pairing
      _selectedPairs[_selectedLeftItem!] = item;
      _selectedLeftItem = null;
    });

    widget.onPairsChanged(_selectedPairs);
  }
}
