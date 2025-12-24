import 'package:flutter/material.dart';
import '../../../domain/entities/ordering_question.dart';
import '../../../../../core/constants/app_colors.dart';

/// Ordering question widget (reorderable list)
class OrderingWidget extends StatefulWidget {
  final OrderingQuestion question;
  final List<String>? orderedItems;
  final Function(List<String>) onOrderChanged;
  final bool isReviewMode;
  final List<String>? correctOrder;

  const OrderingWidget({
    super.key,
    required this.question,
    this.orderedItems,
    required this.onOrderChanged,
    this.isReviewMode = false,
    this.correctOrder,
  });

  @override
  State<OrderingWidget> createState() => _OrderingWidgetState();
}

class _OrderingWidgetState extends State<OrderingWidget> {
  late List<String> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.orderedItems != null
        ? List.from(widget.orderedItems!)
        : List.from(widget.question.items);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Text(
          'رتب العناصر التالية بالترتيب الصحيح:',
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
                Icon(
                  Icons.drag_indicator_rounded,
                  color: AppColors.info,
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'اسحب العناصر لتغيير الترتيب',
                    style: TextStyle(fontSize: 12, color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        widget.isReviewMode ? _buildStaticList() : _buildReorderableList(),
      ],
    );
  }

  Widget _buildReorderableList() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = _items.removeAt(oldIndex);
          _items.insert(newIndex, item);
        });
        widget.onOrderChanged(_items);
      },
      itemBuilder: (context, index) {
        final item = _items[index];
        return _buildDraggableItem(item, index, key: ValueKey(item));
      },
    );
  }

  Widget _buildDraggableItem(String item, int index, {required Key key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
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
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Icon(Icons.drag_indicator_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildStaticList() {
    return Column(
      children: List.generate(_items.length, (index) {
        final item = _items[index];
        final isCorrectPosition =
            widget.correctOrder != null && widget.correctOrder![index] == item;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCorrectPosition
                ? AppColors.success.withOpacity(0.1)
                : AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCorrectPosition ? AppColors.success : AppColors.error,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCorrectPosition
                      ? AppColors.success
                      : AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    fontWeight: isCorrectPosition
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              Icon(
                isCorrectPosition ? Icons.check_circle : Icons.cancel,
                color: isCorrectPosition ? AppColors.success : AppColors.error,
                size: 24,
              ),
            ],
          ),
        );
      }),
    );
  }
}
