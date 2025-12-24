import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/study_session.dart';

/// Compact inline countdown timer widget for session cards
///
/// Displays remaining time in MM:SS format with a progress bar
/// Used in session cards when session is in progress
class SessionTimerInline extends StatefulWidget {
  final StudySession session;
  final VoidCallback? onTimerComplete;

  const SessionTimerInline({
    Key? key,
    required this.session,
    this.onTimerComplete,
  }) : super(key: key);

  @override
  State<SessionTimerInline> createState() => _SessionTimerInlineState();
}

class _SessionTimerInlineState extends State<SessionTimerInline> {
  Timer? _timer;
  late Duration _remainingTime;
  late Duration _totalDuration;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeTimer() {
    _totalDuration = widget.session.duration;

    // Calculate remaining time based on actual start time
    if (widget.session.actualStartTime != null) {
      final elapsed = DateTime.now().difference(widget.session.actualStartTime!);
      _remainingTime = _totalDuration - elapsed;
      if (_remainingTime.isNegative) {
        _remainingTime = Duration.zero;
      }
    } else {
      _remainingTime = _totalDuration;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        } else {
          _timer?.cancel();
          widget.onTimerComplete?.call();
        }
      });
    });
  }

  String get _formattedTime {
    final hours = _remainingTime.inHours;
    final minutes = _remainingTime.inMinutes.remainder(60);
    final seconds = _remainingTime.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (_totalDuration.inSeconds == 0) return 0;
    // Calculate elapsed progress (0% at start → 100% at end)
    return 1.0 - (_remainingTime.inSeconds / _totalDuration.inSeconds);
  }

  Color get _timerColor {
    // Color based on elapsed progress: green at start, orange middle, red near end
    if (_progress < 0.5) return Colors.green;
    if (_progress < 0.75) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _timerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _timerColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timer icon with animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: 0.8),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: _remainingTime.inSeconds % 2 == 0 ? 1.0 : 0.95,
                child: Icon(
                  Icons.timer_outlined,
                  color: _timerColor,
                  size: 18,
                ),
              );
            },
          ),
          const SizedBox(width: 8),

          // Time display
          Text(
            _formattedTime,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _timerColor,
            ),
          ),

          const SizedBox(width: 12),

          // Progress bar
          SizedBox(
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(_timerColor),
                minHeight: 6,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Percentage
          Text(
            '${(_progress * 100).toInt()}%',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _timerColor,
            ),
          ),
        ],
      ),
    );
  }
}
