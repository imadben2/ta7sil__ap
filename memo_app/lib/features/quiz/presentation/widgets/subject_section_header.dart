import 'package:flutter/material.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../../../core/constants/app_colors.dart';

/// Collapsible section header for subject groups in quiz list
class SubjectSectionHeader extends StatelessWidget {
  final SubjectInfo subject;
  final int quizCount;
  final bool isExpanded;
  final VoidCallback onToggle;

  const SubjectSectionHeader({
    super.key,
    required this.subject,
    required this.quizCount,
    required this.isExpanded,
    required this.onToggle,
  });

  Color get _subjectColor {
    if (subject.color != null && subject.color!.isNotEmpty) {
      try {
        final colorString = subject.color!.replaceFirst('#', '');
        return Color(int.parse(colorString, radix: 16) + 0xFF000000);
      } catch (_) {}
    }
    return AppColors.primary;
  }

  IconData get _subjectIcon {
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            right: BorderSide(color: _subjectColor, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: _subjectColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Subject Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _subjectColor,
                    _subjectColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_subjectIcon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),

            // Subject Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.nameAr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (quizCount == 0)
                    Text(
                      'لا توجد اختبارات',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),

            // Quiz Count Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: quizCount > 0
                    ? _subjectColor.withOpacity(0.15)
                    : AppColors.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$quizCount',
                style: TextStyle(
                  color: quizCount > 0 ? _subjectColor : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Expand/Collapse Chevron
            AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: isExpanded ? 0.5 : 0,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
