import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/profile_entity.dart';

/// ويدجت الهيدر الحديث للملف الشخصي
///
/// التصميم مطابق لصفحة دوراتي مع:
/// - خلفية gradient بنفسجية
/// - صورة الملف الشخصي مع حدود بيضاء
/// - معلومات المستخدم (الاسم، البريد، المعلومات الأكاديمية)
/// - بطاقات الإحصائيات السريعة بتأثير glass-morphism
/// - قاع منحني (curved bottom)
class ModernProfileHeader extends StatelessWidget {
  final ProfileEntity profile;
  final VoidCallback? onEditPhoto;
  final VoidCallback? onRefresh;

  // ثوابت الألوان
  static const _primaryPurple = AppColors.primary;
  static const _secondaryPurple = AppColors.primaryDark;
  static const _bgColor = AppColors.slateBackground;

  const ModernProfileHeader({
    super.key,
    required this.profile,
    this.onEditPhoto,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryPurple, _secondaryPurple],
        ),
      ),
      child: Column(
        children: [
          // محتوى الهيدر
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // صف العنوان مع زر التحديث
                _buildTitleRow(),
                const SizedBox(height: 14),

                // صورة الملف الشخصي
                _buildProfileAvatar(),
                const SizedBox(height: 10),

                // معلومات المستخدم
                _buildUserInfo(),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // القاع المنحني
          _buildCurvedBottom(),
        ],
      ),
    );
  }

  /// بناء صف العنوان مع زر التحديث
  Widget _buildTitleRow() {
    return Row(
      children: [
        // أيقونة
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        // العنوان
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'حسابي',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'إدارة الملف الشخصي',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        // زر التحديث
        if (onRefresh != null)
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
      ],
    );
  }

  /// بناء صورة الملف الشخصي
  Widget _buildProfileAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // الحلقة الخارجية
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
            ),
          ),
        ),
        // الصورة
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: Colors.white,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: profile.avatar != null && profile.avatar!.isNotEmpty
                ? Image.network(
                    profile.avatar!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildAvatarPlaceholder(),
                  )
                : _buildAvatarPlaceholder(),
          ),
        ),
        // زر تعديل الصورة
        if (onEditPhoto != null)
          Positioned(
            bottom: 0,
            left: 0,
            child: GestureDetector(
              onTap: onEditPhoto,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _primaryPurple,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryPurple.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// بناء placeholder للصورة
  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.purpleLight.withOpacity(0.3),
      child: Icon(
        Icons.person_rounded,
        size: 36,
        color: _primaryPurple.withOpacity(0.7),
      ),
    );
  }

  /// بناء معلومات المستخدم
  Widget _buildUserInfo() {
    return Column(
      children: [
        // الاسم
        Text(
          profile.fullName,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        // البريد الإلكتروني
        Text(
          profile.email,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
        // المعلومات الأكاديمية
        if (profile.hasAcademicProfile) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Text(
              '${profile.yearName ?? ''} • ${profile.streamName ?? ''}',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// بناء صف الإحصائيات السريعة
  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.emoji_events_rounded,
          value: profile.points.toString(),
          label: 'النقاط',
          iconBgColor: AppColors.warningYellow,
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          icon: Icons.star_rounded,
          value: profile.level.toString(),
          label: 'المستوى',
          iconBgColor: AppColors.violet500,
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          icon: Icons.local_fire_department_rounded,
          value: profile.streak.toString(),
          label: 'السلسلة',
          iconBgColor: AppColors.fireRed,
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          icon: Icons.access_time_rounded,
          value: profile.totalStudyHours.toStringAsFixed(0),
          label: 'ساعات',
          iconBgColor: AppColors.emerald500,
        ),
      ],
    );
  }

  /// بناء بطاقة إحصائية واحدة بتأثير glass-morphism
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconBgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconBgColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 14, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 9,
                color: Colors.white.withOpacity(0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء القاع المنحني
  Widget _buildCurvedBottom() {
    return Container(
      height: 20,
      decoration: const BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );
  }
}
