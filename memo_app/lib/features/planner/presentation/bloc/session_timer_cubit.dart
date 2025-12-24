import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'session_timer_state.dart';

/// Cubit for managing Pomodoro timer during study sessions
///
/// Features:
/// - Start/pause/resume/stop timer
/// - Automatic break scheduling
/// - Pomodoro counting
/// - Sound notifications (can be extended)
class SessionTimerCubit extends Cubit<SessionTimerState> {
  Timer? _timer;
  int _pomodoroDurationMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;
  int _pomodorosBeforeLongBreak = 4;

  SessionTimerCubit() : super(SessionTimerState.initial());

  /// Configure Pomodoro settings
  void configurePomodoroSettings({
    int? pomodoroDuration,
    int? shortBreak,
    int? longBreak,
    int? pomodorosBeforeLongBreak,
  }) {
    _pomodoroDurationMinutes = pomodoroDuration ?? _pomodoroDurationMinutes;
    _shortBreakMinutes = shortBreak ?? _shortBreakMinutes;
    _longBreakMinutes = longBreak ?? _longBreakMinutes;
    _pomodorosBeforeLongBreak =
        pomodorosBeforeLongBreak ?? _pomodorosBeforeLongBreak;
  }

  /// Start a study session timer
  void startTimer({Duration? duration, bool usePomodoro = true}) {
    _stopTimer();

    final sessionDuration =
        duration ?? Duration(minutes: _pomodoroDurationMinutes);

    emit(
      SessionTimerState(
        remainingTime: sessionDuration,
        totalDuration: sessionDuration,
        status: SessionTimerStatus.running,
        completedPomodoros: state.completedPomodoros,
        isBreak: false,
        message: 'جلسة الدراسة بدأت! 📚',
      ),
    );

    _startTicking();
  }

  /// Pause the running timer
  void pauseTimer() {
    if (state.status != SessionTimerStatus.running) return;

    _stopTimer();

    emit(
      state.copyWith(
        status: SessionTimerStatus.paused,
        message: 'تم إيقاف المؤقت مؤقتاً ⏸️',
      ),
    );
  }

  /// Resume a paused timer
  void resumeTimer() {
    if (state.status != SessionTimerStatus.paused) return;

    emit(
      state.copyWith(
        status: SessionTimerStatus.running,
        message: 'تم استئناف المؤقت ▶️',
      ),
    );

    _startTicking();
  }

  /// Stop the timer completely
  void stopTimer() {
    _stopTimer();

    emit(
      state.copyWith(
        status: SessionTimerStatus.cancelled,
        message: 'تم إلغاء الجلسة ❌',
      ),
    );
  }

  /// Complete the current timer (session finished)
  void completeTimer() {
    _stopTimer();

    final wasBreak = state.isBreak;
    final newPomodoroCount = wasBreak
        ? state.completedPomodoros
        : state.completedPomodoros + 1;

    emit(
      state.copyWith(
        remainingTime: Duration.zero,
        status: SessionTimerStatus.completed,
        completedPomodoros: newPomodoroCount,
        message: wasBreak
            ? 'انتهت الاستراحة! عودة للدراسة 📚'
            : 'أحسنت! أكملت جلسة بومودورو 🎉',
      ),
    );
  }

  /// Start a break after completing a pomodoro
  void startBreak() {
    _stopTimer();

    // Determine break duration
    final isLongBreak =
        state.completedPomodoros % _pomodorosBeforeLongBreak == 0;
    final breakDuration = Duration(
      minutes: isLongBreak ? _longBreakMinutes : _shortBreakMinutes,
    );

    emit(
      SessionTimerState(
        remainingTime: breakDuration,
        totalDuration: breakDuration,
        status: SessionTimerStatus.running,
        completedPomodoros: state.completedPomodoros,
        isBreak: true,
        message: isLongBreak
            ? 'استراحة طويلة! استرح جيداً ☕'
            : 'استراحة قصيرة! خذ نفساً عميقاً 💨',
      ),
    );

    _startTicking();
  }

  /// Skip the current break and start studying again
  void skipBreak() {
    if (!state.isBreak) return;

    _stopTimer();

    emit(
      state.copyWith(
        status: SessionTimerStatus.completed,
        message: 'تم تخطي الاستراحة. عودة للدراسة! 💪',
      ),
    );
  }

  /// Reset timer to initial state
  void resetTimer() {
    _stopTimer();

    emit(SessionTimerState.initial());
  }

  /// Start the tick mechanism
  void _startTicking() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingTime.inSeconds <= 0) {
        completeTimer();
        return;
      }

      emit(
        state.copyWith(
          remainingTime: Duration(seconds: state.remainingTime.inSeconds - 1),
        ),
      );
    });
  }

  /// Stop the tick mechanism
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Add extra time to current session
  void addExtraTime(int minutes) {
    if (state.status != SessionTimerStatus.running &&
        state.status != SessionTimerStatus.paused) {
      return;
    }

    final newRemainingTime = Duration(
      seconds: state.remainingTime.inSeconds + (minutes * 60),
    );

    final newTotalDuration = Duration(
      seconds: state.totalDuration.inSeconds + (minutes * 60),
    );

    emit(
      state.copyWith(
        remainingTime: newRemainingTime,
        totalDuration: newTotalDuration,
        message: 'تمت إضافة $minutes دقيقة إضافية ⏱️',
      ),
    );
  }

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }
}
