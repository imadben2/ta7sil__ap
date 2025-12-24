import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Active Session Timer Card for Home Page
/// Shows circular timer with pulse animation when session is in progress
///
/// Example usage:
/// ```dart
/// ActiveSessionTimerCard(
///   subjectName: 'رياضيات',
///   topicName: 'الدوال والنهايات',
///   subjectColor: Color(0xFF3B82F6),
///   remainingDuration: Duration(minutes: 45, seconds: 30),
///   totalDuration: Duration(hours: 1, minutes: 30),
///   onTap: () => navigateToSessionDetail(),
///   onContinue: () => navigateToActiveSession(),
/// )
/// ```
class ActiveSessionTimerCard extends StatefulWidget {
  /// Subject name
  final String subjectName;

  /// Topic/Chapter name (optional)
  final String? topicName;

  /// Subject color for theming
  final Color subjectColor;

  /// Remaining time in the session
  final Duration remainingDuration;

  /// Total session duration
  final Duration totalDuration;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when continue button is pressed
  final VoidCallback? onContinue;

  const ActiveSessionTimerCard({
    super.key,
    required this.subjectName,
    this.topicName,
    required this.subjectColor,
    required this.remainingDuration,
    required this.totalDuration,
    this.onTap,
    this.onContinue,
  });

  @override
  State<ActiveSessionTimerCard> createState() => _ActiveSessionTimerCardState();
}

class _ActiveSessionTimerCardState extends State<ActiveSessionTimerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final hours = widget.remainingDuration.inHours;
    final minutes = widget.remainingDuration.inMinutes.remainder(60);
    final seconds = widget.remainingDuration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (widget.totalDuration.inSeconds == 0) return 0;
    return 1.0 -
        (widget.remainingDuration.inSeconds / widget.totalDuration.inSeconds);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.subjectColor,
              widget.subjectColor.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.subjectColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Timer Circle
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress Ring
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CustomPaint(
                        painter: _CircularProgressPainter(
                          progress: _progress,
                          strokeWidth: 6,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          progressColor: Colors.white,
                        ),
                      ),
                    ),
                    // Time Display
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formattedTime,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_circle_filled,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'جلسة نشطة',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Subject Info
            Text(
              widget.subjectName,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (widget.topicName != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.topicName!,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: widget.subjectColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      size: 22,
                      color: widget.subjectColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'استمرار الجلسة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: widget.subjectColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for circular progress
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
