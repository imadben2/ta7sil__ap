import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_design_tokens.dart';

/// Time display badge for sessions, events, etc.
/// Used in session cards and calendar views
///
/// Example usage:
/// ```dart
/// TimeBadge(
///   time: '10:00 - 11:30',
///   color: AppColors.primary,
/// )
/// ```
class TimeBadge extends StatelessWidget {
  /// Time string to display
  final String time;

  /// Badge color (defaults to primary)
  final Color? color;

  /// Show clock icon
  final bool showIcon;

  /// On tap callback
  final VoidCallback? onTap;

  /// Badge style
  final TimeBadgeStyle style;

  const TimeBadge({
    super.key,
    required this.time,
    this.color,
    this.showIcon = true,
    this.onTap,
    this.style = TimeBadgeStyle.filled,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: _getDecoration(effectiveColor),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                Icons.access_time,
                size: AppDesignTokens.iconSizeXS,
                color: _getTextColor(effectiveColor),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              time,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeCaption,
                fontWeight: FontWeight.w600,
                color: _getTextColor(effectiveColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _getDecoration(Color color) {
    switch (style) {
      case TimeBadgeStyle.filled:
        return BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(
            AppDesignTokens.borderRadiusTiny,
          ),
        );
      case TimeBadgeStyle.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(
            AppDesignTokens.borderRadiusTiny,
          ),
          border: Border.all(
            color: color.withOpacity(0.4),
            width: 1,
          ),
        );
      case TimeBadgeStyle.solid:
        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(
            AppDesignTokens.borderRadiusTiny,
          ),
        );
    }
  }

  Color _getTextColor(Color color) {
    switch (style) {
      case TimeBadgeStyle.filled:
      case TimeBadgeStyle.outlined:
        return color;
      case TimeBadgeStyle.solid:
        return Colors.white;
    }
  }
}

enum TimeBadgeStyle {
  filled, // Colored background with opacity
  outlined, // Border only
  solid, // Solid colored background
}

/// Duration badge (for displaying time duration)
class DurationBadge extends StatelessWidget {
  final String duration;
  final Color? color;
  final VoidCallback? onTap;

  const DurationBadge({
    super.key,
    required this.duration,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: effectiveColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(
            AppDesignTokens.borderRadiusTiny,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              size: AppDesignTokens.iconSizeXS,
              color: effectiveColor,
            ),
            const SizedBox(width: 4),
            Text(
              duration,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeTiny,
                fontWeight: FontWeight.w600,
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Live timer badge (pulsing animation for active sessions)
class LiveTimerBadge extends StatefulWidget {
  final String time;
  final Color? color;
  final VoidCallback? onTap;

  const LiveTimerBadge({
    super.key,
    required this.time,
    this.color,
    this.onTap,
  });

  @override
  State<LiveTimerBadge> createState() => _LiveTimerBadgeState();
}

class _LiveTimerBadgeState extends State<LiveTimerBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? AppColors.fireRed;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: effectiveColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(
                AppDesignTokens.borderRadiusTiny,
              ),
              border: Border.all(
                color: effectiveColor.withOpacity(_animation.value),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: effectiveColor.withOpacity(_animation.value),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.time,
                  style: TextStyle(
                    fontSize: AppDesignTokens.fontSizeLabel,
                    fontWeight: FontWeight.bold,
                    color: effectiveColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
