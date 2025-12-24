import 'package:hive/hive.dart';
import '../../../domain/entities/subject.dart';

/// Hive type adapter for Subject entity
/// Type ID: 13
///
/// Version History:
/// - v1: Original fields (12 fields without lastYearAverage)
/// - v2: Added lastYearAverage field (معدل السنة الماضية) - 13 fields total
class SubjectAdapter extends TypeAdapter<Subject> {
  @override
  final int typeId = 13;

  @override
  Subject read(BinaryReader reader) {
    // Read lastStudiedAt first (as in original format)
    final lastStudiedMs = reader.read() as int?;

    final id = reader.readString();
    final name = reader.readString();
    final nameAr = reader.readString();
    final coefficient = reader.readInt();
    final difficultyLevel = reader.readInt();
    final colorHex = reader.readString();
    final iconName = reader.readString();
    final progressPercentage = reader.readDouble();
    final totalChapters = reader.readInt();
    final completedChapters = reader.readInt();
    final averageScore = reader.readDouble();

    // Try to read lastYearAverage (new field) - handle both old and new format
    double? lastYearAverage;
    try {
      // Check if there's more data available
      lastYearAverage = reader.read() as double?;
    } catch (_) {
      // Old format without lastYearAverage - just ignore
      lastYearAverage = null;
    }

    return Subject(
      id: id,
      name: name,
      nameAr: nameAr,
      coefficient: coefficient,
      difficultyLevel: difficultyLevel,
      colorHex: colorHex,
      iconName: iconName,
      progressPercentage: progressPercentage,
      lastStudiedAt: lastStudiedMs != null
          ? DateTime.fromMillisecondsSinceEpoch(lastStudiedMs)
          : null,
      totalChapters: totalChapters,
      completedChapters: completedChapters,
      averageScore: averageScore,
      lastYearAverage: lastYearAverage,
    );
  }

  @override
  void write(BinaryWriter writer, Subject obj) {
    // Keep same write order for backward compatibility
    writer.write(obj.lastStudiedAt?.millisecondsSinceEpoch);
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.nameAr);
    writer.writeInt(obj.coefficient);
    writer.writeInt(obj.difficultyLevel);
    writer.writeString(obj.colorHex);
    writer.writeString(obj.iconName);
    writer.writeDouble(obj.progressPercentage);
    writer.writeInt(obj.totalChapters);
    writer.writeInt(obj.completedChapters);
    writer.writeDouble(obj.averageScore);
    // New field - append at end for backward compatibility
    writer.write(obj.lastYearAverage);
  }
}
