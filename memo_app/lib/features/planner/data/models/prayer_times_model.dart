import 'package:flutter/material.dart';
import '../../domain/entities/prayer_times.dart';

/// Data model for PrayerTimes with JSON serialization
class PrayerTimesModel {
  final String date; // "2025-11-10"
  final String city;
  final String fajrTime; // "05:30"
  final String sunriseTime; // "06:45"
  final String dhuhrTime; // "12:45"
  final String asrTime; // "15:30"
  final String maghribTime; // "18:00"
  final String ishaTime; // "19:30"

  PrayerTimesModel({
    required this.date,
    required this.city,
    required this.fajrTime,
    required this.sunriseTime,
    required this.dhuhrTime,
    required this.asrTime,
    required this.maghribTime,
    required this.ishaTime,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    return PrayerTimesModel(
      date: json['date'] as String,
      city: json['city'] as String,
      fajrTime: json['fajr_time'] as String,
      sunriseTime: json['sunrise_time'] as String,
      dhuhrTime: json['dhuhr_time'] as String,
      asrTime: json['asr_time'] as String,
      maghribTime: json['maghrib_time'] as String,
      ishaTime: json['isha_time'] as String,
    );
  }

  /// Parse from Aladhan API response format
  factory PrayerTimesModel.fromAladhanJson(Map<String, dynamic> json) {
    final timings = json['timings'] as Map<String, dynamic>;
    final date = json['date'] as Map<String, dynamic>;
    final readable = date['readable'] as String;

    return PrayerTimesModel(
      date: readable,
      city: json['meta']?['timezone'] as String? ?? 'Algiers',
      fajrTime: _extractTime(timings['Fajr'] as String),
      sunriseTime: _extractTime(timings['Sunrise'] as String),
      dhuhrTime: _extractTime(timings['Dhuhr'] as String),
      asrTime: _extractTime(timings['Asr'] as String),
      maghribTime: _extractTime(timings['Maghrib'] as String),
      ishaTime: _extractTime(timings['Isha'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'city': city,
      'fajr_time': fajrTime,
      'sunrise_time': sunriseTime,
      'dhuhr_time': dhuhrTime,
      'asr_time': asrTime,
      'maghrib_time': maghribTime,
      'isha_time': ishaTime,
    };
  }

  PrayerTimes toEntity() {
    return PrayerTimes(
      date: DateTime.parse(date),
      city: city,
      fajr: _parseTimeOfDay(fajrTime),
      sunrise: _parseTimeOfDay(sunriseTime),
      dhuhr: _parseTimeOfDay(dhuhrTime),
      asr: _parseTimeOfDay(asrTime),
      maghrib: _parseTimeOfDay(maghribTime),
      isha: _parseTimeOfDay(ishaTime),
    );
  }

  factory PrayerTimesModel.fromEntity(PrayerTimes entity) {
    return PrayerTimesModel(
      date: entity.date.toIso8601String().split('T')[0],
      city: entity.city,
      fajrTime: _formatTimeOfDay(entity.fajr),
      sunriseTime: _formatTimeOfDay(entity.sunrise),
      dhuhrTime: _formatTimeOfDay(entity.dhuhr),
      asrTime: _formatTimeOfDay(entity.asr),
      maghribTime: _formatTimeOfDay(entity.maghrib),
      ishaTime: _formatTimeOfDay(entity.isha),
    );
  }

  static TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Extract time from Aladhan API format (e.g., "05:30 (CEST)" -> "05:30")
  static String _extractTime(String aladhanTime) {
    return aladhanTime.split(' ')[0];
  }
}
