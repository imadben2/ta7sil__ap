import 'package:flutter/material.dart';
import '../../../../core/utils/password_validator.dart';

/// Password requirements checklist widget
///
/// Displays a list of 5 password requirements with ✓/✗ icons:
/// 1. At least 8 characters - 8 أحرف على الأقل
/// 2. Uppercase letter - حرف كبير
/// 3. Lowercase letter - حرف صغير
/// 4. Digit - رقم
/// 5. Special character - رمز خاص (موصى به)
///
/// Updates in real-time as the user types in the password field.
class PasswordRequirementsChecklist extends StatelessWidget {
  /// The password to check requirements against
  final String password;

  /// Whether to use compact spacing (default: false)
  final bool compact;

  const PasswordRequirementsChecklist({
    Key? key,
    required this.password,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final requirements = PasswordValidator.getRequirements(password);

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'متطلبات كلمة المرور:',
            style: TextStyle(
              fontSize: compact ? 13 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              fontFamily: 'Cairo',
            ),
          ),
          SizedBox(height: compact ? 8 : 12),

          // Requirements list
          _buildRequirementItem(
            context: context,
            isMet: requirements['minLength']!,
            label: '8 أحرف على الأقل',
            compact: compact,
          ),
          _buildRequirementItem(
            context: context,
            isMet: requirements['hasUppercase']!,
            label: 'حرف كبير (A-Z)',
            compact: compact,
          ),
          _buildRequirementItem(
            context: context,
            isMet: requirements['hasLowercase']!,
            label: 'حرف صغير (a-z)',
            compact: compact,
          ),
          _buildRequirementItem(
            context: context,
            isMet: requirements['hasDigit']!,
            label: 'رقم (0-9)',
            compact: compact,
          ),
          _buildRequirementItem(
            context: context,
            isMet: requirements['hasSpecialChar']!,
            label: 'رمز خاص (!@#\$%)',
            isRecommended: true,
            compact: compact,
          ),
        ],
      ),
    );
  }

  /// Build a single requirement item with icon and label
  Widget _buildRequirementItem({
    required BuildContext context,
    required bool isMet,
    required String label,
    bool isRecommended = false,
    required bool compact,
  }) {
    final iconSize = compact ? 16.0 : 18.0;
    final fontSize = compact ? 12.0 : 13.0;
    final verticalPadding = compact ? 4.0 : 6.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        children: [
          // Icon (check or cross)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isMet ? Icons.check_circle : Icons.cancel,
              key: ValueKey(isMet),
              size: iconSize,
              color: isMet ? Colors.green[600] : Colors.grey[400],
            ),
          ),
          const SizedBox(width: 8),

          // Label
          Expanded(
            child: Text(
              isRecommended ? '$label (موصى به)' : label,
              style: TextStyle(
                fontSize: fontSize,
                color: isMet ? Colors.grey[800] : Colors.grey[600],
                fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simplified checklist showing only unmet requirements
class UnmetRequirementsChecklist extends StatelessWidget {
  final String password;

  const UnmetRequirementsChecklist({
    Key? key,
    required this.password,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final requirements = PasswordValidator.getRequirements(password);
    final unmetRequirements = <String>[];

    if (!requirements['minLength']!) unmetRequirements.add('8 أحرف على الأقل');
    if (!requirements['hasUppercase']!) unmetRequirements.add('حرف كبير');
    if (!requirements['hasLowercase']!) unmetRequirements.add('حرف صغير');
    if (!requirements['hasDigit']!) unmetRequirements.add('رقم');

    // Don't show if all met or password is empty
    if (unmetRequirements.isEmpty || password.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red[200]!,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: Colors.red[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'متطلبات مفقودة:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unmetRequirements.join('، '),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red[700],
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
