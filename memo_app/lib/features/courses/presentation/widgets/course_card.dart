import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/course_entity.dart';

/// Exact Course Card matching reference design
class CourseCard extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onTap;

  const CourseCard({super.key, required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey[200]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Content Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge (Top Left)
                  _buildCategoryBadge(context),

                  const SizedBox(height: 12),

                  // Course Title (Right-aligned Arabic)
                  Text(
                    course.titleAr,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Stats Row (Left side)
                  Row(
                    children: [
                      // Rating
                      const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Text(
                        course.averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Lessons
                      Icon(Icons.play_circle_outline_rounded,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${course.totalLessons} درس',
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Duration
                      Icon(Icons.access_time_rounded, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        course.formattedDuration,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Right Icon Section
            _buildCourseIcon(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    final badgeColor = _getCategoryColor(course.subjectNameAr);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        course.subjectNameAr,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildCourseIcon(BuildContext context) {
    final gradientColors = _getGradientColors(course.subjectNameAr);

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: course.thumbnailUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: course.thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildIconContent(),
                errorWidget: (context, url, error) => _buildIconContent(),
              ),
            )
          : _buildIconContent(),
    );
  }

  Widget _buildIconContent() {
    final icon = _getSubjectIcon(course.subjectNameAr);
    return Center(
      child: Icon(icon, size: 40, color: Colors.white),
    );
  }

  // Category badge color
  Color _getCategoryColor(String subject) {
    if (subject.contains('التصميم') || subject.contains('Design')) {
      return const Color(0xFF6366F1); // Blue
    } else if (subject.contains('البرمجة') || subject.contains('Programming')) {
      return const Color(0xFFEC4899); // Pink
    } else if (subject.contains('الأعمال') || subject.contains('Business')) {
      return const Color(0xFF10B981); // Green
    } else if (subject.contains('التسويق') || subject.contains('Marketing')) {
      return const Color(0xFFF59E0B); // Orange
    } else if (subject.contains('اللغات') || subject.contains('Languages')) {
      return const Color(0xFFEF4444); // Red
    } else if (subject.contains('رياضيات') || subject.contains('Math')) {
      return const Color(0xFF8B5CF6); // Purple
    } else if (subject.contains('فيزياء') || subject.contains('Physics')) {
      return const Color(0xFFEC4899); // Pink
    } else if (subject.contains('كيمياء') || subject.contains('Chemistry')) {
      return const Color(0xFF06B6D4); // Cyan
    } else if (subject.contains('علوم') || subject.contains('Science')) {
      return const Color(0xFF10B981); // Green
    } else {
      return const Color(0xFF6366F1); // Default blue
    }
  }

  // Gradient colors for icon
  List<Color> _getGradientColors(String subject) {
    if (subject.contains('التصميم') || subject.contains('Design')) {
      return [const Color(0xFF667EEA), const Color(0xFF764BA2)]; // Purple
    } else if (subject.contains('البرمجة') || subject.contains('Programming')) {
      return [const Color(0xFFF093FB), const Color(0xFFF5576C)]; // Pink
    } else if (subject.contains('الأعمال') || subject.contains('Business')) {
      return [const Color(0xFF4FACFE), const Color(0xFF00F2FE)]; // Cyan
    } else if (subject.contains('التسويق') || subject.contains('Marketing')) {
      return [const Color(0xFF43E97B), const Color(0xFF38F9D7)]; // Green
    } else if (subject.contains('اللغات') || subject.contains('Languages')) {
      return [const Color(0xFFFA709A), const Color(0xFFFEE140)]; // Orange
    } else if (subject.contains('رياضيات') || subject.contains('Math')) {
      return [const Color(0xFF667EEA), const Color(0xFF764BA2)];
    } else if (subject.contains('فيزياء') || subject.contains('Physics')) {
      return [const Color(0xFFF093FB), const Color(0xFFF5576C)];
    } else if (subject.contains('كيمياء') || subject.contains('Chemistry')) {
      return [const Color(0xFF4FACFE), const Color(0xFF00F2FE)];
    } else if (subject.contains('علوم') || subject.contains('Science')) {
      return [const Color(0xFF43E97B), const Color(0xFF38F9D7)];
    } else {
      return [const Color(0xFF667EEA), const Color(0xFF764BA2)];
    }
  }

  // Subject icon
  IconData _getSubjectIcon(String subject) {
    if (subject.contains('التصميم') || subject.contains('Design')) {
      return Icons.palette_rounded;
    } else if (subject.contains('البرمجة') || subject.contains('Programming')) {
      return Icons.laptop_rounded;
    } else if (subject.contains('الأعمال') || subject.contains('Business')) {
      return Icons.bar_chart_rounded;
    } else if (subject.contains('التسويق') || subject.contains('Marketing')) {
      return Icons.phone_android_rounded;
    } else if (subject.contains('اللغات') || subject.contains('Languages')) {
      return Icons.language_rounded;
    } else if (subject.contains('رياضيات') || subject.contains('Math')) {
      return Icons.calculate_rounded;
    } else if (subject.contains('فيزياء') || subject.contains('Physics')) {
      return Icons.science_rounded;
    } else if (subject.contains('كيمياء') || subject.contains('Chemistry')) {
      return Icons.biotech_rounded;
    } else if (subject.contains('علوم') || subject.contains('Science')) {
      return Icons.eco_rounded;
    } else {
      return Icons.school_rounded;
    }
  }
}
