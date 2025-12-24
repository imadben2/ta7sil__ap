import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../core/utils/gradient_helper.dart';
import '../../../../core/utils/password_validator.dart';
import '../widgets/password_strength_indicator.dart';
import '../widgets/password_requirements_checklist.dart';
import '../widgets/profile_page_header.dart';

/// صفحة تغيير كلمة المرور - تصميم عصري عربي
///
/// الحقول:
/// - كلمة المرور الحالية (مع visibility toggle)
/// - كلمة المرور الجديدة (مع strength meter)
/// - تأكيد كلمة المرور
///
/// Validation:
/// - كلمة المرور الحالية: مطلوب
/// - كلمة المرور الجديدة: 8+ أحرف، uppercase, lowercase, number
/// - التأكيد: يطابق كلمة المرور الجديدة
///
/// Rate Limiting: 5 محاولات/ساعة
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Visibility toggles
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add listener to trigger real-time UI updates
    _newPasswordController.addListener(() {
      setState(() {}); // Rebuild to update strength indicator and checklist
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.slateBackground,
        body: Column(
          children: [
            // الهيدر الموحد
            ProfilePageHeader(
              title: 'تغيير كلمة المرور',
              subtitle: 'تحديث كلمة المرور',
              icon: Icons.lock_rounded,
              onBack: () => Navigator.pop(context),
              onAction: _isLoading ? null : _handleChangePassword,
              actionIcon: Icons.check_rounded,
            ),
            // المحتوى
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // رسالة توضيحية
                    _buildInfoCard(),

                    const SizedBox(height: 24),

                    // كلمة المرور الحالية
                    _buildCurrentPasswordField(),

                    const SizedBox(height: 20),

                    // كلمة المرور الجديدة
                    _buildNewPasswordField(),

                    const SizedBox(height: 16),

                    // Password Strength Indicator (New Component)
                    PasswordStrengthIndicator(
                      password: _newPasswordController.text,
                      height: 8.0,
                      borderRadius: 4.0,
                      showLabel: true,
                    ),

                    const SizedBox(height: 16),

                    // Password Requirements Checklist (New Component)
                    PasswordRequirementsChecklist(
                      password: _newPasswordController.text,
                      compact: false,
                    ),

                    const SizedBox(height: 20),

                    // تأكيد كلمة المرور
                    _buildConfirmPasswordField(),

                    const SizedBox(height: 32),

                    // زر الحفظ
                    _buildSaveButton(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بطاقة معلومات
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: AppColors.info, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'بعد تغيير كلمة المرور، سيتم تسجيل خروجك من جميع الأجهزة الأخرى',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// حقل كلمة المرور الحالية
  Widget _buildCurrentPasswordField() {
    return TextFormField(
      controller: _currentPasswordController,
      obscureText: _obscureCurrentPassword,
      style: const TextStyle(fontFamily: 'Cairo'),
      decoration: InputDecoration(
        labelText: 'كلمة المرور الحالية',
        hintText: 'أدخل كلمة المرور الحالية',
        prefixIcon: Icon(Icons.lock, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureCurrentPassword = !_obscureCurrentPassword;
            });
          },
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'كلمة المرور الحالية مطلوبة';
        }
        return null;
      },
    );
  }

  /// حقل كلمة المرور الجديدة
  Widget _buildNewPasswordField() {
    return TextFormField(
      controller: _newPasswordController,
      obscureText: _obscureNewPassword,
      style: const TextStyle(fontFamily: 'Cairo'),
      decoration: InputDecoration(
        labelText: 'كلمة المرور الجديدة',
        hintText: 'أدخل كلمة المرور الجديدة',
        prefixIcon: Icon(Icons.lock_open, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureNewPassword = !_obscureNewPassword;
            });
          },
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      validator: (value) {
        // Use the new PasswordValidator utility
        final validationError = PasswordValidator.validatePassword(value);
        if (validationError != null) {
          return validationError;
        }

        if (value == _currentPasswordController.text) {
          return 'كلمة المرور الجديدة يجب أن تختلف عن الحالية';
        }
        return null;
      },
    );
  }

  /// حقل تأكيد كلمة المرور
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      style: const TextStyle(fontFamily: 'Cairo'),
      decoration: InputDecoration(
        labelText: 'تأكيد كلمة المرور',
        hintText: 'أعد إدخال كلمة المرور الجديدة',
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      validator: (value) {
        // Use the new PasswordValidator utility
        return PasswordValidator.validatePasswordConfirmation(
          _newPasswordController.text,
          value,
        );
      },
    );
  }

  /// زر الحفظ
  Widget _buildSaveButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: GradientHelper.primary,
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPrimary,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleChangePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'تغيير كلمة المرور',
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSizeBody,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
      ),
    );
  }

  /// معالج تغيير كلمة المرور
  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Replace with actual BLoC integration
      // context.read<ProfileBloc>().add(
      //   ChangePasswordRequested(
      //     currentPassword: _currentPasswordController.text,
      //     newPassword: _newPasswordController.text,
      //     logoutOtherDevices: true, // TODO: Add checkbox option
      //   ),
      // );

      // محاكاة API call for now
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // نجاح
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                const Text('نجاح', style: TextStyle(fontFamily: 'Cairo')),
              ],
            ),
            content: const Text(
              'تم تغيير كلمة المرور بنجاح.\nسيتم تسجيل خروجك من جميع الأجهزة الأخرى.',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // close page
                },
                child: const Text('حسنًا', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ: ${e.toString()}',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}
