import 'package:flutter/material.dart';
import '../../../domain/entities/course_lesson_entity.dart';

/// Lesson status for display
enum LessonStatus {
  completed,
  available,
  locked,
}

/// Modern lesson item matching session checklist design
/// Shows lesson with status icon and duration
class ModernLessonItem extends StatelessWidget {
  final CourseLessonEntity lesson;
  final LessonStatus status;
  final VoidCallback? onTap;
  final int lessonNumber;

  const ModernLessonItem({
    super.key,
    required this.lesson,
    required this.status,
    this.onTap,
    this.lessonNumber = 0,
  });

  Color get _statusColor {
    switch (status) {
      case LessonStatus.completed:
        return const Color(0xFF10B981); // Green
      case LessonStatus.available:
        return const Color(0xFF3B82F6); // Blue
      case LessonStatus.locked:
        return const Color(0xFF94A3B8); // Gray
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case LessonStatus.completed:
        return Icons.check_circle_rounded;
      case LessonStatus.available:
        return Icons.play_circle_outline_rounded;
      case LessonStatus.locked:
        return Icons.lock_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAccessible = status != LessonStatus.locked || lesson.isFreePreview;

    return InkWell(
      onTap: isAccessible ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: status == LessonStatus.completed
              ? const Color(0xFF10B981).withOpacity(0.05)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Status Icon with Number
            _buildStatusIcon(),
            const SizedBox(width: 12),

            // Lesson Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    lesson.titleAr,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: status == LessonStatus.locked
                          ? Colors.grey[500]
                          : const Color(0xFF1E293B),
                      decoration: status == LessonStatus.completed
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: const Color(0xFF10B981),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Duration and badges row
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lesson.formattedDuration,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (lesson.hasQuiz) ...[
                        const SizedBox(width: 12),
                        _buildQuizBadge(),
                      ],
                      if (lesson.hasAttachments) ...[
                        const SizedBox(width: 8),
                        _buildAttachmentBadge(),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Free Preview Badge or Chevron
            if (lesson.isFreePreview && status == LessonStatus.locked)
              _buildFreePreviewBadge()
            else if (isAccessible)
              Icon(
                Icons.chevron_left_rounded,
                color: Colors.grey[400],
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(
          status == LessonStatus.completed ? 0.15 : 0.1,
        ),
        borderRadius: BorderRadius.circular(10),
        border: status == LessonStatus.available
            ? Border.all(color: _statusColor.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: Center(
        child: status == LessonStatus.completed
            ? Icon(_statusIcon, color: _statusColor, size: 20)
            : lessonNumber > 0
                ? Text(
                    '$lessonNumber',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _statusColor,
                    ),
                  )
                : Icon(_statusIcon, color: _statusColor, size: 20),
      ),
    );
  }

  Widget _buildFreePreviewBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.visibility_rounded,
            size: 12,
            color: Color(0xFF10B981),
          ),
          const SizedBox(width: 4),
          const Text(
            'معاينة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.quiz_rounded,
            size: 10,
            color: Color(0xFF8B5CF6),
          ),
          const SizedBox(width: 2),
          const Text(
            'اختبار',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              color: Color(0xFF8B5CF6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentBadge() {
    return Icon(
      Icons.attach_file_rounded,
      size: 14,
      color: Colors.grey[500],
    );
  }
}
