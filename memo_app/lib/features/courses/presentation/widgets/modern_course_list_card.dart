import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/course_entity.dart';

/// Modern Course List Card - Design moderne avec image cover
/// Affiche une carte de cours avec image en arrière-plan ou icône par défaut
class ModernCourseListCard extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onTap;
  final bool showProgress;
  final double? progress;

  const ModernCourseListCard({
    super.key,
    required this.course,
    required this.onTap,
    this.showProgress = false,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              // Image/Icon Section (Right side for RTL)
              _buildImageSection(),

              // Content Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title Row with Icon
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Subject Icon (left side)
                          _buildSubjectIconBadge(),
                          const SizedBox(width: 10),
                          // Title (right side, expands)
                          Expanded(
                            child: Text(
                              course.titleAr,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate900,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Stats Row
                      _buildStatsRow(),

                      // Progress Bar (if showing)
                      if (showProgress && progress != null) _buildProgressBar(),
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

  Widget _buildImageSection() {
    final gradientColors = _getGradientColors(course.subjectNameAr);
    final hasImage = course.thumbnailUrl != null && course.thumbnailUrl!.isNotEmpty;

    return Container(
      width: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: hasImage
          ? Stack(
              fit: StackFit.expand,
              children: [
                // Cover Image
                CachedNetworkImage(
                  imageUrl: course.thumbnailUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildDefaultIcon(gradientColors),
                  errorWidget: (context, url, error) => _buildDefaultIcon(gradientColors),
                ),
                // Gradient Overlay for readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        gradientColors[1].withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Play Icon Overlay
                const Center(
                  child: Icon(
                    Icons.play_circle_filled_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                // Lessons Count Badge
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_lesson_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${course.totalLessons}',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : _buildDefaultIcon(gradientColors),
    );
  }

  Widget _buildDefaultIcon(List<Color> gradientColors) {
    final icon = _getSubjectIcon(course.subjectNameAr);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Stack(
        children: [
          // Decorative Circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Main Icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 36,
                color: Colors.white,
              ),
            ),
          ),
          // Lessons Badge
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.play_lesson_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${course.totalLessons}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectIconBadge() {
    final badgeColor = _getCategoryColor(course.subjectNameAr);
    final icon = _getSubjectIcon(course.subjectNameAr);

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 18,
        color: badgeColor,
      ),
    );
  }

  Widget _buildCategoryBadge() {
    final badgeColor = _getCategoryColor(course.subjectNameAr);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        course.subjectNameAr,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildFeaturedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: Colors.white, size: 12),
          SizedBox(width: 2),
          Text(
            'مميز',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        // Rating
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
              const SizedBox(width: 3),
              Text(
                course.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB45309),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // Duration
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time_rounded, size: 14, color: AppColors.slate500),
            const SizedBox(width: 4),
            Text(
              _formatDuration(course.totalDurationMinutes),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.slate600,
              ),
            ),
          ],
        ),

        const Spacer(),

        // Price Badge
        _buildPriceBadge(),
      ],
    );
  }

  Widget _buildPriceBadge() {
    if (course.isFreeAccess) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'مجاني',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF059669),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (course.hasDiscount && course.originalPriceDzd != null) ...[
          Text(
            '${course.originalPriceDzd} دج',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.slate500,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 6),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.blue500.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${course.priceDzd} دج',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.blue500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'التقدم',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.slate500,
              ),
            ),
            Text(
              '${(progress! * 100).toInt()}%',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.blue500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress! >= 1.0 ? const Color(0xFF10B981) : AppColors.blue500,
            ),
            minHeight: 4,
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
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours س';
    }
    return '$hours س ${mins} د';
  }

  Color _getCategoryColor(String subject) {
    final colors = {
      'رياضيات': const Color(0xFF8B5CF6),
      'فيزياء': const Color(0xFFEC4899),
      'كيمياء': const Color(0xFF06B6D4),
      'علوم': const Color(0xFF10B981),
      'عربية': const Color(0xFFEF4444),
      'فرنسية': const Color(0xFF6366F1),
      'إنجليزية': const Color(0xFF14B8A6),
      'تاريخ': const Color(0xFFA855F7),
      'جغرافيا': const Color(0xFF0EA5E9),
      'فلسفة': const Color(0xFFEAB308),
      'إسلامية': const Color(0xFF22C55E),
    };

    for (final entry in colors.entries) {
      if (subject.contains(entry.key)) {
        return entry.value;
      }
    }
    return const Color(0xFF6366F1);
  }

  List<Color> _getGradientColors(String subject) {
    final gradients = {
      'رياضيات': [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      'فيزياء': [const Color(0xFFF093FB), const Color(0xFFF5576C)],
      'كيمياء': [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
      'علوم': [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
      'عربية': [const Color(0xFFFA709A), const Color(0xFFFEE140)],
      'فرنسية': [const Color(0xFF5A67D8), const Color(0xFF9F7AEA)],
      'إنجليزية': [const Color(0xFF38B2AC), const Color(0xFF4FD1C5)],
      'تاريخ': [const Color(0xFF9F7AEA), const Color(0xFFB794F4)],
      'جغرافيا': [const Color(0xFF0BC5EA), const Color(0xFF00B5D8)],
      'فلسفة': [const Color(0xFFD69E2E), const Color(0xFFF6AD55)],
      'إسلامية': [const Color(0xFF48BB78), const Color(0xFF68D391)],
    };

    for (final entry in gradients.entries) {
      if (subject.contains(entry.key)) {
        return entry.value;
      }
    }
    return [const Color(0xFF667EEA), const Color(0xFF764BA2)];
  }

  IconData _getSubjectIcon(String subject) {
    final icons = {
      'رياضيات': Icons.calculate_rounded,
      'فيزياء': Icons.science_rounded,
      'كيمياء': Icons.biotech_rounded,
      'علوم': Icons.eco_rounded,
      'عربية': Icons.menu_book_rounded,
      'فرنسية': Icons.language_rounded,
      'إنجليزية': Icons.translate_rounded,
      'تاريخ': Icons.history_edu_rounded,
      'جغرافيا': Icons.public_rounded,
      'فلسفة': Icons.psychology_rounded,
      'إسلامية': Icons.mosque_rounded,
    };

    for (final entry in icons.entries) {
      if (subject.contains(entry.key)) {
        return entry.value;
      }
    }
    return Icons.school_rounded;
  }
}
