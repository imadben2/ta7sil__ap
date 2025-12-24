import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/flashcard_stats_entity.dart';
import '../../../domain/usecases/get_stats_usecase.dart';
import 'flashcard_stats_event.dart';
import 'flashcard_stats_state.dart';

class FlashcardStatsBloc
    extends Bloc<FlashcardStatsEvent, FlashcardStatsState> {
  final GetFlashcardStatsUseCase getStatsUseCase;
  final GetForecastUseCase getForecastUseCase;
  final GetTodaySummaryUseCase getTodaySummaryUseCase;

  FlashcardStatsBloc({
    required this.getStatsUseCase,
    required this.getForecastUseCase,
    required this.getTodaySummaryUseCase,
  }) : super(const FlashcardStatsInitial()) {
    on<LoadFlashcardStats>(_onLoadFlashcardStats);
    on<LoadForecast>(_onLoadForecast);
    on<LoadTodaySummary>(_onLoadTodaySummary);
    on<RefreshStats>(_onRefreshStats);
  }

  Future<void> _onLoadFlashcardStats(
    LoadFlashcardStats event,
    Emitter<FlashcardStatsState> emit,
  ) async {
    emit(const FlashcardStatsLoading());

    // Load today summary and stats in parallel for faster loading
    final summaryFuture = getTodaySummaryUseCase();
    final statsFuture = getStatsUseCase(deckId: event.deckId);

    // Wait for today summary first (usually faster)
    final summaryResult = await summaryFuture;
    final todaySummary = summaryResult.fold<TodaySummary?>(
      (failure) => null,
      (summary) {
        // Emit early with just the summary so UI can show it
        emit(FlashcardStatsLoaded(todaySummary: summary));
        return summary;
      },
    );

    // Wait for stats
    final statsResult = await statsFuture;

    statsResult.fold(
      (failure) => emit(FlashcardStatsError(message: failure.message)),
      (stats) {
        emit(FlashcardStatsLoaded(
          stats: stats,
          todaySummary: todaySummary,
        ));

        // Load forecast after main stats
        add(const LoadForecast());
      },
    );
  }

  Future<void> _onLoadForecast(
    LoadForecast event,
    Emitter<FlashcardStatsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FlashcardStatsLoaded) return;

    final result = await getForecastUseCase(days: event.days);

    result.fold(
      (failure) {
        // Don't emit error, just log - forecast is optional
      },
      (forecast) {
        emit(currentState.copyWith(forecast: forecast));
      },
    );
  }

  Future<void> _onLoadTodaySummary(
    LoadTodaySummary event,
    Emitter<FlashcardStatsState> emit,
  ) async {
    final result = await getTodaySummaryUseCase();

    result.fold(
      (failure) {
        // Don't emit error, just log - summary is optional
      },
      (summary) {
        final currentState = state;
        if (currentState is FlashcardStatsLoaded) {
          emit(currentState.copyWith(todaySummary: summary));
        } else {
          // Create a minimal loaded state with just the summary
          // This allows the UI to show the summary card before full stats load
          emit(FlashcardStatsLoaded(
            stats: null,
            todaySummary: summary,
          ));
        }
      },
    );
  }

  Future<void> _onRefreshStats(
    RefreshStats event,
    Emitter<FlashcardStatsState> emit,
  ) async {
    add(const LoadFlashcardStats());
  }
}
