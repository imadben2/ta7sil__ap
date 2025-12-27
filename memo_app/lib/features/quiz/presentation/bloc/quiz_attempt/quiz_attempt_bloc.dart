import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/usecases/get_current_attempt_usecase.dart';
import '../../../domain/usecases/save_answer_usecase.dart';
import '../../../domain/usecases/submit_quiz_usecase.dart';
import '../../../domain/usecases/abandon_quiz_usecase.dart';
import 'quiz_attempt_event.dart';
import 'quiz_attempt_state.dart';

/// BLoC for managing active quiz attempt
class QuizAttemptBloc extends Bloc<QuizAttemptEvent, QuizAttemptState> {
  final GetCurrentAttemptUseCase getCurrentAttemptUseCase;
  final SaveAnswerUseCase saveAnswerUseCase;
  final SubmitQuizUseCase submitQuizUseCase;
  final AbandonQuizUseCase abandonQuizUseCase;

  QuizAttemptBloc({
    required this.getCurrentAttemptUseCase,
    required this.saveAnswerUseCase,
    required this.submitQuizUseCase,
    required this.abandonQuizUseCase,
  }) : super(const QuizAttemptInitial()) {
    on<LoadCurrentAttempt>(_onLoadCurrentAttempt);
    on<NavigateToQuestion>(_onNavigateToQuestion);
    on<NavigateToNextQuestion>(_onNavigateToNextQuestion);
    on<NavigateToPreviousQuestion>(_onNavigateToPreviousQuestion);
    // Add debouncing to answer saving to prevent rapid API calls
    // Using restartable to cancel previous saves when new answer comes
    on<SaveAnswer>(
      _onSaveAnswer,
      transformer: restartable(),
    );
    on<SubmitQuiz>(_onSubmitQuiz);
    on<AbandonQuiz>(_onAbandonQuiz);
    on<UpdateTimeSpent>(_onUpdateTimeSpent);
    on<ToggleQuestionFlag>(_onToggleQuestionFlag);
  }

  /// Load current attempt
  Future<void> _onLoadCurrentAttempt(
    LoadCurrentAttempt event,
    Emitter<QuizAttemptState> emit,
  ) async {
    emit(const QuizAttemptLoading());

    final result = await getCurrentAttemptUseCase();

    result.fold(
      (failure) {
        emit(QuizAttemptError(message: failure.message));
      },
      (attempt) {
        if (attempt == null) {
          emit(const NoActiveAttempt());
        } else {
          emit(
            QuizAttemptActive(
              attempt: attempt,
              currentQuestionIndex: 0,
              answers: attempt.answers,
              flaggedQuestions: const {},
              timeSpentSeconds: attempt.timeSpentSeconds,
            ),
          );
        }
      },
    );
  }

  /// Navigate to specific question
  void _onNavigateToQuestion(
    NavigateToQuestion event,
    Emitter<QuizAttemptState> emit,
  ) {
    if (state is! QuizAttemptActive) return;

    final currentState = state as QuizAttemptActive;

    // Validate index
    if (event.questionIndex < 0 ||
        event.questionIndex >= currentState.attempt.questions.length) {
      return;
    }

    emit(currentState.copyWith(currentQuestionIndex: event.questionIndex));
  }

  /// Navigate to next question
  void _onNavigateToNextQuestion(
    NavigateToNextQuestion event,
    Emitter<QuizAttemptState> emit,
  ) {
    if (state is! QuizAttemptActive) return;

    final currentState = state as QuizAttemptActive;

    if (currentState.canNavigateNext) {
      emit(
        currentState.copyWith(
          currentQuestionIndex: currentState.currentQuestionIndex + 1,
        ),
      );
    }
  }

  /// Navigate to previous question
  void _onNavigateToPreviousQuestion(
    NavigateToPreviousQuestion event,
    Emitter<QuizAttemptState> emit,
  ) {
    if (state is! QuizAttemptActive) return;

    final currentState = state as QuizAttemptActive;

    if (currentState.canNavigatePrevious) {
      emit(
        currentState.copyWith(
          currentQuestionIndex: currentState.currentQuestionIndex - 1,
        ),
      );
    }
  }

  /// Save answer with debouncing
  /// Updates local state immediately, but debounces the API call by 300ms
  /// This prevents rapid API calls when user is typing or changing answers quickly
  Future<void> _onSaveAnswer(
    SaveAnswer event,
    Emitter<QuizAttemptState> emit,
  ) async {
    if (state is! QuizAttemptActive) return;

    final currentState = state as QuizAttemptActive;

    // Update answers locally first (instant feedback)
    final updatedAnswers = Map<int, dynamic>.from(currentState.answers);
    updatedAnswers[event.questionId] = event.answer;

    emit(currentState.copyWith(answers: updatedAnswers));

    // Debounce: wait 300ms before saving to backend
    // The restartable transformer will cancel this if a new answer comes in
    await Future.delayed(const Duration(milliseconds: 300));

    // Save to backend
    final result = await saveAnswerUseCase(
      SaveAnswerParams(
        attemptId: currentState.attempt.id,
        questionId: event.questionId,
        answer: event.answer,
      ),
    );

    result.fold(
      (failure) {
        // Show error but keep the local answer (it will be synced later on submit)
        // Don't emit error state to avoid disrupting the quiz flow
      },
      (_) {
        // Answer saved successfully to backend
      },
    );
  }

  /// Submit quiz
  Future<void> _onSubmitQuiz(
    SubmitQuiz event,
    Emitter<QuizAttemptState> emit,
  ) async {
    if (state is! QuizAttemptActive) return;

    final currentState = state as QuizAttemptActive;

    emit(QuizAttemptSubmitting(previousState: currentState));

    final result = await submitQuizUseCase(
      SubmitQuizParams(
        attemptId: currentState.attempt.id,
        finalAnswers: currentState.answers,
      ),
    );

    result.fold(
      (failure) {
        emit(
          QuizAttemptError(
            message: failure.message,
            previousState: currentState,
          ),
        );
      },
      (result) {
        emit(QuizAttemptSubmitted(result: result));
      },
    );
  }

  /// Abandon quiz
  Future<void> _onAbandonQuiz(
    AbandonQuiz event,
    Emitter<QuizAttemptState> emit,
  ) async {
    if (state is! QuizAttemptActive) return;

    final currentState = state as QuizAttemptActive;
    final quizId = currentState.attempt.quizId;

    emit(const QuizAttemptAbandoning());

    final result = await abandonQuizUseCase(currentState.attempt.id);

    result.fold(
      (failure) {
        emit(
          QuizAttemptError(
            message: failure.message,
            previousState: currentState,
          ),
        );
      },
      (_) {
        emit(QuizAttemptAbandoned(quizId: quizId));
      },
    );
  }

  /// Update time spent
  void _onUpdateTimeSpent(
    UpdateTimeSpent event,
    Emitter<QuizAttemptState> emit,
  ) {
    if (state is! QuizAttemptActive) return;

    final currentState = state as QuizAttemptActive;

    emit(currentState.copyWith(timeSpentSeconds: event.seconds));
  }

  /// Toggle question flag
  void _onToggleQuestionFlag(
    ToggleQuestionFlag event,
    Emitter<QuizAttemptState> emit,
  ) {
    if (state is! QuizAttemptActive) return;

    final currentState = state as QuizAttemptActive;

    final updatedFlags = Set<int>.from(currentState.flaggedQuestions);
    if (updatedFlags.contains(event.questionId)) {
      updatedFlags.remove(event.questionId);
    } else {
      updatedFlags.add(event.questionId);
    }

    emit(currentState.copyWith(flaggedQuestions: updatedFlags));
  }
}
