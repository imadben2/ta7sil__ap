import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'study_session.dart';

/// Domain entity representing planner configuration settings
class PlannerSettings extends Equatable {
  final String userId;

  // Study Time Window
  final TimeOfDay studyStartTime;
  final TimeOfDay studyEndTime;

  // Sleep Schedule
  final TimeOfDay sleepStartTime;
  final TimeOfDay sleepEndTime;

  // Exercise/Sport
  final bool exerciseEnabled;
  final List<int> exerciseDays; // 1=Monday, 7=Sunday
  final TimeOfDay? exerciseTime;
  final int exerciseDurationMinutes;

  // Energy Levels (1-10 scale)
  final int morningEnergyLevel; // 6:00-12:00
  final int afternoonEnergyLevel; // 12:00-18:00
  final int eveningEnergyLevel; // 18:00-22:00
  final int nightEnergyLevel; // 22:00-6:00

  // Pomodoro Settings
  final bool usePomodoroTechnique;
  final int pomodoroDurationMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int pomodorosBeforeLongBreak;

  // Prayer Times
  final bool enablePrayerTimes;
  final String cityForPrayer; // Algiers, Oran, Constantine, etc.
  final int prayerDurationMinutes;

  // Auto-Adaptation
  final bool autoRescheduleEnabled;
  final bool adaptToPerformanceEnabled;

  // Priority Weights (must sum to 100)
  final int coefficientWeight; // Default: 40%
  final int examProximityWeight; // Default: 25%
  final int difficultyWeight; // Default: 15%
  final int historicalPerformanceGapWeight; // Default: 10%
  final int performanceGapWeight; // Default: 5%
  final int inactivityWeight; // Default: 5%

  // Limits
  final int maxStudyHoursPerDay;
  final int minBreakBetweenSessions; // minutes

  // Pomodoro Sessions (for long break interval)
  final int pomodoroSessions; // Number of pomodoros before long break

  // Notifications
  final bool sessionReminders; // Enable session start/end notifications
  final bool examReminders; // Enable exam reminder notifications
  final bool prayerReminders; // Enable prayer time notifications
  final int reminderMinutesBefore; // Minutes before event to send reminder

  // UI Preferences
  final bool darkModeEnabled; // Dark mode toggle
  final String languageCode; // 'ar', 'fr', 'en'
  final String? viewMode; // View mode: 'list', 'grid', 'calendar', 'timeline'

  // Schedule Preferences
  final bool allowFriday; // Allow scheduling on Friday (Jumu'ah)
  final int defaultEnergyLevel; // Default energy level for new sessions (1-10)

  // Session Duration (non-Pomodoro mode)
  final int sessionDurationMinutes; // Default session duration (30-90 minutes)

  // Session Lifecycle
  final int gracePeriodMinutes; // Minutes after session end before marking as missed (5-60)
  final List<String> selectedSubjectIds; // IDs of subjects selected for scheduling

  // Session Duration by Coefficient (Map: coefficient -> duration in minutes)
  final Map<int, int> coefficientDurations; // e.g., {7: 90, 5: 75, 3: 60, 2: 45, 1: 30}

  const PlannerSettings({
    required this.userId,
    required this.studyStartTime,
    required this.studyEndTime,
    required this.sleepStartTime,
    required this.sleepEndTime,
    this.exerciseEnabled = false,
    this.exerciseDays = const [],
    this.exerciseTime,
    this.exerciseDurationMinutes = 60,
    this.morningEnergyLevel = 7,
    this.afternoonEnergyLevel = 6,
    this.eveningEnergyLevel = 8,
    this.nightEnergyLevel = 4,
    this.usePomodoroTechnique = true,
    this.pomodoroDurationMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.pomodorosBeforeLongBreak = 4,
    this.enablePrayerTimes = false,
    this.cityForPrayer = 'Algiers',
    this.prayerDurationMinutes = 30,
    this.autoRescheduleEnabled = true,
    this.adaptToPerformanceEnabled = true,
    this.coefficientWeight = 40,
    this.examProximityWeight = 25,
    this.difficultyWeight = 15,
    this.historicalPerformanceGapWeight = 10,
    this.performanceGapWeight = 5,
    this.inactivityWeight = 5,
    this.maxStudyHoursPerDay = 8,
    this.minBreakBetweenSessions = 10,
    this.pomodoroSessions = 4,
    this.sessionReminders = true,
    this.examReminders = true,
    this.prayerReminders = true,
    this.reminderMinutesBefore = 15,
    this.darkModeEnabled = false,
    this.languageCode = 'ar',
    this.viewMode = 'list',
    this.allowFriday = false,
    this.defaultEnergyLevel = 7,
    this.sessionDurationMinutes = 60,
    this.gracePeriodMinutes = 15,
    this.selectedSubjectIds = const [],
    this.coefficientDurations = const {
      7: 90,  // High coefficient → 90 minutes
      6: 80,  // Medium-high+ → 80 minutes
      5: 75,  // Medium-high → 75 minutes
      4: 60,  // Medium → 60 minutes
      3: 50,  // Medium-low → 50 minutes
      2: 40,  // Low → 40 minutes
      1: 30,  // Very low → 30 minutes
    },
  });

  @override
  List<Object?> get props => [
    userId,
    studyStartTime,
    studyEndTime,
    sleepStartTime,
    sleepEndTime,
    exerciseEnabled,
    exerciseDays,
    exerciseTime,
    exerciseDurationMinutes,
    morningEnergyLevel,
    afternoonEnergyLevel,
    eveningEnergyLevel,
    nightEnergyLevel,
    usePomodoroTechnique,
    pomodoroDurationMinutes,
    shortBreakMinutes,
    longBreakMinutes,
    pomodorosBeforeLongBreak,
    enablePrayerTimes,
    cityForPrayer,
    prayerDurationMinutes,
    autoRescheduleEnabled,
    adaptToPerformanceEnabled,
    coefficientWeight,
    examProximityWeight,
    difficultyWeight,
    historicalPerformanceGapWeight,
    performanceGapWeight,
    inactivityWeight,
    maxStudyHoursPerDay,
    minBreakBetweenSessions,
    pomodoroSessions,
    sessionReminders,
    examReminders,
    prayerReminders,
    reminderMinutesBefore,
    darkModeEnabled,
    languageCode,
    viewMode,
    allowFriday,
    defaultEnergyLevel,
    sessionDurationMinutes,
    gracePeriodMinutes,
    selectedSubjectIds,
    coefficientDurations,
  ];

  // Helper: Hour extraction properties for UI
  int get studyStartHour => studyStartTime.hour;
  int get studyEndHour => studyEndTime.hour;
  int get sleepStartHour => sleepStartTime.hour;
  int get sleepEndHour => sleepEndTime.hour;

  // Helper: Available study duration per day
  Duration get dailyStudyWindow {
    final start = Duration(
      hours: studyStartTime.hour,
      minutes: studyStartTime.minute,
    );
    final end = Duration(
      hours: studyEndTime.hour,
      minutes: studyEndTime.minute,
    );
    return end - start;
  }

  // Helper: Get energy level for time of day
  EnergyLevel getEnergyLevelForTime(TimeOfDay time) {
    final hour = time.hour;
    int level;

    if (hour >= 6 && hour < 12) {
      level = morningEnergyLevel;
    } else if (hour >= 12 && hour < 18) {
      level = afternoonEnergyLevel;
    } else if (hour >= 18 && hour < 22) {
      level = eveningEnergyLevel;
    } else {
      level = nightEnergyLevel;
    }

    if (level >= 7) return EnergyLevel.high;
    if (level >= 4) return EnergyLevel.medium;
    return EnergyLevel.low;
  }

  // Helper: Get session duration for a coefficient
  int getCoefficientDuration(int coefficient) {
    return coefficientDurations[coefficient] ?? sessionDurationMinutes;
  }

  // Validation: Check if study window overlaps with sleep schedule
  bool get hasStudySleepConflict {
    final studyStartMinutes = studyStartTime.hour * 60 + studyStartTime.minute;
    final studyEndMinutes = studyEndTime.hour * 60 + studyEndTime.minute;
    final sleepStartMinutes = sleepStartTime.hour * 60 + sleepStartTime.minute;
    final sleepEndMinutes = sleepEndTime.hour * 60 + sleepEndTime.minute;

    // Handle case where sleep/study crosses midnight
    if (sleepStartMinutes > sleepEndMinutes) {
      // Sleep crosses midnight (e.g., 23:00 - 07:00)
      return (studyStartMinutes >= sleepStartMinutes || studyStartMinutes < sleepEndMinutes) ||
             (studyEndMinutes >= sleepStartMinutes || studyEndMinutes < sleepEndMinutes);
    } else {
      // Normal case
      return (studyStartMinutes >= sleepStartMinutes && studyStartMinutes < sleepEndMinutes) ||
             (studyEndMinutes > sleepStartMinutes && studyEndMinutes <= sleepEndMinutes) ||
             (studyStartMinutes <= sleepStartMinutes && studyEndMinutes >= sleepEndMinutes);
    }
  }

  // Validation: Check if daily goal is achievable within study window
  bool get isDailyGoalAchievable {
    final availableHours = dailyStudyWindow.inMinutes / 60.0;
    return maxStudyHoursPerDay <= availableHours;
  }

  // Validation: Check if priority weights sum to 100%
  bool get arePriorityWeightsValid {
    final total = coefficientWeight + examProximityWeight +
                  difficultyWeight + historicalPerformanceGapWeight +
                  performanceGapWeight + inactivityWeight;
    return total == 100;
  }

  // Helper: Net study time available after accounting for breaks
  Duration get netStudyTimeAvailable {
    if (!usePomodoroTechnique) {
      return dailyStudyWindow;
    }

    // Estimate break overhead for Pomodoro technique
    final avgSessionsPerDay = maxStudyHoursPerDay * 60 / pomodoroDurationMinutes;
    final totalPomodoros = avgSessionsPerDay;

    // Calculate breaks: short breaks + long breaks
    final numLongBreaks = (totalPomodoros / pomodorosBeforeLongBreak).floor();
    final numShortBreaks = totalPomodoros - numLongBreaks;

    final breakOverhead = (numShortBreaks * shortBreakMinutes) +
                          (numLongBreaks * longBreakMinutes);

    final netMinutes = dailyStudyWindow.inMinutes - breakOverhead.toInt();
    return Duration(minutes: netMinutes.clamp(0, dailyStudyWindow.inMinutes));
  }

  // Helper: Get all validation issues
  List<String> get validationIssues {
    final issues = <String>[];

    if (hasStudySleepConflict) {
      issues.add('Study window overlaps with sleep schedule');
    }

    if (!isDailyGoalAchievable) {
      issues.add('Daily study goal (${maxStudyHoursPerDay}h) exceeds available time (${(dailyStudyWindow.inMinutes / 60).toStringAsFixed(1)}h)');
    }

    if (!arePriorityWeightsValid) {
      final total = coefficientWeight + examProximityWeight +
                    difficultyWeight + historicalPerformanceGapWeight +
                    performanceGapWeight + inactivityWeight;
      issues.add('Priority weights must sum to 100% (currently ${total}%)');
    }

    return issues;
  }

  // Helper: Check if settings are valid
  bool get isValid => validationIssues.isEmpty;

  PlannerSettings copyWith({
    TimeOfDay? studyStartTime,
    TimeOfDay? studyEndTime,
    TimeOfDay? sleepStartTime,
    TimeOfDay? sleepEndTime,
    bool? exerciseEnabled,
    List<int>? exerciseDays,
    TimeOfDay? exerciseTime,
    int? exerciseDurationMinutes,
    int? morningEnergyLevel,
    int? afternoonEnergyLevel,
    int? eveningEnergyLevel,
    int? nightEnergyLevel,
    bool? usePomodoroTechnique,
    int? pomodoroDurationMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? pomodorosBeforeLongBreak,
    bool? enablePrayerTimes,
    String? cityForPrayer,
    int? prayerDurationMinutes,
    bool? autoRescheduleEnabled,
    bool? adaptToPerformanceEnabled,
    int? coefficientWeight,
    int? examProximityWeight,
    int? difficultyWeight,
    int? historicalPerformanceGapWeight,
    int? performanceGapWeight,
    int? inactivityWeight,
    int? maxStudyHoursPerDay,
    int? minBreakBetweenSessions,
    int? pomodoroSessions,
    bool? sessionReminders,
    bool? examReminders,
    bool? prayerReminders,
    int? reminderMinutesBefore,
    bool? darkModeEnabled,
    String? languageCode,
    String? viewMode,
    bool? allowFriday,
    int? defaultEnergyLevel,
    int? sessionDurationMinutes,
    int? gracePeriodMinutes,
    List<String>? selectedSubjectIds,
    Map<int, int>? coefficientDurations,
  }) {
    return PlannerSettings(
      userId: userId,
      studyStartTime: studyStartTime ?? this.studyStartTime,
      studyEndTime: studyEndTime ?? this.studyEndTime,
      sleepStartTime: sleepStartTime ?? this.sleepStartTime,
      sleepEndTime: sleepEndTime ?? this.sleepEndTime,
      exerciseEnabled: exerciseEnabled ?? this.exerciseEnabled,
      exerciseDays: exerciseDays ?? this.exerciseDays,
      exerciseTime: exerciseTime ?? this.exerciseTime,
      exerciseDurationMinutes:
          exerciseDurationMinutes ?? this.exerciseDurationMinutes,
      morningEnergyLevel: morningEnergyLevel ?? this.morningEnergyLevel,
      afternoonEnergyLevel: afternoonEnergyLevel ?? this.afternoonEnergyLevel,
      eveningEnergyLevel: eveningEnergyLevel ?? this.eveningEnergyLevel,
      nightEnergyLevel: nightEnergyLevel ?? this.nightEnergyLevel,
      usePomodoroTechnique: usePomodoroTechnique ?? this.usePomodoroTechnique,
      pomodoroDurationMinutes:
          pomodoroDurationMinutes ?? this.pomodoroDurationMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      pomodorosBeforeLongBreak:
          pomodorosBeforeLongBreak ?? this.pomodorosBeforeLongBreak,
      enablePrayerTimes: enablePrayerTimes ?? this.enablePrayerTimes,
      cityForPrayer: cityForPrayer ?? this.cityForPrayer,
      prayerDurationMinutes:
          prayerDurationMinutes ?? this.prayerDurationMinutes,
      autoRescheduleEnabled:
          autoRescheduleEnabled ?? this.autoRescheduleEnabled,
      adaptToPerformanceEnabled:
          adaptToPerformanceEnabled ?? this.adaptToPerformanceEnabled,
      coefficientWeight: coefficientWeight ?? this.coefficientWeight,
      examProximityWeight: examProximityWeight ?? this.examProximityWeight,
      difficultyWeight: difficultyWeight ?? this.difficultyWeight,
      historicalPerformanceGapWeight: historicalPerformanceGapWeight ?? this.historicalPerformanceGapWeight,
      performanceGapWeight: performanceGapWeight ?? this.performanceGapWeight,
      inactivityWeight: inactivityWeight ?? this.inactivityWeight,
      maxStudyHoursPerDay: maxStudyHoursPerDay ?? this.maxStudyHoursPerDay,
      minBreakBetweenSessions:
          minBreakBetweenSessions ?? this.minBreakBetweenSessions,
      pomodoroSessions: pomodoroSessions ?? this.pomodoroSessions,
      sessionReminders: sessionReminders ?? this.sessionReminders,
      examReminders: examReminders ?? this.examReminders,
      prayerReminders: prayerReminders ?? this.prayerReminders,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      languageCode: languageCode ?? this.languageCode,
      viewMode: viewMode ?? this.viewMode,
      allowFriday: allowFriday ?? this.allowFriday,
      defaultEnergyLevel: defaultEnergyLevel ?? this.defaultEnergyLevel,
      sessionDurationMinutes:
          sessionDurationMinutes ?? this.sessionDurationMinutes,
      gracePeriodMinutes: gracePeriodMinutes ?? this.gracePeriodMinutes,
      selectedSubjectIds: selectedSubjectIds ?? this.selectedSubjectIds,
      coefficientDurations: coefficientDurations ?? this.coefficientDurations,
    );
  }

  // Convenience getters for compatibility with UI pages
  TimeOfDay get sleepTime => sleepStartTime;
  TimeOfDay get wakeTime => sleepEndTime;
  int get shortBreak => shortBreakMinutes;
  int get longBreak => longBreakMinutes;
  int get pomodoroDuration => pomodoroDurationMinutes;
  TimeOfDay? get exerciseStartTime => exerciseTime;
}
