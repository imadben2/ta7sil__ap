import 'package:equatable/equatable.dart';
import '../../../domain/entities/quiz_result_entity.dart';
import '../../../domain/entities/quiz_performance_entity.dart';
import '../../../domain/entities/quiz_attempt_entity.dart';

/// States for QuizResultsBloc
abstract class QuizResultsState extends Equatable {
  const QuizResultsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class QuizResultsInitial extends QuizResultsState {
  const QuizResultsInitial();
}

/// Loading state
class QuizResultsLoading extends QuizResultsState {
  const QuizResultsLoading();
}

/// Results loaded state
class QuizResultsLoaded extends QuizResultsState {
  final QuizResultEntity result;

  const QuizResultsLoaded({required this.result});

  @override
  List<Object?> get props => [result];
}

/// Review loaded state
class QuizReviewLoaded extends QuizResultsState {
  final QuizResultEntity result;

  const QuizReviewLoaded({required this.result});

  @override
  List<Object?> get props => [result];
}

/// Performance stats loaded state
class PerformanceStatsLoaded extends QuizResultsState {
  final QuizPerformanceEntity performance;

  const PerformanceStatsLoaded({required this.performance});

  @override
  List<Object?> get props => [performance];
}

/// Attempts history loaded state
class AttemptsHistoryLoaded extends QuizResultsState {
  final List<QuizAttemptEntity> attempts;
  final int currentPage;
  final bool hasMore;

  const AttemptsHistoryLoaded({
    required this.attempts,
    required this.currentPage,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [attempts, currentPage, hasMore];

  AttemptsHistoryLoaded copyWith({
    List<QuizAttemptEntity>? attempts,
    int? currentPage,
    bool? hasMore,
  }) {
    return AttemptsHistoryLoaded(
      attempts: attempts ?? this.attempts,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Loading more attempts (pagination)
class AttemptsHistoryLoadingMore extends QuizResultsState {
  final List<QuizAttemptEntity> currentAttempts;

  const AttemptsHistoryLoadingMore({required this.currentAttempts});

  @override
  List<Object?> get props => [currentAttempts];
}

/// Error state
class QuizResultsError extends QuizResultsState {
  final String message;

  const QuizResultsError({required this.message});

  @override
  List<Object?> get props => [message];
}
