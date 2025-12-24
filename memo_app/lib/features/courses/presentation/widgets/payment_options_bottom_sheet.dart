import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import 'subscription_code_dialog.dart';

/// Modern payment options bottom sheet
/// Displays 3 payment methods: Subscription Code, Baridi Mob, CCP
class PaymentOptionsBottomSheet extends StatelessWidget {
  final int courseId;
  final VoidCallback? onCodeRedeemed;
  final BuildContext parentContext;

  const PaymentOptionsBottomSheet({
    super.key,
    required this.courseId,
    required this.parentContext,
    this.onCodeRedeemed,
  });

  /// Show the payment options bottom sheet
  static Future<void> show(
    BuildContext context, {
    required int courseId,
    VoidCallback? onCodeRedeemed,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) => PaymentOptionsBottomSheet(
        courseId: courseId,
        parentContext: context, // Pass the parent context
        onCodeRedeemed: onCodeRedeemed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.85,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8FAFC),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF7C3AED).withOpacity(0.1),
                    const Color(0xFF7C3AED).withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6).withOpacity(0.1),
                    const Color(0xFF3B82F6).withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.textSecondary.withOpacity(0.3),
                            AppColors.textSecondary.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),

                    // Animated icon
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF7C3AED),
                              Color(0xFF9333EA),
                              Color(0xFFC026D3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.payment_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    // Title with gradient
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF1E293B),
                          Color(0xFF475569),
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'اختر طريقة الدفع',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle with icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'يمكنك الاشتراك في الدورة بإحدى الطرق التالية',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              color: AppColors.textSecondary.withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Payment options with staggered animation
                    _buildAnimatedOption(
                      context,
                      delay: 0,
                      icon: Icons.qr_code_scanner_rounded,
                      iconGradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
                      ),
                      title: 'استخدام كود اشتراك',
                      description: 'أدخل الكود المكون من 6 أحرف',
                      badge: 'سريع',
                      onTap: () => _handleCodeOption(context),
                    ),
                    const SizedBox(height: 14),

                    _buildAnimatedOption(
                      context,
                      delay: 100,
                      icon: Icons.phone_android_rounded,
                      iconGradient: const LinearGradient(
                        colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)],
                      ),
                      title: 'الدفع عبر بريدي موب',
                      description: 'قم بتحويل المبلغ ثم أرسل الإيصال',
                      badge: 'قريباً',
                      isDisabled: true,
                      onTap: () => _showComingSoonDialog(context),
                    ),
                    const SizedBox(height: 14),

                    _buildAnimatedOption(
                      context,
                      delay: 200,
                      icon: Icons.account_balance_rounded,
                      iconGradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                      ),
                      title: 'الدفع عبر CCP',
                      description: 'قم بالتحويل البريدي ثم أرسل الإيصال',
                      badge: 'آمن',
                      onTap: () => _handleCCPOption(context),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedOption(
    BuildContext context, {
    required int delay,
    required IconData icon,
    required Gradient iconGradient,
    required String title,
    required String description,
    required String badge,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: _buildPaymentOption(
        context,
        icon: icon,
        iconGradient: iconGradient,
        title: title,
        description: description,
        badge: badge,
        onTap: onTap,
        isDisabled: isDisabled,
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required IconData icon,
    required Gradient iconGradient,
    required String title,
    required String description,
    required String badge,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: iconGradient.colors.first.withOpacity(0.1),
        highlightColor: iconGradient.colors.first.withOpacity(0.05),
        child: Opacity(
          opacity: isDisabled ? 0.6 : 1.0,
          child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDisabled ? const Color(0xFFF1F5F9) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDisabled ? const Color(0xFFD1D5DB) : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: isDisabled ? null : [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon with gradient and glow effect
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: iconGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: iconGradient.colors.first.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow effect
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Text content with badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: iconGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon with circle background
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF64748B),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.construction_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'الخاصية قيد التطوير',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'نعمل على إضافة خدمة الدفع الإلكتروني عبر بريدي موب قريباً.\nيرجى استخدام طرق الدفع الأخرى المتاحة.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'حسناً',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCodeOption(BuildContext context) async {
    // Close bottom sheet first
    Navigator.of(context).pop();

    // Wait a bit for smooth transition
    await Future.delayed(const Duration(milliseconds: 200));

    // Show subscription code dialog using parentContext which has access to SubscriptionBloc
    if (parentContext.mounted) {
      try {
        await SubscriptionCodeDialog.show(
          parentContext, // Use parentContext instead of context
          courseId: courseId,
          onSuccess: onCodeRedeemed,
        );
      } catch (e) {
        // Show error if SubscriptionBloc is not available
        if (parentContext.mounted) {
          ScaffoldMessenger.of(parentContext).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'حدث خطأ: لا يمكن الوصول إلى خدمة الاشتراكات\nالرجاء المحاولة مرة أخرى',
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  void _handleBaridiMobOption(BuildContext context) {
    // Close bottom sheet
    Navigator.of(context).pop();

    // Navigate to payment receipt page with Baridi Mob method
    context.push(
      '/payment-receipt',
      extra: {
        'courseId': courseId,
        'paymentMethod': 'baridimob',
      },
    );
  }

  void _handleCCPOption(BuildContext context) {
    // Close bottom sheet
    Navigator.of(context).pop();

    // Navigate to payment receipt page with CCP method
    context.push(
      '/payment-receipt',
      extra: {
        'courseId': courseId,
        'paymentMethod': 'ccp',
      },
    );
  }
}
