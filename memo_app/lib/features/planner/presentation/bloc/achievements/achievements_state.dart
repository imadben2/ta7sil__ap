import 'package:equatable/equatable.dart';
import '../../../domain/entities/achievement.dart';

abstract class AchievementsState extends Equatable {
  const AchievementsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class AchievementsInitial extends AchievementsState {
  const AchievementsInitial();
}

/// Loading state while fetching achievements
class AchievementsLoading extends AchievementsState {
  final String? message;

  const AchievementsLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Successfully loaded achievements
class AchievementsLoaded extends AchievementsState {
  final AchievementsResponse response;

  const AchievementsLoaded(this.response);

  /// Get all achievements
  List<Achievement> get achievements => response.achievements;

  /// Get unlocked achievements only
  List<Achievement> get unlockedAchievements =>
      response.achievements.where((a) => a.unlocked).toList();

  /// Get locked achievements only
  List<Achievement> get lockedAchievements =>
      response.achievements.where((a) => !a.unlocked).toList();

  /// Get achievement stats
  AchievementStats get stats => response.stats;

  /// Get completion percentage
  double get completionPercentage => response.completionPercentage;

  @override
  List<Object?> get props => [response];
}

/// Error state when loading fails
class AchievementsError extends AchievementsState {
  final String message;

  const AchievementsError(this.message);

  @override
  List<Object?> get props => [message];
}
