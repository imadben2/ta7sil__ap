import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_state.dart';
import '../bloc/profile/profile_event.dart';
import '../bloc/statistics/statistics_bloc.dart';
import '../../domain/entities/profile_entity.dart';
import '../../../../injection_container.dart';
import '../../../content_library/presentation/bloc/bookmark/bookmark_bloc.dart';
import '../../../content_library/presentation/bloc/bookmark/bookmark_event.dart';
import '../../../content_library/presentation/pages/bookmarks_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../widgets/modern_profile_header.dart';
import '../widgets/modern_profile_menu_card.dart';
import 'statistics_page.dart';
import 'devices_page.dart';

/// صفحة الملف الشخصي - تصميم عصري مطابق لصفحة دوراتي
///
/// التصميم:
/// - Header بنفسجي مع gradient وصورة الملف الشخصي
/// - بطاقات إحصائيات سريعة بتأثير glass-morphism داخل الهيدر
/// - قائمة خيارات ببطاقات حديثة مع ظلال بنفسجية
/// - Material 3 Design
/// - RTL Support كامل
class ProfilePage extends StatefulWidget {
  final bool showAppBar;

  const ProfilePage({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ثوابت الألوان - مطابقة لصفحة دوراتي
  static const _primaryPurple = AppColors.primary;
  static const _bgColor = AppColors.slateBackground;

  @override
  void initState() {
    super.initState();
    // تحميل الملف الشخصي عند فتح الصفحة
    Future.microtask(() {
      context.read<ProfileBloc>().add(LoadProfile());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is DataExported) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تصدير البيانات بنجاح'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is AccountDeleted) {
              context.go('/auth/login');
            }
          },
          builder: (context, state) {
            // Show loading for both initial and loading states
            if (state is ProfileInitial || state is ProfileLoading) {
              return _buildLoadingState();
            }

            ProfileEntity? profile;
            if (state is ProfileLoaded) {
              profile = state.profile;
            } else if (state is ProfileError && state.currentProfile != null) {
              profile = state.currentProfile;
            }

            if (profile == null) {
              return _buildErrorState();
            }

            return _buildContent(profile);
          },
        ),
      ),
    );
  }

  /// حالة التحميل
  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 400,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primaryPurple, AppColors.primaryDark],
              ),
            ),
          ),
        ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryPurple),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'جاري تحميل الملف الشخصي...',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// حالة الخطأ
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _primaryPurple.withOpacity(0.1),
                    AppColors.primaryDark.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: _primaryPurple.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'فشل تحميل الملف الشخصي',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.slate900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'تحقق من اتصالك بالإنترنت وحاول مجدداً',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.slate500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProfileBloc>().add(LoadProfile());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// المحتوى الرئيسي
  Widget _buildContent(ProfileEntity profile) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProfileBloc>().add(LoadProfile());
      },
      color: _primaryPurple,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // الهيدر الحديث مع الإحصائيات
          SliverToBoxAdapter(
            child: ModernProfileHeader(
              profile: profile,
              onEditPhoto: () => context.push('/profile/edit'),
              onRefresh: () => context.read<ProfileBloc>().add(LoadProfile()),
            ),
          ),

          // المحتوى
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // قسم إدارة الحساب
                  const ModernProfileSectionTitle(
                    title: 'إدارة الحساب',
                    icon: Icons.manage_accounts_rounded,
                  ),

                  // بطاقات الخيارات
                  ModernProfileMenuCard(
                    icon: Icons.edit_rounded,
                    iconColor: AppColors.primary,
                    iconBgColor: AppColors.purpleBgLight,
                    title: 'تعديل الملف الشخصي',
                    subtitle: 'تحديث المعلومات الشخصية',
                    onTap: () => context.push('/profile/edit'),
                  ),

                  ModernProfileMenuCard(
                    icon: Icons.card_membership_rounded,
                    iconColor: AppColors.violet500,
                    iconBgColor: const Color(0xFFF5F3FF),
                    title: 'اشتراكاتي',
                    subtitle: 'إدارة الباقات والإيصالات',
                    onTap: () => context.push('/subscriptions'),
                  ),

                  ModernProfileMenuCard(
                    icon: Icons.school_rounded,
                    iconColor: AppColors.indigo500,
                    iconBgColor: const Color(0xFFEEF2FF),
                    title: 'تغيير المرحلة الدراسية',
                    subtitle: 'تحديث الطور والسنة والشعبة',
                    onTap: () => context.push('/auth/academic-selection', extra: true),
                  ),

                  ModernProfileMenuCard(
                    icon: Icons.bar_chart_rounded,
                    iconColor: AppColors.blue500,
                    iconBgColor: const Color(0xFFEFF6FF),
                    title: 'الإحصائيات التفصيلية',
                    subtitle: 'عرض الرسوم البيانية والتقدم',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider<StatisticsBloc>(
                            create: (context) => sl<StatisticsBloc>(),
                            child: const StatisticsPage(),
                          ),
                        ),
                      );
                    },
                  ),

                  ModernProfileMenuCard(
                    icon: Icons.bookmark_rounded,
                    iconColor: AppColors.violet500,
                    iconBgColor: const Color(0xFFF5F3FF),
                    title: 'العلامات المرجعية',
                    subtitle: 'المحتوى المحفوظ',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider<BookmarkBloc>(
                            create: (context) => sl<BookmarkBloc>()..add(const LoadBookmarks()),
                            child: const BookmarksPage(),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // قسم الأمان
                  const ModernProfileSectionTitle(
                    title: 'الأمان والخصوصية',
                    icon: Icons.security_rounded,
                  ),

                  ModernProfileMenuCard(
                    icon: Icons.lock_rounded,
                    iconColor: AppColors.amber500,
                    iconBgColor: const Color(0xFFFFFBEB),
                    title: 'تغيير كلمة المرور',
                    subtitle: 'تحديث كلمة المرور الخاصة بك',
                    onTap: () => context.push('/profile/change-password'),
                  ),

                  ModernProfileMenuCard(
                    icon: Icons.devices_rounded,
                    iconColor: AppColors.teal500,
                    iconBgColor: const Color(0xFFF0FDFA),
                    title: 'الأجهزة المتصلة',
                    subtitle: 'إدارة الأجهزة وجلسات تسجيل الدخول',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DevicesPage()),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // قسم الإعدادات
                  const ModernProfileSectionTitle(
                    title: 'الإعدادات',
                    icon: Icons.settings_rounded,
                  ),

                  ModernProfileMenuCard(
                    icon: Icons.tune_rounded,
                    iconColor: AppColors.emerald500,
                    iconBgColor: const Color(0xFFECFDF5),
                    title: 'الإعدادات العامة',
                    subtitle: 'الإشعارات، اللغة، الثيم',
                    onTap: () => context.push('/profile/settings'),
                  ),

                  ModernProfileMenuCard(
                    icon: Icons.download_rounded,
                    iconColor: AppColors.cyan500,
                    iconBgColor: const Color(0xFFECFEFF),
                    title: 'تصدير البيانات',
                    subtitle: 'تحميل نسخة من بياناتك',
                    onTap: _handleExportData,
                  ),

                  const SizedBox(height: 24),

                  // قسم تسجيل الخروج
                  const ModernProfileSectionTitle(
                    title: 'تسجيل الخروج',
                    icon: Icons.logout_rounded,
                  ),

                  ModernProfileMenuCard(
                    icon: Icons.logout_rounded,
                    iconColor: AppColors.orange500,
                    iconBgColor: const Color(0xFFFFF7ED),
                    title: 'تسجيل الخروج',
                    subtitle: 'الخروج من هذا الجهاز',
                    onTap: _handleLogout,
                  ),

                  const SizedBox(height: 24),

                  // قسم الخطر
                  const ModernProfileSectionTitle(
                    title: 'منطقة الخطر',
                    icon: Icons.warning_rounded,
                  ),

                  ModernProfileMenuCard(
                    icon: Icons.delete_forever_rounded,
                    iconColor: AppColors.error,
                    iconBgColor: const Color(0xFFFEF2F2),
                    title: 'حذف الحساب',
                    subtitle: 'حذف دائم لجميع بياناتك',
                    onTap: _handleDeleteAccount,
                    isDanger: true,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// معالجة تصدير البيانات
  void _handleExportData() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cyan500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.download_rounded,
                color: AppColors.cyan500,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'تصدير البيانات',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: const Text(
          'سيتم تحميل نسخة كاملة من جميع بياناتك بصيغة JSON. هل تريد المتابعة؟',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.slate600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.slate500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProfileBloc>().add(ExportPersonalData());
            },
            child: const Text(
              'تصدير',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }

  /// معالجة تسجيل الخروج
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.orange500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.orange500,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'تسجيل الخروج',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.slate600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.slate500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const LogoutRequested());
              context.go('/auth/login');
            },
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }

  /// معالجة حذف الحساب
  void _handleDeleteAccount() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'تحذير!',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.1),
                ),
              ),
              child: const Text(
                'سيتم حذف حسابك وجميع بياناتك بشكل دائم. هذا الإجراء لا يمكن التراجع عنه.',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'أدخل كلمة المرور للتأكيد:',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.slate900,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.slate500),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error, width: 2),
                ),
                hintText: 'كلمة المرور',
                hintStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.slate500,
                ),
                prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.slate500),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.slate500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'الرجاء إدخال كلمة المرور',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext);
              context.read<ProfileBloc>().add(
                DeleteAccount(password: passwordController.text),
              );
            },
            child: const Text(
              'حذف الحساب',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }
}
