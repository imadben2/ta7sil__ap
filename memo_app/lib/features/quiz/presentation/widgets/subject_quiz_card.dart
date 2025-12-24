import 'package:flutter/material.dart';
import '../../domain/entities/quiz_entity.dart';

/// Card widget for displaying a subject with quiz count (Gradient style like BAC archives)
/// Used in quiz list page - tapping navigates to subject's quizzes
class SubjectQuizCard extends StatelessWidget {
  final SubjectInfo subject;
  final int quizCount;
  final VoidCallback onTap;

  const SubjectQuizCard({
    super.key,
    required this.subject,
    required this.quizCount,
    required this.onTap,
  });

  Color get _subjectColor {
    if (subject.color != null && subject.color!.isNotEmpty) {
      try {
        final colorString = subject.color!.replaceFirst('#', '');
        return Color(int.parse(colorString, radix: 16) + 0xFF000000);
      } catch (_) {}
    }
    return _getSubjectColor(subject.nameAr);
  }

  IconData get _subjectIcon {
    if (subject.icon != null && subject.icon!.isNotEmpty) {
      switch (subject.icon) {
        case 'calculate':
          return Icons.calculate_rounded;
        case 'science':
          return Icons.science_rounded;
        case 'language':
          return Icons.language_rounded;
        case 'mosque':
          return Icons.mosque_rounded;
        case 'public':
          return Icons.public_rounded;
        case 'psychology':
          return Icons.psychology_rounded;
        case 'history':
        case 'history_edu':
          return Icons.history_edu_rounded;
        case 'biotech':
          return Icons.biotech_rounded;
        case 'menu_book':
          return Icons.menu_book_rounded;
        case 'translate':
          return Icons.translate_rounded;
        case 'functions':
          return Icons.functions_rounded;
        default:
          return Icons.book_rounded;
      }
    }
    return _getSubjectIcon(subject.nameAr);
  }

  @override
  Widget build(BuildContext context) {
    final hasQuizzes = quizCount > 0;
    final cardColor = hasQuizzes ? _subjectColor : const Color(0xFFE2E8F0);

    return GestureDetector(
      onTap: hasQuizzes ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: hasQuizzes
                ? [cardColor, cardColor.withOpacity(0.85)]
                : [cardColor, cardColor.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: hasQuizzes
              ? [
                  BoxShadow(
                    color: cardColor.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Background decorative circles
            Positioned(
              right: -20,
              top: -20,
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
              left: -25,
              bottom: -25,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon container
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _subjectIcon,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subject name and quiz count
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.nameAr,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          hasQuizzes ? '$quizCount اختبار' : 'لا توجد اختبارات',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow indicator (only if has quizzes)
            if (hasQuizzes)
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Get subject color based on Arabic name (fallback)
  Color _getSubjectColor(String subjectName) {
    final name = subjectName.toLowerCase();

    if (name.contains('رياضيات') || name.contains('math')) {
      return const Color(0xFF3B82F6); // Blue
    }
    if (name.contains('فيزياء') || name.contains('physi')) {
      return const Color(0xFF8B5CF6); // Purple
    }
    if (name.contains('كيمياء') || name.contains('chimi')) {
      return const Color(0xFF10B981); // Green
    }
    if (name.contains('علوم') || name.contains('طبيعة') || name.contains('حياة')) {
      return const Color(0xFF06B6D4); // Cyan
    }
    if (name.contains('عربية') || name.contains('arab')) {
      return const Color(0xFF10B981); // Green
    }
    if (name.contains('فرنسية') || name.contains('fran')) {
      return const Color(0xFFEF4444); // Red
    }
    if (name.contains('إنجليزية') || name.contains('angl')) {
      return const Color(0xFFF97316); // Orange
    }
    if (name.contains('تاريخ') || name.contains('histoi')) {
      return const Color(0xFF78716C); // Brown
    }
    if (name.contains('جغرافيا') || name.contains('géog')) {
      return const Color(0xFF14B8A6); // Teal
    }
    if (name.contains('فلسفة') || name.contains('philos')) {
      return const Color(0xFFF59E0B); // Amber
    }
    if (name.contains('إسلامية') || name.contains('islam')) {
      return const Color(0xFF059669); // Emerald
    }

    return const Color(0xFF64748B); // Default slate
  }

  /// Get subject icon based on Arabic name (fallback)
  IconData _getSubjectIcon(String subjectName) {
    final name = subjectName.toLowerCase();

    if (name.contains('رياضيات') || name.contains('math')) {
      return Icons.calculate_rounded;
    }
    if (name.contains('فيزياء') || name.contains('physi')) {
      return Icons.science_rounded;
    }
    if (name.contains('كيمياء') || name.contains('chimi')) {
      return Icons.biotech_rounded;
    }
    if (name.contains('علوم') || name.contains('طبيعة') || name.contains('حياة')) {
      return Icons.menu_book_rounded;
    }
    if (name.contains('عربية') || name.contains('arab')) {
      return Icons.text_fields_rounded;
    }
    if (name.contains('فرنسية') || name.contains('fran')) {
      return Icons.language_rounded;
    }
    if (name.contains('إنجليزية') || name.contains('angl')) {
      return Icons.translate_rounded;
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

    return Icons.menu_book_rounded;
  }
}
