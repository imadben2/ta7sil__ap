import 'package:equatable/equatable.dart';
import '../../domain/entities/leaderboard_entity.dart';

/// Base class for all leaderboard events
abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load stream leaderboard (by academic stream)
class LoadStreamLeaderboard extends LeaderboardEvent {
  final LeaderboardPeriod period;
  final int limit;

  const LoadStreamLeaderboard({
    this.period = LeaderboardPeriod.all,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [period, limit];
}

/// Event to load subject leaderboard
class LoadSubjectLeaderboard extends LeaderboardEvent {
  final int subjectId;
  final LeaderboardPeriod period;
  final int limit;

  const LoadSubjectLeaderboard({
    required this.subjectId,
    this.period = LeaderboardPeriod.all,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [subjectId, period, limit];
}

/// Event to change the time period filter
class ChangePeriod extends LeaderboardEvent {
  final LeaderboardPeriod period;

  const ChangePeriod(this.period);

  @override
  List<Object?> get props => [period];
}

/// Event to change the scope filter (subject/stream)
class ChangeScope extends LeaderboardEvent {
  final LeaderboardScope scope;

  const ChangeScope(this.scope);

  @override
  List<Object?> get props => [scope];
}

/// Event to refresh leaderboard data
class RefreshLeaderboard extends LeaderboardEvent {
  const RefreshLeaderboard();
}
