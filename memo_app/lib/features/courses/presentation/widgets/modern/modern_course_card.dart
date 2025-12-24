import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/entities/course_entity.dart';
import 'course_level_badge.dart';

/// Modern course card matching session view design
/// Features: gradient icon, level badge, stats row, subject-colored border
class ModernCourseCard extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onTap;

  const ModernCourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  Color get _subjectColor =>
      AppColors.getSubjectColor(course.subjectNameAr);

  IconData get _subjectIcon {
    final name = course.subjectNameAr.toLowerCase();
    if (name.contains('رياضيات') || name.contains('math')) {
      return Icons.calculate_rounded;
    }
    if (name.contains('فيزياء') || name.contains('physi')) {
      return Icons.science_rounded;
    }
    if (name.contains('كيمياء') || name.contains('chimi')) {
      return Icons.biotech_rounded;
    }
    if (name.contains('عربية') || name.contains('arab')) {
      return Icons.menu_book_rounded;
    }
    if (name.contains('فرنسية') || name.contains('fran')) {
      return Icons.translate_rounded;
    }
    if (name.contains('إنجليزية') || name.contains('angl')) {
      return Icons.language_rounded;
    }
    if (name.contains('تاريخ') || name.contains('histoi')) {
      return Icons.history_edu_rounded;
    }
    if (name.contains('جغرافيا') || name.contains('géog')) {
      return Icons.public_rounded;
    }
    if (name.contains('فلسفة') || name.contains('philos')) {
      return Icons.psychology_rounded;
    }
    if (name.contains('إسلامية') || name.contains('islam')) {
      return Icons.mosque_rounded;
    }
    return Icons.school_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            right: BorderSide(
              color: _subjectColor,
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: _subjectColor.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient Icon Container
              _buildGradientIconContainer(),
              const SizedBox(width: 14),

              // Content Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Row with Level Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            course.titleAr,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate900,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CourseLevelBadge(level: course.level, compact: true),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Instructor Name
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            course.instructorName,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Stats Row
                    _buildStatsRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientIconContainer() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _subjectColor,
            _subjectColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _subjectColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        _subjectIcon,
        color: Colors.white,
        size: 26,
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        // Rating
        _buildStatItem(
          icon: Icons.star_rounded,
          value: course.formattedRating,
          color: AppColors.amber500,
        ),
        _buildDivider(),

        // Lessons Count
        _buildStatItem(
          icon: Icons.play_circle_outline_rounded,
          value: '${course.totalLessons} درس',
          color: AppColors.primary,
        ),
        _buildDivider(),

        // Duration
        _buildStatItem(
          icon: Icons.access_time_rounded,
          value: _formatDuration(course.totalDurationMinutes),
          color: AppColors.emerald500,
        ),

        // Price Badge (if not free)
        if (!course.isFreeAccess) ...[
          const Spacer(),
          _buildPriceBadge(),
        ],
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 12,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildPriceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.emerald500.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        course.formattedPrice,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.emerald500,
        ),
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
    return '$hours س $mins د';
  }
}
