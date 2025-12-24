import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/quiz_timer/quiz_timer_cubit.dart';
import '../bloc/quiz_timer/quiz_timer_state.dart';

/// Timer widget for timed quizzes
class QuizTimerWidget extends StatelessWidget {
  final bool showProgress;

  const QuizTimerWidget({super.key, this.showProgress = true});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizTimerCubit, QuizTimerState>(
      builder: (context, state) {
        if (state is QuizTimerInitial) {
          return const SizedBox.shrink();
        }

        if (state is QuizTimerExpired) {
          return _buildExpiredTimer();
        }

        if (state is QuizTimerRunning) {
          return _buildRunningTimer(state, context);
        }

        if (state is QuizTimerPaused) {
          return _buildPausedTimer(state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRunningTimer(QuizTimerRunning state, BuildContext context) {
    final isWarning = state.isWarning;
    final isDanger = state.isDanger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDanger
            ? AppColors.error.withOpacity(0.1)
            : isWarning
            ? AppColors.warning.withOpacity(0.1)
            : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDanger
              ? AppColors.error
              : isWarning
              ? AppColors.warning
              : AppColors.primary,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDanger ? Icons.warning_rounded : Icons.timer_rounded,
                color: isDanger
                    ? AppColors.error
                    : isWarning
                    ? AppColors.warning
                    : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                state.formattedTimeLong,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDanger
                      ? AppColors.error
                      : isWarning
                      ? AppColors.warning
                      : AppColors.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          if (showProgress) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: state.remainingSeconds / state.totalSeconds,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDanger
                      ? AppColors.error
                      : isWarning
                      ? AppColors.warning
                      : AppColors.primary,
                ),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPausedTimer(QuizTimerPaused state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textSecondary, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.pause_circle_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'موقف مؤقتاً',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredTimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.timer_off_rounded, color: AppColors.error, size: 20),
          SizedBox(width: 8),
          Text(
            'انتهى الوقت',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact timer widget for app bar
class CompactTimerWidget extends StatelessWidget {
  const CompactTimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizTimerCubit, QuizTimerState>(
      builder: (context, state) {
        if (state is QuizTimerRunning) {
          final isDanger = state.isDanger;
          final isWarning = state.isWarning;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDanger
                  ? AppColors.error
                  : isWarning
                  ? AppColors.warning
                  : AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDanger ? Icons.warning_rounded : Icons.timer_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  state.formattedTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
