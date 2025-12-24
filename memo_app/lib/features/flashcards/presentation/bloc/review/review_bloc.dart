import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/review_session_entity.dart';
import '../../../domain/usecases/complete_session_usecase.dart';
import '../../../domain/usecases/start_review_usecase.dart';
import '../../../domain/usecases/submit_answer_usecase.dart';
import 'review_event.dart';
import 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final StartReviewUseCase startReviewUseCase;
  final SubmitAnswerUseCase submitAnswerUseCase;
  final CompleteSessionUseCase completeSessionUseCase;

  Timer? _timer;

  ReviewBloc({
    required this.startReviewUseCase,
    required this.submitAnswerUseCase,
    required this.completeSessionUseCase,
  }) : super(const ReviewInitial()) {
    on<StartReviewSession>(_onStartReviewSession);
    on<FlipCard>(_onFlipCard);
    on<SubmitCardAnswer>(_onSubmitCardAnswer);
    on<NextCard>(_onNextCard);
    on<PreviousCard>(_onPreviousCard);
    on<CompleteReview>(_onCompleteReview);
    on<AbandonReview>(_onAbandonReview);
    on<UpdateTimer>(_onUpdateTimer);
    on<ResetReview>(_onResetReview);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const UpdateTimer());
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _onStartReviewSession(
    StartReviewSession event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());

    final result = await startReviewUseCase(StartReviewParams(
      deckId: event.deckId,
      cardLimit: event.cardLimit,
      browseMode: event.browseMode,
    ));

    await result.fold(
      (failure) async => emit(ReviewError(message: failure.message)),
      (data) async {
        if (data.cards.isEmpty) {
          emit(ReviewError(message: event.browseMode
              ? 'لا توجد بطاقات في هذه المجموعة'
              : 'لا توجد بطاقات للمراجعة'));
          return;
        }

        var cards = data.cards;

        // Shuffle cards if requested
        if (event.shuffle) {
          cards = List.from(cards)..shuffle();
        }

        final now = DateTime.now();

        // Don't start timer in browse mode
        if (!event.browseMode) {
          _startTimer();
        }

        emit(ReviewActive(
          session: data.session,
          cards: cards,
          currentCardIndex: 0,
          isCardFlipped: false,
          answers: {},
          sessionStartTime: now,
          cardStartTime: now,
          browseMode: event.browseMode,
        ));
      },
    );
  }

  void _onFlipCard(FlipCard event, Emitter<ReviewState> emit) {
    final currentState = state;
    if (currentState is! ReviewActive) return;

    emit(currentState.copyWith(isCardFlipped: !currentState.isCardFlipped));
  }

  Future<void> _onSubmitCardAnswer(
    SubmitCardAnswer event,
    Emitter<ReviewState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ReviewActive) return;

    // Calculate time spent on this card
    final timeSpent = currentState.currentCardTimeSpent;

    emit(ReviewSubmitting(previousState: currentState));

    final result = await submitAnswerUseCase(SubmitAnswerParams(
      sessionId: currentState.session.id,
      cardId: event.cardId,
      response: event.response,
      responseTimeSeconds: timeSpent,
    ));

    await result.fold(
      (failure) async {
        emit(ReviewError(
          message: failure.message,
          previousState: currentState,
        ));
      },
      (answerResult) async {
        // Update answers map
        final updatedAnswers = Map<int, AnswerResult>.from(currentState.answers);
        updatedAnswers[event.cardId] = answerResult;

        // Check if this was the last card
        final isComplete = updatedAnswers.length >= currentState.cards.length;

        if (isComplete) {
          // Auto-complete the session
          add(const CompleteReview());
        } else {
          // Move to next card
          final nextIndex = currentState.currentCardIndex + 1;

          emit(currentState.copyWith(
            answers: updatedAnswers,
            currentCardIndex: nextIndex < currentState.cards.length
                ? nextIndex
                : currentState.currentCardIndex,
            isCardFlipped: false,
            cardStartTime: DateTime.now(),
          ));
        }
      },
    );
  }

  void _onNextCard(NextCard event, Emitter<ReviewState> emit) {
    final currentState = state;
    if (currentState is! ReviewActive) return;

    final nextIndex = currentState.currentCardIndex + 1;
    if (nextIndex >= currentState.cards.length) {
      // All cards reviewed
      if (currentState.isComplete) {
        add(const CompleteReview());
      }
      return;
    }

    emit(currentState.copyWith(
      currentCardIndex: nextIndex,
      isCardFlipped: false,
      cardStartTime: DateTime.now(),
    ));
  }

  void _onPreviousCard(PreviousCard event, Emitter<ReviewState> emit) {
    final currentState = state;
    if (currentState is! ReviewActive) return;

    if (currentState.currentCardIndex > 0) {
      emit(currentState.copyWith(
        currentCardIndex: currentState.currentCardIndex - 1,
        isCardFlipped: false,
        cardStartTime: DateTime.now(),
      ));
    }
  }

  Future<void> _onCompleteReview(
    CompleteReview event,
    Emitter<ReviewState> emit,
  ) async {
    final currentState = state;
    ReviewActive activeState;

    if (currentState is ReviewActive) {
      activeState = currentState;
    } else if (currentState is ReviewSubmitting) {
      activeState = currentState.previousState;
    } else {
      return;
    }

    _stopTimer();

    final result = await completeSessionUseCase(activeState.session.id);

    result.fold(
      (failure) {
        // Even on failure, show completion with local data
        final duration = DateTime.now().difference(activeState.sessionStartTime);
        emit(ReviewCompleted(
          session: activeState.session,
          answers: activeState.answers,
          totalCards: activeState.cards.length,
          correctCount: activeState.correctCount,
          incorrectCount: activeState.incorrectCount,
          duration: duration,
        ));
      },
      (completedSession) {
        final duration = DateTime.now().difference(activeState.sessionStartTime);
        emit(ReviewCompleted(
          session: completedSession,
          answers: activeState.answers,
          totalCards: activeState.cards.length,
          correctCount: activeState.correctCount,
          incorrectCount: activeState.incorrectCount,
          duration: duration,
        ));
      },
    );
  }

  Future<void> _onAbandonReview(
    AbandonReview event,
    Emitter<ReviewState> emit,
  ) async {
    _stopTimer();
    emit(const ReviewInitial());
  }

  void _onUpdateTimer(UpdateTimer event, Emitter<ReviewState> emit) {
    final currentState = state;
    if (currentState is! ReviewActive) return;

    emit(currentState.copyWith(
      elapsedSeconds: DateTime.now()
          .difference(currentState.sessionStartTime)
          .inSeconds,
    ));
  }

  void _onResetReview(ResetReview event, Emitter<ReviewState> emit) {
    _stopTimer();
    emit(const ReviewInitial());
  }
}
