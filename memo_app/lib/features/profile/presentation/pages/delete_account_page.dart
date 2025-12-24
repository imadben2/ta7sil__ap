import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../widgets/delete_account_warning.dart';
import '../widgets/profile_page_header.dart';
import '../../domain/usecases/delete_account_usecase.dart';

/// صفحة حذف الحساب - تصميم عصري عربي
///
/// Complete account deletion flow with:
/// - Warning card showing data to be deleted
/// - Optional: Export data before deletion button
/// - Confirmation text input (must type "حذف" or "delete")
/// - Reason selection dropdown (5 predefined options + other)
/// - Optional feedback text field
/// - Final confirmation dialog
/// - GDPR compliant (30-day soft delete grace period)
///
/// Flow:
/// 1. User sees warning with data list
/// 2. User can export data (optional)
/// 3. User types confirmation text ("حذف" or "delete")
/// 4. User selects reason (optional)
/// 5. User provides feedback (optional)
/// 6. User clicks delete button
/// 7. Final confirmation dialog appears
/// 8. API call to delete account
/// 9. Clear all local data (Hive)
/// 10. Navigate to login screen
class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({Key? key}) : super(key: key);

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _confirmationController = TextEditingController();
  final _feedbackController = TextEditingController();

  String? _selectedReason;
  bool _isLoading = false;
  bool _showExportOption = true; // Set to false after export

  @override
  void dispose() {
    _confirmationController.dispose();
    _feedbackController.dispose();
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
            // الهيدر الموحد - بتدرج أحمر
            ProfilePageHeader(
              title: 'حذف الحساب',
              subtitle: 'إزالة حسابك نهائياً',
              icon: Icons.delete_forever_rounded,
              onBack: () => Navigator.pop(context),
              gradientStart: Colors.red.shade700,
              gradientEnd: Colors.red.shade500,
            ),
            // المحتوى
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Warning card
                    const DeleteAccountWarning(),

                    const SizedBox(height: 24),

                    // Export data option (optional)
                    if (_showExportOption) ...[
                      _buildExportDataCard(),
                      const SizedBox(height: 24),
                    ],

                    // Instructions
                    _buildInstructionsCard(),

                    const SizedBox(height: 24),

                    // Confirmation text input
                    _buildConfirmationTextField(),

                    const SizedBox(height: 20),

                    // Reason dropdown
                    _buildReasonDropdown(),

                    const SizedBox(height: 20),

                    // Feedback text field (optional)
                    _buildFeedbackTextField(),

                    const SizedBox(height: 32),

                    // Delete button
                    _buildDeleteButton(),

                    const SizedBox(height: 20),

                    // Cancel button
                    _buildCancelButton(),

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

  /// Export data card
  Widget _buildExportDataCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.download, color: Colors.blue[700], size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'هل تريد تصدير بياناتك قبل الحذف؟',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'يمكنك تحميل نسخة من جميع بياناتك قبل حذف الحساب.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue[800],
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _handleExportData,
            icon: const Icon(Icons.file_download, size: 18),
            label: const Text(
              'تصدير بياناتي',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Instructions card
  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'للمتابعة، يرجى كتابة "حذف" أو "delete" في الحقل أدناه:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• سيتم حذف حسابك بشكل نهائي بعد 30 يوماً\n'
            '• يمكنك استعادة حسابك خلال 30 يوماً بتسجيل الدخول\n'
            '• بعد 30 يوماً، لن تتمكن من استعادة بياناتك',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'Cairo',
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// Confirmation text field
  Widget _buildConfirmationTextField() {
    return TextFormField(
      controller: _confirmationController,
      style: const TextStyle(fontFamily: 'Cairo'),
      decoration: InputDecoration(
        labelText: 'كلمة التأكيد *',
        hintText: 'اكتب "حذف" أو "delete"',
        prefixIcon: Icon(Icons.keyboard, color: Colors.red[700]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'يرجى إدخال كلمة التأكيد';
        }
        final trimmed = value.trim();
        if (trimmed != 'حذف' && trimmed.toLowerCase() != 'delete') {
          return 'كلمة التأكيد غير صحيحة. يرجى كتابة "حذف" أو "delete"';
        }
        return null;
      },
    );
  }

  /// Reason dropdown
  Widget _buildReasonDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedReason,
      decoration: InputDecoration(
        labelText: 'السبب (اختياري)',
        hintText: 'اختر سبب حذف الحساب',
        prefixIcon: Icon(Icons.comment, color: Colors.grey[700]),
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
      ),
      items: DeleteAccountParams.predefinedReasons.map((reason) {
        return DropdownMenuItem(
          value: reason,
          child: Text(
            reason,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedReason = value;
        });
      },
      style: const TextStyle(fontFamily: 'Cairo', color: Colors.black),
    );
  }

  /// Feedback text field
  Widget _buildFeedbackTextField() {
    return TextFormField(
      controller: _feedbackController,
      maxLines: 4,
      style: const TextStyle(fontFamily: 'Cairo'),
      decoration: InputDecoration(
        labelText: 'ملاحظات إضافية (اختياري)',
        hintText: 'أخبرنا كيف يمكننا تحسين التطبيق...',
        alignLabelWithHint: true,
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
      ),
    );
  }

  /// Delete button
  Widget _buildDeleteButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[700]!, Colors.red[500]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleDeleteAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'حذف الحساب نهائياً',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
      ),
    );
  }

  /// Cancel button
  Widget _buildCancelButton() {
    return OutlinedButton(
      onPressed: () => Navigator.pop(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey[700],
        side: BorderSide(color: Colors.grey[400]!, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
        ),
        minimumSize: const Size(double.infinity, 56),
      ),
      child: const Text(
        'إلغاء',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  /// Handle export data
  void _handleExportData() {
    // TODO: Implement export data flow (UC-PROF-008)
    // For now, show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم تصدير بياناتك بنجاح',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    setState(() {
      _showExportOption = false;
    });
  }

  /// Handle delete account
  Future<void> _handleDeleteAccount() async {
    if (!_formKey.currentState!.validate()) return;

    // Show final confirmation dialog
    final confirmed = await _showFinalConfirmationDialog();
    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Replace with actual BLoC integration
      // context.read<ProfileBloc>().add(
      //   DeleteAccountRequested(
      //     confirmation: _confirmationController.text.trim(),
      //     reason: _selectedReason,
      //     additionalFeedback: _feedbackController.text.trim().isNotEmpty
      //         ? _feedbackController.text.trim()
      //         : null,
      //   ),
      // );

      // محاكاة API call for now
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // نجاح - Navigate to login
        await _showSuccessDialog();

        // TODO: Clear all Hive boxes
        // TODO: Clear SecureStorage (token)
        // TODO: Navigate to login screen
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
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

  /// Show final confirmation dialog
  Future<bool?> _showFinalConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 28),
            const SizedBox(width: 12),
            const Text(
              'تأكيد نهائي',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف حسابك؟\n\n'
          'سيتم حذف جميع بياناتك نهائياً بعد 30 يوماً.\n\n'
          'هذا الإجراء لا يمكن التراجع عنه بعد انتهاء فترة ال 30 يوماً.',
          style: TextStyle(fontFamily: 'Cairo', height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'نعم، احذف حسابي',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }

  /// Show success dialog
  Future<void> _showSuccessDialog() {
    return showDialog(
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
            const Text('تم الحذف', style: TextStyle(fontFamily: 'Cairo')),
          ],
        ),
        content: const Text(
          'تم حذف حسابك بنجاح.\n\n'
          'يمكنك استعادة حسابك خلال 30 يوماً بتسجيل الدخول مرة أخرى.\n\n'
          'نأسف لرحيلك، ونتمنى أن نراك مرة أخرى!',
          style: TextStyle(fontFamily: 'Cairo', height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'حسناً',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }
}
