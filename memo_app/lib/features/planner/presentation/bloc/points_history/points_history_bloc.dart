import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_points_history.dart';
import 'points_history_event.dart';
import 'points_history_state.dart';

/// BLoC for managing points history
class PointsHistoryBloc extends Bloc<PointsHistoryEvent, PointsHistoryState> {
  final GetPointsHistory getPointsHistory;

  PointsHistoryBloc({required this.getPointsHistory})
      : super(const PointsHistoryInitial()) {
    on<LoadPointsHistoryEvent>(_onLoadPointsHistory);
    on<RefreshPointsHistoryEvent>(_onRefreshPointsHistory);
  }

  Future<void> _onLoadPointsHistory(
    LoadPointsHistoryEvent event,
    Emitter<PointsHistoryState> emit,
  ) async {
    emit(const PointsHistoryLoading(message: 'جاري تحميل سجل النقاط...'));

    final params = PointsHistoryParams(periodDays: event.periodDays);
    final result = await getPointsHistory(params);

    result.fold(
      (failure) {
        emit(PointsHistoryError('فشل في تحميل سجل النقاط: ${failure.message}'));
      },
      (history) {
        emit(PointsHistoryLoaded(history));
      },
    );
  }

  Future<void> _onRefreshPointsHistory(
    RefreshPointsHistoryEvent event,
    Emitter<PointsHistoryState> emit,
  ) async {
    // Keep current data visible during refresh
    final currentState = state;

    if (currentState is! PointsHistoryLoaded) {
      emit(const PointsHistoryLoading(message: 'جاري تحديث سجل النقاط...'));
    }

    final params = PointsHistoryParams(periodDays: event.periodDays);
    final result = await getPointsHistory(params);

    result.fold(
      (failure) {
        // If refresh fails, keep showing current data
        if (currentState is PointsHistoryLoaded) {
          emit(currentState);
        } else {
          emit(PointsHistoryError('فشل في تحديث سجل النقاط: ${failure.message}'));
        }
      },
      (history) {
        emit(PointsHistoryLoaded(history));
      },
    );
  }
}
