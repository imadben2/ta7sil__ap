import 'dart:math';
import 'package:flutter/material.dart';

/// Modern circular progress indicator with percentage display
/// Optimized for RTL Arabic text
/// استخدم هذا الويدجت لعرض التقدم بشكل دائري مع النسبة المئوية
class ProgressRingWidget extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool showPercentage;
  final TextStyle? percentageStyle;
  final bool animate;

  const ProgressRingWidget({
    super.key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 6,
    this.backgroundColor,
    this.progressColor,
    this.showPercentage = true,
    this.percentageStyle,
    this.animate = true,
  });

  @override
  State<ProgressRingWidget> createState() => _ProgressRingWidgetState();
}

class _ProgressRingWidgetState extends State<ProgressRingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    if (widget.animate) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ProgressRingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation =
          Tween<double>(
            begin: oldWidget.progress,
            end: widget.progress,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOutCubic,
            ),
          );
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor =
        widget.backgroundColor ??
        theme.colorScheme.surfaceContainerHighest.withOpacity(0.3);
    final fgColor = widget.progressColor ?? theme.colorScheme.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final currentProgress = widget.animate
              ? _animation.value
              : widget.progress;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ProgressRingPainter(
                  progress: 1.0,
                  strokeWidth: widget.strokeWidth,
                  color: bgColor,
                ),
              ),
              // Progress arc
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ProgressRingPainter(
                  progress: currentProgress,
                  strokeWidth: widget.strokeWidth,
                  color: fgColor,
                ),
              ),
              // Percentage text
              if (widget.showPercentage)
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    '${(currentProgress * 100).toInt()}%',
                    textDirection: TextDirection.rtl,
                    style:
                        widget.percentageStyle ??
                        theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: fgColor,
                        ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw arc (starts from top, clockwise for RTL)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      2 * pi * progress, // Sweep angle based on progress
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color;
  }
}

/// Compact progress ring for small spaces
class CompactProgressRing extends StatelessWidget {
  final double progress;
  final double size;

  const CompactProgressRing({
    super.key,
    required this.progress,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return ProgressRingWidget(
      progress: progress,
      size: size,
      strokeWidth: 3,
      showPercentage: false,
      animate: false,
    );
  }
}
