import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../utils/formatters.dart';

/// Subject card widget showing progress and statistics
class SubjectCard extends StatelessWidget {
  final String subjectName;
  final String? subjectNameArabic;
  final Color color;
  final double progress; // 0.0 to 1.0
  final int lessonsCompleted;
  final int totalLessons;
  final int quizzesTaken;
  final VoidCallback? onTap;

  const SubjectCard({
    super.key,
    required this.subjectName,
    this.subjectNameArabic,
    required this.color,
    required this.progress,
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.quizzesTaken,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      child: Container(
        height: AppSizes.subjectCardHeight,
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Subject name
            Text(
              subjectNameArabic ?? subjectName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textOnPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Statistics
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lessons progress
                Row(
                  children: [
                    const Icon(
                      Icons.book_outlined,
                      size: AppSizes.iconSM,
                      color: AppColors.textOnPrimary,
                    ),
                    const SizedBox(width: AppSizes.paddingXS),
                    Text(
                      '${Formatters.toArabicNumerals(lessonsCompleted)}/${Formatters.toArabicNumerals(totalLessons)} دروس',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingXS),

                // Quizzes
                Row(
                  children: [
                    const Icon(
                      Icons.quiz_outlined,
                      size: AppSizes.iconSM,
                      color: AppColors.textOnPrimary,
                    ),
                    const SizedBox(width: AppSizes.paddingXS),
                    Text(
                      '${Formatters.toArabicNumerals(quizzesTaken)} اختبار',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingSM),

                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'التقدم',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                        Text(
                          Formatters.formatPercentage(progress * 100),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingXS),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusCircle,
                      ),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.textOnPrimary.withOpacity(
                          0.3,
                        ),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.textOnPrimary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
