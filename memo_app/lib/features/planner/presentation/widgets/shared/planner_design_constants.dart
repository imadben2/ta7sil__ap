import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/entities/study_session.dart';

/// Planner Design Constants
///
/// Centralized design system for all planner screens
/// Based on session_detail_screen.dart modern design
class PlannerDesignConstants {
  PlannerDesignConstants._();

  // ============================================
  // COLORS - Using AppColors for consistency
  // ============================================

  /// Background color for planner screens
  static const Color slateBackground = AppColors.slateBackground;

  /// Card background
  static const Color cardBackground = AppColors.surface;

  /// Primary colors - Updated to purple theme
  static const Color primaryBlue = AppColors.primary; // Now purple
  static const Color accentViolet = AppColors.primaryLight;
  static const Color successEmerald = AppColors.emerald500;
  static const Color warningAmber = AppColors.amber500;
  static const Color errorRed = AppColors.red500;
  static const Color neutralSlate = AppColors.slate500;

  /// Text colors
  static const Color textPrimary = AppColors.slate900;
  static const Color textSecondary = AppColors.slate600;
  static const Color textMuted = AppColors.slate500;

  // ============================================
  // SUBJECT COLORS
  // ============================================

  static const Map<String, Color> subjectColors = {
    'رياضيات': Color(0xFF3B82F6), // Blue
    'فيزياء': Color(0xFF8B5CF6), // Purple
    'كيمياء': Color(0xFF10B981), // Green
    'علوم': Color(0xFF14B8A6), // Teal
    'فلسفة': Color(0xFFF97316), // Orange
    'عربية': Color(0xFF78716C), // Stone
    'فرنسية': Color(0xFF6366F1), // Indigo
    'إنجليزية': Color(0xFF06B6D4), // Cyan
    'تاريخ': Color(0xFFEC4899), // Pink
    'جغرافيا': Color(0xFF84CC16), // Lime
    'اقتصاد': Color(0xFFF59E0B), // Amber
    'إسلامية': Color(0xFF059669), // Emerald
  };

  /// Get color for a subject name
  static Color getSubjectColor(String subjectName) {
    return subjectColors[subjectName] ?? const Color(0xFF64748B);
  }

  // ============================================
  // STATUS COLORS
  // ============================================

  static const Map<SessionStatus, Color> statusColors = {
    SessionStatus.scheduled: Color(0xFF3B82F6), // Blue
    SessionStatus.inProgress: Color(0xFF10B981), // Green
    SessionStatus.paused: Color(0xFFF59E0B), // Amber
    SessionStatus.completed: Color(0xFF10B981), // Green
    SessionStatus.missed: Color(0xFFEF4444), // Red
    SessionStatus.skipped: Color(0xFF64748B), // Slate
  };

  /// Get color for a session status
  static Color getStatusColor(SessionStatus status) {
    return statusColors[status] ?? neutralSlate;
  }

  /// Get icon for a session status
  static IconData getStatusIcon(SessionStatus status) {
    switch (status) {
      case SessionStatus.scheduled:
        return Icons.schedule_rounded;
      case SessionStatus.inProgress:
        return Icons.play_circle_rounded;
      case SessionStatus.paused:
        return Icons.pause_circle_rounded;
      case SessionStatus.completed:
        return Icons.check_circle_rounded;
      case SessionStatus.missed:
        return Icons.cancel_rounded;
      case SessionStatus.skipped:
        return Icons.skip_next_rounded;
    }
  }

  /// Get Arabic label for a session status
  static String getStatusLabel(SessionStatus status) {
    switch (status) {
      case SessionStatus.scheduled:
        return 'مجدولة';
      case SessionStatus.inProgress:
        return 'جارية';
      case SessionStatus.paused:
        return 'موقوفة';
      case SessionStatus.completed:
        return 'مكتملة';
      case SessionStatus.missed:
        return 'فائتة';
      case SessionStatus.skipped:
        return 'تم التخطي';
    }
  }

  // ============================================
  // PRIORITY COLORS
  // ============================================

  /// Get color for priority score
  static Color getPriorityColor(int priorityScore) {
    if (priorityScore >= 80) return const Color(0xFFEF4444); // Critical - Red
    if (priorityScore >= 60) return const Color(0xFFF59E0B); // High - Amber
    if (priorityScore >= 40) return const Color(0xFF3B82F6); // Medium - Blue
    return const Color(0xFF10B981); // Low - Green
  }

  /// Get Arabic label for priority
  static String getPriorityLabel(int priorityScore) {
    if (priorityScore >= 80) return 'حرج';
    if (priorityScore >= 60) return 'عالي';
    if (priorityScore >= 40) return 'متوسط';
    return 'منخفض';
  }

  // ============================================
  // DIMENSIONS
  // ============================================

  /// Card border radius
  static const double cardRadius = 20.0;

  /// Card padding
  static const double cardPadding = 20.0;

  /// Icon container radius (large)
  static const double iconContainerRadiusLarge = 16.0;

  /// Icon container radius (medium)
  static const double iconContainerRadiusMedium = 12.0;

  /// Icon container radius (small)
  static const double iconContainerRadiusSmall = 10.0;

  /// Status badge radius
  static const double badgeRadius = 20.0;

  /// Standard horizontal padding
  static const double horizontalPadding = 20.0;

  /// Standard vertical spacing
  static const double verticalSpacing = 20.0;

  // ============================================
  // DECORATIONS
  // ============================================

  /// Modern card decoration with shadow
  static BoxDecoration modernCardDecoration({
    Color? color,
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: color ?? cardBackground,
      borderRadius: BorderRadius.circular(borderRadius ?? cardRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Gradient card decoration
  static BoxDecoration gradientCardDecoration(Color baseColor) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [baseColor, baseColor.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(cardRadius),
      boxShadow: [
        BoxShadow(
          color: baseColor.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Icon container decoration
  static BoxDecoration iconContainerDecoration(
    Color color, {
    bool isGradient = true,
    double? radius,
  }) {
    if (isGradient) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius ?? iconContainerRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(radius ?? iconContainerRadiusLarge),
    );
  }

  /// Status badge decoration
  static BoxDecoration statusBadgeDecoration(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(badgeRadius),
      border: Border.all(
        color: color.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  // ============================================
  // TEXT STYLES
  // ============================================

  /// Title style (large)
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  /// Title style (medium)
  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  /// Body style
  static const TextStyle bodyText = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  /// Caption style
  static const TextStyle caption = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textMuted,
  );

  /// Timer display style
  static const TextStyle timerStyle = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 42,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // ============================================
  // HELPER WIDGETS
  // ============================================

  /// Build a gradient icon container
  static Widget buildGradientIconContainer({
    required IconData icon,
    required Color color,
    double size = 60,
    double iconSize = 28,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: iconContainerDecoration(color),
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize,
      ),
    );
  }

  /// Build a status badge
  static Widget buildStatusBadge(SessionStatus status, {bool compact = false}) {
    final color = getStatusColor(status);
    final icon = getStatusIcon(status);
    final label = getStatusLabel(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: statusBadgeDecoration(color),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 14 : 16, color: color),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: compact ? 10 : 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build a priority badge
  static Widget buildPriorityBadge(int priorityScore, {bool showLabel = true}) {
    final color = getPriorityColor(priorityScore);
    final label = getPriorityLabel(priorityScore);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build a stat card
  static Widget buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: modernCardDecoration(),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: iconContainerDecoration(color, isGradient: false),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build an info tile (icon + label + value)
  static Widget buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    final color = iconColor ?? primaryBlue;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(iconContainerRadiusMedium),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: bodyText,
        ),
        const Spacer(),
        Text(
          value,
          style: bodyText.copyWith(
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
      ],
    );
  }
}
