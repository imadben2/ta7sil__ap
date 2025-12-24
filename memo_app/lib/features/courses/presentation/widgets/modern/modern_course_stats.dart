import 'package:flutter/material.dart';
import '../../../domain/entities/course_entity.dart';

/// Modern 3-column stats section with gradient backgrounds
/// Shows lessons count, duration, and rating
class ModernCourseStats extends StatelessWidget {
  final CourseEntity course;

  const ModernCourseStats({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Lessons Count
          Expanded(
            child: _GradientStatCard(
              icon: Icons.play_circle_filled_rounded,
              label: 'الدروس',
              value: '${course.totalLessons}',
              gradientColors: const [
                Color(0xFF3B82F6),
                Color(0xFF1D4ED8),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Duration
          Expanded(
            child: _GradientStatCard(
              icon: Icons.schedule_rounded,
              label: 'المدة',
              value: _formatDuration(course.totalDurationMinutes),
              gradientColors: const [
                Color(0xFF10B981),
                Color(0xFF059669),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Rating
          Expanded(
            child: _GradientStatCard(
              icon: Icons.star_rounded,
              label: 'التقييم',
              value: course.formattedRating,
              gradientColors: const [
                Color(0xFFF59E0B),
                Color(0xFFD97706),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes د';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours س';
    }
    return '$hours:${mins.toString().padLeft(2, '0')}';
  }
}

class _GradientStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradientColors;

  const _GradientStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with glass effect
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),

          // Value
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Label
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal variant for compact display
class ModernCourseStatsHorizontal extends StatelessWidget {
  final CourseEntity course;

  const ModernCourseStatsHorizontal({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCompactStat(
            Icons.play_circle_filled_rounded,
            '${course.totalLessons} درس',
            const Color(0xFF3B82F6),
          ),
          _buildDivider(),
          _buildCompactStat(
            Icons.schedule_rounded,
            _formatDuration(course.totalDurationMinutes),
            const Color(0xFF10B981),
          ),
          _buildDivider(),
          _buildCompactStat(
            Icons.star_rounded,
            course.formattedRating,
            const Color(0xFFF59E0B),
          ),
          _buildDivider(),
          _buildCompactStat(
            Icons.people_rounded,
            course.enrollmentText,
            const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey[200],
    );
  }

  Widget _buildCompactStat(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes د';
    }
    final hours = minutes ~/ 60;
    return '$hours س';
  }
}
