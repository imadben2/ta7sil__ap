import 'package:flutter/material.dart';
import '../../domain/entities/course_entity.dart';

/// صف إحصائيات الدورة
class CourseStatsRow extends StatelessWidget {
  final CourseEntity course;

  const CourseStatsRow({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatItem(
          context,
          icon: Icons.star,
          value: course.averageRating.toStringAsFixed(1),
          label: '${course.totalReviews} تقييم',
          color: Colors.amber,
        ),
        _buildDivider(),
        _buildStatItem(
          context,
          icon: Icons.people,
          value: _formatNumber(course.totalStudents),
          label: 'طالب',
          color: Colors.blue,
        ),
        _buildDivider(),
        _buildStatItem(
          context,
          icon: Icons.play_circle_outline,
          value: '${course.totalLessons}',
          label: 'درس',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 50, width: 1, color: Colors.grey[300]);
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
