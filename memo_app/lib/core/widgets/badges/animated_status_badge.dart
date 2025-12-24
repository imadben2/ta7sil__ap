import 'package:flutter/material.dart';

/// Status types for the animated badge
enum BadgeStatus {
  pending,
  approved,
  rejected,
  active,
  expired,
  processing,
}

/// Modern animated status badge with pulse effect
///
/// Features:
/// - Pulse animation for pending/processing states
/// - Gradient background option
/// - Icon + text layout
/// - Customizable colors per status
/// - RTL support with Cairo font
class AnimatedStatusBadge extends StatefulWidget {
  final BadgeStatus status;
  final String? customLabel;
  final bool showPulse;
  final bool showIcon;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const AnimatedStatusBadge({
    super.key,
    required this.status,
    this.customLabel,
    this.showPulse = true,
    this.showIcon = true,
    this.fontSize = 12,
    this.padding,
  });

  @override
  State<AnimatedStatusBadge> createState() => _AnimatedStatusBadgeState();
}

class _AnimatedStatusBadgeState extends State<AnimatedStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (_shouldPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldPulse && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!_shouldPulse && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _shouldPulse =>
      widget.showPulse &&
      (widget.status == BadgeStatus.pending ||
          widget.status == BadgeStatus.processing);

  StatusConfig get _config {
    switch (widget.status) {
      case BadgeStatus.pending:
        return StatusConfig(
          color: const Color(0xFFF59E0B),
          icon: Icons.schedule_rounded,
          label: widget.customLabel ?? 'قيد الانتظار',
        );
      case BadgeStatus.approved:
        return StatusConfig(
          color: const Color(0xFF10B981),
          icon: Icons.check_circle_rounded,
          label: widget.customLabel ?? 'مقبول',
        );
      case BadgeStatus.rejected:
        return StatusConfig(
          color: const Color(0xFFEF4444),
          icon: Icons.cancel_rounded,
          label: widget.customLabel ?? 'مرفوض',
        );
      case BadgeStatus.active:
        return StatusConfig(
          color: const Color(0xFF10B981),
          icon: Icons.verified_rounded,
          label: widget.customLabel ?? 'نشط',
        );
      case BadgeStatus.expired:
        return StatusConfig(
          color: const Color(0xFF64748B),
          icon: Icons.timer_off_rounded,
          label: widget.customLabel ?? 'منتهي',
        );
      case BadgeStatus.processing:
        return StatusConfig(
          color: const Color(0xFF3B82F6),
          icon: Icons.hourglass_top_rounded,
          label: widget.customLabel ?? 'جاري المعالجة',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _shouldPulse ? _pulseAnimation.value : 1.0,
          child: child,
        );
      },
      child: Container(
        padding: widget.padding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: config.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: config.color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: _shouldPulse
              ? [
                  BoxShadow(
                    color: config.color.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showIcon) ...[
              Icon(
                config.icon,
                size: widget.fontSize + 2,
                color: config.color,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              config.label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w600,
                color: config.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Configuration for each status type
class StatusConfig {
  final Color color;
  final IconData icon;
  final String label;

  const StatusConfig({
    required this.color,
    required this.icon,
    required this.label,
  });
}

/// Simple static status badge without animation
class StatusBadge extends StatelessWidget {
  final Color color;
  final String label;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusBadge({
    super.key,
    required this.color,
    required this.label,
    this.icon,
    this.fontSize = 12,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
