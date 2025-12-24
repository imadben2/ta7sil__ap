import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Success animation widget with confetti and points display
/// Shows after completing a study session
class SuccessAnimationWidget extends StatefulWidget {
  final int pointsEarned;
  final String? message;
  final VoidCallback? onComplete;
  final Duration displayDuration;

  const SuccessAnimationWidget({
    Key? key,
    required this.pointsEarned,
    this.message,
    this.onComplete,
    this.displayDuration = const Duration(milliseconds: 3500),
  }) : super(key: key);

  @override
  State<SuccessAnimationWidget> createState() => _SuccessAnimationWidgetState();
}

class _SuccessAnimationWidgetState extends State<SuccessAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _checkController;
  late AnimationController _pointsController;
  late Animation<double> _checkAnimation;
  late Animation<int> _pointsAnimation;
  final List<ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Confetti animation (lasts 2 seconds)
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Check icon animation (elastic bounce)
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    // Points counter animation
    _pointsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pointsAnimation = IntTween(begin: 0, end: widget.pointsEarned).animate(
      CurvedAnimation(parent: _pointsController, curve: Curves.easeOutCubic),
    );

    // Generate confetti particles
    _generateConfetti();

    // Start animations
    _checkController.forward();
    _pointsController.forward();
    _confettiController.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  void _generateConfetti() {
    final random = math.Random();
    for (int i = 0; i < 30; i++) {
      _particles.add(
        ConfettiParticle(
          color: _getRandomColor(random),
          startX: random.nextDouble(),
          startY: -0.1,
          endX: random.nextDouble(),
          endY: 1.2 + random.nextDouble() * 0.3,
          rotation: random.nextDouble() * 4 * math.pi,
          size: 8 + random.nextDouble() * 8,
        ),
      );
    }
  }

  Color _getRandomColor(math.Random random) {
    final colors = [
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFFC107), // Amber
      const Color(0xFF2196F3), // Blue
      const Color(0xFFE91E63), // Pink
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF9C27B0), // Purple
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _checkController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        // Confetti layer
        AnimatedBuilder(
          animation: _confettiController,
          builder: (context, child) {
            return CustomPaint(
              painter: ConfettiPainter(
                particles: _particles,
                progress: _confettiController.value,
              ),
              child: Container(),
            );
          },
        ),

        // Content layer
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated check icon
              ScaleTransition(
                scale: _checkAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 60),
                ),
              ),
              const SizedBox(height: 24),

              // Points earned text
              AnimatedBuilder(
                animation: _pointsAnimation,
                builder: (context, child) {
                  return Text(
                    '+${_pointsAnimation.value} FB7)!',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    textDirection: TextDirection.rtl,
                  );
                },
              ),

              const SizedBox(height: 12),

              // Success message
              if (widget.message != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    widget.message!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Confetti particle model
class ConfettiParticle {
  final Color color;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double rotation;
  final double size;

  ConfettiParticle({
    required this.color,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.rotation,
    required this.size,
  });
}

/// Custom painter for confetti animation
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(1.0 - progress * 0.5)
        ..style = PaintingStyle.fill;

      // Calculate current position using cubic easing
      final t = _easeOutCubic(progress);
      final x =
          size.width *
          (particle.startX + (particle.endX - particle.startX) * t);
      final y =
          size.height *
          (particle.startY + (particle.endY - particle.startY) * t);

      // Calculate rotation
      final rotation = particle.rotation * progress;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      // Draw confetti as a rounded rectangle
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        Radius.circular(particle.size * 0.2),
      );

      canvas.drawRRect(rect, paint);
      canvas.restore();
    }
  }

  double _easeOutCubic(double t) {
    return (1 - math.pow(1 - t, 3)).toDouble();
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Compact success indicator for smaller spaces
class CompactSuccessIndicator extends StatefulWidget {
  final int pointsEarned;
  final Duration duration;

  const CompactSuccessIndicator({
    Key? key,
    required this.pointsEarned,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  State<CompactSuccessIndicator> createState() =>
      _CompactSuccessIndicatorState();
}

class _CompactSuccessIndicatorState extends State<CompactSuccessIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                '+${widget.pointsEarned} FB7)',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
