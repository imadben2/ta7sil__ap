import 'package:hive/hive.dart';
import '../../../domain/entities/centralized_subject.dart';

/// Hive type adapter for CentralizedSubject entity
class CentralizedSubjectAdapter extends TypeAdapter<CentralizedSubject> {
  @override
  final int typeId = 16;

  @override
  CentralizedSubject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return CentralizedSubject(
      id: fields[0] as int,
      nameAr: fields[1] as String,
      slug: fields[2] as String,
      coefficient: fields[3] as double,
      descriptionAr: fields[4] as String?,
      color: fields[5] as String?,
      icon: fields[6] as String?,
      academicStreamIds: (fields[7] as List<dynamic>?)?.cast<int>(),
      academicYearId: fields[8] as int?,
      isActive: fields[9] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, CentralizedSubject obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nameAr)
      ..writeByte(2)
      ..write(obj.slug)
      ..writeByte(3)
      ..write(obj.coefficient)
      ..writeByte(4)
      ..write(obj.descriptionAr)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.icon)
      ..writeByte(7)
      ..write(obj.academicStreamIds)
      ..writeByte(8)
      ..write(obj.academicYearId)
      ..writeByte(9)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CentralizedSubjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
