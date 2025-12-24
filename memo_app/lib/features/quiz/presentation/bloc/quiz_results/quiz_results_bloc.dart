import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_quiz_results_usecase.dart';
import '../../../domain/usecases/get_quiz_review_usecase.dart';
import '../../../domain/usecases/get_performance_usecase.dart';
import '../../../domain/usecases/get_attempts_history_usecase.dart';
import 'quiz_results_event.dart';
import 'quiz_results_state.dart';

/// BLoC for managing quiz results, review, and performance stats
class QuizResultsBloc extends Bloc<QuizResultsEvent, QuizResultsState> {
  final GetQuizResultsUseCase getQuizResultsUseCase;
  final GetQuizReviewUseCase getQuizReviewUseCase;
  final GetPerformanceUseCase getPerformanceUseCase;
  final GetAttemptsHistoryUseCase getAttemptsHistoryUseCase;

  QuizResultsBloc({
    required this.getQuizResultsUseCase,
    required this.getQuizReviewUseCase,
    required this.getPerformanceUseCase,
    required this.getAttemptsHistoryUseCase,
  }) : super(const QuizResultsInitial()) {
    on<LoadQuizResults>(_onLoadQuizResults);
    on<LoadQuizReview>(_onLoadQuizReview);
    on<LoadPerformanceStats>(_onLoadPerformanceStats);
    on<LoadAttemptsHistory>(_onLoadAttemptsHistory);
    on<LoadMoreAttempts>(_onLoadMoreAttempts);
  }

  /// Load quiz results
  Future<void> _onLoadQuizResults(
    LoadQuizResults event,
    Emitter<QuizResultsState> emit,
  ) async {
    emit(const QuizResultsLoading());

    final result = await getQuizResultsUseCase(event.attemptId);

    result.fold(
      (failure) {
        emit(QuizResultsError(message: failure.message));
      },
      (results) {
        emit(QuizResultsLoaded(result: results));
      },
    );
  }

  /// Load quiz review
  Future<void> _onLoadQuizReview(
    LoadQuizReview event,
    Emitter<QuizResultsState> emit,
  ) async {
    emit(const QuizResultsLoading());

    final result = await getQuizReviewUseCase(event.attemptId);

    result.fold(
      (failure) {
        emit(QuizResultsError(message: failure.message));
      },
      (review) {
        emit(QuizReviewLoaded(result: review));
      },
    );
  }

  /// Load performance statistics
  Future<void> _onLoadPerformanceStats(
    LoadPerformanceStats event,
    Emitter<QuizResultsState> emit,
  ) async {
    emit(const QuizResultsLoading());

    final result = await getPerformanceUseCase(
      GetPerformanceParams(subjectId: event.subjectId, period: event.period),
    );

    result.fold(
      (failure) {
        emit(QuizResultsError(message: failure.message));
      },
      (performance) {
        emit(PerformanceStatsLoaded(performance: performance));
      },
    );
  }

  /// Load attempts history
  Future<void> _onLoadAttemptsHistory(
    LoadAttemptsHistory event,
    Emitter<QuizResultsState> emit,
  ) async {
    emit(const QuizResultsLoading());

    final result = await getAttemptsHistoryUseCase(
      GetAttemptsHistoryParams(page: event.page),
    );

    result.fold(
      (failure) {
        emit(QuizResultsError(message: failure.message));
      },
      (attempts) {
        emit(
          AttemptsHistoryLoaded(
            attempts: attempts,
            currentPage: event.page,
            hasMore: attempts.length >= 15, // Assuming perPage = 15
          ),
        );
      },
    );
  }

  /// Load more attempts (pagination)
  Future<void> _onLoadMoreAttempts(
    LoadMoreAttempts event,
    Emitter<QuizResultsState> emit,
  ) async {
    if (state is! AttemptsHistoryLoaded) return;

    final currentState = state as AttemptsHistoryLoaded;
    if (!currentState.hasMore) return;

    emit(AttemptsHistoryLoadingMore(currentAttempts: currentState.attempts));

    final nextPage = currentState.currentPage + 1;

    final result = await getAttemptsHistoryUseCase(
      GetAttemptsHistoryParams(page: nextPage),
    );

    result.fold(
      (failure) {
        emit(QuizResultsError(message: failure.message));
      },
      (newAttempts) {
        final allAttempts = [...currentState.attempts, ...newAttempts];

        emit(
          AttemptsHistoryLoaded(
            attempts: allAttempts,
            currentPage: nextPage,
            hasMore: newAttempts.length >= 15,
          ),
        );
      },
    );
  }
}
