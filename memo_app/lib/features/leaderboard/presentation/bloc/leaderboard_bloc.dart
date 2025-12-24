import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/leaderboard_entity.dart';
import '../../domain/usecases/get_leaderboard_usecase.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

/// BLoC for managing leaderboard state
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final GetStreamLeaderboardUseCase getStreamLeaderboard;
  final GetSubjectLeaderboardUseCase getSubjectLeaderboard;

  /// Current subject ID (used for reloading when changing period)
  int? _currentSubjectId;

  LeaderboardBloc({
    required this.getStreamLeaderboard,
    required this.getSubjectLeaderboard,
  }) : super(const LeaderboardInitial()) {
    on<LoadStreamLeaderboard>(_onLoadStreamLeaderboard);
    on<LoadSubjectLeaderboard>(_onLoadSubjectLeaderboard);
    on<ChangePeriod>(_onChangePeriod);
    on<ChangeScope>(_onChangeScope);
    on<RefreshLeaderboard>(_onRefreshLeaderboard);
  }

  /// Handle loading stream leaderboard
  Future<void> _onLoadStreamLeaderboard(
    LoadStreamLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(const LeaderboardLoading());

    final result = await getStreamLeaderboard(
      period: event.period,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(LeaderboardError(message: failure.message)),
      (data) => emit(StreamLeaderboardLoaded(
        data: data,
        period: event.period,
      )),
    );
  }

  /// Handle loading subject leaderboard
  Future<void> _onLoadSubjectLeaderboard(
    LoadSubjectLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(const LeaderboardLoading());
    _currentSubjectId = event.subjectId;

    final result = await getSubjectLeaderboard(
      subjectId: event.subjectId,
      period: event.period,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(LeaderboardError(message: failure.message)),
      (data) => emit(SubjectLeaderboardLoaded(
        data: data,
        subjectId: event.subjectId,
        period: event.period,
      )),
    );
  }

  /// Handle changing time period filter
  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<LeaderboardState> emit,
  ) async {
    final currentState = state;

    if (currentState is StreamLeaderboardLoaded) {
      add(LoadStreamLeaderboard(period: event.period));
    } else if (currentState is SubjectLeaderboardLoaded) {
      add(LoadSubjectLeaderboard(
        subjectId: currentState.subjectId,
        period: event.period,
      ));
    }
  }

  /// Handle changing scope filter (subject/stream)
  Future<void> _onChangeScope(
    ChangeScope event,
    Emitter<LeaderboardState> emit,
  ) async {
    final currentState = state;
    LeaderboardPeriod period = LeaderboardPeriod.all;

    // Get current period
    if (currentState is StreamLeaderboardLoaded) {
      period = currentState.period;
    } else if (currentState is SubjectLeaderboardLoaded) {
      period = currentState.period;
    }

    if (event.scope == LeaderboardScope.stream) {
      add(LoadStreamLeaderboard(period: period));
    } else if (event.scope == LeaderboardScope.subject && _currentSubjectId != null) {
      add(LoadSubjectLeaderboard(
        subjectId: _currentSubjectId!,
        period: period,
      ));
    }
  }

  /// Handle refresh
  Future<void> _onRefreshLeaderboard(
    RefreshLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    final currentState = state;

    if (currentState is StreamLeaderboardLoaded) {
      add(LoadStreamLeaderboard(period: currentState.period));
    } else if (currentState is SubjectLeaderboardLoaded) {
      add(LoadSubjectLeaderboard(
        subjectId: currentState.subjectId,
        period: currentState.period,
      ));
    }
  }
}
