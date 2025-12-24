import 'package:equatable/equatable.dart';

abstract class PointsHistoryEvent extends Equatable {
  const PointsHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Load points history for a specific period
class LoadPointsHistoryEvent extends PointsHistoryEvent {
  final int periodDays;

  const LoadPointsHistoryEvent({this.periodDays = 30});

  @override
  List<Object?> get props => [periodDays];
}

/// Refresh points history
class RefreshPointsHistoryEvent extends PointsHistoryEvent {
  final int periodDays;

  const RefreshPointsHistoryEvent({this.periodDays = 30});

  @override
  List<Object?> get props => [periodDays];
}
