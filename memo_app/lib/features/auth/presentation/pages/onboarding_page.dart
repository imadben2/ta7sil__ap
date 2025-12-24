import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../core/constants/app_strings_ar.dart';

/// Onboarding page with 3 screens
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      context.go('/auth/login');
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  AppStringsAr.skip,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildPage1Welcome(),
                  _buildPage2Features(),
                  _buildPage3Motivation(),
                ],
              ),
            ),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.textTertiary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Next/Start button
            Padding(
              padding: const EdgeInsets.all(AppDesignTokens.spacingLG),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(
                    _currentPage == 2
                        ? AppStringsAr.getStarted
                        : AppStringsAr.next,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage1Welcome() {
    return Padding(
      padding: const EdgeInsets.all(AppDesignTokens.spacingLG),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration placeholder (emoji for now)
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🎓', style: TextStyle(fontSize: 80)),
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            AppStringsAr.onboardingWelcome,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            'منصتك التعليمية الشاملة لتحضير البكالوريا بأحدث الطرق التعليمية الذكية. نساعدك على تنظيم دراستك وتحقيق أهدافك الأكاديمية',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPage2Features() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDesignTokens.spacingLG),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration placeholder
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppDesignTokens.borderRadiusCard,
              ),
            ),
            child: const Center(
              child: Text('📚', style: TextStyle(fontSize: 80)),
            ),
          ),
          const SizedBox(height: 40),

          // Title
          const Text(
            'كل ما تحتاجه في مكان واحد',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Features list
          _buildFeatureItem('📚', 'دروس تفاعلية', 'محتوى تعليمي غني ومتنوع'),
          const SizedBox(height: 16),
          _buildFeatureItem('📅', 'مخطط ذكي', 'تنظيم وقتك بفعالية'),
          const SizedBox(height: 16),
          _buildFeatureItem('📝', 'اختبارات متنوعة', 'تقييم معرفتك بشكل دوري'),
          const SizedBox(height: 16),
          _buildFeatureItem('📊', 'تتبع التقدم', 'إحصائيات مفصلة عن أدائك'),
          const SizedBox(height: 16),
          _buildFeatureItem('🏆', 'نظام المكافآت', 'نقاط وشارات تحفيزية'),
          const SizedBox(height: 16),
          _buildFeatureItem('📖', 'أرشيف البكالوريا', 'مواضيع وحلول سابقة'),
        ],
      ),
    );
  }

  Widget _buildPage3Motivation() {
    return Padding(
      padding: const EdgeInsets.all(AppDesignTokens.spacingLG),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration placeholder
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🏆', style: TextStyle(fontSize: 80)),
            ),
          ),
          const SizedBox(height: 48),

          // Title
          const Text(
            'ابدأ رحلتك نحو التفوق',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            'انضم إلى آلاف الطلاب الذين يستخدمون ميمو لتحسين نتائجهم الدراسية وتحقيق أحلامهم الأكاديمية. كل خطوة صغيرة تقربك من هدفك الكبير!',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Statistics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('+10,000', 'طالب'),
              _buildStatItem('95%', 'نسبة النجاح'),
              _buildStatItem('+5,000', 'اختبار'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(AppDesignTokens.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppDesignTokens.borderRadiusSmall,
              ),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: AppDesignTokens.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
