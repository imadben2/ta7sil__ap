import 'package:flutter/material.dart';
import '../../domain/entities/planner_settings.dart';

/// Data model for PlannerSettings with JSON serialization
class PlannerSettingsModel {
  final String userId;
  final String studyStartTime; // "08:00"
  final String studyEndTime; // "22:00"
  final String sleepStartTime; // "23:00"
  final String sleepEndTime; // "07:00"
  final bool exerciseEnabled;
  final List<int> exerciseDays;
  final String? exerciseTime;
  final int exerciseDurationMinutes;
  final int morningEnergyLevel;
  final int afternoonEnergyLevel;
  final int eveningEnergyLevel;
  final int nightEnergyLevel;
  final bool usePomodoroTechnique;
  final int pomodoroDurationMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int pomodorosBeforeLongBreak;
  final bool enablePrayerTimes;
  final String cityForPrayer;
  final int prayerDurationMinutes;
  final bool autoRescheduleEnabled;
  final bool adaptToPerformanceEnabled;
  final int coefficientWeight;
  final int examProximityWeight;
  final int difficultyWeight;
  final int inactivityWeight;
  final int performanceGapWeight;
  final int maxStudyHoursPerDay;
  final int minBreakBetweenSessions;
  final int sessionDurationMinutes;
  final Map<int, int> coefficientDurations;

  PlannerSettingsModel({
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
    this.inactivityWeight = 10,
    this.performanceGapWeight = 10,
    this.maxStudyHoursPerDay = 8,
    this.minBreakBetweenSessions = 10,
    this.sessionDurationMinutes = 60,
    this.coefficientDurations = const {
      7: 90,
      6: 80,
      5: 75,
      4: 60,
      3: 50,
      2: 40,
      1: 30,
    },
  });

  factory PlannerSettingsModel.fromJson(Map<String, dynamic> json) {
    return PlannerSettingsModel(
      userId: json['user_id']?.toString() ?? '',
      studyStartTime: json['study_start_time'] as String,
      studyEndTime: json['study_end_time'] as String,
      sleepStartTime: json['sleep_start_time'] as String,
      sleepEndTime: json['sleep_end_time'] as String,
      exerciseEnabled: json['exercise_enabled'] as bool? ?? false,
      exerciseDays:
          (json['exercise_days'] as List<dynamic>?)?.cast<int>() ?? [],
      exerciseTime: json['exercise_time'] as String?,
      exerciseDurationMinutes: json['exercise_duration_minutes'] as int? ?? 60,
      morningEnergyLevel: json['morning_energy_level'] as int? ?? 7,
      afternoonEnergyLevel: json['afternoon_energy_level'] as int? ?? 6,
      eveningEnergyLevel: json['evening_energy_level'] as int? ?? 8,
      nightEnergyLevel: json['night_energy_level'] as int? ?? 4,
      usePomodoroTechnique: json['use_pomodoro'] as bool? ?? json['use_pomodoro_technique'] as bool? ?? true,
      pomodoroDurationMinutes: json['pomodoro_duration'] as int? ?? json['pomodoro_duration_minutes'] as int? ?? 25,
      shortBreakMinutes: json['short_break'] as int? ?? json['short_break_minutes'] as int? ?? 5,
      longBreakMinutes: json['long_break'] as int? ?? json['long_break_minutes'] as int? ?? 15,
      pomodorosBeforeLongBreak:
          json['pomodoros_before_long_break'] as int? ?? 4,
      enablePrayerTimes: json['enable_prayer_times'] as bool? ?? false,
      cityForPrayer: json['city_for_prayer'] as String? ?? 'Algiers',
      prayerDurationMinutes: json['prayer_duration_minutes'] as int? ?? 30,
      autoRescheduleEnabled: json['auto_reschedule_missed'] as bool? ?? json['auto_reschedule_enabled'] as bool? ?? true,
      adaptToPerformanceEnabled:
          json['adapt_to_performance_enabled'] as bool? ?? true,
      coefficientWeight: json['coefficient_weight'] as int? ?? 40,
      examProximityWeight: json['exam_proximity_weight'] as int? ?? 25,
      difficultyWeight: json['difficulty_weight'] as int? ?? 15,
      inactivityWeight: json['inactivity_weight'] as int? ?? 10,
      performanceGapWeight: json['performance_gap_weight'] as int? ?? 10,
      maxStudyHoursPerDay: json['max_study_hours_per_day'] as int? ?? 8,
      minBreakBetweenSessions: json['min_break_between_sessions'] as int? ?? 10,
      sessionDurationMinutes: json['session_duration_minutes'] as int? ?? 60,
      coefficientDurations: _parseCoefficientDurations(json['coefficient_durations']),
    );
  }

  /// Parse coefficient durations from JSON (handles null and various formats)
  static Map<int, int> _parseCoefficientDurations(dynamic json) {
    const defaultDurations = {
      7: 90,
      6: 80,
      5: 75,
      4: 60,
      3: 50,
      2: 40,
      1: 30,
    };

    if (json == null) return defaultDurations;

    if (json is Map) {
      final result = <int, int>{};
      json.forEach((key, value) {
        final intKey = key is int ? key : int.tryParse(key.toString());
        final intValue = value is int ? value : int.tryParse(value.toString());
        if (intKey != null && intValue != null) {
          result[intKey] = intValue;
        }
      });
      return result.isEmpty ? defaultDurations : result;
    }

    return defaultDurations;
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'study_start_time': studyStartTime,
      'study_end_time': studyEndTime,
      'sleep_start_time': sleepStartTime,
      'sleep_end_time': sleepEndTime,
      'exercise_enabled': exerciseEnabled,
      'exercise_days': exerciseDays,
      'exercise_time': exerciseTime,
      'exercise_duration_minutes': exerciseDurationMinutes,
      'morning_energy_level': morningEnergyLevel,
      'afternoon_energy_level': afternoonEnergyLevel,
      'evening_energy_level': eveningEnergyLevel,
      'night_energy_level': nightEnergyLevel,
      // Backend expects 'use_pomodoro', 'pomodoro_duration', 'short_break', 'long_break'
      'use_pomodoro': usePomodoroTechnique,
      'pomodoro_duration': pomodoroDurationMinutes,
      'short_break': shortBreakMinutes,
      'long_break': longBreakMinutes,
      'pomodoros_before_long_break': pomodorosBeforeLongBreak,
      'enable_prayer_times': enablePrayerTimes,
      'city_for_prayer': cityForPrayer,
      'prayer_duration_minutes': prayerDurationMinutes,
      // Backend expects 'auto_reschedule_missed'
      'auto_reschedule_missed': autoRescheduleEnabled,
      'adapt_to_performance_enabled': adaptToPerformanceEnabled,
      'coefficient_weight': coefficientWeight,
      'exam_proximity_weight': examProximityWeight,
      'difficulty_weight': difficultyWeight,
      'inactivity_weight': inactivityWeight,
      'performance_gap_weight': performanceGapWeight,
      'max_study_hours_per_day': maxStudyHoursPerDay,
      'min_break_between_sessions': minBreakBetweenSessions,
      'session_duration_minutes': sessionDurationMinutes,
      'coefficient_durations': coefficientDurations.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    };
  }

  PlannerSettings toEntity() {
    return PlannerSettings(
      userId: userId,
      studyStartTime: _parseTimeOfDay(studyStartTime),
      studyEndTime: _parseTimeOfDay(studyEndTime),
      sleepStartTime: _parseTimeOfDay(sleepStartTime),
      sleepEndTime: _parseTimeOfDay(sleepEndTime),
      exerciseEnabled: exerciseEnabled,
      exerciseDays: exerciseDays,
      exerciseTime: exerciseTime != null
          ? _parseTimeOfDay(exerciseTime!)
          : null,
      exerciseDurationMinutes: exerciseDurationMinutes,
      morningEnergyLevel: morningEnergyLevel,
      afternoonEnergyLevel: afternoonEnergyLevel,
      eveningEnergyLevel: eveningEnergyLevel,
      nightEnergyLevel: nightEnergyLevel,
      usePomodoroTechnique: usePomodoroTechnique,
      pomodoroDurationMinutes: pomodoroDurationMinutes,
      shortBreakMinutes: shortBreakMinutes,
      longBreakMinutes: longBreakMinutes,
      pomodorosBeforeLongBreak: pomodorosBeforeLongBreak,
      enablePrayerTimes: enablePrayerTimes,
      cityForPrayer: cityForPrayer,
      prayerDurationMinutes: prayerDurationMinutes,
      autoRescheduleEnabled: autoRescheduleEnabled,
      adaptToPerformanceEnabled: adaptToPerformanceEnabled,
      coefficientWeight: coefficientWeight,
      examProximityWeight: examProximityWeight,
      difficultyWeight: difficultyWeight,
      inactivityWeight: inactivityWeight,
      performanceGapWeight: performanceGapWeight,
      maxStudyHoursPerDay: maxStudyHoursPerDay,
      minBreakBetweenSessions: minBreakBetweenSessions,
      sessionDurationMinutes: sessionDurationMinutes,
      coefficientDurations: coefficientDurations,
    );
  }

  factory PlannerSettingsModel.fromEntity(PlannerSettings entity) {
    return PlannerSettingsModel(
      userId: entity.userId,
      studyStartTime: _formatTimeOfDay(entity.studyStartTime),
      studyEndTime: _formatTimeOfDay(entity.studyEndTime),
      sleepStartTime: _formatTimeOfDay(entity.sleepStartTime),
      sleepEndTime: _formatTimeOfDay(entity.sleepEndTime),
      exerciseEnabled: entity.exerciseEnabled,
      exerciseDays: entity.exerciseDays,
      exerciseTime: entity.exerciseTime != null
          ? _formatTimeOfDay(entity.exerciseTime!)
          : null,
      exerciseDurationMinutes: entity.exerciseDurationMinutes,
      morningEnergyLevel: entity.morningEnergyLevel,
      afternoonEnergyLevel: entity.afternoonEnergyLevel,
      eveningEnergyLevel: entity.eveningEnergyLevel,
      nightEnergyLevel: entity.nightEnergyLevel,
      usePomodoroTechnique: entity.usePomodoroTechnique,
      pomodoroDurationMinutes: entity.pomodoroDurationMinutes,
      shortBreakMinutes: entity.shortBreakMinutes,
      longBreakMinutes: entity.longBreakMinutes,
      pomodorosBeforeLongBreak: entity.pomodorosBeforeLongBreak,
      enablePrayerTimes: entity.enablePrayerTimes,
      cityForPrayer: entity.cityForPrayer,
      prayerDurationMinutes: entity.prayerDurationMinutes,
      autoRescheduleEnabled: entity.autoRescheduleEnabled,
      adaptToPerformanceEnabled: entity.adaptToPerformanceEnabled,
      coefficientWeight: entity.coefficientWeight,
      examProximityWeight: entity.examProximityWeight,
      difficultyWeight: entity.difficultyWeight,
      inactivityWeight: entity.inactivityWeight,
      performanceGapWeight: entity.performanceGapWeight,
      maxStudyHoursPerDay: entity.maxStudyHoursPerDay,
      minBreakBetweenSessions: entity.minBreakBetweenSessions,
      sessionDurationMinutes: entity.sessionDurationMinutes,
      coefficientDurations: entity.coefficientDurations,
    );
  }

  static TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
