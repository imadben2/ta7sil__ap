import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../bloc/session_timer_cubit.dart';
import '../bloc/session_timer_state.dart';

/// Pomodoro Timer Widget
///
/// Displays a circular progress indicator with timer controls
/// Shows remaining time, pomodoro count, and break indicators
class PomodoroTimerWidget extends StatelessWidget {
  const PomodoroTimerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionTimerCubit, SessionTimerState>(
      builder: (context, state) {
        if (state is TimerInitial) {
          return _buildInitialState(context);
        } else if (state is TimerRunning || state is TimerPaused) {
          return _buildActiveTimer(context, state);
        } else if (state is BreakRunning || state is BreakPaused) {
          return _buildBreakTimer(context, state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Build initial state (no timer active)
  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_outlined, size: 120, color: Colors.grey),
          const SizedBox(height: 24),
          Text(
            'جاهز للبدء',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: 'Cairo',
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ جلسة دراسة لتفعيل المؤقت',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontFamily: 'Cairo',
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build active study timer
  Widget _buildActiveTimer(BuildContext context, SessionTimerState state) {
    final isRunning = state is TimerRunning;
    final remainingSeconds = state.remainingTime.inSeconds;
    final elapsedSeconds =
        state.totalDuration.inSeconds - state.remainingTime.inSeconds;
    final pomodoroCount = state.pomodoroCount;
    final totalDuration = state.totalDuration;

    return _buildTimerDisplay(
      context: context,
      remainingSeconds: remainingSeconds,
      elapsedSeconds: elapsedSeconds,
      totalDuration: totalDuration.inSeconds,
      pomodoroCount: pomodoroCount,
      isRunning: isRunning,
      isBreak: false,
    );
  }

  /// Build break timer
  Widget _buildBreakTimer(BuildContext context, SessionTimerState state) {
    final isRunning = state is BreakRunning;
    final remainingSeconds = state.remainingTime.inSeconds;
    final elapsedSeconds =
        state.totalDuration.inSeconds - state.remainingTime.inSeconds;
    // Determine if it's a long break based on completed pomodoros
    final isLongBreak =
        state.completedPomodoros % 4 == 0 && state.completedPomodoros > 0;
    final totalDuration = state.totalDuration;

    return _buildTimerDisplay(
      context: context,
      remainingSeconds: remainingSeconds,
      elapsedSeconds: elapsedSeconds,
      totalDuration: totalDuration.inSeconds,
      pomodoroCount: 0,
      isRunning: isRunning,
      isBreak: true,
      isLongBreak: isLongBreak,
    );
  }

  /// Build timer display with circular progress
  Widget _buildTimerDisplay({
    required BuildContext context,
    required int remainingSeconds,
    required int elapsedSeconds,
    required int totalDuration,
    required int pomodoroCount,
    required bool isRunning,
    required bool isBreak,
    bool isLongBreak = false,
  }) {
    final progress = elapsedSeconds / totalDuration;
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    final timerColor = isBreak
        ? (isLongBreak ? Colors.purple : Colors.orange)
        : Colors.green;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Timer type indicator
        _buildTimerTypeIndicator(
          context,
          isBreak: isBreak,
          isLongBreak: isLongBreak,
          pomodoroCount: pomodoroCount,
        ),
        const SizedBox(height: 32),

        // Circular progress timer
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              CustomPaint(
                size: const Size(280, 280),
                painter: _CircleProgressPainter(
                  progress: 1.0,
                  color: timerColor.withOpacity(0.1),
                  strokeWidth: 16,
                ),
              ),
              // Progress circle
              CustomPaint(
                size: const Size(280, 280),
                painter: _CircleProgressPainter(
                  progress: progress,
                  color: timerColor,
                  strokeWidth: 16,
                ),
              ),
              // Time display
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 64,
                      color: timerColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!isBreak) _buildPomodoroCounter(context, pomodoroCount),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),

        // Control buttons
        _buildControlButtons(context, isRunning, isBreak),
      ],
    );
  }

  /// Build timer type indicator
  Widget _buildTimerTypeIndicator(
    BuildContext context, {
    required bool isBreak,
    required bool isLongBreak,
    required int pomodoroCount,
  }) {
    String text;
    IconData icon;
    Color color;

    if (isBreak) {
      if (isLongBreak) {
        text = 'استراحة طويلة';
        icon = Icons.free_breakfast;
        color = Colors.purple;
      } else {
        text = 'استراحة قصيرة';
        icon = Icons.coffee;
        color = Colors.orange;
      }
    } else {
      text = 'جلسة دراسة';
      icon = Icons.school;
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'Cairo',
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build pomodoro counter (tomatoes)
  Widget _buildPomodoroCounter(BuildContext context, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            Icons.circle,
            size: 16,
            color: index < count ? Colors.green : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  /// Build control buttons
  Widget _buildControlButtons(
    BuildContext context,
    bool isRunning,
    bool isBreak,
  ) {
    final cubit = context.read<SessionTimerCubit>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Stop button
        ElevatedButton.icon(
          onPressed: () => cubit.stopTimer(),
          icon: const Icon(Icons.stop),
          label: Text('إيقاف', style: const TextStyle(fontFamily: 'Cairo')),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        const SizedBox(width: 16),

        // Play/Pause button
        ElevatedButton.icon(
          onPressed: () {
            if (isRunning) {
              cubit.pauseTimer();
            } else {
              cubit.resumeTimer();
            }
          },
          icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
          label: Text(
            isRunning ? 'إيقاف مؤقت' : 'استئناف',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isRunning ? Colors.orange : Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        const SizedBox(width: 16),

        // Skip break button (only during breaks)
        if (isBreak)
          ElevatedButton.icon(
            onPressed: () => cubit.skipBreak(),
            icon: const Icon(Icons.skip_next),
            label: Text('تخطي', style: const TextStyle(fontFamily: 'Cairo')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),

        // Add time button (only during study)
        if (!isBreak)
          IconButton(
            onPressed: () => cubit.addExtraTime(5),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'إضافة 5 دقائق',
            iconSize: 32,
            color: Colors.blue,
          ),
      ],
    );
  }
}

/// Custom painter for circular progress
class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw arc from top (-90 degrees) clockwise
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      2 * math.pi * progress, // Sweep angle based on progress
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
