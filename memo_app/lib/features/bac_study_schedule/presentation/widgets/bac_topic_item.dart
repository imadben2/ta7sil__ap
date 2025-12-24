import 'package:flutter/material.dart';
import '../../domain/entities/bac_day_topic.dart';

/// Widget for displaying a single topic with checkbox
class BacTopicItem extends StatelessWidget {
  final BacDayTopic topic;
  final bool isUpdating;
  final ValueChanged<bool> onToggle;

  const BacTopicItem({
    super.key,
    required this.topic,
    required this.isUpdating,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final Color taskColor;

    switch (topic.taskType) {
      case 'memorize':
        taskColor = const Color(0xFF10B981);
        break;
      case 'solve':
        taskColor = const Color(0xFF8B5CF6);
        break;
      case 'review':
        taskColor = const Color(0xFFF59E0B);
        break;
      case 'exercise':
        taskColor = const Color(0xFFEC4899);
        break;
      default: // study
        taskColor = const Color(0xFF3B82F6);
    }

    return InkWell(
      onTap: isUpdating ? null : () => onToggle(!topic.isCompleted),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            GestureDetector(
              onTap: isUpdating ? null : () => onToggle(!topic.isCompleted),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: topic.isCompleted
                      ? const Color(0xFF10B981)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: topic.isCompleted
                        ? const Color(0xFF10B981)
                        : const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                ),
                child: topic.isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: taskColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      topic.taskTypeDisplayAr,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: taskColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Topic title
                  Text(
                    topic.topicAr,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: topic.isCompleted
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF1E293B),
                      decoration: topic.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),

                  // Description if available
                  if (topic.descriptionAr != null &&
                      topic.descriptionAr!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      topic.descriptionAr!,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: topic.isCompleted
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
