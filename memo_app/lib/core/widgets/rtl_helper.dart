import 'package:flutter/material.dart';

/// Helper class for RTL layout management
class RTLHelper {
  RTLHelper._();

  /// Check if current locale is RTL
  static bool isRTL(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl;
  }

  /// Flip value for RTL (e.g., for padding/margin)
  static double flipForRTL(BuildContext context, double value) {
    return isRTL(context) ? -value : value;
  }

  /// Get start alignment based on directionality
  static Alignment getStartAlignment(BuildContext context) {
    return isRTL(context) ? Alignment.centerRight : Alignment.centerLeft;
  }

  /// Get end alignment based on directionality
  static Alignment getEndAlignment(BuildContext context) {
    return isRTL(context) ? Alignment.centerLeft : Alignment.centerRight;
  }

  /// Get EdgeInsets with start/end support
  static EdgeInsetsDirectional getEdgeInsets({
    double top = 0,
    double bottom = 0,
    double start = 0,
    double end = 0,
  }) {
    return EdgeInsetsDirectional.only(
      top: top,
      bottom: bottom,
      start: start,
      end: end,
    );
  }
}

/// RTL-aware icon widget that auto-flips directional icons
class RTLIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final bool flipInRTL;

  const RTLIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.flipInRTL = true,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLHelper.isRTL(context);

    if (flipInRTL && isRTL && _isDirectionalIcon(icon)) {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(3.14159), // 180 degrees
        child: Icon(icon, size: size, color: color),
      );
    }

    return Icon(icon, size: size, color: color);
  }

  /// Check if icon should be flipped in RTL
  bool _isDirectionalIcon(IconData icon) {
    // List of directional icons that should be flipped
    final directionalIcons = [
      Icons.arrow_back,
      Icons.arrow_forward,
      Icons.chevron_left,
      Icons.chevron_right,
      Icons.navigate_before,
      Icons.navigate_next,
      Icons.keyboard_arrow_left,
      Icons.keyboard_arrow_right,
      Icons.arrow_back_ios,
      Icons.arrow_forward_ios,
      Icons.first_page,
      Icons.last_page,
    ];

    return directionalIcons.contains(icon);
  }
}

/// RTL-aware ListTile that swaps leading/trailing in RTL
class RTLListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;
  final Widget? title;
  final Widget? subtitle;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;

  const RTLListTile({
    super.key,
    this.leading,
    this.trailing,
    this.title,
    this.subtitle,
    this.onTap,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLHelper.isRTL(context);

    return ListTile(
      leading: isRTL ? trailing : leading,
      trailing: isRTL ? leading : trailing,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      contentPadding: contentPadding,
    );
  }
}
