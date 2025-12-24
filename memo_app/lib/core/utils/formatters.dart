import 'package:intl/intl.dart' as intl;

/// Formatting utilities for Arabic RTL display
class Formatters {
  Formatters._();

  /// Map of Western to Eastern Arabic numerals
  static const Map<String, String> _arabicNumerals = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  /// Convert Western numbers to Eastern Arabic numerals
  static String toArabicNumerals(dynamic value) {
    final stringValue = value.toString();
    String result = stringValue;

    _arabicNumerals.forEach((western, eastern) {
      result = result.replaceAll(western, eastern);
    });

    return result;
  }

  /// Convert Eastern Arabic numerals to Western numbers
  static String fromArabicNumerals(String value) {
    String result = value;

    _arabicNumerals.forEach((western, eastern) {
      result = result.replaceAll(eastern, western);
    });

    return result;
  }

  /// Format number with thousands separator (Arabic)
  static String formatNumber(num value, {bool useArabicNumerals = false}) {
    final formatter = intl.NumberFormat('#,###', 'ar');
    final formatted = formatter.format(value);
    return useArabicNumerals ? toArabicNumerals(formatted) : formatted;
  }

  /// Format currency (Algerian Dinar)
  static String formatCurrency(num value, {bool useArabicNumerals = false}) {
    final formatted = '${formatNumber(value, useArabicNumerals: false)} دج';
    return useArabicNumerals ? toArabicNumerals(formatted) : formatted;
  }

  /// Format date in Arabic (e.g., "السبت، 19 نوفمبر 2025")
  static String formatDate(DateTime date, {bool useArabicNumerals = false}) {
    final formatter = intl.DateFormat('EEEE، d MMMM yyyy', 'ar');
    final formatted = formatter.format(date);
    return useArabicNumerals ? toArabicNumerals(formatted) : formatted;
  }

  /// Format time in 24-hour format (e.g., "14:30")
  static String formatTime(DateTime time, {bool useArabicNumerals = false}) {
    final formatter = intl.DateFormat('HH:mm', 'ar');
    final formatted = formatter.format(time);
    return useArabicNumerals ? toArabicNumerals(formatted) : formatted;
  }

  /// Format date and time (e.g., "السبت، 19 نوفمبر 2025 - 14:30")
  static String formatDateTime(
    DateTime dateTime, {
    bool useArabicNumerals = false,
  }) {
    final date = formatDate(dateTime, useArabicNumerals: false);
    final time = formatTime(dateTime, useArabicNumerals: false);
    final formatted = '$date - $time';
    return useArabicNumerals ? toArabicNumerals(formatted) : formatted;
  }

  /// Format relative time (e.g., "منذ 3 دقائق", "منذ ساعتين")
  static String formatRelativeTime(DateTime dateTime, {bool useArabicNumerals = false}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      final formatted = 'منذ $minutes ${_pluralizeArabic(minutes, 'دقيقة', 'دقيقتين', 'دقائق')}';
      return useArabicNumerals ? toArabicNumerals(formatted) : formatted;
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      final formatted = 'منذ $hours ${_pluralizeArabic(hours, 'ساعة', 'ساعتين', 'ساعات')}';
      return useArabicNumerals ? toArabicNumerals(formatted) : formatted;
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      final formatted = 'منذ $days ${_pluralizeArabic(days, 'يوم', 'يومين', 'أيام')}';
      return useArabicNumerals ? toArabicNumerals(formatted) : formatted;
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      final formatted = 'منذ $weeks ${_pluralizeArabic(weeks, 'أسبوع', 'أسبوعين', 'أسابيع')}';
      return useArabicNumerals ? toArabicNumerals(formatted) : formatted;
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      final formatted = 'منذ $months ${_pluralizeArabic(months, 'شهر', 'شهرين', 'أشهر')}';
      return useArabicNumerals ? toArabicNumerals(formatted) : formatted;
    } else {
      final years = (difference.inDays / 365).floor();
      final formatted = 'منذ $years ${_pluralizeArabic(years, 'سنة', 'سنتين', 'سنوات')}';
      return useArabicNumerals ? toArabicNumerals(formatted) : formatted;
    }
  }

  /// Format duration (e.g., "3 ساعات و25 دقيقة")
  static String formatDuration(
    Duration duration, {
    bool useArabicNumerals = false,
  }) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      final formattedHours =
          '${hours} ${_pluralizeArabic(hours, 'ساعة', 'ساعتين', 'ساعات')}';
      final formattedMinutes =
          '${minutes} ${_pluralizeArabic(minutes, 'دقيقة', 'دقيقتين', 'دقائق')}';
      final formatted = '$formattedHours و$formattedMinutes';
      return useArabicNumerals ? toArabicNumerals(formatted) : formatted;
    } else if (hours > 0) {
      final formatted =
          '$hours ${_pluralizeArabic(hours, 'ساعة', 'ساعتين', 'ساعات')}';
      return useArabicNumerals ? toArabicNumerals(formatted) : formatted;
    } else {
      final formatted =
          '$minutes ${_pluralizeArabic(minutes, 'دقيقة', 'دقيقتين', 'دقائق')}';
      return useArabicNumerals ? toArabicNumerals(formatted) : formatted;
    }
  }

  /// Format percentage (e.g., "75٪")
  static String formatPercentage(num value, {bool useArabicNumerals = false}) {
    final formatted = '${value.toStringAsFixed(0)}٪';
    return useArabicNumerals ? toArabicNumerals(formatted) : formatted;
  }

  /// Format file size (e.g., "2.5 MB")
  static String formatFileSize(int bytes, {bool useArabicNumerals = false}) {
    if (bytes < 1024) {
      final formatted = '$bytes B';
      return useArabicNumerals ? toArabicNumerals(formatted) : formatted;
    } else if (bytes < 1024 * 1024) {
      final kb = (bytes / 1024).toStringAsFixed(1);
      final formatted = '$kb KB';
      return useArabicNumerals ? toArabicNumerals(formatted) : formatted;
    } else if (bytes < 1024 * 1024 * 1024) {
      final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
      final formatted = '$mb MB';
      return useArabicNumerals ? toArabicNumerals(formatted) : formatted;
    } else {
      final gb = (bytes / (1024 * 1024 * 1024)).toStringAsFixed(1);
      final formatted = '$gb GB';
      return useArabicNumerals ? toArabicNumerals(formatted) : formatted;
    }
  }

  /// Arabic pluralization helper
  static String _pluralizeArabic(
    int count,
    String singular,
    String dual,
    String plural,
  ) {
    if (count == 1) {
      return singular;
    } else if (count == 2) {
      return dual;
    } else {
      return plural;
    }
  }

  /// Format phone number (Algerian format)
  static String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    // Format as: 0XXX XX XX XX
    if (digitsOnly.startsWith('0') && digitsOnly.length == 10) {
      return '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4, 6)} ${digitsOnly.substring(6, 8)} ${digitsOnly.substring(8)}';
    }
    // Format as: +213 XXX XX XX XX
    else if (digitsOnly.startsWith('213') && digitsOnly.length == 12) {
      return '+213 ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6, 8)} ${digitsOnly.substring(8, 10)} ${digitsOnly.substring(10)}';
    }

    return phone; // Return original if format doesn't match
  }
}
