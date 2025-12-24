import 'package:equatable/equatable.dart';
import '../../domain/entities/leaderboard_entity.dart';

/// Base class for all leaderboard states
abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial();
}

/// Loading state while fetching data
class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading();
}

/// State when stream leaderboard is loaded
class StreamLeaderboardLoaded extends LeaderboardState {
  final LeaderboardData data;
  final LeaderboardPeriod period;
  final LeaderboardScope scope;

  const StreamLeaderboardLoaded({
    required this.data,
    required this.period,
    this.scope = LeaderboardScope.stream,
  });

  @override
  List<Object?> get props => [data, period, scope];

  StreamLeaderboardLoaded copyWith({
    LeaderboardData? data,
    LeaderboardPeriod? period,
    LeaderboardScope? scope,
  }) {
    return StreamLeaderboardLoaded(
      data: data ?? this.data,
      period: period ?? this.period,
      scope: scope ?? this.scope,
    );
  }
}

/// State when subject leaderboard is loaded
class SubjectLeaderboardLoaded extends LeaderboardState {
  final LeaderboardData data;
  final int subjectId;
  final LeaderboardPeriod period;
  final LeaderboardScope scope;

  const SubjectLeaderboardLoaded({
    required this.data,
    required this.subjectId,
    required this.period,
    this.scope = LeaderboardScope.subject,
  });

  @override
  List<Object?> get props => [data, subjectId, period, scope];

  SubjectLeaderboardLoaded copyWith({
    LeaderboardData? data,
    int? subjectId,
    LeaderboardPeriod? period,
    LeaderboardScope? scope,
  }) {
    return SubjectLeaderboardLoaded(
      data: data ?? this.data,
      subjectId: subjectId ?? this.subjectId,
      period: period ?? this.period,
      scope: scope ?? this.scope,
    );
  }
}

/// Error state
class LeaderboardError extends LeaderboardState {
  final String message;
  final LeaderboardData? cachedData;

  const LeaderboardError({
    required this.message,
    this.cachedData,
  });

  @override
  List<Object?> get props => [message, cachedData];
}
