import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_session_history.dart';
import 'session_history_state.dart';

/// Cubit for managing session history
class SessionHistoryCubit extends Cubit<SessionHistoryState> {
  final GetSessionHistory getSessionHistory;

  SessionHistoryCubit({required this.getSessionHistory})
    : super(const SessionHistoryInitial());

  /// Load session history for the last 3 months
  Future<void> loadHistory() async {
    emit(const SessionHistoryLoading(message: 'جاري تحميل السجل...'));

    final params = SessionHistoryParams.lastThreeMonths();
    final result = await getSessionHistory(params);

    result.fold(
      (failure) {
        emit(SessionHistoryError('فشل في تحميل السجل: ${failure.message}'));
      },
      (history) {
        emit(SessionHistoryLoaded(history: history));
      },
    );
  }

  /// Load history for a custom date range
  Future<void> loadHistoryForRange({
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? filters,
  }) async {
    emit(const SessionHistoryLoading(message: 'جاري تحميل السجل...'));

    final params = SessionHistoryParams(
      startDate: startDate,
      endDate: endDate,
      filters: filters,
    );
    final result = await getSessionHistory(params);

    result.fold(
      (failure) {
        emit(SessionHistoryError('فشل في تحميل السجل: ${failure.message}'));
      },
      (history) {
        emit(SessionHistoryLoaded(history: history));
      },
    );
  }

  /// Apply filter to current history
  Future<void> applyFilter(Map<String, dynamic> filters) async {
    final currentState = state;
    if (currentState is! SessionHistoryLoaded) return;

    final params = SessionHistoryParams(
      startDate: currentState.history.startDate,
      endDate: currentState.history.endDate,
      filters: filters,
    );

    final result = await getSessionHistory(params);

    result.fold(
      (failure) {
        emit(SessionHistoryError('فشل في تطبيق الفلتر: ${failure.message}'));
      },
      (history) {
        emit(
          SessionHistoryLoaded(
            history: history,
            selectedDate: currentState.selectedDate,
          ),
        );
      },
    );
  }

  /// Select a specific date
  void selectDate(DateTime date) {
    final currentState = state;
    if (currentState is SessionHistoryLoaded) {
      emit(
        SessionHistoryLoaded(history: currentState.history, selectedDate: date),
      );
    }
  }

  /// Refresh history data
  Future<void> refresh() async {
    final currentState = state;
    if (currentState is SessionHistoryLoaded) {
      await loadHistoryForRange(
        startDate: currentState.history.startDate,
        endDate: currentState.history.endDate,
        filters: currentState.history.filters,
      );
    } else {
      await loadHistory();
    }
  }
}
