import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_quiz_details_usecase.dart';
import '../../../domain/usecases/start_quiz_usecase.dart';
import 'quiz_detail_event.dart';
import 'quiz_detail_state.dart';

/// BLoC for managing quiz detail page
class QuizDetailBloc extends Bloc<QuizDetailEvent, QuizDetailState> {
  final GetQuizDetailsUseCase getQuizDetailsUseCase;
  final StartQuizUseCase startQuizUseCase;

  int? _currentQuizId;

  QuizDetailBloc({
    required this.getQuizDetailsUseCase,
    required this.startQuizUseCase,
  }) : super(const QuizDetailInitial()) {
    on<LoadQuizDetails>(_onLoadQuizDetails);
    on<RefreshQuizDetails>(_onRefreshQuizDetails);
    on<StartQuiz>(_onStartQuiz);
  }

  /// Load quiz details
  Future<void> _onLoadQuizDetails(
    LoadQuizDetails event,
    Emitter<QuizDetailState> emit,
  ) async {
    _currentQuizId = event.quizId;

    emit(const QuizDetailLoading());

    final result = await getQuizDetailsUseCase(event.quizId);

    result.fold(
      (failure) {
        emit(QuizDetailError(message: failure.message));
      },
      (quiz) {
        emit(QuizDetailLoaded(quiz: quiz));
      },
    );
  }

  /// Refresh quiz details
  Future<void> _onRefreshQuizDetails(
    RefreshQuizDetails event,
    Emitter<QuizDetailState> emit,
  ) async {
    if (_currentQuizId == null) return;

    if (state is QuizDetailLoaded) {
      final currentState = state as QuizDetailLoaded;
      emit(currentState.copyWith(isRefreshing: true));
    }

    final result = await getQuizDetailsUseCase(_currentQuizId!);

    result.fold(
      (failure) {
        if (state is QuizDetailLoaded) {
          final currentState = state as QuizDetailLoaded;
          emit(
            QuizDetailError(
              message: failure.message,
              cachedQuiz: currentState.quiz,
            ),
          );
        } else {
          emit(QuizDetailError(message: failure.message));
        }
      },
      (quiz) {
        emit(QuizDetailLoaded(quiz: quiz, isRefreshing: false));
      },
    );
  }

  /// Start quiz
  Future<void> _onStartQuiz(
    StartQuiz event,
    Emitter<QuizDetailState> emit,
  ) async {
    if (state is! QuizDetailLoaded) return;

    final currentState = state as QuizDetailLoaded;

    emit(QuizStarting(quiz: currentState.quiz));

    final result = await startQuizUseCase(
      StartQuizParams(quizId: currentState.quiz.id, seed: event.seed),
    );

    result.fold(
      (failure) {
        emit(QuizStartError(message: failure.message, quiz: currentState.quiz));
      },
      (attempt) {
        emit(QuizStarted(attempt: attempt));
      },
    );
  }
}
