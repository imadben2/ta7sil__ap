import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_dashboard_data_usecase.dart';
import '../../domain/usecases/mark_session_completed_usecase.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

/// BLoC for managing home dashboard state
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetDashboardDataUseCase getDashboardDataUseCase;
  final MarkSessionCompletedUseCase markSessionCompletedUseCase;
  final HomeRepository homeRepository;

  Timer? _autoRefreshTimer;

  HomeBloc({
    required this.getDashboardDataUseCase,
    required this.markSessionCompletedUseCase,
    required this.homeRepository,
  }) : super(const HomeInitial()) {
    on<DashboardLoadRequested>(_onDashboardLoadRequested);
    on<DashboardRefreshRequested>(_onDashboardRefreshRequested);
    on<SessionCompletedRequested>(_onSessionCompletedRequested);
    on<SessionMissedRequested>(_onSessionMissedRequested);
    on<StudyTimeUpdateRequested>(_onStudyTimeUpdateRequested);

    // Start auto-refresh timer (every 5 minutes)
    _startAutoRefresh();
  }

  /// Load dashboard data
  Future<void> _onDashboardLoadRequested(
    DashboardLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    final result = await getDashboardDataUseCase();

    result.fold(
      (failure) {
        // Try to show cached data if available
        emit(HomeError(message: failure.message, cachedData: null));
      },
      (data) {
        emit(HomeLoaded(data: data, lastUpdated: DateTime.now()));
      },
    );
  }

  /// Refresh dashboard data (pull-to-refresh)
  Future<void> _onDashboardRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    // Keep showing current data while refreshing
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(HomeRefreshing(currentState.data));
    }

    final result = await getDashboardDataUseCase();

    result.fold(
      (failure) {
        // On refresh error, go back to loaded state with old data
        if (state is HomeRefreshing) {
          final refreshingState = state as HomeRefreshing;
          emit(
            HomeLoaded(
              data: refreshingState.currentData,
              lastUpdated: DateTime.now(),
            ),
          );
        } else {
          emit(HomeError(message: failure.message));
        }
      },
      (data) {
        emit(HomeLoaded(data: data, lastUpdated: DateTime.now()));
      },
    );
  }

  /// Mark a session as completed
  Future<void> _onSessionCompletedRequested(
    SessionCompletedRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(
        HomeSessionUpdating(
          currentData: currentState.data,
          sessionId: event.sessionId,
        ),
      );

      final result = await markSessionCompletedUseCase(event.sessionId);

      await result.fold(
        (failure) async {
          // On error, go back to loaded state
          emit(
            HomeLoaded(
              data: currentState.data,
              lastUpdated: currentState.lastUpdated,
            ),
          );
        },
        (_) async {
          // Success - reload dashboard to get updated data
          add(const DashboardRefreshRequested());
        },
      );
    }
  }

  /// Mark a session as missed
  Future<void> _onSessionMissedRequested(
    SessionMissedRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(
        HomeSessionUpdating(
          currentData: currentState.data,
          sessionId: event.sessionId,
        ),
      );

      final result = await homeRepository.markSessionMissed(event.sessionId);

      await result.fold(
        (failure) async {
          emit(
            HomeLoaded(
              data: currentState.data,
              lastUpdated: currentState.lastUpdated,
            ),
          );
        },
        (_) async {
          add(const DashboardRefreshRequested());
        },
      );
    }
  }

  /// Update study time
  Future<void> _onStudyTimeUpdateRequested(
    StudyTimeUpdateRequested event,
    Emitter<HomeState> emit,
  ) async {
    final result = await homeRepository.updateStudyTime(event.minutes);

    result.fold(
      (failure) {
        // Silently fail - don't disrupt UI
      },
      (_) {
        // Success - refresh stats to show updated time
        if (state is HomeLoaded) {
          add(const DashboardRefreshRequested());
        }
      },
    );
  }

  /// Start auto-refresh timer
  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (state is HomeLoaded) {
        add(const DashboardRefreshRequested());
      }
    });
  }

  @override
  Future<void> close() {
    _autoRefreshTimer?.cancel();
    return super.close();
  }
}
