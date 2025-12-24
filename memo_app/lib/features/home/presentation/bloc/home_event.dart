import 'package:equatable/equatable.dart';

/// Base class for all home events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when dashboard needs to be loaded
class DashboardLoadRequested extends HomeEvent {
  const DashboardLoadRequested();
}

/// Event triggered when user pulls to refresh
class DashboardRefreshRequested extends HomeEvent {
  const DashboardRefreshRequested();
}

/// Event triggered when user marks a session as completed
class SessionCompletedRequested extends HomeEvent {
  final int sessionId;

  const SessionCompletedRequested(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Event triggered when user marks a session as missed
class SessionMissedRequested extends HomeEvent {
  final int sessionId;

  const SessionMissedRequested(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Event triggered to update study time
class StudyTimeUpdateRequested extends HomeEvent {
  final int minutes;

  const StudyTimeUpdateRequested(this.minutes);

  @override
  List<Object?> get props => [minutes];
}
