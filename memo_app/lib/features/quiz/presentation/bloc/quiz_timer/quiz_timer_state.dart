import 'package:equatable/equatable.dart';

/// States for QuizTimerCubit
abstract class QuizTimerState extends Equatable {
  const QuizTimerState();

  @override
  List<Object?> get props => [];
}

/// Timer initial state (not started)
class QuizTimerInitial extends QuizTimerState {
  const QuizTimerInitial();
}

/// Timer running
class QuizTimerRunning extends QuizTimerState {
  final int remainingSeconds;
  final int totalSeconds;

  const QuizTimerRunning({
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  @override
  List<Object?> get props => [remainingSeconds, totalSeconds];

  /// Get progress percentage
  double get progressPercentage {
    return (remainingSeconds / totalSeconds) * 100;
  }

  /// Check if timer is in warning zone (< 20%)
  bool get isWarning {
    return progressPercentage < 20;
  }

  /// Check if timer is in danger zone (< 10%)
  bool get isDanger {
    return progressPercentage < 10;
  }

  /// Format remaining time as MM:SS
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format remaining time as HH:MM:SS for long quizzes
  String get formattedTimeLong {
    final hours = remainingSeconds ~/ 3600;
    final minutes = (remainingSeconds % 3600) ~/ 60;
    final seconds = remainingSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}

/// Timer paused
class QuizTimerPaused extends QuizTimerState {
  final int remainingSeconds;
  final int totalSeconds;

  const QuizTimerPaused({
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  @override
  List<Object?> get props => [remainingSeconds, totalSeconds];
}

/// Timer expired
class QuizTimerExpired extends QuizTimerState {
  const QuizTimerExpired();
}
