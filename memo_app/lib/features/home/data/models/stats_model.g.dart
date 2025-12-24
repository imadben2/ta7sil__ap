// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatsModel _$StatsModelFromJson(Map<String, dynamic> json) => StatsModel(
      streak: (json['streak'] as num).toInt(),
      totalPoints: (json['total_points'] as num).toInt(),
      level: (json['level'] as num).toInt(),
      pointsToNextLevel: (json['points_to_next_level'] as num).toInt(),
      studyTimeToday: (json['study_time_today'] as num).toInt(),
      dailyGoal: (json['daily_goal'] as num).toInt(),
    );

Map<String, dynamic> _$StatsModelToJson(StatsModel instance) =>
    <String, dynamic>{
      'streak': instance.streak,
      'total_points': instance.totalPoints,
      'level': instance.level,
      'points_to_next_level': instance.pointsToNextLevel,
      'study_time_today': instance.studyTimeToday,
      'daily_goal': instance.dailyGoal,
    };
