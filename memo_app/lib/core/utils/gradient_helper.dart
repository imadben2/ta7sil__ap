import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Helper class for creating and managing gradients across the app
/// Provides consistent gradient patterns based on the unified design system
class GradientHelper {
  GradientHelper._();

  // ==================== PRIMARY GRADIENTS ====================

  /// Standard primary gradient (2-color)
  static LinearGradient get primary => const LinearGradient(
        colors: AppColors.primaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Hero card gradient (3-color for more vibrant effect)
  static LinearGradient get primaryHero => const LinearGradient(
        colors: AppColors.primaryGradientHero,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Vertical primary gradient
  static LinearGradient get primaryVertical => const LinearGradient(
        colors: AppColors.primaryGradient,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  /// Horizontal primary gradient
  static LinearGradient get primaryHorizontal => const LinearGradient(
        colors: AppColors.primaryGradient,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  // ==================== SUBJECT GRADIENTS ====================

  /// Math gradient
  static LinearGradient get math => const LinearGradient(
        colors: AppColors.mathGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Physics gradient
  static LinearGradient get physics => const LinearGradient(
        colors: AppColors.physicsGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Chemistry gradient
  static LinearGradient get chemistry => const LinearGradient(
        colors: AppColors.chemistryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Literature gradient
  static LinearGradient get literature => const LinearGradient(
        colors: AppColors.literatureGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // ==================== SEMANTIC GRADIENTS ====================

  /// Success gradient
  static LinearGradient get success => const LinearGradient(
        colors: AppColors.successGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Info gradient
  static LinearGradient get info => const LinearGradient(
        colors: AppColors.infoGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Warning gradient
  static LinearGradient get warning => const LinearGradient(
        colors: AppColors.warningGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // ==================== UTILITY METHODS ====================

  /// Get subject gradient by subject name
  static LinearGradient getSubjectGradient(String subjectName) {
    final name = subjectName.toLowerCase();
    if (name.contains('رياضيات') || name.contains('math')) return math;
    if (name.contains('فيزياء') || name.contains('physi')) return physics;
    if (name.contains('كيمياء') || name.contains('chimi')) return chemistry;
    if (name.contains('عربية') ||
        name.contains('arab') ||
        name.contains('فرنسية') ||
        name.contains('fran') ||
        name.contains('إنجليزية') ||
        name.contains('angl')) {
      return literature;
    }
    return primary; // Default gradient
  }

  /// Get stream gradient by stream slug
  static LinearGradient getStreamGradient(String streamSlug) {
    final colors = AppColors.getStreamGradient(streamSlug);
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Create custom gradient with specific colors
  static LinearGradient custom({
    required List<Color> colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
    );
  }

  /// Create gradient with opacity overlay
  static LinearGradient withOpacity(
    LinearGradient gradient,
    double opacity,
  ) {
    return LinearGradient(
      colors: gradient.colors
          .map((color) => color.withOpacity(opacity))
          .toList(),
      begin: gradient.begin,
      end: gradient.end,
      stops: gradient.stops,
    );
  }

  /// Create shimmer gradient for loading states
  static LinearGradient get shimmer => LinearGradient(
        colors: [
          Colors.grey[300]!,
          Colors.grey[100]!,
          Colors.grey[300]!,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: const [0.0, 0.5, 1.0],
      );

  /// Create glass effect gradient (for glassmorphism)
  static LinearGradient get glass => const LinearGradient(
        colors: [
          AppColors.backgroundOverlay,
          Color(0xFFFFFFFF),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // ==================== DECORATIVE GRADIENTS ====================

  /// Subtle overlay gradient (for cards with images)
  static LinearGradient get overlayDark => LinearGradient(
        colors: [
          Colors.black.withOpacity(0.7),
          Colors.black.withOpacity(0.3),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  /// Light overlay gradient
  static LinearGradient get overlayLight => LinearGradient(
        colors: [
          Colors.white.withOpacity(0.9),
          Colors.white.withOpacity(0.5),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  /// Scrim gradient (dark to transparent)
  static LinearGradient get scrim => LinearGradient(
        colors: [
          Colors.black.withOpacity(0.6),
          Colors.transparent,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.center,
      );

  // ==================== ANIMATED GRADIENTS ====================

  /// Create animated gradient for progress indicators
  static SweepGradient progressSweep({
    required Color primaryColor,
    double startAngle = -90.0,
  }) {
    return SweepGradient(
      colors: [
        primaryColor,
        primaryColor.withOpacity(0.5),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
      startAngle: startAngle * (3.14159 / 180), // Convert to radians
    );
  }

  /// Radial gradient for circular effects
  static RadialGradient radial({
    required List<Color> colors,
    Alignment center = Alignment.center,
  }) {
    return RadialGradient(
      colors: colors,
      center: center,
    );
  }

  // ==================== BACKGROUND GRADIENTS ====================

  /// Subtle background gradient for pages
  static LinearGradient get backgroundSubtle => const LinearGradient(
        colors: [
          Color(0xFFFAFAFA),
          Color(0xFFFFFFFF),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  /// Primary background gradient
  static LinearGradient get backgroundPrimary => const LinearGradient(
        colors: [
          Color(0xFF2196F3),
          Color(0xFF1976D2),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // ==================== HELPER FUNCTIONS ====================

  /// Lighten a gradient by reducing opacity
  static LinearGradient lighten(LinearGradient gradient, double amount) {
    return LinearGradient(
      colors: gradient.colors
          .map((color) => Color.lerp(color, Colors.white, amount)!)
          .toList(),
      begin: gradient.begin,
      end: gradient.end,
      stops: gradient.stops,
    );
  }

  /// Darken a gradient by reducing brightness
  static LinearGradient darken(LinearGradient gradient, double amount) {
    return LinearGradient(
      colors: gradient.colors
          .map((color) => Color.lerp(color, Colors.black, amount)!)
          .toList(),
      begin: gradient.begin,
      end: gradient.end,
      stops: gradient.stops,
    );
  }

  /// Reverse gradient direction
  static LinearGradient reverse(LinearGradient gradient) {
    return LinearGradient(
      colors: gradient.colors.reversed.toList(),
      begin: gradient.end,
      end: gradient.begin,
      stops: gradient.stops?.reversed.toList(),
    );
  }

  /// Add stops to a gradient
  static LinearGradient withStops(
    LinearGradient gradient,
    List<double> stops,
  ) {
    return LinearGradient(
      colors: gradient.colors,
      begin: gradient.begin,
      end: gradient.end,
      stops: stops,
    );
  }
}
