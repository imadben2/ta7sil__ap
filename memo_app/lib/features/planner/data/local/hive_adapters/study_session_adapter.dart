import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/study_session.dart';

/// Hive type adapter for StudySession entity
/// Type ID: 10
///
/// NOTE: This adapter uses a versioned format. New fields are added at the end
/// with null-safe reads to maintain backward compatibility.
class StudySessionAdapter extends TypeAdapter<StudySession> {
  @override
  final int typeId = 10;

  @override
  StudySession read(BinaryReader reader) {
    final actualStartMs = reader.read() as int?;
    final actualEndMs = reader.read() as int?;
    final actualDurationMins = reader.read() as int?;

    final id = reader.readString();
    final userId = reader.readString();
    final subjectId = reader.readString();
    final subjectName = reader.readString();
    final chapterId = reader.read() as String?;
    final chapterName = reader.read() as String?;
    final scheduledDate = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final scheduledStartTime = TimeOfDay(
      hour: reader.readInt(),
      minute: reader.readInt(),
    );
    final scheduledEndTime = TimeOfDay(
      hour: reader.readInt(),
      minute: reader.readInt(),
    );
    final duration = Duration(minutes: reader.readInt());
    final suggestedContentId = reader.read() as String?;
    final suggestedContentType = () {
      final contentTypeValue = reader.read();
      if (contentTypeValue == null) return null;
      final contentTypeIndex = contentTypeValue as int;
      return ContentType.values[contentTypeIndex];
    }();
    final contentTitle = reader.read() as String?;
    final sessionType = SessionType.values[reader.readInt()];
    final requiredEnergyLevel = EnergyLevel.values[reader.readInt()];
    final priorityScore = reader.readInt();
    final isPinned = reader.readBool();
    final status = SessionStatus.values[reader.readInt()];
    final userNotes = reader.read() as String?;
    final skipReason = reader.read() as String?;
    final completionPercentage = reader.read() as int?;
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final updatedAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());

    // New fields added in v2 - read with null safety
    bool isBreak = false;
    bool isPrayerTime = false;
    int? subjectColorValue;
    int? estimatedEnergyLevelIndex;
    String? topicName;
    bool usePomodoroTechnique = true;
    int? pomodoroDurationMinutes;
    String? contentSuggestion;

    // Try to read new fields (they may not exist in old data)
    try {
      if (reader.availableBytes > 0) {
        isBreak = reader.readBool();
      }
      if (reader.availableBytes > 0) {
        isPrayerTime = reader.readBool();
      }
      if (reader.availableBytes > 0) {
        subjectColorValue = reader.read() as int?;
      }
      if (reader.availableBytes > 0) {
        estimatedEnergyLevelIndex = reader.read() as int?;
      }
      if (reader.availableBytes > 0) {
        topicName = reader.read() as String?;
      }
      if (reader.availableBytes > 0) {
        usePomodoroTechnique = reader.readBool();
      }
      if (reader.availableBytes > 0) {
        pomodoroDurationMinutes = reader.read() as int?;
      }
      if (reader.availableBytes > 0) {
        contentSuggestion = reader.read() as String?;
      }
    } catch (_) {
      // Old format - use defaults
    }

    return StudySession(
      id: id,
      userId: userId,
      subjectId: subjectId,
      subjectName: subjectName,
      chapterId: chapterId,
      chapterName: chapterName,
      scheduledDate: scheduledDate,
      scheduledStartTime: scheduledStartTime,
      scheduledEndTime: scheduledEndTime,
      duration: duration,
      suggestedContentId: suggestedContentId,
      suggestedContentType: suggestedContentType,
      contentTitle: contentTitle,
      contentSuggestion: contentSuggestion,
      topicName: topicName,
      sessionType: sessionType,
      requiredEnergyLevel: requiredEnergyLevel,
      estimatedEnergyLevel: estimatedEnergyLevelIndex != null
          ? EnergyLevel.values[estimatedEnergyLevelIndex]
          : null,
      priorityScore: priorityScore,
      isPinned: isPinned,
      isBreak: isBreak,
      isPrayerTime: isPrayerTime,
      subjectColor: subjectColorValue != null ? Color(subjectColorValue) : null,
      usePomodoroTechnique: usePomodoroTechnique,
      pomodoroDurationMinutes: pomodoroDurationMinutes,
      status: status,
      actualStartTime: actualStartMs != null
          ? DateTime.fromMillisecondsSinceEpoch(actualStartMs)
          : null,
      actualEndTime: actualEndMs != null
          ? DateTime.fromMillisecondsSinceEpoch(actualEndMs)
          : null,
      actualDuration: actualDurationMins != null
          ? Duration(minutes: actualDurationMins)
          : null,
      userNotes: userNotes,
      skipReason: skipReason,
      completionPercentage: completionPercentage,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  void write(BinaryWriter writer, StudySession obj) {
    // Original fields (must stay in same order for backward compatibility)
    writer.write(obj.actualStartTime?.millisecondsSinceEpoch);
    writer.write(obj.actualEndTime?.millisecondsSinceEpoch);
    writer.write(obj.actualDuration?.inMinutes);
    writer.writeString(obj.id);
    writer.writeString(obj.userId);
    writer.writeString(obj.subjectId);
    writer.writeString(obj.subjectName);
    writer.write(obj.chapterId);
    writer.write(obj.chapterName);
    writer.writeInt(obj.scheduledDate.millisecondsSinceEpoch);
    writer.writeInt(obj.scheduledStartTime.hour);
    writer.writeInt(obj.scheduledStartTime.minute);
    writer.writeInt(obj.scheduledEndTime.hour);
    writer.writeInt(obj.scheduledEndTime.minute);
    writer.writeInt(obj.duration.inMinutes);
    writer.write(obj.suggestedContentId);
    writer.write(obj.suggestedContentType?.index);
    writer.write(obj.contentTitle);
    writer.writeInt(obj.sessionType.index);
    writer.writeInt(obj.requiredEnergyLevel.index);
    writer.writeInt(obj.priorityScore);
    writer.writeBool(obj.isPinned);
    writer.writeInt(obj.status.index);
    writer.write(obj.userNotes);
    writer.write(obj.skipReason);
    writer.write(obj.completionPercentage);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.updatedAt.millisecondsSinceEpoch);

    // New fields added in v2 (appended at end for backward compatibility)
    writer.writeBool(obj.isBreak);
    writer.writeBool(obj.isPrayerTime);
    writer.write(obj.subjectColor?.value);
    writer.write(obj.estimatedEnergyLevel?.index);
    writer.write(obj.topicName);
    writer.writeBool(obj.usePomodoroTechnique);
    writer.write(obj.pomodoroDurationMinutes);
    writer.write(obj.contentSuggestion);
  }
}
