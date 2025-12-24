import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// بطاقة قائمة الملف الشخصي الحديثة
///
/// التصميم مطابق لبطاقات صفحة دوراتي مع:
/// - زوايا دائرية (16px)
/// - ظل بنفسجي خفيف
/// - أيقونة مع خلفية ملونة
/// - عنوان وعنوان فرعي
/// - سهم للتنقل
class ModernProfileMenuCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showArrow;
  final bool isDanger;

  const ModernProfileMenuCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showArrow = true,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDanger
                  ? AppColors.error.withOpacity(0.08)
                  : AppColors.primary.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // الأيقونة مع الخلفية
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // النص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDanger ? AppColors.error : AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: isDanger
                          ? AppColors.error.withOpacity(0.7)
                          : AppColors.slate500,
                    ),
                  ),
                ],
              ),
            ),
            // السهم
            if (showArrow)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDanger
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 14,
                  color: isDanger ? AppColors.error : AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// عنوان قسم في صفحة الملف الشخصي
class ModernProfileSectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;

  const ModernProfileSectionTitle({
    super.key,
    required this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // الخط البنفسجي
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // الأيقونة (اختياري)
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
          ],
          // العنوان
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.slate900,
            ),
          ),
        ],
      ),
    );
  }
}
