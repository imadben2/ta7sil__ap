import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/subscription/subscription_bloc.dart';
import '../bloc/subscription/subscription_event.dart';
import '../bloc/subscription/subscription_state.dart';
import '../../domain/usecases/validate_subscription_code_usecase.dart';
import 'modern_code_input.dart';

/// Premium glassmorphic subscription code dialog
class SubscriptionCodeDialog extends StatefulWidget {
  final SubscriptionBloc subscriptionBloc;
  final int? courseId;
  final VoidCallback? onSuccess;

  const SubscriptionCodeDialog({
    super.key,
    required this.subscriptionBloc,
    this.courseId,
    this.onSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    int? courseId,
    VoidCallback? onSuccess,
  }) {
    try {
      final subscriptionBloc = context.read<SubscriptionBloc>();
      return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => BlocProvider.value(
          value: subscriptionBloc,
          child: SubscriptionCodeDialog(
            subscriptionBloc: subscriptionBloc,
            courseId: courseId,
            onSuccess: onSuccess,
          ),
        ),
      );
    } catch (e) {
      // If SubscriptionBloc is not available, show error
      return Future.error('SubscriptionBloc not found in context: $e');
    }
  }

  @override
  State<SubscriptionCodeDialog> createState() => _SubscriptionCodeDialogState();
}

class _SubscriptionCodeDialogState extends State<SubscriptionCodeDialog>
    with TickerProviderStateMixin {
  final _codeController = TextEditingController();
  final _codeInputKey = GlobalKey<ModernCodeInputState>();
  bool _isValidating = false;
  bool _isRedeeming = false;
  SubscriptionCodeValidationResult? _validatedCodeData;
  String? _errorMessage;

  late AnimationController _backgroundController;
  late AnimationController _successController;
  late AnimationController _slideController;
  late Animation<double> _successScale;
  late Animation<double> _successOpacity;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _successScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _successOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _backgroundController.dispose();
    _successController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onCodeComplete(String code) {
    if (code.length >= 6 && _validatedCodeData == null) {
      _validateCode(code);
    }
  }

  void _validateCode(String code) {
    if (code.trim().isEmpty) {
      _codeInputKey.currentState?.shake();
      return;
    }
    context.read<SubscriptionBloc>().add(ValidateCodeEvent(code: code.trim()));
  }

  void _redeemCode() {
    final code = _codeController.text.trim();
    context.read<SubscriptionBloc>().add(RedeemCodeEvent(code: code));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state is SubscriptionActionInProgress) {
          setState(() {
            if (state.message.contains('التحقق')) {
              _isValidating = true;
              _isRedeeming = false;
            } else if (state.message.contains('تفعيل')) {
              _isValidating = false;
              _isRedeeming = true;
            }
          });
        } else if (state is CodeValidated) {
          setState(() {
            _isValidating = false;
            _validatedCodeData = state.validationResult;
          });
          _successController.forward();
        } else if (state is CodeRedeemed) {
          setState(() => _isRedeeming = false);
          Navigator.of(context).pop();
          _showSuccessSnackBar(state.message);
          // Call onSuccess callback if provided
          widget.onSuccess?.call();
        } else if (state is SubscriptionError) {
          setState(() {
            _isValidating = false;
            _isRedeeming = false;
            _validatedCodeData = null;
            _errorMessage = state.message;
          });
          _codeInputKey.currentState?.shake();
        }
      },
      child: Container(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: Stack(
            children: [
              _buildAnimatedBackground(),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.95),
                        Colors.white.withOpacity(0.98),
                      ],
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                ),
              ),
              SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHandle(),
                          const SizedBox(height: 28),
                          _buildPremiumHeader(),
                          const SizedBox(height: 32),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: _validatedCodeData == null
                                ? _buildCodeSection()
                                : _buildValidationSuccess(),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            _buildErrorMessage(),
                          ],
                          const SizedBox(height: 24),
                          _validatedCodeData == null
                              ? _buildValidateButton()
                              : _buildRedeemButton(),
                          const SizedBox(height: 16),
                          _buildCancelButton(),
                        ],
                      ),
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

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return CustomPaint(
          painter: _BackgroundPainter(animation: _backgroundController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 48,
      height: 5,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
        ),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) =>
              Transform.scale(scale: value, child: child),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFF6366F1),
                  Color(0xFF4F46E5),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: const Icon(Icons.key_rounded, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF475569)],
          ).createShader(bounds),
          child: const Text(
            'تفعيل الاشتراك',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                widget.courseId != null
                    ? 'أدخل كود اشتراك الدورة'
                    : 'أدخل كود التفعيل المكون من 6 أحرف',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCodeSection() {
    return Container(
      key: const ValueKey('code_input'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ModernCodeInput(
            key: _codeInputKey,
            controller: _codeController,
            length: 6,
            onCompleted: _onCodeComplete,
            onChanged: (value) {
              if (_validatedCodeData != null || _errorMessage != null) {
                setState(() {
                  _validatedCodeData = null;
                  _errorMessage = null;
                  _successController.reset();
                });
              }
            },
            enabled: !_isValidating && !_isRedeeming,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFCBD5E1),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'الكود حساس لحالة الأحرف',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFCBD5E1),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEF4444).withOpacity(0.1),
              const Color(0xFFDC2626).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEF4444).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'خطأ في التحقق',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _errorMessage ?? '',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: Color(0xFF7F1D1D),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _errorMessage = null),
              icon: const Icon(
                Icons.close_rounded,
                color: Color(0xFFEF4444),
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationSuccess() {
    final result = _validatedCodeData!;
    return AnimatedBuilder(
      key: const ValueKey('validation_success'),
      animation: _successController,
      builder: (context, child) {
        return Opacity(
          opacity: _successOpacity.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: _successScale.value.clamp(0.0, 1.2),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF10B981).withOpacity(0.08),
              const Color(0xFF059669).withOpacity(0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF10B981).withOpacity(0.25),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF10B981).withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              result.displayTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF047857),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              result.displayDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoCards(result),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCards(SubscriptionCodeValidationResult result) {
    final items = <Widget>[];
    if (result.packageNameAr != null) {
      items.add(_buildInfoCard(
        icon: Icons.workspace_premium_rounded,
        label: 'الباقة',
        value: result.packageNameAr!,
        gradient: const [Color(0xFF8B5CF6), Color(0xFF6366F1)],
      ));
    }
    if (result.courseTitleAr != null) {
      items.add(_buildInfoCard(
        icon: Icons.school_rounded,
        label: 'الدورة',
        value: result.courseTitleAr!,
        gradient: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
      ));
    }
    if (result.durationDays != null) {
      items.add(_buildInfoCard(
        icon: Icons.calendar_today_rounded,
        label: 'المدة',
        value: _formatDuration(result.durationDays!),
        gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
      ));
    }
    if (result.remainingUses != null && result.remainingUses! > 0) {
      items.add(_buildInfoCard(
        icon: Icons.people_rounded,
        label: 'الاستخدامات المتبقية',
        value: '${result.remainingUses}',
        gradient: const [Color(0xFF10B981), Color(0xFF059669)],
      ));
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: items,
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValidateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: _isValidating
            ? LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6).withOpacity(0.6),
                  const Color(0xFF6366F1).withOpacity(0.6),
                ],
              )
            : const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: _isValidating
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isValidating || _isRedeeming
              ? null
              : () => _validateCode(_codeController.text),
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: _isValidating
                ? const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'التحقق من الكود',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildRedeemButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: _isRedeeming
            ? LinearGradient(
                colors: [
                  const Color(0xFF10B981).withOpacity(0.6),
                  const Color(0xFF059669).withOpacity(0.6),
                ],
              )
            : const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: _isRedeeming
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isRedeeming ? null : _redeemCode,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: _isRedeeming
                ? const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'تفعيل الاشتراك الآن',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: _isValidating || _isRedeeming
          ? null
          : () => Navigator.of(context).pop(),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF64748B),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'إلغاء',
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _formatDuration(int days) {
    if (days >= 365) {
      final years = (days / 365).floor();
      return years == 1 ? 'سنة واحدة' : '$years سنوات';
    } else if (days >= 30) {
      final months = (days / 30).floor();
      return months == 1 ? 'شهر واحد' : '$months أشهر';
    } else {
      return days == 1 ? 'يوم واحد' : '$days يوم';
    }
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animation;
  _BackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 6; i++) {
      final progress = (animation + i * 0.15) % 1.0;
      final x = size.width * (0.1 + 0.8 * ((i * 0.17 + progress * 0.3) % 1.0));
      final y = size.height * (0.1 + 0.3 * math.sin(progress * math.pi * 2 + i));
      final radius = 20.0 + 30.0 * math.sin(progress * math.pi + i);
      paint.shader = RadialGradient(
        colors: [
          _getColor(i).withOpacity(0.15 + 0.1 * math.sin(progress * math.pi)),
          _getColor(i).withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius * 2));
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  Color _getColor(int index) {
    final colors = [
      const Color(0xFF8B5CF6),
      const Color(0xFF6366F1),
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
    ];
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
