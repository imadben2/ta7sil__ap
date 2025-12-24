/// Password validation utility for strength calculation and requirement checking
///
/// Provides comprehensive password validation following security best practices:
/// - Minimum 8 characters
/// - At least one uppercase letter
/// - At least one lowercase letter
/// - At least one digit
/// - At least one special character (recommended)
///
/// Strength levels: 0 (Very Weak) to 4 (Very Strong)
class PasswordValidator {
  /// Calculate password strength on a scale of 0-4
  ///
  /// Returns:
  /// - 0: Very weak (< 8 chars or missing critical requirements)
  /// - 1: Weak (8+ chars, only 1-2 requirements met)
  /// - 2: Fair (8+ chars, 3 requirements met)
  /// - 3: Good (8+ chars, 4 requirements met)
  /// - 4: Strong (8+ chars, all 5 requirements met)
  static int calculateStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;
    final requirements = getRequirements(password);

    // Check each requirement
    if (requirements['minLength']!) strength++;
    if (requirements['hasUppercase']!) strength++;
    if (requirements['hasLowercase']!) strength++;
    if (requirements['hasDigit']!) strength++;
    if (requirements['hasSpecialChar']!) strength++;

    // Adjust strength level
    if (strength == 0) return 0; // Very weak
    if (strength <= 2) return 1; // Weak
    if (strength == 3) return 2; // Fair
    if (strength == 4) return 3; // Good
    return 4; // Strong (all 5 requirements)
  }

  /// Get a map of all password requirements and their status
  ///
  /// Returns a map with keys:
  /// - minLength: At least 8 characters
  /// - hasUppercase: Contains uppercase letter
  /// - hasLowercase: Contains lowercase letter
  /// - hasDigit: Contains digit
  /// - hasSpecialChar: Contains special character
  static Map<String, bool> getRequirements(String password) {
    return {
      'minLength': password.length >= 8,
      'hasUppercase': hasUppercase(password),
      'hasLowercase': hasLowercase(password),
      'hasDigit': hasDigit(password),
      'hasSpecialChar': hasSpecialChar(password),
    };
  }

  /// Check if password contains at least one uppercase letter
  static bool hasUppercase(String value) {
    return RegExp(r'[A-Z]').hasMatch(value);
  }

  /// Check if password contains at least one lowercase letter
  static bool hasLowercase(String value) {
    return RegExp(r'[a-z]').hasMatch(value);
  }

  /// Check if password contains at least one digit
  static bool hasDigit(String value) {
    return RegExp(r'\d').hasMatch(value);
  }

  /// Check if password contains at least one special character
  ///
  /// Accepted special characters: !@#$%^&*(),.?":{}|<>_-+=[]
  static bool hasSpecialChar(String value) {
    return RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]]').hasMatch(value);
  }

  /// Get a human-readable strength label (in Arabic)
  ///
  /// Returns:
  /// - 0: ضعيف جداً (Very Weak)
  /// - 1: ضعيف (Weak)
  /// - 2: متوسط (Fair)
  /// - 3: قوي (Good)
  /// - 4: قوي جداً (Very Strong)
  static String getStrengthLabel(int strength) {
    switch (strength) {
      case 0:
        return 'ضعيف جداً';
      case 1:
        return 'ضعيف';
      case 2:
        return 'متوسط';
      case 3:
        return 'قوي';
      case 4:
        return 'قوي جداً';
      default:
        return 'ضعيف جداً';
    }
  }

  /// Get color for strength level
  ///
  /// Returns a color code based on strength:
  /// - 0: Red (0xFFF44336)
  /// - 1: Deep Orange (0xFFFF5722)
  /// - 2: Orange (0xFFFF9800)
  /// - 3: Light Green (0xFF8BC34A)
  /// - 4: Green (0xFF4CAF50)
  static int getStrengthColor(int strength) {
    switch (strength) {
      case 0:
        return 0xFFF44336; // Red
      case 1:
        return 0xFFFF5722; // Deep Orange
      case 2:
        return 0xFFFF9800; // Orange
      case 3:
        return 0xFF8BC34A; // Light Green
      case 4:
        return 0xFF4CAF50; // Green
      default:
        return 0xFFF44336; // Red
    }
  }

  /// Validate password meets all minimum requirements
  ///
  /// Returns null if valid, error message in Arabic if invalid
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }

    final requirements = getRequirements(value);

    if (!requirements['minLength']!) {
      return 'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل';
    }

    if (!requirements['hasUppercase']!) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }

    if (!requirements['hasLowercase']!) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }

    if (!requirements['hasDigit']!) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }

    // Special char is recommended but not strictly required for validation
    // Only enforce if strength is too weak
    if (calculateStrength(value) < 2) {
      return 'كلمة المرور ضعيفة جداً، يرجى تحسينها';
    }

    return null; // Valid
  }

  /// Validate password confirmation matches
  ///
  /// Returns null if matches, error message in Arabic if doesn't match
  static String? validatePasswordConfirmation(String? password, String? confirmation) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'يرجى تأكيد كلمة المرور';
    }

    if (password != confirmation) {
      return 'كلمة المرور غير متطابقة';
    }

    return null; // Valid
  }
}
