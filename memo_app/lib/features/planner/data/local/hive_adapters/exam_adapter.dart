import 'package:hive/hive.dart';
import '../../../domain/entities/exam.dart';

/// Hive type adapter for Exam entity
/// Type ID: 14
class ExamAdapter extends TypeAdapter<Exam> {
  @override
  final int typeId = 14;

  @override
  Exam read(BinaryReader reader) {
    return Exam(
      id: reader.readString(),
      userId: reader.readString(),
      subjectId: reader.readString(),
      subjectName: reader.readString(),
      examType: ExamType.values[reader.readInt()],
      examDate: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      durationMinutes: reader.readInt(),
      importanceLevel: ImportanceLevel.values[reader.readInt()],
      preparationDaysBefore: reader.readInt(),
      targetScore: reader.read() as double?,
      actualScore: reader.read() as double?,
      chaptersCovered: (reader.read() as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Exam obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.userId);
    writer.writeString(obj.subjectId);
    writer.writeString(obj.subjectName);
    writer.writeInt(obj.examType.index);
    writer.writeInt(obj.examDate.millisecondsSinceEpoch);
    writer.writeInt(obj.durationMinutes);
    writer.writeInt(obj.importanceLevel.index);
    writer.writeInt(obj.preparationDaysBefore);
    writer.write(obj.targetScore);
    writer.write(obj.actualScore);
    writer.write(obj.chaptersCovered);
  }
}
