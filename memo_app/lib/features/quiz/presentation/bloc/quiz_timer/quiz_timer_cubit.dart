import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'quiz_timer_state.dart';

/// Cubit for managing quiz timer
///
/// Handles countdown timer for timed quizzes.
/// Auto-submits quiz when timer expires.
class QuizTimerCubit extends Cubit<QuizTimerState> {
  Timer? _timer;
  int? _remainingSeconds;
  int? _totalSeconds;

  QuizTimerCubit() : super(const QuizTimerInitial());

  /// Start timer with given duration in seconds
  void startTimer(int durationSeconds) {
    _totalSeconds = durationSeconds;
    _remainingSeconds = durationSeconds;

    emit(
      QuizTimerRunning(
        remainingSeconds: _remainingSeconds!,
        totalSeconds: _totalSeconds!,
      ),
    );

    _startCountdown();
  }

  /// Resume timer from a specific remaining time
  void resumeTimer(int remainingSeconds, int totalSeconds) {
    _totalSeconds = totalSeconds;
    _remainingSeconds = remainingSeconds;

    if (_remainingSeconds! <= 0) {
      emit(const QuizTimerExpired());
      return;
    }

    emit(
      QuizTimerRunning(
        remainingSeconds: _remainingSeconds!,
        totalSeconds: _totalSeconds!,
      ),
    );

    _startCountdown();
  }

  /// Pause timer
  void pauseTimer() {
    _timer?.cancel();

    if (_remainingSeconds != null && _totalSeconds != null) {
      emit(
        QuizTimerPaused(
          remainingSeconds: _remainingSeconds!,
          totalSeconds: _totalSeconds!,
        ),
      );
    }
  }

  /// Resume paused timer
  void resumePausedTimer() {
    if (state is QuizTimerPaused) {
      final pausedState = state as QuizTimerPaused;
      resumeTimer(pausedState.remainingSeconds, pausedState.totalSeconds);
    }
  }

  /// Stop timer completely
  void stopTimer() {
    _timer?.cancel();
    _remainingSeconds = null;
    _totalSeconds = null;
    emit(const QuizTimerInitial());
  }

  /// Add time to timer (e.g., for time extensions)
  void addTime(int seconds) {
    if (_remainingSeconds != null && _totalSeconds != null) {
      _remainingSeconds = _remainingSeconds! + seconds;
      _totalSeconds = _totalSeconds! + seconds;

      emit(
        QuizTimerRunning(
          remainingSeconds: _remainingSeconds!,
          totalSeconds: _totalSeconds!,
        ),
      );
    }
  }

  /// Internal countdown implementation
  void _startCountdown() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == null || _remainingSeconds! <= 0) {
        timer.cancel();
        emit(const QuizTimerExpired());
        return;
      }

      _remainingSeconds = _remainingSeconds! - 1;

      emit(
        QuizTimerRunning(
          remainingSeconds: _remainingSeconds!,
          totalSeconds: _totalSeconds!,
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
