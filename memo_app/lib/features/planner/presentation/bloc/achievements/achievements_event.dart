import 'package:equatable/equatable.dart';

abstract class AchievementsEvent extends Equatable {
  const AchievementsEvent();

  @override
  List<Object?> get props => [];
}

/// Load all achievements from the API
class LoadAchievementsEvent extends AchievementsEvent {
  const LoadAchievementsEvent();
}

/// Refresh achievements (pull to refresh)
class RefreshAchievementsEvent extends AchievementsEvent {
  const RefreshAchievementsEvent();
}
