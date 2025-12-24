import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Reusable card widget with optional gradient and tap handler
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final double? elevation;
  final double? borderRadius;
  final Border? border;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.elevation,
    this.borderRadius,
    this.border,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final cardChild = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppColors.surface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius ?? AppSizes.radiusMD),
        border: border,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: elevation ?? AppSizes.elevationSM,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppSizes.radiusMD,
          ),
          child: cardChild,
        ),
      );
    }

    return Padding(padding: margin ?? EdgeInsets.zero, child: cardChild);
  }
}
