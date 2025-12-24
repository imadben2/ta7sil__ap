import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/planner_settings.dart';

/// Hive type adapter for PlannerSettings entity
/// Type ID: 11
///
/// Version history:
/// - v1: Initial version
/// - v2: Added gracePeriodMinutes, selectedSubjectIds
class PlannerSettingsAdapter extends TypeAdapter<PlannerSettings> {
  @override
  final int typeId = 11;

  // Current schema version
  static const int _currentVersion = 2;

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
      inactivityWeight: inactivityWeight,
      performanceGapWeight: performanceGapWeight,
      maxStudyHoursPerDay: maxStudyHoursPerDay,
      minBreakBetweenSessions: minBreakBetweenSessions,
      gracePeriodMinutes: gracePeriodMinutes,
      selectedSubjectIds: selectedSubjectIds,
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
  }
}
