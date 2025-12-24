import 'package:flutter/material.dart';

/// Application color palette - Arabic RTL design
class AppColors {
  AppColors._();

  // Primary Colors (Purple Theme)
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF6D28D9);

  // Primary Gradient Colors (for individual access)
  static const Color primaryGradientStart = Color(0xFF7C3AED);
  static const Color primaryGradientMiddle = Color(0xFF8B5CF6);
  static const Color primaryGradientEnd = Color(0xFF6D28D9);

  // Purple Theme Extended Palette
  static const Color purpleLight = Color(0xFFA78BFA);
  static const Color purpleBgLight = Color(0xFFF5F3FF);
  static const Color purpleCardBg = Color(0xFFEDE9FE);
  static const Color purpleBorder = Color(0xFFDDD6FE);

  // Subject-Specific Colors
  static const Color mathematics = Color(0xFF2196F3); // Blue
  static const Color physics = Color(0xFF9C27B0); // Purple
  static const Color purple = Color(0xFF9C27B0); // Purple (alias for physics)
  static const Color chemistry = Color(0xFF00BCD4); // Cyan
  static const Color cyan = Color(0xFF00BCD4); // Cyan (alias for chemistry)
  static const Color arabic = Color(0xFF4CAF50); // Green
  static const Color french = Color(0xFFFF5722); // Deep Orange
  static const Color english = Color(0xFFF44336); // Red
  static const Color history = Color(0xFF795548); // Brown
  static const Color geography = Color(0xFF009688); // Teal
  static const Color philosophy = Color(0xFF673AB7); // Deep Purple
  static const Color islamic = Color(0xFF8BC34A); // Light Green

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF7C3AED);

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFAFAFA);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Additional UI Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);
  static const Color border = Color(0xFFE0E0E0);
  static const Color textTertiary = Color(0xFF9E9E9E);

  // Enhanced Text Colors (for modern design)
  static const Color textDark = Color(0xFF0F172A); // Slate 900 - for dark text
  static const Color textMedium = Color(0xFF475569); // Slate 600 - for medium emphasis

  // Border Colors with Opacity
  static const Color borderLight = Color(0xFFEEEEEE); // Grey[200]
  static const Color borderMedium = Color(0xFFE0E0E0); // Grey[300]

  // Shadow Colors for Cards (Purple Theme)
  static const Color shadowPrimary = Color(0x667C3AED); // Purple @ 40% opacity
  static const Color shadowPrimaryLight = Color(0x4D7C3AED); // Purple @ 30% opacity
  static const Color shadowPrimarySubtle = Color(0x337C3AED); // Purple @ 20% opacity
  static const Color shadowDark = Color(0x08000000); // Black @ 3% opacity

  // Overlay Colors
  static const Color overlayWhite20 = Color(0x33FFFFFF); // White @ 20%
  static const Color overlayWhite10 = Color(0x1AFFFFFF); // White @ 10%
  static const Color overlayWhite5 = Color(0x0DFFFFFF); // White @ 5%
  static const Color overlayMedium = Color(0x80000000); // Black @ 50%

  // Background Opacity Colors (for glassmorphism)
  static const Color backgroundOverlay = Color(0xF2FFFFFF); // White @ 95%

  // Accent Colors (for badges and highlights)
  static const Color fireRed = Color(0xFFEF4444); // Red 500
  static const Color successGreen = Color(0xFF10B981); // Emerald 500
  static const Color warningYellow = Color(0xFFF59E0B); // Amber 500

  // Gradients (as color lists for LinearGradient)
  static const List<Color> primaryGradient = [
    Color(0xFF7C3AED),
    Color(0xFF6D28D9),
  ];

  // Hero Card Gradient (3-color for vibrant effect)
  static const List<Color> primaryGradientHero = [
    Color(0xFFA78BFA), // Light Purple
    Color(0xFF7C3AED), // Primary Purple
    Color(0xFF6D28D9), // Dark Purple
  ];

  // Purple Theme Gradient
  static const List<Color> purpleGradient = [
    Color(0xFF7C3AED),
    Color(0xFF8B5CF6),
  ];

  static const List<Color> infoGradient = [
    Color(0xFF42A5F5),
    Color(0xFF1E88E5),
  ];

  static const List<Color> successGradient = [
    Color(0xFF66BB6A),
    Color(0xFF43A047),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFFFB74D),
    Color(0xFFFFA726),
  ];

  static const List<Color> mathGradient = [
    Color(0xFF42A5F5),
    Color(0xFF1E88E5),
  ];

  static const List<Color> physicsGradient = [
    Color(0xFFAB47BC),
    Color(0xFF8E24AA),
  ];

  static const List<Color> chemistryGradient = [
    Color(0xFF26C6DA),
    Color(0xFF00ACC1),
  ];

  static const List<Color> literatureGradient = [
    Color(0xFF66BB6A),
    Color(0xFF43A047),
  ];

  /// Get subject color by subject name
  static Color getSubjectColor(String subjectName) {
    final name = subjectName.toLowerCase();
    if (name.contains('رياضيات') || name.contains('math')) return mathematics;
    if (name.contains('فيزياء') || name.contains('physi')) return physics;
    if (name.contains('كيمياء') || name.contains('chimi')) return chemistry;
    if (name.contains('عربية') || name.contains('arab')) return arabic;
    if (name.contains('فرنسية') || name.contains('fran')) return french;
    if (name.contains('إنجليزية') || name.contains('angl')) return english;
    if (name.contains('تاريخ') || name.contains('histoi')) return history;
    if (name.contains('جغرافيا') || name.contains('géog')) return geography;
    if (name.contains('فلسفة') || name.contains('philos')) return philosophy;
    if (name.contains('إسلامية') || name.contains('islam')) return islamic;
    return primary; // Default color
  }

  // ==================== Modern UI Colors (Tailwind/Session Detail Style) ====================

  /// Slate Background - Light grey background for screens
  static const Color slateBackground = Color(0xFFF8FAFC);

  /// Slate 900 - Dark text color
  static const Color slate900 = Color(0xFF1E293B);

  /// Slate 600 - Medium grey text
  static const Color slate600 = Color(0xFF475569);

  /// Slate 500 - Light grey text
  static const Color slate500 = Color(0xFF64748B);

  /// Blue 500 - Primary action color
  static const Color blue500 = Color(0xFF3B82F6);

  /// Violet 500 - Secondary accent
  static const Color violet500 = Color(0xFF8B5CF6);

  /// Emerald 500 - Success/active color
  static const Color emerald500 = Color(0xFF10B981);

  /// Amber 500 - Warning color
  static const Color amber500 = Color(0xFFF59E0B);

  /// Amber 600 - Darker warning color
  static const Color amber600 = Color(0xFFD97706);

  /// Red 500 - Error/danger color
  static const Color red500 = Color(0xFFEF4444);

  /// Cyan 500 - Info color
  static const Color cyan500 = Color(0xFF06B6D4);

  /// Teal 500 - Alternative accent
  static const Color teal500 = Color(0xFF14B8A6);

  /// Orange 500 - Highlight color
  static const Color orange500 = Color(0xFFF97316);

  /// Stone 500 - Neutral grey
  static const Color stone500 = Color(0xFF78716C);

  /// Indigo 500 - Deep purple
  static const Color indigo500 = Color(0xFF6366F1);

  // Modern Gradients
  static const List<Color> blueVioletGradient = [
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
  ];

  static const List<Color> greenGradient = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];

  static const List<Color> violetGradient = [
    Color(0xFF8B5CF6),
    Color(0xFFA78BFA),
  ];

  /// Get stream gradient colors
  static List<Color> getStreamGradient(String streamSlug) {
    switch (streamSlug) {
      case 'math':
      case 'sciences-math':
        return mathGradient;
      case 'experimental':
      case 'sciences-exp':
        return physicsGradient;
      case 'literature':
      case 'lettres':
        return literatureGradient;
      case 'languages':
        return successGradient;
      default:
        return infoGradient;
    }
  }
}
