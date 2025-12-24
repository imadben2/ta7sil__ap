import 'package:equatable/equatable.dart';

/// Achievement Entity for the planner gamification system
class Achievement extends Equatable {
  /// Unique identifier for the achievement
  final String id;

  /// Achievement title in English
  final String title;

  /// Achievement title in Arabic
  final String titleAr;

  /// Achievement description in English
  final String description;

  /// Achievement description in Arabic
  final String descriptionAr;

  /// Icon name (Material icon name)
  final String icon;

  /// Whether the achievement is unlocked
  final bool unlocked;

  /// Progress percentage (0-100)
  final double progress;

  /// Current value towards the achievement
  final int? currentValue;

  /// Required value to unlock the achievement
  final int? requiredValue;

  /// Date when the achievement was unlocked
  final DateTime? unlockedAt;

  /// Category of the achievement
  final AchievementCategory category;

  const Achievement({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    required this.icon,
    required this.unlocked,
    required this.progress,
    this.currentValue,
    this.requiredValue,
    this.unlockedAt,
    this.category = AchievementCategory.general,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    titleAr,
    description,
    descriptionAr,
    icon,
    unlocked,
    progress,
    currentValue,
    requiredValue,
    unlockedAt,
    category,
  ];

  /// Get localized title based on locale
  String getLocalizedTitle(String locale) {
    return locale.startsWith('ar') ? titleAr : title;
  }

  /// Get localized description based on locale
  String getLocalizedDescription(String locale) {
    return locale.startsWith('ar') ? descriptionAr : description;
  }
}

/// Achievement statistics from the API
class AchievementStats extends Equatable {
  /// Total number of completed sessions
  final int totalSessions;

  /// Total study hours
  final double totalStudyHours;

  /// Current study streak (consecutive days)
  final int currentStreak;

  /// Longest study streak ever achieved
  final int longestStreak;

  /// Number of perfect sessions (100% completion)
  final int perfectSessions;

  const AchievementStats({
    required this.totalSessions,
    required this.totalStudyHours,
    required this.currentStreak,
    required this.longestStreak,
    required this.perfectSessions,
  });

  @override
  List<Object?> get props => [
    totalSessions,
    totalStudyHours,
    currentStreak,
    longestStreak,
    perfectSessions,
  ];
}

/// Achievement response containing achievements and stats
class AchievementsResponse extends Equatable {
  /// List of all achievements
  final List<Achievement> achievements;

  /// User's achievement statistics
  final AchievementStats stats;

  /// Number of unlocked achievements
  final int unlockedCount;

  /// Total number of achievements
  final int totalCount;

  const AchievementsResponse({
    required this.achievements,
    required this.stats,
    required this.unlockedCount,
    required this.totalCount,
  });

  /// Get completion percentage
  double get completionPercentage =>
      totalCount > 0 ? (unlockedCount / totalCount) * 100 : 0;

  @override
  List<Object?> get props => [
    achievements,
    stats,
    unlockedCount,
    totalCount,
  ];
}

/// Categories for achievements
enum AchievementCategory {
  general,
  streak,
  sessions,
  mastery,
  special,
}
