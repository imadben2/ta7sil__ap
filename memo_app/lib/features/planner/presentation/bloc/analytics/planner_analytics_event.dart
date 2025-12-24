import 'package:equatable/equatable.dart';

/// Events for PlannerAnalyticsBloc
abstract class PlannerAnalyticsEvent extends Equatable {
  const PlannerAnalyticsEvent();

  @override
  List<Object?> get props => [];
}

/// Load planner analytics for a specific period
class LoadPlannerAnalyticsEvent extends PlannerAnalyticsEvent {
  final String
  period; // 'last_7_days', 'last_30_days', 'last_3_months', 'all_time'

  const LoadPlannerAnalyticsEvent({this.period = 'last_30_days'});

  @override
  List<Object?> get props => [period];
}

/// Refresh analytics data
class RefreshPlannerAnalyticsEvent extends PlannerAnalyticsEvent {
  final String period;

  const RefreshPlannerAnalyticsEvent({this.period = 'last_30_days'});

  @override
  List<Object?> get props => [period];
}
