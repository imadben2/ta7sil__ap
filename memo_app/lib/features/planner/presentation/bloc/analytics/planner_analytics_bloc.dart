import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_planner_analytics.dart';
import 'planner_analytics_event.dart';
import 'planner_analytics_state.dart';

/// BLoC for managing planner analytics
class PlannerAnalyticsBloc
    extends Bloc<PlannerAnalyticsEvent, PlannerAnalyticsState> {
  final GetPlannerAnalytics getPlannerAnalytics;

  PlannerAnalyticsBloc({required this.getPlannerAnalytics})
    : super(const PlannerAnalyticsInitial()) {
    on<LoadPlannerAnalyticsEvent>(_onLoadAnalytics);
    on<RefreshPlannerAnalyticsEvent>(_onRefreshAnalytics);
  }

  Future<void> _onLoadAnalytics(
    LoadPlannerAnalyticsEvent event,
    Emitter<PlannerAnalyticsState> emit,
  ) async {
    emit(const PlannerAnalyticsLoading(message: 'جاري تحميل التحليلات...'));

    final params = PlannerAnalyticsParams(period: event.period);
    final result = await getPlannerAnalytics(params);

    result.fold(
      (failure) {
        emit(
          PlannerAnalyticsError('فشل في تحميل التحليلات: ${failure.message}'),
        );
      },
      (analytics) {
        emit(PlannerAnalyticsLoaded(analytics));
      },
    );
  }

  Future<void> _onRefreshAnalytics(
    RefreshPlannerAnalyticsEvent event,
    Emitter<PlannerAnalyticsState> emit,
  ) async {
    // Keep current data visible during refresh
    final currentState = state;
    if (currentState is! PlannerAnalyticsLoaded) {
      emit(const PlannerAnalyticsLoading(message: 'جاري تحديث التحليلات...'));
    }

    final params = PlannerAnalyticsParams(period: event.period);
    final result = await getPlannerAnalytics(params);

    result.fold(
      (failure) {
        // If refresh fails, keep showing current data with error message
        if (currentState is PlannerAnalyticsLoaded) {
          emit(currentState); // Keep showing data
        } else {
          emit(
            PlannerAnalyticsError('فشل في تحديث التحليلات: ${failure.message}'),
          );
        }
      },
      (analytics) {
        emit(PlannerAnalyticsLoaded(analytics));
      },
    );
  }
}
