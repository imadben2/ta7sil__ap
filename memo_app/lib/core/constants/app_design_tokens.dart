import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized design tokens for the unified design system
/// Based on the modern home_page.dart design patterns
class AppDesignTokens {
  AppDesignTokens._();

  // ==================== CONTAINER SIZES ====================

  /// Hero card height (large feature cards like points display)
  static const double heroCardHeight = 200.0;

  /// Stats card height (medium info cards)
  static const double statsCardHeight = 120.0;

  /// Mini stat card height (small stat displays)
  static const double miniStatCardHeight = 90.0;

  /// Icon container sizes
  static const double iconContainerXL = 56.0; // Large icons (sessions, subjects)
  static const double iconContainerLG = 50.0; // Medium-large icons
  static const double iconContainerMD = 44.0; // Medium icons (mini stats)
  static const double iconContainerSM = 36.0; // Small icons

  /// Badge sizes
  static const double badgeSizeSmall = 20.0;
  static const double badgeSizeMedium = 28.0;
  static const double badgeSizeLarge = 36.0;

  /// Progress bar heights
  static const double progressBarThin = 6.0;
  static const double progressBarMedium = 8.0;
  static const double progressBarThick = 10.0;

  // ==================== BORDER RADIUS ====================

  /// Hero card border radius (extra large cards)
  static const double borderRadiusHero = 28.0;

  /// Standard card border radius
  static const double borderRadiusCard = 20.0;

  /// Medium border radius (session cards, badges)
  static const double borderRadiusMedium = 18.0;

  /// Icon container border radius
  static const double borderRadiusIcon = 14.0;

  /// Large border radius (special containers, modals)
  static const double borderRadiusLarge = 30.0;

  /// Small border radius (buttons, chips)
  static const double borderRadiusSmall = 12.0;

  /// Tiny border radius (progress bars, badges)
  static const double borderRadiusTiny = 10.0;

  /// Extra small border radius (compact elements)
  static const double borderRadiusXSmall = 8.0;

  // ==================== SPACING ====================

  /// Grid spacing between cards
  static const double gridSpacing = 14.0;

  /// Section spacing (between major sections)
  static const double sectionSpacing = 24.0;

  /// Card internal padding
  static const double cardPaddingLarge = 20.0;
  static const double cardPaddingMedium = 18.0;
  static const double cardPaddingSmall = 16.0;

  /// Screen horizontal padding
  static const double screenPaddingHorizontal = 24.0;

  /// Vertical spacing between elements
  static const double spacingXXS = 4.0; // Alias for spacingXS
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 12.0;
  static const double spacingLG = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 40.0;

  // ==================== ANIMATION DURATIONS ====================

  /// Fast animations (button presses, small transitions)
  static const Duration animationFast = Duration(milliseconds: 200);

  /// Normal animations (card animations, navigation)
  static const Duration animationNormal = Duration(milliseconds: 300);

  /// Slow animations (page transitions, complex animations)
  static const Duration animationSlow = Duration(milliseconds: 800);

  /// Refresh indicator delay
  static const Duration refreshDelay = Duration(seconds: 1);

  // ==================== ANIMATION CURVES ====================

  /// Standard easing curve
  static const Curve curveStandard = Curves.easeInOut;

  /// Emphasized easing (for important transitions)
  static const Curve curveEmphasized = Curves.easeInOutCubic;

  /// Deceleration curve (for entry animations)
  static const Curve curveDecelerate = Curves.easeOut;

  /// Acceleration curve (for exit animations)
  static const Curve curveAccelerate = Curves.easeIn;

  // ==================== SHADOWS ====================

  /// Small shadow (subtle elevation)
  static BoxShadow get shadowSM => BoxShadow(
        color: AppColors.shadowDark,
        blurRadius: 8,
        offset: const Offset(0, 2),
      );

  /// Medium shadow (standard cards)
  static BoxShadow get shadowMD => BoxShadow(
        color: AppColors.shadowDark,
        blurRadius: 12,
        offset: const Offset(0, 4),
      );

  /// Large shadow (elevated cards)
  static BoxShadow get shadowLG => BoxShadow(
        color: AppColors.shadowDark,
        blurRadius: 16,
        offset: const Offset(0, 6),
      );

  /// Primary shadow (for hero cards with primary color)
  static BoxShadow get shadowPrimary => BoxShadow(
        color: AppColors.shadowPrimary,
        blurRadius: 24,
        offset: const Offset(0, 12),
      );

  /// Primary light shadow (for medium primary cards)
  static BoxShadow get shadowPrimaryLight => BoxShadow(
        color: AppColors.shadowPrimaryLight,
        blurRadius: 20,
        offset: const Offset(0, 8),
      );

  /// Primary subtle shadow (for light primary elements)
  static BoxShadow get shadowPrimarySubtle => BoxShadow(
        color: AppColors.shadowPrimarySubtle,
        blurRadius: 16,
        offset: const Offset(0, 6),
      );

  /// Card shadow (alias for shadowMD)
  static BoxShadow get shadowCard => shadowMD;

  // ==================== BORDER WIDTHS ====================

  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 1.5;
  static const double borderWidthThick = 2.0;

  // ==================== OPACITY VALUES ====================

  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.60;
  static const double opacityHigh = 0.87;
  static const double opacityOverlay = 0.20;
  static const double opacitySubtle = 0.10;
  static const double opacityVerySubtle = 0.05;

  // ==================== ICON SIZES ====================

  static const double iconSizeXS = 16.0;
  static const double iconSizeSM = 20.0;
  static const double iconSizeMD = 24.0;
  static const double iconSizeLG = 28.0;
  static const double iconSizeXL = 32.0;
  static const double iconSizeXXL = 40.0;

  // ==================== FONT SIZES ====================

  /// Display sizes (large headers)
  static const double fontSizeDisplay = 48.0;
  static const double fontSizeH2 = 48.0; // Alias for fontSizeDisplay
  static const double fontSizeDisplaySmall = 32.0;
  static const double fontSizeH3 = 32.0; // Alias for fontSizeDisplaySmall

  /// Headline sizes
  static const double fontSizeHeadline = 28.0;
  static const double fontSizeH4 = 28.0; // Alias for fontSizeHeadline
  static const double fontSizeHeadlineSmall = 24.0;

  /// Title sizes
  static const double fontSizeTitle = 20.0;
  static const double fontSizeH5 = 20.0; // Alias for fontSizeTitle
  static const double fontSizeTitleSmall = 18.0;

  /// Body sizes
  static const double fontSizeBody = 16.0;
  static const double fontSizeBodySmall = 14.0;
  static const double fontSizeSmall = 14.0; // Alias for fontSizeBodySmall

  /// Label/Caption sizes
  static const double fontSizeLabel = 12.0;
  static const double fontSizeCaption = 11.0;
  static const double fontSizeTiny = 10.0;

  // ==================== GRID CONFIGURATIONS ====================

  /// Number of columns for subject grid
  static const int gridColumnsSubjects = 2;

  /// Aspect ratio for subject cards
  static const double aspectRatioSubjectCard = 0.85;

  /// Aspect ratio for square cards
  static const double aspectRatioSquare = 1.0;

  /// Aspect ratio for wide cards
  static const double aspectRatioWide = 1.5;

  // ==================== COMMON PADDINGS (EdgeInsets) ====================

  /// Screen padding (horizontal)
  static const EdgeInsets paddingScreen =
      EdgeInsets.symmetric(horizontal: screenPaddingHorizontal);

  /// Card padding (all sides)
  static const EdgeInsets paddingCard = EdgeInsets.all(cardPaddingMedium);

  /// Card padding (large)
  static const EdgeInsets paddingCardLarge = EdgeInsets.all(cardPaddingLarge);

  /// Small padding
  static const EdgeInsets paddingSmall = EdgeInsets.all(spacingMD);

  /// Button padding
  static const EdgeInsets paddingButton =
      EdgeInsets.symmetric(horizontal: 24, vertical: 12);

  // ==================== FEATURE FLAGS ====================

  /// Enable/disable floating action button on home screen
  /// Set to true to show FAB for quick access to courses
  static const bool enableCourseFAB = false;

  // ==================== BLUR VALUES ====================

  /// Glassmorphism blur (for modern bottom nav)
  static const double blurGlassmorphism = 10.0;

  /// Light blur effect
  static const double blurLight = 5.0;

  /// Heavy blur effect
  static const double blurHeavy = 20.0;

  // ==================== HELPER METHODS ====================

  /// Get shadow for card based on elevation level
  static BoxShadow getShadow(String level) {
    switch (level) {
      case 'sm':
        return shadowSM;
      case 'md':
        return shadowMD;
      case 'lg':
        return shadowLG;
      case 'primary':
        return shadowPrimary;
      case 'primary-light':
        return shadowPrimaryLight;
      case 'primary-subtle':
        return shadowPrimarySubtle;
      default:
        return shadowMD;
    }
  }

  /// Get animation duration based on speed
  static Duration getAnimationDuration(String speed) {
    switch (speed) {
      case 'fast':
        return animationFast;
      case 'normal':
        return animationNormal;
      case 'slow':
        return animationSlow;
      default:
        return animationNormal;
    }
  }

  /// Get animation curve based on type
  static Curve getAnimationCurve(String type) {
    switch (type) {
      case 'standard':
        return curveStandard;
      case 'emphasized':
        return curveEmphasized;
      case 'decelerate':
        return curveDecelerate;
      case 'accelerate':
        return curveAccelerate;
      default:
        return curveStandard;
    }
  }
}
