import 'package:equatable/equatable.dart';

/// Events for QuizAttemptBloc
abstract class QuizAttemptEvent extends Equatable {
  const QuizAttemptEvent();

  @override
  List<Object?> get props => [];
}

/// Load current attempt
class LoadCurrentAttempt extends QuizAttemptEvent {
  const LoadCurrentAttempt();
}

/// Navigate to question
class NavigateToQuestion extends QuizAttemptEvent {
  final int questionIndex;

  const NavigateToQuestion({required this.questionIndex});

  @override
  List<Object?> get props => [questionIndex];
}

/// Navigate to next question
class NavigateToNextQuestion extends QuizAttemptEvent {
  const NavigateToNextQuestion();
}

/// Navigate to previous question
class NavigateToPreviousQuestion extends QuizAttemptEvent {
  const NavigateToPreviousQuestion();
}

/// Save answer for current question
class SaveAnswer extends QuizAttemptEvent {
  final int questionId;
  final dynamic answer;

  const SaveAnswer({required this.questionId, required this.answer});

  @override
  List<Object?> get props => [questionId, answer];
}

/// Submit quiz for grading
class SubmitQuiz extends QuizAttemptEvent {
  final bool autoSubmit;

  const SubmitQuiz({this.autoSubmit = false});

  @override
  List<Object?> get props => [autoSubmit];
}

/// Abandon quiz
class AbandonQuiz extends QuizAttemptEvent {
  const AbandonQuiz();
}

/// Update time spent
class UpdateTimeSpent extends QuizAttemptEvent {
  final int seconds;

  const UpdateTimeSpent({required this.seconds});

  @override
  List<Object?> get props => [seconds];
}

/// Mark question as flagged
class ToggleQuestionFlag extends QuizAttemptEvent {
  final int questionId;

  const ToggleQuestionFlag({required this.questionId});

  @override
  List<Object?> get props => [questionId];
}
