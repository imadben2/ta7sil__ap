import 'package:equatable/equatable.dart';

/// Status of the session timer
enum SessionTimerStatus { initial, running, paused, completed, cancelled }

/// State for SessionTimerCubit
class SessionTimerState extends Equatable {
  final Duration remainingTime;
  final Duration totalDuration;
  final SessionTimerStatus status;
  final int completedPomodoros;
  final bool isBreak;
  final String? message;

  const SessionTimerState({
    required this.remainingTime,
    required this.totalDuration,
    this.status = SessionTimerStatus.initial,
    this.completedPomodoros = 0,
    this.isBreak = false,
    this.message,
  });

  /// Calculate progress (0.0 to 1.0)
  double get progress {
    if (totalDuration.inSeconds == 0) return 0.0;
    return 1.0 - (remainingTime.inSeconds / totalDuration.inSeconds);
  }

  /// Check if timer is active (running or paused)
  bool get isActive =>
      status == SessionTimerStatus.running ||
      status == SessionTimerStatus.paused;

  /// Check if timer is finished
  bool get isFinished => status == SessionTimerStatus.completed;

  /// Get formatted remaining time (MM:SS)
  String get formattedTime {
    final minutes = remainingTime.inMinutes;
    final seconds = remainingTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Initial state
  factory SessionTimerState.initial() {
    return const SessionTimerState(
      remainingTime: Duration.zero,
      totalDuration: Duration.zero,
      status: SessionTimerStatus.initial,
    );
  }

  /// Copy with method for state updates
  SessionTimerState copyWith({
    Duration? remainingTime,
    Duration? totalDuration,
    SessionTimerStatus? status,
    int? completedPomodoros,
    bool? isBreak,
    String? message,
  }) {
    return SessionTimerState(
      remainingTime: remainingTime ?? this.remainingTime,
      totalDuration: totalDuration ?? this.totalDuration,
      status: status ?? this.status,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      isBreak: isBreak ?? this.isBreak,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    remainingTime,
    totalDuration,
    status,
    completedPomodoros,
    isBreak,
    message,
  ];

  // Convenience getter for pomodoro count (alias for completedPomodoros)
  int get pomodoroCount => completedPomodoros;
}

// Convenience type aliases for checking state
class TimerInitial extends SessionTimerState {
  const TimerInitial()
    : super(
        remainingTime: Duration.zero,
        totalDuration: Duration.zero,
        status: SessionTimerStatus.initial,
      );
}

class TimerRunning extends SessionTimerState {
  const TimerRunning({
    required super.remainingTime,
    required super.totalDuration,
    super.completedPomodoros,
    super.isBreak,
  }) : super(status: SessionTimerStatus.running);

  @override
  int get pomodoroCount => completedPomodoros;
}

class TimerPaused extends SessionTimerState {
  const TimerPaused({
    required super.remainingTime,
    required super.totalDuration,
    super.completedPomodoros,
    super.isBreak,
  }) : super(status: SessionTimerStatus.paused);

  @override
  int get pomodoroCount => completedPomodoros;
}

class TimerCompleted extends SessionTimerState {
  const TimerCompleted({required super.totalDuration, super.completedPomodoros})
    : super(remainingTime: Duration.zero, status: SessionTimerStatus.completed);
}

class BreakRunning extends SessionTimerState {
  const BreakRunning({
    required super.remainingTime,
    required super.totalDuration,
    super.completedPomodoros,
  }) : super(status: SessionTimerStatus.running, isBreak: true);
}

class BreakPaused extends SessionTimerState {
  const BreakPaused({
    required super.remainingTime,
    required super.totalDuration,
    super.completedPomodoros,
  }) : super(status: SessionTimerStatus.paused, isBreak: true);
}
