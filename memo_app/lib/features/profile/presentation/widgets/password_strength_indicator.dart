import 'package:flutter/material.dart';
import '../../../../core/utils/password_validator.dart';

/// Visual password strength indicator widget
///
/// Displays a colored progress bar with label showing password strength:
/// - 0 (Very Weak): Red, 0% progress - ضعيف جداً
/// - 1 (Weak): Deep Orange, 25% progress - ضعيف
/// - 2 (Fair): Orange, 50% progress - متوسط
/// - 3 (Good): Light Green, 75% progress - قوي
/// - 4 (Very Strong): Green, 100% progress - قوي جداً
///
/// Updates in real-time as the user types in the password field.
class PasswordStrengthIndicator extends StatelessWidget {
  /// The password to calculate strength for
  final String password;

  /// Optional height for the progress bar (default: 8.0)
  final double height;

  /// Optional border radius (default: 4.0)
  final double borderRadius;

  /// Whether to show the text label (default: true)
  final bool showLabel;

  const PasswordStrengthIndicator({
    Key? key,
    required this.password,
    this.height = 8.0,
    this.borderRadius = 4.0,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strength = PasswordValidator.calculateStrength(password);
    final label = PasswordValidator.getStrengthLabel(strength);
    final colorValue = PasswordValidator.getStrengthColor(strength);
    final color = Color(colorValue);
    final progress = _getProgress(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Label (if enabled)
        if (showLabel && password.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'قوة كلمة المرور:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontFamily: 'Cairo',
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'Cairo',
                ),
                child: Text(label),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Convert strength level (0-4) to progress percentage (0.0-1.0)
  double _getProgress(int strength) {
    switch (strength) {
      case 0:
        return 0.0;
      case 1:
        return 0.25;
      case 2:
        return 0.50;
      case 3:
        return 0.75;
      case 4:
        return 1.0;
      default:
        return 0.0;
    }
  }
}

/// Compact version of password strength indicator (just the bar, no label)
class CompactPasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final double height;

  const CompactPasswordStrengthIndicator({
    Key? key,
    required this.password,
    this.height = 6.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PasswordStrengthIndicator(
      password: password,
      height: height,
      showLabel: false,
    );
  }
}
