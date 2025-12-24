import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// هيدر موحد لجميع صفحات الملف الشخصي
///
/// يعرض:
/// - خلفية متدرجة بنفسجية (أو مخصصة)
/// - زر الرجوع على اليمين
/// - أيقونة + عنوان + عنوان فرعي
/// - زر إجراء اختياري على اليسار
/// - قاع منحني
class ProfilePageHeader extends StatelessWidget {
  /// العنوان الرئيسي
  final String title;

  /// العنوان الفرعي
  final String subtitle;

  /// أيقونة الصفحة
  final IconData icon;

  /// عند الضغط على زر الرجوع
  final VoidCallback onBack;

  /// عند الضغط على زر الإجراء (اختياري)
  final VoidCallback? onAction;

  /// أيقونة زر الإجراء (اختياري)
  final IconData? actionIcon;

  /// لون بداية التدرج (اختياري - الافتراضي بنفسجي)
  final Color? gradientStart;

  /// لون نهاية التدرج (اختياري)
  final Color? gradientEnd;

  /// لون الخلفية أسفل الهيدر
  final Color backgroundColor;

  const ProfilePageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onBack,
    this.onAction,
    this.actionIcon,
    this.gradientStart,
    this.gradientEnd,
    this.backgroundColor = AppColors.slateBackground,
  });

  @override
  Widget build(BuildContext context) {
    final startColor = gradientStart ?? AppColors.primary;
    final endColor = gradientEnd ?? AppColors.primaryDark;

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
      ),
      child: Column(
        children: [
          // محتوى الهيدر
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // زر الرجوع
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // الأيقونة
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // العنوان
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                // زر الإجراء (اختياري)
                if (onAction != null && actionIcon != null)
                  GestureDetector(
                    onTap: onAction,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        actionIcon,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // القاع المنحني
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
