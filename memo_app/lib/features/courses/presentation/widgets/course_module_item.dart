import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/course_lesson_entity.dart';
import '../../domain/entities/course_module_entity.dart';

/// عنصر وحدة الدورة (Module) مع الدروس
class CourseModuleItem extends StatefulWidget {
  final CourseModuleEntity module;
  final bool hasAccess;
  final Function(CourseLessonEntity) onLessonTap;

  const CourseModuleItem({
    super.key,
    required this.module,
    required this.hasAccess,
    required this.onLessonTap,
  });

  @override
  State<CourseModuleItem> createState() => _CourseModuleItemState();
}

class _CourseModuleItemState extends State<CourseModuleItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Module Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Expand Icon
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primary,
                  ),

                  const SizedBox(width: 12),

                  // Module Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.module.titleAr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.module.totalLessons} دروس',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Module Number Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'الوحدة ${widget.module.order}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lessons List
          if (_isExpanded && widget.module.lessons != null)
            ...widget.module.lessons!.map((lesson) => _buildLessonItem(lesson)),
        ],
      ),
    );
  }

  Widget _buildLessonItem(CourseLessonEntity lesson) {
    return InkWell(
      onTap: () => widget.onLessonTap(lesson),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            // Play Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.hasAccess || lesson.isFreePreview
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                lesson.isFreePreview
                    ? Icons.play_circle_outline
                    : widget.hasAccess
                    ? Icons.play_circle_outline
                    : Icons.lock_outline,
                color: widget.hasAccess || lesson.isFreePreview
                    ? AppColors.primary
                    : Colors.grey,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            // Lesson Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lesson.titleAr,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (lesson.isFreePreview)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'معاينة مجانية',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(lesson.videoDurationSeconds),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      if (lesson.hasQuiz) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.quiz_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'اختبار',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '$minutes:${secs.toString().padLeft(2, '0')} د';
    }
    return '$secs ث';
  }
}
