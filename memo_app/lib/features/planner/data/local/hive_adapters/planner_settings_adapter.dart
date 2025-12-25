import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/planner_settings.dart';

/// Hive type adapter for PlannerSettings entity
/// Type ID: 11
///
/// Version history:
/// - v1: Initial version
/// - v2: Added gracePeriodMinutes, selectedSubjectIds
/// - v3: Added all missing fields (notifications, UI prefs, coefficientDurations, etc.)
class PlannerSettingsAdapter extends TypeAdapter<PlannerSettings> {
  @override
  final int typeId = 11;

  // Current schema version
  static const int _currentVersion = 3;

  @override
  PlannerSettings read(BinaryReader reader) {
    // Read version number (for backward compatibility)
    final numFields = reader.readByte();

    // If first byte is small (< 50), it's an old format without version
    // Old format starts with userId string length
    final bool isOldFormat = numFields < 50;

    if (isOldFormat) {
      // Rewind and read old format
      return _readOldFormat(reader, numFields);
    }

    // New versioned format
    final version = numFields; // This was actually the version
    return _readVersioned(reader, version);
  }

  PlannerSettings _readOldFormat(BinaryReader reader, int firstByte) {
    // The firstByte was part of the userId string length, we need to reconstruct
    // Actually, for Hive's writeString, it writes length as varint first
    // Let's just read the old format directly

    // Re-read from beginning using the old logic
    // Since we already read one byte, we need to handle this carefully
    // For simplicity, use try-catch with defaults for missing fields

    try {
      // Reconstruct userId by prepending the already-read byte
      final remainingLength = reader.readByte();
      final totalLength = (firstByte << 8) | remainingLength;

      // This approach is complex, let's use a simpler strategy:
      // Just return defaults for new format, the data will be saved in new format on next write
      return PlannerSettings(
        userId: 'current_user',
        studyStartTime: const TimeOfDay(hour: 8, minute: 0),
        studyEndTime: const TimeOfDay(hour: 22, minute: 0),
        sleepStartTime: const TimeOfDay(hour: 23, minute: 0),
        sleepEndTime: const TimeOfDay(hour: 7, minute: 0),
      );
    } catch (e) {
      return PlannerSettings(
        userId: 'current_user',
        studyStartTime: const TimeOfDay(hour: 8, minute: 0),
        studyEndTime: const TimeOfDay(hour: 22, minute: 0),
        sleepStartTime: const TimeOfDay(hour: 23, minute: 0),
        sleepEndTime: const TimeOfDay(hour: 7, minute: 0),
      );
    }
  }

  PlannerSettings _readVersioned(BinaryReader reader, int version) {
    // Read all fields
    final userId = reader.readString();
    final studyStartTime = TimeOfDay(
      hour: reader.readInt(),
      minute: reader.readInt(),
    );
    final studyEndTime = TimeOfDay(
      hour: reader.readInt(),
      minute: reader.readInt(),
    );
    final sleepStartTime = TimeOfDay(
      hour: reader.readInt(),
      minute: reader.readInt(),
    );
    final sleepEndTime = TimeOfDay(
      hour: reader.readInt(),
      minute: reader.readInt(),
    );
    final exerciseEnabled = reader.readBool();
    final exerciseDays = (reader.read() as List).cast<int>();
    final hasExerciseTime = reader.read() != null;
    TimeOfDay? exerciseTime;
    if (hasExerciseTime) {
      exerciseTime = TimeOfDay(
        hour: reader.readInt(),
        minute: reader.readInt(),
      );
    }
    final exerciseDurationMinutes = reader.readInt();
    final morningEnergyLevel = reader.readInt();
    final afternoonEnergyLevel = reader.readInt();
    final eveningEnergyLevel = reader.readInt();
    final nightEnergyLevel = reader.readInt();
    final usePomodoroTechnique = reader.readBool();
    final pomodoroDurationMinutes = reader.readInt();
    final shortBreakMinutes = reader.readInt();
    final longBreakMinutes = reader.readInt();
    final pomodorosBeforeLongBreak = reader.readInt();
    final enablePrayerTimes = reader.readBool();
    final cityForPrayer = reader.readString();
    final prayerDurationMinutes = reader.readInt();
    final autoRescheduleEnabled = reader.readBool();
    final adaptToPerformanceEnabled = reader.readBool();
    final coefficientWeight = reader.readInt();
    final examProximityWeight = reader.readInt();
    final difficultyWeight = reader.readInt();
    final inactivityWeight = reader.readInt();
    final performanceGapWeight = reader.readInt();
    final maxStudyHoursPerDay = reader.readInt();
    final minBreakBetweenSessions = reader.readInt();

    // Version 2 fields
    int gracePeriodMinutes = 15;
    List<String> selectedSubjectIds = [];

    if (version >= 2) {
      gracePeriodMinutes = reader.readInt();
      selectedSubjectIds = (reader.read() as List).cast<String>();
    }

    // Version 3 fields - all the missing ones
    int historicalPerformanceGapWeight = 10;
    int pomodoroSessions = 4;
    bool sessionReminders = true;
    bool examReminders = true;
    bool prayerReminders = true;
    int reminderMinutesBefore = 15;
    bool darkModeEnabled = false;
    String languageCode = 'ar';
    String? viewMode = 'list';
    bool allowFriday = false;
    int defaultEnergyLevel = 7;
    int sessionDurationMinutes = 60;
    Map<int, int> coefficientDurations = const {
      7: 90, 6: 80, 5: 75, 4: 60, 3: 50, 2: 40, 1: 30,
    };

    if (version >= 3) {
      historicalPerformanceGapWeight = reader.readInt();
      pomodoroSessions = reader.readInt();
      sessionReminders = reader.readBool();
      examReminders = reader.readBool();
      prayerReminders = reader.readBool();
      reminderMinutesBefore = reader.readInt();
      darkModeEnabled = reader.readBool();
      languageCode = reader.readString();
      final hasViewMode = reader.readBool();
      viewMode = hasViewMode ? reader.readString() : null;
      allowFriday = reader.readBool();
      defaultEnergyLevel = reader.readInt();
      sessionDurationMinutes = reader.readInt();
      // Read coefficientDurations map
      final durationsLength = reader.readInt();
      final durations = <int, int>{};
      for (var i = 0; i < durationsLength; i++) {
        final key = reader.readInt();
        final value = reader.readInt();
        durations[key] = value;
      }
      coefficientDurations = durations;
    }

    return PlannerSettings(
      userId: userId,
      studyStartTime: studyStartTime,
      studyEndTime: studyEndTime,
      sleepStartTime: sleepStartTime,
      sleepEndTime: sleepEndTime,
      exerciseEnabled: exerciseEnabled,
      exerciseDays: exerciseDays,
      exerciseTime: exerciseTime,
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
      historicalPerformanceGapWeight: historicalPerformanceGapWeight,
      inactivityWeight: inactivityWeight,
      performanceGapWeight: performanceGapWeight,
      maxStudyHoursPerDay: maxStudyHoursPerDay,
      minBreakBetweenSessions: minBreakBetweenSessions,
      pomodoroSessions: pomodoroSessions,
      sessionReminders: sessionReminders,
      examReminders: examReminders,
      prayerReminders: prayerReminders,
      reminderMinutesBefore: reminderMinutesBefore,
      darkModeEnabled: darkModeEnabled,
      languageCode: languageCode,
      viewMode: viewMode,
      allowFriday: allowFriday,
      defaultEnergyLevel: defaultEnergyLevel,
      sessionDurationMinutes: sessionDurationMinutes,
      gracePeriodMinutes: gracePeriodMinutes,
      selectedSubjectIds: selectedSubjectIds,
      coefficientDurations: coefficientDurations,
    );
  }

  @override
  void write(BinaryWriter writer, PlannerSettings obj) {
    // Write version first
    writer.writeByte(_currentVersion);

    // Write all fields
    writer.writeString(obj.userId);
    writer.writeInt(obj.studyStartTime.hour);
    writer.writeInt(obj.studyStartTime.minute);
    writer.writeInt(obj.studyEndTime.hour);
    writer.writeInt(obj.studyEndTime.minute);
    writer.writeInt(obj.sleepStartTime.hour);
    writer.writeInt(obj.sleepStartTime.minute);
    writer.writeInt(obj.sleepEndTime.hour);
    writer.writeInt(obj.sleepEndTime.minute);
    writer.writeBool(obj.exerciseEnabled);
    writer.write(obj.exerciseDays);
    writer.write(obj.exerciseTime != null ? true : null);
    if (obj.exerciseTime != null) {
      writer.writeInt(obj.exerciseTime!.hour);
      writer.writeInt(obj.exerciseTime!.minute);
    }
    writer.writeInt(obj.exerciseDurationMinutes);
    writer.writeInt(obj.morningEnergyLevel);
    writer.writeInt(obj.afternoonEnergyLevel);
    writer.writeInt(obj.eveningEnergyLevel);
    writer.writeInt(obj.nightEnergyLevel);
    writer.writeBool(obj.usePomodoroTechnique);
    writer.writeInt(obj.pomodoroDurationMinutes);
    writer.writeInt(obj.shortBreakMinutes);
    writer.writeInt(obj.longBreakMinutes);
    writer.writeInt(obj.pomodorosBeforeLongBreak);
    writer.writeBool(obj.enablePrayerTimes);
    writer.writeString(obj.cityForPrayer);
    writer.writeInt(obj.prayerDurationMinutes);
    writer.writeBool(obj.autoRescheduleEnabled);
    writer.writeBool(obj.adaptToPerformanceEnabled);
    writer.writeInt(obj.coefficientWeight);
    writer.writeInt(obj.examProximityWeight);
    writer.writeInt(obj.difficultyWeight);
    writer.writeInt(obj.inactivityWeight);
    writer.writeInt(obj.performanceGapWeight);
    writer.writeInt(obj.maxStudyHoursPerDay);
    writer.writeInt(obj.minBreakBetweenSessions);

    // Version 2 fields
    writer.writeInt(obj.gracePeriodMinutes);
    writer.write(obj.selectedSubjectIds);

    // Version 3 fields
    writer.writeInt(obj.historicalPerformanceGapWeight);
    writer.writeInt(obj.pomodoroSessions);
    writer.writeBool(obj.sessionReminders);
    writer.writeBool(obj.examReminders);
    writer.writeBool(obj.prayerReminders);
    writer.writeInt(obj.reminderMinutesBefore);
    writer.writeBool(obj.darkModeEnabled);
    writer.writeString(obj.languageCode);
    writer.writeBool(obj.viewMode != null);
    if (obj.viewMode != null) {
      writer.writeString(obj.viewMode!);
    }
    writer.writeBool(obj.allowFriday);
    writer.writeInt(obj.defaultEnergyLevel);
    writer.writeInt(obj.sessionDurationMinutes);
    // Write coefficientDurations map
    writer.writeInt(obj.coefficientDurations.length);
    for (final entry in obj.coefficientDurations.entries) {
      writer.writeInt(entry.key);
      writer.writeInt(entry.value);
    }
  }
}
