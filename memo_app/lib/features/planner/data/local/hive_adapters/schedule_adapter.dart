import 'package:hive/hive.dart';
import '../../../domain/entities/schedule.dart';
import '../../../domain/entities/study_session.dart';

/// Hive type adapter for Schedule entity
/// Type ID: 15
class ScheduleAdapter extends TypeAdapter<Schedule> {
  @override
  final int typeId = 15;

  @override
  Schedule read(BinaryReader reader) {
    return Schedule(
      id: reader.readString(),
      userId: reader.readString(),
      startDate: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      endDate: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      sessions: (reader.read() as List).cast<StudySession>(),
      isActive: reader.readBool(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, Schedule obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.userId);
    writer.writeInt(obj.startDate.millisecondsSinceEpoch);
    writer.writeInt(obj.endDate.millisecondsSinceEpoch);
    writer.write(obj.sessions);
    writer.writeBool(obj.isActive);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
