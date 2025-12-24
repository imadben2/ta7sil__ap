import 'package:equatable/equatable.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../../../domain/entities/quiz_attempt_entity.dart';

/// States for QuizDetailBloc
abstract class QuizDetailState extends Equatable {
  const QuizDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class QuizDetailInitial extends QuizDetailState {
  const QuizDetailInitial();
}

/// Loading state
class QuizDetailLoading extends QuizDetailState {
  const QuizDetailLoading();
}

/// Loaded state
class QuizDetailLoaded extends QuizDetailState {
  final QuizEntity quiz;
  final bool isRefreshing;

  const QuizDetailLoaded({required this.quiz, this.isRefreshing = false});

  @override
  List<Object?> get props => [quiz, isRefreshing];

  QuizDetailLoaded copyWith({QuizEntity? quiz, bool? isRefreshing}) {
    return QuizDetailLoaded(
      quiz: quiz ?? this.quiz,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// Error state
class QuizDetailError extends QuizDetailState {
  final String message;
  final QuizEntity? cachedQuiz;

  const QuizDetailError({required this.message, this.cachedQuiz});

  @override
  List<Object?> get props => [message, cachedQuiz];
}

/// Starting quiz state
class QuizStarting extends QuizDetailState {
  final QuizEntity quiz;

  const QuizStarting({required this.quiz});

  @override
  List<Object?> get props => [quiz];
}

/// Quiz started successfully
class QuizStarted extends QuizDetailState {
  final QuizAttemptEntity attempt;

  const QuizStarted({required this.attempt});

  @override
  List<Object?> get props => [attempt];
}

/// Quiz start error
class QuizStartError extends QuizDetailState {
  final String message;
  final QuizEntity quiz;

  const QuizStartError({required this.message, required this.quiz});

  @override
  List<Object?> get props => [message, quiz];
}
