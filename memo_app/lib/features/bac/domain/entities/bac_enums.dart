/// Enums for BAC feature

/// Status of a simulation
enum SimulationStatus { notStarted, inProgress, paused, completed, abandoned }

/// Mode of simulation
enum SimulationMode {
  practice, // Practice mode - no time limit, can pause
  exam, // Exam mode - timed, strict rules
  quick, // Quick quiz - short time, few questions
}

/// Difficulty level
enum DifficultyLevel {
  easy,
  medium,
  hard,
  mixed, // Mix of all difficulties
}

/// Timer alerts
enum TimerAlert {
  thirtyMinutes, // 30 minutes remaining
  tenMinutes, // 10 minutes remaining
  fiveMinutes, // 5 minutes remaining
  oneMinute, // 1 minute remaining
  timeUp, // Time is up
}

/// Extensions for enum display
extension SimulationStatusExtension on SimulationStatus {
  String get displayName {
    switch (this) {
      case SimulationStatus.notStarted:
        return 'لم تبدأ';
      case SimulationStatus.inProgress:
        return 'جارية';
      case SimulationStatus.paused:
        return 'متوقفة مؤقتاً';
      case SimulationStatus.completed:
        return 'مكتملة';
      case SimulationStatus.abandoned:
        return 'متروكة';
    }
  }
}

extension SimulationModeExtension on SimulationMode {
  String get displayName {
    switch (this) {
      case SimulationMode.practice:
        return 'تدريب';
      case SimulationMode.exam:
        return 'امتحان';
      case SimulationMode.quick:
        return 'سريع';
    }
  }
}

extension DifficultyLevelExtension on DifficultyLevel {
  String get displayName {
    switch (this) {
      case DifficultyLevel.easy:
        return 'سهل';
      case DifficultyLevel.medium:
        return 'متوسط';
      case DifficultyLevel.hard:
        return 'صعب';
      case DifficultyLevel.mixed:
        return 'مختلط';
    }
  }
}

extension TimerAlertExtension on TimerAlert {
  String get displayMessage {
    switch (this) {
      case TimerAlert.thirtyMinutes:
        return 'تبقى 30 دقيقة';
      case TimerAlert.tenMinutes:
        return 'تبقى 10 دقائق';
      case TimerAlert.fiveMinutes:
        return 'تبقى 5 دقائق';
      case TimerAlert.oneMinute:
        return 'تبقى دقيقة واحدة';
      case TimerAlert.timeUp:
        return 'انتهى الوقت';
    }
  }

  int get remainingSeconds {
    switch (this) {
      case TimerAlert.thirtyMinutes:
        return 1800;
      case TimerAlert.tenMinutes:
        return 600;
      case TimerAlert.fiveMinutes:
        return 300;
      case TimerAlert.oneMinute:
        return 60;
      case TimerAlert.timeUp:
        return 0;
    }
  }
}
