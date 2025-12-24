import 'package:flutter/material.dart';

/// فلاتر أنواع الإشعارات
class NotificationFilterChips extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String?> onTypeSelected;

  const NotificationFilterChips({
    super.key,
    this.selectedType,
    required this.onTypeSelected,
  });

  static const _types = [
    (null, 'الكل', Icons.all_inclusive),
    ('study_reminder', 'تذكير', Icons.book),
    ('exam_alert', 'امتحان', Icons.school),
    ('achievement', 'إنجاز', Icons.emoji_events),
    ('course_update', 'دورات', Icons.video_library),
    ('system', 'نظام', Icons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _types.map((type) {
          final isSelected = selectedType == type.$1;
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type.$3,
                    size: 16,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 4),
                  Text(type.$2),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => onTypeSelected(type.$1),
            ),
          );
        }).toList(),
      ),
    );
  }
}
