import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/prayer_times.dart';

/// Hive type adapter for PrayerTimes entity
/// Type ID: 12
class PrayerTimesAdapter extends TypeAdapter<PrayerTimes> {
  @override
  final int typeId = 12;

  @override
  PrayerTimes read(BinaryReader reader) {
    return PrayerTimes(
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      city: reader.readString(),
      fajr: TimeOfDay(hour: reader.readInt(), minute: reader.readInt()),
      sunrise: TimeOfDay(hour: reader.readInt(), minute: reader.readInt()),
      dhuhr: TimeOfDay(hour: reader.readInt(), minute: reader.readInt()),
      asr: TimeOfDay(hour: reader.readInt(), minute: reader.readInt()),
      maghrib: TimeOfDay(hour: reader.readInt(), minute: reader.readInt()),
      isha: TimeOfDay(hour: reader.readInt(), minute: reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, PrayerTimes obj) {
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeString(obj.city);
    writer.writeInt(obj.fajr.hour);
    writer.writeInt(obj.fajr.minute);
    writer.writeInt(obj.sunrise.hour);
    writer.writeInt(obj.sunrise.minute);
    writer.writeInt(obj.dhuhr.hour);
    writer.writeInt(obj.dhuhr.minute);
    writer.writeInt(obj.asr.hour);
    writer.writeInt(obj.asr.minute);
    writer.writeInt(obj.maghrib.hour);
    writer.writeInt(obj.maghrib.minute);
    writer.writeInt(obj.isha.hour);
    writer.writeInt(obj.isha.minute);
  }
}
