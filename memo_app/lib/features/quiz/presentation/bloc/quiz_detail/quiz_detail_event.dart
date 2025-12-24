import 'package:equatable/equatable.dart';

/// Events for QuizDetailBloc
abstract class QuizDetailEvent extends Equatable {
  const QuizDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Load quiz details
class LoadQuizDetails extends QuizDetailEvent {
  final int quizId;

  const LoadQuizDetails({required this.quizId});

  @override
  List<Object?> get props => [quizId];
}

/// Refresh quiz details
class RefreshQuizDetails extends QuizDetailEvent {
  const RefreshQuizDetails();
}

/// Start quiz
class StartQuiz extends QuizDetailEvent {
  final int? seed; // For reproducible shuffling

  const StartQuiz({this.seed});

  @override
  List<Object?> get props => [seed];
}
