import 'package:equatable/equatable.dart';

/// Events for QuizResultsBloc
abstract class QuizResultsEvent extends Equatable {
  const QuizResultsEvent();

  @override
  List<Object?> get props => [];
}

/// Load quiz results
class LoadQuizResults extends QuizResultsEvent {
  final int attemptId;

  const LoadQuizResults({required this.attemptId});

  @override
  List<Object?> get props => [attemptId];
}

/// Load quiz review (answer breakdown)
class LoadQuizReview extends QuizResultsEvent {
  final int attemptId;

  const LoadQuizReview({required this.attemptId});

  @override
  List<Object?> get props => [attemptId];
}

/// Load performance statistics
class LoadPerformanceStats extends QuizResultsEvent {
  final int? subjectId;
  final String period;

  const LoadPerformanceStats({this.subjectId, this.period = 'all'});

  @override
  List<Object?> get props => [subjectId, period];
}

/// Load attempts history
class LoadAttemptsHistory extends QuizResultsEvent {
  final int? subjectId;
  final String? status;
  final int page;

  const LoadAttemptsHistory({this.subjectId, this.status, this.page = 1});

  @override
  List<Object?> get props => [subjectId, status, page];
}

/// Load more attempts (pagination)
class LoadMoreAttempts extends QuizResultsEvent {
  const LoadMoreAttempts();
}
