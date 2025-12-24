import '../../domain/entities/planner_analytics.dart';

/// Planner Analytics Model for JSON serialization
class PlannerAnalyticsModel extends PlannerAnalytics {
  const PlannerAnalyticsModel({
    required super.period,
    required super.startDate,
    required super.endDate,
    required super.totalHours,
    required super.sessionsCompleted,
    required super.sessionsMissed,
    required super.sessionsSkipped,
    required super.completionRate,
    required super.averageSessionDuration,
    required super.currentStreak,
    required super.longestStreak,
    required super.totalPoints,
    required super.currentLevel,
    required super.subjectTimeBreakdown,
    required super.subjectSessionCount,
    required super.weeklyProductivityHours,
    required super.dailyStudyTrend,
    super.patterns,
    super.recommendations,
  });

  factory PlannerAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return PlannerAnalyticsModel(
      period: json['period'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      totalHours: (json['total_hours'] as num).toDouble(),
      sessionsCompleted: json['sessions_completed'] as int,
      sessionsMissed: json['sessions_missed'] as int,
      sessionsSkipped: json['sessions_skipped'] as int? ?? 0,
      completionRate: (json['completion_rate'] as num).toDouble(),
      averageSessionDuration: json['average_session_duration'] as int,
      currentStreak: json['current_streak'] as int,
      longestStreak: json['longest_streak'] as int,
      totalPoints: json['total_points'] as int? ?? 0,
      currentLevel: json['current_level'] as int? ?? 1,
      subjectTimeBreakdown:
          (json['subject_time_breakdown'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          ) ??
          {},
      subjectSessionCount:
          (json['subject_session_count'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
      weeklyProductivityHours:
          (json['weekly_productivity_hours'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(int.parse(key), (value as num).toDouble()),
          ) ??
          {},
      dailyStudyTrend:
          (json['daily_study_trend'] as List<dynamic>?)
              ?.map(
                (item) =>
                    DailyStudyDataModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      patterns: json['patterns'] != null
          ? ProductivityPatternsModel.fromJson(
              json['patterns'] as Map<String, dynamic>,
            )
          : null,
      recommendations:
          (json['recommendations'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_hours': totalHours,
      'sessions_completed': sessionsCompleted,
      'sessions_missed': sessionsMissed,
      'sessions_skipped': sessionsSkipped,
      'completion_rate': completionRate,
      'average_session_duration': averageSessionDuration,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_points': totalPoints,
      'current_level': currentLevel,
      'subject_time_breakdown': subjectTimeBreakdown,
      'subject_session_count': subjectSessionCount,
      'weekly_productivity_hours': weeklyProductivityHours.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'daily_study_trend': dailyStudyTrend
          .map((data) => DailyStudyDataModel.fromEntity(data).toJson())
          .toList(),
      if (patterns != null)
        'patterns': ProductivityPatternsModel.fromEntity(patterns!).toJson(),
      'recommendations': recommendations,
    };
  }

  PlannerAnalytics toEntity() => this;
}

/// Daily Study Data Model
class DailyStudyDataModel extends DailyStudyData {
  const DailyStudyDataModel({
    required super.date,
    required super.hours,
    required super.sessionCount,
  });

  factory DailyStudyDataModel.fromJson(Map<String, dynamic> json) {
    return DailyStudyDataModel(
      date: DateTime.parse(json['date'] as String),
      hours: (json['hours'] as num).toDouble(),
      sessionCount: json['session_count'] as int,
    );
  }

  factory DailyStudyDataModel.fromEntity(DailyStudyData entity) {
    return DailyStudyDataModel(
      date: entity.date,
      hours: entity.hours,
      sessionCount: entity.sessionCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'hours': hours,
      'session_count': sessionCount,
    };
  }
}

/// Productivity Patterns Model
class ProductivityPatternsModel extends ProductivityPatterns {
  const ProductivityPatternsModel({
    required super.bestTimeOfDay,
    required super.bestDayOfWeek,
    required super.optimalSessionDuration,
    required super.productivityScore,
    required super.peakStudyHour,
  });

  factory ProductivityPatternsModel.fromJson(Map<String, dynamic> json) {
    return ProductivityPatternsModel(
      bestTimeOfDay: json['best_time_of_day'] as String,
      bestDayOfWeek: json['best_day_of_week'] as String,
      optimalSessionDuration: json['optimal_session_duration'] as int,
      productivityScore: (json['productivity_score'] as num).toDouble(),
      peakStudyHour: json['peak_study_hour'] as int,
    );
  }

  factory ProductivityPatternsModel.fromEntity(ProductivityPatterns entity) {
    return ProductivityPatternsModel(
      bestTimeOfDay: entity.bestTimeOfDay,
      bestDayOfWeek: entity.bestDayOfWeek,
      optimalSessionDuration: entity.optimalSessionDuration,
      productivityScore: entity.productivityScore,
      peakStudyHour: entity.peakStudyHour,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'best_time_of_day': bestTimeOfDay,
      'best_day_of_week': bestDayOfWeek,
      'optimal_session_duration': optimalSessionDuration,
      'productivity_score': productivityScore,
      'peak_study_hour': peakStudyHour,
    };
  }
}
