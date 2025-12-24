// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatisticsModel _$StatisticsModelFromJson(Map<String, dynamic> json) =>
    StatisticsModel(
      currentStreak: (json['current_streak'] as num).toInt(),
      longestStreak: (json['longest_streak'] as num).toInt(),
      totalPoints: (json['total_points'] as num).toInt(),
      completedSessions: (json['completed_sessions'] as num).toInt(),
      totalStudyHours: (json['total_study_hours'] as num).toDouble(),
      averageQuizScore: (json['average_quiz_score'] as num?)?.toDouble(),
      unlockedBadges: (json['unlocked_badges'] as num).toInt(),
      totalBadges: (json['total_badges'] as num).toInt(),
      weeklyHours: (json['weekly_hours'] as List<dynamic>)
          .map((e) => WeeklyDataPointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subjectBreakdown: (json['subject_breakdown'] as List<dynamic>)
          .map((e) => SubjectBreakdownModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      achievements: (json['achievements'] as List<dynamic>)
          .map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      streakCalendar: StreakCalendarModel.fromJson(
          json['streak_calendar'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StatisticsModelToJson(StatisticsModel instance) =>
    <String, dynamic>{
      'current_streak': instance.currentStreak,
      'longest_streak': instance.longestStreak,
      'total_points': instance.totalPoints,
      'completed_sessions': instance.completedSessions,
      'total_study_hours': instance.totalStudyHours,
      'average_quiz_score': instance.averageQuizScore,
      'unlocked_badges': instance.unlockedBadges,
      'total_badges': instance.totalBadges,
      'weekly_hours': instance.weeklyHours,
      'subject_breakdown': instance.subjectBreakdown,
      'achievements': instance.achievements,
      'streak_calendar': instance.streakCalendar,
    };

WeeklyDataPointModel _$WeeklyDataPointModelFromJson(
        Map<String, dynamic> json) =>
    WeeklyDataPointModel(
      date: json['date'] as String,
      hours: (json['hours'] as num).toDouble(),
      sessions: (json['sessions'] as num).toInt(),
    );

Map<String, dynamic> _$WeeklyDataPointModelToJson(
        WeeklyDataPointModel instance) =>
    <String, dynamic>{
      'date': instance.date,
      'hours': instance.hours,
      'sessions': instance.sessions,
    };

SubjectBreakdownModel _$SubjectBreakdownModelFromJson(
        Map<String, dynamic> json) =>
    SubjectBreakdownModel(
      subjectId: (json['subject_id'] as num).toInt(),
      subjectName: json['subject_name'] as String,
      subjectNameAr: json['subject_name_ar'] as String,
      color: json['color'] as String,
      hours: (json['hours'] as num).toDouble(),
      sessions: (json['sessions'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$SubjectBreakdownModelToJson(
        SubjectBreakdownModel instance) =>
    <String, dynamic>{
      'subject_id': instance.subjectId,
      'subject_name': instance.subjectName,
      'subject_name_ar': instance.subjectNameAr,
      'color': instance.color,
      'hours': instance.hours,
      'sessions': instance.sessions,
      'percentage': instance.percentage,
    };

AchievementModel _$AchievementModelFromJson(Map<String, dynamic> json) =>
    AchievementModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      titleAr: json['title_ar'] as String,
      description: json['description'] as String,
      descriptionAr: json['description_ar'] as String,
      icon: json['icon'] as String,
      isUnlocked: json['is_unlocked'] as bool,
      unlockedAt: json['unlocked_at'] as String?,
      points: (json['points'] as num).toInt(),
    );

Map<String, dynamic> _$AchievementModelToJson(AchievementModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'title_ar': instance.titleAr,
      'description': instance.description,
      'description_ar': instance.descriptionAr,
      'icon': instance.icon,
      'is_unlocked': instance.isUnlocked,
      'unlocked_at': instance.unlockedAt,
      'points': instance.points,
    };

StreakCalendarModel _$StreakCalendarModelFromJson(Map<String, dynamic> json) =>
    StreakCalendarModel(
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      activeDays: (json['active_days'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      activeDaysCount: (json['active_days_count'] as num).toInt(),
    );

Map<String, dynamic> _$StreakCalendarModelToJson(
        StreakCalendarModel instance) =>
    <String, dynamic>{
      'month': instance.month,
      'year': instance.year,
      'active_days': instance.activeDays,
      'active_days_count': instance.activeDaysCount,
    };
