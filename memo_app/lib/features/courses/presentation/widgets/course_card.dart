import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/course_entity.dart';

/// Hybrid Course Card - shows image if exists, otherwise gradient card
class CourseCard extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onTap;

  const CourseCard({super.key, required this.course, required this.onTap});

  /// Check if course has a valid thumbnail
  bool get _hasImage => course.thumbnailUrl != null && course.thumbnailUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    // Hybrid: use image card if thumbnail exists, otherwise gradient card
    if (_hasImage) {
      return _buildImageCard(context);
    } else {
      return _buildGradientCard(context);
    }
  }

  /// Image-based card (when thumbnail exists)
  Widget _buildImageCard(BuildContext context) {
    final gradientColors = _getGradientColors(course.subjectNameAr);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: course.thumbnailUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.school_rounded, size: 50, color: Colors.white),
                    ),
                  ),
                ),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),
              ),

              // Category Badge (Top Left)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    course.subjectNameAr,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: gradientColors[0],
                    ),
                  ),
                ),
              ),

              // Price Badge (Top Right)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    course.isFree ? 'مجاني' : '${course.priceDzd} دج',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Bottom Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Course Title
                      Text(
                        course.titleAr,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildStatBadge(Icons.star_rounded, course.averageRating.toStringAsFixed(1), const Color(0xFFF59E0B)),
                          const SizedBox(width: 8),
                          _buildStatBadge(Icons.play_circle_outline_rounded, '${course.totalLessons}', Colors.white70),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Gradient-based card (when no thumbnail)
  Widget _buildGradientCard(BuildContext context) {
    final gradientColors = _getGradientColors(course.subjectNameAr);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
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
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              // Icon Section (now on right in RTL)
              _buildCourseIcon(context, gradientColors),

              // Content Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price Badge (Top)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradientColors),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              course.isFree ? 'مجاني' : '${course.priceDzd} دج',
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Rating
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                course.averageRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Course Title
                      Text(
                        course.titleAr,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '${course.totalLessons} درس',
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.menu_book_rounded,
                              size: 14, color: Colors.grey[500]),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildCourseIcon(BuildContext context, List<Color> gradientColors) {
    return Container(
      width: 90,
      height: 90,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // School icon
          Center(
            child: Icon(
              Icons.school_rounded,
              size: 40,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          // Lesson count badge
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${course.totalLessons}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
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
