import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/statistics_entity.dart';

part 'statistics_model.g.dart';

/// نموذج الإحصائيات للتعامل مع API
@JsonSerializable()
class StatisticsModel {
  @JsonKey(name: 'current_streak')
  final int currentStreak;
  @JsonKey(name: 'longest_streak')
  final int longestStreak;
  @JsonKey(name: 'total_points')
  final int totalPoints;
  @JsonKey(name: 'completed_sessions')
  final int completedSessions;
  @JsonKey(name: 'total_study_hours')
  final double totalStudyHours;
  @JsonKey(name: 'average_quiz_score')
  final double? averageQuizScore;
  @JsonKey(name: 'unlocked_badges')
  final int unlockedBadges;
  @JsonKey(name: 'total_badges')
  final int totalBadges;
  @JsonKey(name: 'weekly_hours')
  final List<WeeklyDataPointModel> weeklyHours;
  @JsonKey(name: 'subject_breakdown')
  final List<SubjectBreakdownModel> subjectBreakdown;
  final List<AchievementModel> achievements;
  @JsonKey(name: 'streak_calendar')
  final StreakCalendarModel streakCalendar;

  StatisticsModel({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalPoints,
    required this.completedSessions,
    required this.totalStudyHours,
    this.averageQuizScore,
    required this.unlockedBadges,
    required this.totalBadges,
    required this.weeklyHours,
    required this.subjectBreakdown,
    required this.achievements,
    required this.streakCalendar,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) =>
      _$StatisticsModelFromJson(json);

  Map<String, dynamic> toJson() => _$StatisticsModelToJson(this);

  StatisticsEntity toEntity() {
    return StatisticsEntity(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalPoints: totalPoints,
      completedSessions: completedSessions,
      totalStudyHours: totalStudyHours,
      averageQuizScore: averageQuizScore,
      unlockedBadges: unlockedBadges,
      totalBadges: totalBadges,
      weeklyHours: weeklyHours.map((e) => e.toEntity()).toList(),
      subjectBreakdown: subjectBreakdown.map((e) => e.toEntity()).toList(),
      achievements: achievements.map((e) => e.toEntity()).toList(),
      streakCalendar: streakCalendar.toEntity(),
    );
  }
}

@JsonSerializable()
class WeeklyDataPointModel {
  final String date;
  final double hours;
  final int sessions;

  WeeklyDataPointModel({
    required this.date,
    required this.hours,
    required this.sessions,
  });

  factory WeeklyDataPointModel.fromJson(Map<String, dynamic> json) =>
      _$WeeklyDataPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeeklyDataPointModelToJson(this);

  WeeklyDataPoint toEntity() {
    return WeeklyDataPoint(
      date: DateTime.parse(date),
      hours: hours,
      sessions: sessions,
    );
  }
}

@JsonSerializable()
class SubjectBreakdownModel {
  @JsonKey(name: 'subject_id')
  final int subjectId;
  @JsonKey(name: 'subject_name')
  final String subjectName;
  @JsonKey(name: 'subject_name_ar')
  final String subjectNameAr;
  final String color;
  final double hours;
  final int sessions;
  final double percentage;

  SubjectBreakdownModel({
    required this.subjectId,
    required this.subjectName,
    required this.subjectNameAr,
    required this.color,
    required this.hours,
    required this.sessions,
    required this.percentage,
  });

  factory SubjectBreakdownModel.fromJson(Map<String, dynamic> json) =>
      _$SubjectBreakdownModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectBreakdownModelToJson(this);

  SubjectBreakdown toEntity() {
    return SubjectBreakdown(
      subjectId: subjectId,
      subjectName: subjectName,
      subjectNameAr: subjectNameAr,
      color: color,
      hours: hours,
      sessions: sessions,
      percentage: percentage,
    );
  }
}

@JsonSerializable()
class AchievementModel {
  final int id;
  final String title;
  @JsonKey(name: 'title_ar')
  final String titleAr;
  final String description;
  @JsonKey(name: 'description_ar')
  final String descriptionAr;
  final String icon;
  @JsonKey(name: 'is_unlocked')
  final bool isUnlocked;
  @JsonKey(name: 'unlocked_at')
  final String? unlockedAt;
  final int points;

  AchievementModel({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    required this.icon,
    required this.isUnlocked,
    this.unlockedAt,
    required this.points,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      _$AchievementModelFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementModelToJson(this);

  Achievement toEntity() {
    return Achievement(
      id: id,
      title: title,
      titleAr: titleAr,
      description: description,
      descriptionAr: descriptionAr,
      icon: icon,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt != null ? DateTime.parse(unlockedAt!) : null,
      points: points,
    );
  }
}

@JsonSerializable()
class StreakCalendarModel {
  final int month;
  final int year;
  @JsonKey(name: 'active_days')
  final List<int> activeDays;
  @JsonKey(name: 'active_days_count')
  final int activeDaysCount;

  StreakCalendarModel({
    required this.month,
    required this.year,
    required this.activeDays,
    required this.activeDaysCount,
  });

  factory StreakCalendarModel.fromJson(Map<String, dynamic> json) =>
      _$StreakCalendarModelFromJson(json);

  Map<String, dynamic> toJson() => _$StreakCalendarModelToJson(this);

  StreakCalendar toEntity() {
    return StreakCalendar(
      month: month,
      year: year,
      activeDays: activeDays,
      activeDaysCount: activeDaysCount,
    );
  }
}
