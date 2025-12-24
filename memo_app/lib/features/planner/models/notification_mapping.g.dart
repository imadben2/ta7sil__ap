// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_mapping.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationMappingAdapter extends TypeAdapter<NotificationMapping> {
  @override
  final int typeId = 17;

  @override
  NotificationMapping read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationMapping(
      sessionId: fields[0] as String,
      notificationId: fields[1] as int,
      scheduledFor: fields[2] as DateTime,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationMapping obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.sessionId)
      ..writeByte(1)
      ..write(obj.notificationId)
      ..writeByte(2)
      ..write(obj.scheduledFor)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationMappingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
