import '../../domain/entities/points_history.dart';

/// Points History Model for JSON serialization
class PointsHistoryModel extends PointsHistory {
  const PointsHistoryModel({
    required super.dailyPoints,
    required super.totalPoints,
    required super.periodDays,
  });

  factory PointsHistoryModel.fromJson(Map<String, dynamic> json) {
    return PointsHistoryModel(
      dailyPoints: (json['points_history'] as List<dynamic>)
          .map((item) => DailyPointsModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPoints: json['total_points'] as int? ?? 0,
      periodDays: json['period_days'] as int? ?? 30,
    );
  }

  factory PointsHistoryModel.fromEntity(PointsHistory entity) {
    return PointsHistoryModel(
      dailyPoints: entity.dailyPoints,
      totalPoints: entity.totalPoints,
      periodDays: entity.periodDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'points_history': dailyPoints
          .map((dp) => DailyPointsModel.fromEntity(dp).toJson())
          .toList(),
      'total_points': totalPoints,
      'period_days': periodDays,
    };
  }

  PointsHistory toEntity() => this;
}

/// Daily Points Model for JSON serialization
class DailyPointsModel extends DailyPoints {
  const DailyPointsModel({
    required super.date,
    required super.totalPoints,
    required super.sessionsCount,
  });

  factory DailyPointsModel.fromJson(Map<String, dynamic> json) {
    return DailyPointsModel(
      date: DateTime.parse(json['date'] as String),
      totalPoints: json['total_points'] as int? ?? 0,
      sessionsCount: json['sessions_count'] as int? ?? 0,
    );
  }

  factory DailyPointsModel.fromEntity(DailyPoints entity) {
    return DailyPointsModel(
      date: entity.date,
      totalPoints: entity.totalPoints,
      sessionsCount: entity.sessionsCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'total_points': totalPoints,
      'sessions_count': sessionsCount,
    };
  }

  DailyPoints toEntity() => this;
}

/// Points Transaction Model for JSON serialization
class PointsTransactionModel extends PointsTransaction {
  const PointsTransactionModel({
    required super.id,
    required super.points,
    required super.type,
    required super.description,
    required super.createdAt,
    super.sessionId,
  });

  factory PointsTransactionModel.fromJson(Map<String, dynamic> json) {
    return PointsTransactionModel(
      id: json['id'] as String,
      points: json['points'] as int,
      type: _typeFromString(json['type'] as String),
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      sessionId: json['session_id'] as String?,
    );
  }

  factory PointsTransactionModel.fromEntity(PointsTransaction entity) {
    return PointsTransactionModel(
      id: entity.id,
      points: entity.points,
      type: entity.type,
      description: entity.description,
      createdAt: entity.createdAt,
      sessionId: entity.sessionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points': points,
      'type': _typeToString(type),
      'description': description,
      'created_at': createdAt.toIso8601String(),
      if (sessionId != null) 'session_id': sessionId,
    };
  }

  PointsTransaction toEntity() => this;

  static PointsTransactionType _typeFromString(String type) {
    switch (type) {
      case 'session_completed':
        return PointsTransactionType.sessionCompleted;
      case 'session_skipped':
        return PointsTransactionType.sessionSkipped;
      case 'perfect_session':
        return PointsTransactionType.perfectSession;
      case 'streak_bonus':
        return PointsTransactionType.streakBonus;
      case 'achievement_unlocked':
        return PointsTransactionType.achievementUnlocked;
      case 'daily_bonus':
        return PointsTransactionType.dailyBonus;
      case 'exam_bonus':
        return PointsTransactionType.examBonus;
      default:
        return PointsTransactionType.sessionCompleted;
    }
  }

  static String _typeToString(PointsTransactionType type) {
    switch (type) {
      case PointsTransactionType.sessionCompleted:
        return 'session_completed';
      case PointsTransactionType.sessionSkipped:
        return 'session_skipped';
      case PointsTransactionType.perfectSession:
        return 'perfect_session';
      case PointsTransactionType.streakBonus:
        return 'streak_bonus';
      case PointsTransactionType.achievementUnlocked:
        return 'achievement_unlocked';
      case PointsTransactionType.dailyBonus:
        return 'daily_bonus';
      case PointsTransactionType.examBonus:
        return 'exam_bonus';
    }
  }
}
