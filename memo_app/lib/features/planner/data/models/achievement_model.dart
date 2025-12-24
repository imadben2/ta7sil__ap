import '../../domain/entities/achievement.dart';

/// Achievement Model for JSON serialization
class AchievementModel extends Achievement {
  const AchievementModel({
    required super.id,
    required super.title,
    required super.titleAr,
    required super.description,
    required super.descriptionAr,
    required super.icon,
    required super.unlocked,
    required super.progress,
    super.currentValue,
    super.requiredValue,
    super.unlockedAt,
    super.category,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      titleAr: json['title_ar'] as String,
      description: json['description'] as String,
      descriptionAr: json['description_ar'] as String,
      icon: json['icon'] as String,
      unlocked: json['unlocked'] as bool,
      progress: (json['progress'] as num).toDouble(),
      currentValue: json['current_value'] as int?,
      requiredValue: json['required_value'] as int?,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'] as String)
          : null,
      category: _categoryFromString(json['category'] as String?),
    );
  }

  factory AchievementModel.fromEntity(Achievement entity) {
    return AchievementModel(
      id: entity.id,
      title: entity.title,
      titleAr: entity.titleAr,
      description: entity.description,
      descriptionAr: entity.descriptionAr,
      icon: entity.icon,
      unlocked: entity.unlocked,
      progress: entity.progress,
      currentValue: entity.currentValue,
      requiredValue: entity.requiredValue,
      unlockedAt: entity.unlockedAt,
      category: entity.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_ar': titleAr,
      'description': description,
      'description_ar': descriptionAr,
      'icon': icon,
      'unlocked': unlocked,
      'progress': progress,
      if (currentValue != null) 'current_value': currentValue,
      if (requiredValue != null) 'required_value': requiredValue,
      if (unlockedAt != null) 'unlocked_at': unlockedAt!.toIso8601String(),
      'category': _categoryToString(category),
    };
  }

  Achievement toEntity() => this;

  static AchievementCategory _categoryFromString(String? category) {
    switch (category) {
      case 'streak':
        return AchievementCategory.streak;
      case 'sessions':
        return AchievementCategory.sessions;
      case 'mastery':
        return AchievementCategory.mastery;
      case 'special':
        return AchievementCategory.special;
      default:
        return AchievementCategory.general;
    }
  }

  static String _categoryToString(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.streak:
        return 'streak';
      case AchievementCategory.sessions:
        return 'sessions';
      case AchievementCategory.mastery:
        return 'mastery';
      case AchievementCategory.special:
        return 'special';
      case AchievementCategory.general:
        return 'general';
    }
  }
}

/// Achievement Stats Model for JSON serialization
class AchievementStatsModel extends AchievementStats {
  const AchievementStatsModel({
    required super.totalSessions,
    required super.totalStudyHours,
    required super.currentStreak,
    required super.longestStreak,
    required super.perfectSessions,
  });

  factory AchievementStatsModel.fromJson(Map<String, dynamic> json) {
    return AchievementStatsModel(
      totalSessions: json['total_sessions'] as int,
      totalStudyHours: (json['total_study_hours'] as num).toDouble(),
      currentStreak: json['current_streak'] as int,
      longestStreak: json['longest_streak'] as int,
      perfectSessions: json['perfect_sessions'] as int,
    );
  }

  factory AchievementStatsModel.fromEntity(AchievementStats entity) {
    return AchievementStatsModel(
      totalSessions: entity.totalSessions,
      totalStudyHours: entity.totalStudyHours,
      currentStreak: entity.currentStreak,
      longestStreak: entity.longestStreak,
      perfectSessions: entity.perfectSessions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sessions': totalSessions,
      'total_study_hours': totalStudyHours,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'perfect_sessions': perfectSessions,
    };
  }

  AchievementStats toEntity() => this;
}

/// Achievements Response Model for JSON serialization
class AchievementsResponseModel extends AchievementsResponse {
  const AchievementsResponseModel({
    required super.achievements,
    required super.stats,
    required super.unlockedCount,
    required super.totalCount,
  });

  factory AchievementsResponseModel.fromJson(Map<String, dynamic> json) {
    return AchievementsResponseModel(
      achievements: (json['achievements'] as List<dynamic>)
          .map((item) => AchievementModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      stats: AchievementStatsModel.fromJson(json['stats'] as Map<String, dynamic>),
      unlockedCount: json['unlocked_count'] as int,
      totalCount: json['total_count'] as int,
    );
  }

  factory AchievementsResponseModel.fromEntity(AchievementsResponse entity) {
    return AchievementsResponseModel(
      achievements: entity.achievements,
      stats: entity.stats,
      unlockedCount: entity.unlockedCount,
      totalCount: entity.totalCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achievements': achievements
          .map((a) => AchievementModel.fromEntity(a).toJson())
          .toList(),
      'stats': AchievementStatsModel.fromEntity(stats).toJson(),
      'unlocked_count': unlockedCount,
      'total_count': totalCount,
    };
  }

  AchievementsResponse toEntity() => this;
}
