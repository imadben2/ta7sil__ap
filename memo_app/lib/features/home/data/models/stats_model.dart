import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/stats_entity.dart';

part 'stats_model.g.dart';

@JsonSerializable()
class StatsModel {
  final int streak;
  @JsonKey(name: 'total_points')
  final int totalPoints;
  final int level;
  @JsonKey(name: 'points_to_next_level')
  final int pointsToNextLevel;
  @JsonKey(name: 'study_time_today')
  final int studyTimeToday;
  @JsonKey(name: 'daily_goal')
  final int dailyGoal;

  const StatsModel({
    required this.streak,
    required this.totalPoints,
    required this.level,
    required this.pointsToNextLevel,
    required this.studyTimeToday,
    required this.dailyGoal,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) =>
      _$StatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$StatsModelToJson(this);

  StatsEntity toEntity() {
    return StatsEntity(
      streak: streak,
      totalPoints: totalPoints,
      level: level,
      pointsToNextLevel: pointsToNextLevel,
      studyTimeToday: studyTimeToday,
      dailyGoal: dailyGoal,
    );
  }
}
