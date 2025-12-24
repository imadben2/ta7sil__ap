import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_stats.dart';
import '../../domain/usecases/get_week_schedule.dart';
import '../../domain/usecases/get_day_with_progress.dart';
import '../../domain/usecases/get_weekly_rewards.dart';
import '../../domain/usecases/mark_topic_complete.dart';
import 'bac_study_event.dart';
import 'bac_study_state.dart';

/// BLoC for managing BAC Study Schedule feature
class BacStudyBloc extends Bloc<BacStudyEvent, BacStudyState> {
  final GetUserStats getUserStats;
  final GetWeekSchedule getWeekSchedule;
  final GetDayWithProgress getDayWithProgress;
  final GetWeeklyRewards getWeeklyRewards;
  final MarkTopicComplete markTopicComplete;

  BacStudyBloc({
    required this.getUserStats,
    required this.getWeekSchedule,
    required this.getDayWithProgress,
    required this.getWeeklyRewards,
    required this.markTopicComplete,
  }) : super(const BacStudyInitial()) {
    on<LoadBacStudyStats>(_onLoadStats);
    on<LoadBacStudyWeek>(_onLoadWeek);
    on<LoadBacStudyDay>(_onLoadDay);
    on<LoadBacStudyRewards>(_onLoadRewards);
    on<ToggleBacStudyTopicComplete>(_onToggleTopicComplete);
    on<SelectBacStudyWeek>(_onSelectWeek);
    on<RefreshBacStudyData>(_onRefreshData);
  }

  Future<void> _onLoadStats(
    LoadBacStudyStats event,
    Emitter<BacStudyState> emit,
  ) async {
    emit(const BacStudyLoading());

    final statsResult = await getUserStats(
      GetUserStatsParams(streamId: event.streamId),
    );

    final statsFailure = statsResult.fold(
      (failure) => failure,
      (stats) => null,
    );

    if (statsFailure != null) {
      emit(BacStudyError(statsFailure.message));
      return;
    }

    final stats = statsResult.getOrElse(() => throw Exception('Stats should exist'));
    final currentWeek = stats.currentWeek;

    emit(BacStudyLoaded(
      stats: stats,
      selectedWeek: currentWeek,
      isLoadingWeek: true,
    ));

    // Load the current week's schedule
    final weekResult = await getWeekSchedule(
      GetWeekScheduleParams(streamId: event.streamId, weekNumber: currentWeek),
    );

    final currentState = state;
    if (currentState is BacStudyLoaded) {
      weekResult.fold(
        (failure) => emit(currentState.copyWith(
          isLoadingWeek: false,
          weekLoadError: failure.message,
        )),
        (weekData) => emit(currentState.copyWith(
          currentWeekData: weekData,
          isLoadingWeek: false,
        )),
      );
    }
  }

  Future<void> _onLoadWeek(
    LoadBacStudyWeek event,
    Emitter<BacStudyState> emit,
  ) async {
    final currentState = state;

    if (currentState is BacStudyLoaded) {
      emit(currentState.copyWith(
        selectedWeek: event.weekNumber,
        isLoadingWeek: true,
        weekLoadError: null,
      ));

      final result = await getWeekSchedule(
        GetWeekScheduleParams(
          streamId: event.streamId,
          weekNumber: event.weekNumber,
        ),
      );

      final newState = state;
      if (newState is BacStudyLoaded) {
        result.fold(
          (failure) => emit(newState.copyWith(
            isLoadingWeek: false,
            weekLoadError: failure.message,
          )),
          (weekData) => emit(newState.copyWith(
            currentWeekData: weekData,
            isLoadingWeek: false,
          )),
        );
      }
    } else {
      // First time loading - load stats first
      add(LoadBacStudyStats(streamId: event.streamId));
    }
  }

  Future<void> _onLoadDay(
    LoadBacStudyDay event,
    Emitter<BacStudyState> emit,
  ) async {
    emit(const BacStudyLoading());

    final dayResult = await getDayWithProgress(
      GetDayWithProgressParams(
        streamId: event.streamId,
        dayNumber: event.dayNumber,
      ),
    );

    final dayFailure = dayResult.fold((f) => f, (_) => null);
    if (dayFailure != null) {
      emit(BacStudyError(dayFailure.message));
      return;
    }

    final day = dayResult.getOrElse(() => throw Exception('Day should exist'));

    // Also load stats for context
    final statsResult = await getUserStats(
      GetUserStatsParams(streamId: event.streamId),
    );

    statsResult.fold(
      (failure) => emit(BacStudyDayLoaded(day: day)),
      (stats) => emit(BacStudyDayLoaded(day: day, stats: stats)),
    );
  }

  Future<void> _onLoadRewards(
    LoadBacStudyRewards event,
    Emitter<BacStudyState> emit,
  ) async {
    emit(const BacStudyLoading());

    final rewardsResult = await getWeeklyRewards(
      GetWeeklyRewardsParams(streamId: event.streamId),
    );

    final rewardsFailure = rewardsResult.fold((f) => f, (_) => null);
    if (rewardsFailure != null) {
      emit(BacStudyError(rewardsFailure.message));
      return;
    }

    final rewards = rewardsResult.getOrElse(() => throw Exception('Rewards should exist'));

    // Also load stats
    final statsResult = await getUserStats(
      GetUserStatsParams(streamId: event.streamId),
    );

    statsResult.fold(
      (failure) => emit(BacStudyRewardsLoaded(rewards: rewards)),
      (stats) => emit(BacStudyRewardsLoaded(rewards: rewards, stats: stats)),
    );
  }

  Future<void> _onToggleTopicComplete(
    ToggleBacStudyTopicComplete event,
    Emitter<BacStudyState> emit,
  ) async {
    final currentState = state;

    if (currentState is BacStudyDayLoaded) {
      // Show updating state
      emit(currentState.copyWith(isUpdating: true));

      // Mark topic complete
      final result = await markTopicComplete(
        MarkTopicCompleteParams(
          topicId: event.topicId,
          isCompleted: event.isCompleted,
        ),
      );

      final markFailure = result.fold((f) => f, (_) => null);
      if (markFailure != null) {
        // Revert on error
        emit(currentState.copyWith(isUpdating: false));
        return;
      }

      // Reload day to get fresh data
      final dayResult = await getDayWithProgress(
        GetDayWithProgressParams(
          streamId: event.streamId,
          dayNumber: event.dayNumber,
        ),
      );

      final statsResult = await getUserStats(
        GetUserStatsParams(streamId: event.streamId),
      );

      final dayFailure = dayResult.fold((f) => f, (_) => null);
      if (dayFailure != null) {
        emit(currentState.copyWith(isUpdating: false));
        return;
      }

      final day = dayResult.getOrElse(() => throw Exception('Day should exist'));

      statsResult.fold(
        (failure) => emit(BacStudyDayLoaded(day: day)),
        (stats) => emit(BacStudyDayLoaded(day: day, stats: stats)),
      );
    }
  }

  Future<void> _onSelectWeek(
    SelectBacStudyWeek event,
    Emitter<BacStudyState> emit,
  ) async {
    final currentState = state;

    if (currentState is BacStudyLoaded) {
      emit(currentState.copyWith(selectedWeek: event.weekNumber));
    }
  }

  Future<void> _onRefreshData(
    RefreshBacStudyData event,
    Emitter<BacStudyState> emit,
  ) async {
    final currentState = state;

    if (currentState is BacStudyLoaded) {
      // Refresh stats
      final statsResult = await getUserStats(
        GetUserStatsParams(streamId: event.streamId),
      );

      final statsFailure = statsResult.fold((f) => f, (_) => null);
      if (statsFailure != null) {
        // Keep current state on error
        return;
      }

      final stats = statsResult.getOrElse(() => throw Exception('Stats should exist'));
      emit(currentState.copyWith(stats: stats, isLoadingWeek: true));

      // Refresh current week
      final weekResult = await getWeekSchedule(
        GetWeekScheduleParams(
          streamId: event.streamId,
          weekNumber: currentState.selectedWeek,
        ),
      );

      final newState = state;
      if (newState is BacStudyLoaded) {
        weekResult.fold(
          (failure) => emit(newState.copyWith(isLoadingWeek: false)),
          (weekData) => emit(newState.copyWith(
            currentWeekData: weekData,
            isLoadingWeek: false,
          )),
        );
      }
    } else if (currentState is BacStudyDayLoaded) {
      // Refresh day
      add(LoadBacStudyDay(
        streamId: event.streamId,
        dayNumber: currentState.day.dayNumber,
      ));
    }
  }
}
