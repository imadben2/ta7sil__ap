import 'package:equatable/equatable.dart';
import '../../../domain/entities/planner_analytics.dart';

/// States for PlannerAnalyticsBloc
abstract class PlannerAnalyticsState extends Equatable {
  const PlannerAnalyticsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PlannerAnalyticsInitial extends PlannerAnalyticsState {
  const PlannerAnalyticsInitial();
}

/// Loading state
class PlannerAnalyticsLoading extends PlannerAnalyticsState {
  final String? message;

  const PlannerAnalyticsLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Loaded state with analytics data
class PlannerAnalyticsLoaded extends PlannerAnalyticsState {
  final PlannerAnalytics analytics;

  const PlannerAnalyticsLoaded(this.analytics);

  @override
  List<Object?> get props => [analytics];
}

/// Error state
class PlannerAnalyticsError extends PlannerAnalyticsState {
  final String message;

  const PlannerAnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
