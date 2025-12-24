import 'package:flutter/material.dart';

/// Reusable gradient subject card widget
/// Used by Content Library and BAC Archives pages
/// Displays subject with gradient background, icon, and coefficient badge
class GradientSubjectCard extends StatelessWidget {
  final String nameAr;
  final int coefficient;
  final VoidCallback onTap;
  final Color? color;
  final IconData? icon;

  const GradientSubjectCard({
    super.key,
    required this.nameAr,
    required this.coefficient,
    required this.onTap,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? _getSubjectColor(nameAr);
    final cardIcon = icon ?? _getSubjectIcon(nameAr);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardColor,
              cardColor.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
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
              child: Row(
                children: [
                  // Icon container
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      cardIcon,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Subject name and coefficient
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          nameAr,
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
                            'المعامل: $coefficient',
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
                  ),
                ],
              ),
            ),

            // Arrow indicator
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

  /// Get subject color based on Arabic name
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

  /// Get subject icon based on Arabic name
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
