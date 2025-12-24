import 'dart:ui';
import 'package:flutter/material.dart';

/// Modern glassmorphic bottom sheet wrapper
///
/// Features:
/// - BackdropFilter with blur effect
/// - Semi-transparent white background
/// - Modern handle bar
/// - Smooth animations
/// - RTL support
class GlassBottomSheet extends StatelessWidget {
  final Widget child;
  final double? height;
  final bool showHandle;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const GlassBottomSheet({
    super.key,
    required this.child,
    this.height,
    this.showHandle = true,
    this.onClose,
    this.padding,
    this.borderRadius = 24,
  });

  /// Show the glass bottom sheet as a modal
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double? height,
    bool showHandle = true,
    bool isDismissible = true,
    bool enableDrag = true,
    EdgeInsetsGeometry? padding,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (context) => GlassBottomSheet(
        height: height,
        showHandle: showHandle,
        padding: padding,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(borderRadius),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(borderRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: height == null ? MainAxisSize.min : MainAxisSize.max,
            children: [
              if (showHandle) _buildHandle(context),
              Flexible(
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(24),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return GestureDetector(
      onTap: onClose ?? () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

/// A scrollable glass bottom sheet for longer content
class ScrollableGlassBottomSheet extends StatelessWidget {
  final Widget child;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final bool showHandle;
  final EdgeInsetsGeometry? padding;

  const ScrollableGlassBottomSheet({
    super.key,
    required this.child,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.25,
    this.maxChildSize = 0.95,
    this.showHandle = true,
    this.padding,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double initialChildSize = 0.5,
    double minChildSize = 0.25,
    double maxChildSize = 0.95,
    bool showHandle = true,
    bool isDismissible = true,
    EdgeInsetsGeometry? padding,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: isDismissible,
      builder: (context) => ScrollableGlassBottomSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        showHandle: showHandle,
        padding: padding,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (showHandle) _buildHandle(),
                  Expanded(
                    child: Padding(
                      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
