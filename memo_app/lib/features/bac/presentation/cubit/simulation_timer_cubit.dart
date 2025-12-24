import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/bac_enums.dart';

/// State for simulation timer
class SimulationTimerState extends Equatable {
  final int remainingSeconds;
  final int elapsedSeconds;
  final bool isRunning;
  final bool isPaused;
  final TimerAlert? currentAlert;
  final int totalDurationSeconds;

  const SimulationTimerState({
    required this.remainingSeconds,
    required this.elapsedSeconds,
    required this.isRunning,
    required this.isPaused,
    this.currentAlert,
    required this.totalDurationSeconds,
  });

  /// Get formatted remaining time (mm:ss)
  String get formattedRemainingTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get formatted elapsed time (mm:ss)
  String get formattedElapsedTime {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get progress percentage (0.0 - 1.0)
  double get progress {
    if (totalDurationSeconds == 0) return 0.0;
    return elapsedSeconds / totalDurationSeconds;
  }

  /// Check if time is up
  bool get isTimeUp => remainingSeconds <= 0;

  factory SimulationTimerState.initial() {
    return const SimulationTimerState(
      remainingSeconds: 0,
      elapsedSeconds: 0,
      isRunning: false,
      isPaused: false,
      currentAlert: null,
      totalDurationSeconds: 0,
    );
  }

  SimulationTimerState copyWith({
    int? remainingSeconds,
    int? elapsedSeconds,
    bool? isRunning,
    bool? isPaused,
    TimerAlert? currentAlert,
    bool clearAlert = false,
    int? totalDurationSeconds,
  }) {
    return SimulationTimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      currentAlert: clearAlert ? null : (currentAlert ?? this.currentAlert),
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
    );
  }

  @override
  List<Object?> get props => [
    remainingSeconds,
    elapsedSeconds,
    isRunning,
    isPaused,
    currentAlert,
    totalDurationSeconds,
  ];
}

/// Cubit for managing simulation timer with alerts
class SimulationTimerCubit extends Cubit<SimulationTimerState> {
  Timer? _timer;
  Set<TimerAlert> _firedAlerts = {};

  SimulationTimerCubit() : super(SimulationTimerState.initial());

  /// Initialize timer with duration in minutes
  void initialize(int durationMinutes, {int? elapsedSeconds}) {
    final totalSeconds = durationMinutes * 60;
    final elapsed = elapsedSeconds ?? 0;
    final remaining = totalSeconds - elapsed;

    _firedAlerts.clear();

    emit(
      SimulationTimerState(
        remainingSeconds: remaining,
        elapsedSeconds: elapsed,
        isRunning: false,
        isPaused: false,
        currentAlert: null,
        totalDurationSeconds: totalSeconds,
      ),
    );
  }

  /// Start or resume the timer
  void start() {
    if (state.isRunning) return;
    if (state.isTimeUp) return;

    emit(state.copyWith(isRunning: true, isPaused: false));
    _startTicking();
  }

  /// Pause the timer
  void pause() {
    if (!state.isRunning || state.isPaused) return;

    _timer?.cancel();
    emit(state.copyWith(isRunning: false, isPaused: true));
  }

  /// Resume the timer
  void resume() {
    if (!state.isPaused) return;
    if (state.isTimeUp) return;

    emit(state.copyWith(isRunning: true, isPaused: false));
    _startTicking();
  }

  /// Stop the timer
  void stop() {
    _timer?.cancel();
    emit(state.copyWith(isRunning: false, isPaused: false));
  }

  /// Reset the timer
  void reset() {
    _timer?.cancel();
    _firedAlerts.clear();
    emit(SimulationTimerState.initial());
  }

  /// Start the countdown ticker
  void _startTicking() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isRunning) {
        timer.cancel();
        return;
      }

      final newRemaining = state.remainingSeconds - 1;
      final newElapsed = state.elapsedSeconds + 1;

      if (newRemaining <= 0) {
        // Time is up
        timer.cancel();
        emit(
          state.copyWith(
            remainingSeconds: 0,
            elapsedSeconds: newElapsed,
            isRunning: false,
            currentAlert: TimerAlert.timeUp,
          ),
        );
        _firedAlerts.add(TimerAlert.timeUp);
        return;
      }

      // Check for alerts
      TimerAlert? alert = _checkForAlert(newRemaining);

      emit(
        state.copyWith(
          remainingSeconds: newRemaining,
          elapsedSeconds: newElapsed,
          currentAlert: alert,
        ),
      );
    });
  }

  /// Check if an alert should be fired
  TimerAlert? _checkForAlert(int remainingSeconds) {
    TimerAlert? alert;

    // Check alerts in order of priority
    if (remainingSeconds == 1800 &&
        !_firedAlerts.contains(TimerAlert.thirtyMinutes)) {
      alert = TimerAlert.thirtyMinutes;
      _firedAlerts.add(alert);
    } else if (remainingSeconds == 600 &&
        !_firedAlerts.contains(TimerAlert.tenMinutes)) {
      alert = TimerAlert.tenMinutes;
      _firedAlerts.add(alert);
    } else if (remainingSeconds == 300 &&
        !_firedAlerts.contains(TimerAlert.fiveMinutes)) {
      alert = TimerAlert.fiveMinutes;
      _firedAlerts.add(alert);
    } else if (remainingSeconds == 60 &&
        !_firedAlerts.contains(TimerAlert.oneMinute)) {
      alert = TimerAlert.oneMinute;
      _firedAlerts.add(alert);
    }

    return alert;
  }

  /// Clear current alert
  void clearAlert() {
    emit(state.copyWith(clearAlert: true));
  }

  /// Add time (for testing or adjustments)
  void addTime(int seconds) {
    emit(state.copyWith(remainingSeconds: state.remainingSeconds + seconds));
  }

  /// Subtract time (for testing or adjustments)
  void subtractTime(int seconds) {
    final newRemaining = state.remainingSeconds - seconds;
    emit(
      state.copyWith(
        remainingSeconds: newRemaining > 0 ? newRemaining : 0,
        elapsedSeconds: state.elapsedSeconds + seconds,
      ),
    );
  }

  /// Get current state for persistence
  Map<String, dynamic> getStateForPersistence() {
    return {
      'remaining_seconds': state.remainingSeconds,
      'elapsed_seconds': state.elapsedSeconds,
      'is_paused': state.isPaused,
      'total_duration_seconds': state.totalDurationSeconds,
    };
  }

  /// Restore state from persistence
  void restoreState(Map<String, dynamic> savedState) {
    final remainingSeconds = savedState['remaining_seconds'] as int? ?? 0;
    final elapsedSeconds = savedState['elapsed_seconds'] as int? ?? 0;
    final isPaused = savedState['is_paused'] as bool? ?? false;
    final totalDurationSeconds =
        savedState['total_duration_seconds'] as int? ?? 0;

    emit(
      SimulationTimerState(
        remainingSeconds: remainingSeconds,
        elapsedSeconds: elapsedSeconds,
        isRunning: false,
        isPaused: isPaused,
        currentAlert: null,
        totalDurationSeconds: totalDurationSeconds,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
