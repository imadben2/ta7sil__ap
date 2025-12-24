import '../constants/app_strings_ar.dart';

/// Form validation utilities
class Validators {
  Validators._();

  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStringsAr.validationEmailRequired;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return AppStringsAr.errorInvalidEmail;
    }

    return null;
  }

  /// Validate password strength
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return AppStringsAr.validationPasswordRequired;
    }

    if (value.length < minLength) {
      return AppStringsAr.validationPasswordLength;
    }

    return null;
  }

  /// Validate password confirmation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return AppStringsAr.validationPasswordRequired;
    }

    if (value != password) {
      return AppStringsAr.errorPasswordMismatch;
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? '$fieldName ${AppStringsAr.errorFieldRequired}'
          : AppStringsAr.errorFieldRequired;
    }
    return null;
  }

  /// Validate name (Arabic and Latin characters)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStringsAr.validationNameRequired;
    }

    if (value.length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }

    // Allow Arabic, Latin letters, and spaces
    final nameRegex = RegExp(r'^[\u0600-\u06FFa-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'الاسم يجب أن يحتوي على حروف فقط';
    }

    return null;
  }

  /// Validate Algerian phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return AppStringsAr.validationPhoneRequired;
    }

    // Algerian phone formats: 0XXXXXXXXX, 213XXXXXXXXX, +213XXXXXXXXX
    final phoneRegex = RegExp(r'^(\+?213|0)[5-7][0-9]{8}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\s'), ''))) {
      return 'رقم الهاتف غير صالح';
    }

    return null;
  }

  /// Validate number input
  static String? validateNumber(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return AppStringsAr.errorFieldRequired;
    }

    final number = int.tryParse(value);
    if (number == null) {
      return 'يجب إدخال رقم صحيح';
    }

    if (min != null && number < min) {
      return 'القيمة يجب أن تكون $min على الأقل';
    }

    if (max != null && number > max) {
      return 'القيمة يجب أن تكون $max على الأكثر';
    }

    return null;
  }

  /// Validate URL format
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'رابط غير صالح';
    }

    return null;
  }
}
