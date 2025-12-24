import 'package:flutter/material.dart';

/// Enrollment status badge matching session status badge design
/// Shows whether user is enrolled in a course
class CourseEnrollmentBadge extends StatelessWidget {
  final bool isEnrolled;
  final bool isOnGradient;

  const CourseEnrollmentBadge({
    super.key,
    required this.isEnrolled,
    this.isOnGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = isEnrolled
        ? const Color(0xFF10B981) // Green
        : const Color(0xFF64748B); // Gray

    if (isOnGradient) {
      // For use on gradient backgrounds
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isEnrolled
                  ? Icons.check_circle_rounded
                  : Icons.add_circle_outline_rounded,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              isEnrolled ? 'مسجل' : 'غير مسجل',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // For use on white backgrounds
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEnrolled
                ? Icons.check_circle_rounded
                : Icons.add_circle_outline_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isEnrolled ? 'مسجل' : 'غير مسجل',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
