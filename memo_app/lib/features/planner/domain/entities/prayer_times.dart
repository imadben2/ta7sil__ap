import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Domain entity representing Islamic prayer times for a specific date
class PrayerTimes extends Equatable {
  final DateTime date;
  final String city;

  final TimeOfDay fajr;
  final TimeOfDay sunrise; // Not a prayer, but useful
  final TimeOfDay dhuhr;
  final TimeOfDay asr;
  final TimeOfDay maghrib;
  final TimeOfDay isha;

  const PrayerTimes({
    required this.date,
    required this.city,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  @override
  List<Object?> get props => [date, city];

  // Get all prayer times as list
  List<Prayer> get allPrayers => [
    Prayer(name: 'الفجر', time: fajr, type: PrayerType.fajr),
    Prayer(name: 'الظهر', time: dhuhr, type: PrayerType.dhuhr),
    Prayer(name: 'العصر', time: asr, type: PrayerType.asr),
    Prayer(name: 'المغرب', time: maghrib, type: PrayerType.maghrib),
    Prayer(name: 'العشاء', time: isha, type: PrayerType.isha),
  ];

  // Get next prayer from current time
  Prayer? getNextPrayer() {
    final now = TimeOfDay.now();
    for (var prayer in allPrayers) {
      if (_isAfter(prayer.time, now)) {
        return prayer;
      }
    }
    return null; // After Isha, next is Fajr tomorrow
  }

  bool _isAfter(TimeOfDay a, TimeOfDay b) {
    if (a.hour > b.hour) return true;
    if (a.hour == b.hour && a.minute > b.minute) return true;
    return false;
  }
}

class Prayer extends Equatable {
  final String name;
  final TimeOfDay time;
  final PrayerType type;

  const Prayer({required this.name, required this.time, required this.type});

  @override
  List<Object?> get props => [name, time, type];
}

enum PrayerType { fajr, dhuhr, asr, maghrib, isha }
