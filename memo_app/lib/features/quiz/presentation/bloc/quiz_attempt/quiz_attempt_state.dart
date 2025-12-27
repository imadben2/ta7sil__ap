import 'package:equatable/equatable.dart';
import '../../../domain/entities/quiz_attempt_entity.dart';
import '../../../domain/entities/question_entity.dart';
import '../../../domain/entities/quiz_result_entity.dart';

/// States for QuizAttemptBloc
abstract class QuizAttemptState extends Equatable {
  const QuizAttemptState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class QuizAttemptInitial extends QuizAttemptState {
  const QuizAttemptInitial();
}

/// Loading state
class QuizAttemptLoading extends QuizAttemptState {
  const QuizAttemptLoading();
}

/// Active attempt state (taking quiz)
class QuizAttemptActive extends QuizAttemptState {
  final QuizAttemptEntity attempt;
  final int currentQuestionIndex;
  final Map<int, dynamic> answers; // questionId -> answer
  final Set<int> flaggedQuestions;
  final int timeSpentSeconds;

  const QuizAttemptActive({
    required this.attempt,
    required this.currentQuestionIndex,
    required this.answers,
    required this.flaggedQuestions,
    required this.timeSpentSeconds,
  });

  @override
  List<Object?> get props => [
    attempt,
    currentQuestionIndex,
    answers,
    flaggedQuestions,
    timeSpentSeconds,
  ];

  QuizAttemptActive copyWith({
    QuizAttemptEntity? attempt,
    int? currentQuestionIndex,
    Map<int, dynamic>? answers,
    Set<int>? flaggedQuestions,
    int? timeSpentSeconds,
  }) {
    return QuizAttemptActive(
      attempt: attempt ?? this.attempt,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      flaggedQuestions: flaggedQuestions ?? this.flaggedQuestions,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
    );
  }

  /// Get current question
  QuestionEntity get currentQuestion {
    return attempt.questions[currentQuestionIndex];
  }

  /// Check if current question is answered
  bool get isCurrentQuestionAnswered {
    return answers.containsKey(currentQuestion.id);
  }

  /// Get progress (answered / total)
  int get answeredCount => answers.length;

  /// Get progress percentage
  double get progressPercentage {
    return (answeredCount / attempt.questions.length) * 100;
  }

  /// Check if can navigate to next question
  bool get canNavigateNext {
    return currentQuestionIndex < attempt.questions.length - 1;
  }

  /// Check if can navigate to previous question
  bool get canNavigatePrevious {
    return currentQuestionIndex > 0;
  }

  /// Get unanswered questions count
  int get unansweredCount {
    return attempt.questions.length - answeredCount;
  }

  /// Check if all questions are answered
  bool get allQuestionsAnswered {
    return answeredCount == attempt.questions.length;
  }
}

/// Saving answer state
class QuizAttemptSavingAnswer extends QuizAttemptState {
  final QuizAttemptActive previousState;

  const QuizAttemptSavingAnswer({required this.previousState});

  @override
  List<Object?> get props => [previousState];
}

/// Submitting quiz state
class QuizAttemptSubmitting extends QuizAttemptState {
  final QuizAttemptActive previousState;

  const QuizAttemptSubmitting({required this.previousState});

  @override
  List<Object?> get props => [previousState];
}

/// Quiz submitted successfully
class QuizAttemptSubmitted extends QuizAttemptState {
  final QuizResultEntity result;

  const QuizAttemptSubmitted({required this.result});

  @override
  List<Object?> get props => [result];
}

/// Abandoning quiz state
class QuizAttemptAbandoning extends QuizAttemptState {
  const QuizAttemptAbandoning();
}

/// Quiz abandoned
class QuizAttemptAbandoned extends QuizAttemptState {
  final int quizId;

  const QuizAttemptAbandoned({required this.quizId});

  @override
  List<Object?> get props => [quizId];
}

/// Error state
class QuizAttemptError extends QuizAttemptState {
  final String message;
  final QuizAttemptActive? previousState;

  const QuizAttemptError({required this.message, this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}

/// No active attempt
class NoActiveAttempt extends QuizAttemptState {
  const NoActiveAttempt();
}
