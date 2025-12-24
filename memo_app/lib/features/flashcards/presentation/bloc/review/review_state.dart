import 'package:equatable/equatable.dart';

import '../../../domain/entities/flashcard_entity.dart';
import '../../../domain/entities/review_session_entity.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

/// Loading review session
class ReviewLoading extends ReviewState {
  const ReviewLoading();
}

/// Active review session
class ReviewActive extends ReviewState {
  final ReviewSessionEntity session;
  final List<FlashcardEntity> cards;
  final int currentCardIndex;
  final bool isCardFlipped;
  final Map<int, AnswerResult> answers;
  final DateTime sessionStartTime;
  final DateTime cardStartTime;
  final int elapsedSeconds;
  final bool browseMode;

  const ReviewActive({
    required this.session,
    required this.cards,
    required this.currentCardIndex,
    required this.isCardFlipped,
    required this.answers,
    required this.sessionStartTime,
    required this.cardStartTime,
    this.elapsedSeconds = 0,
    this.browseMode = false,
  });

  /// Get current card
  FlashcardEntity get currentCard => cards[currentCardIndex];

  /// Get total cards
  int get totalCards => cards.length;

  /// Get cards reviewed count
  int get cardsReviewed => answers.length;

  /// Get remaining cards
  int get remainingCards => totalCards - cardsReviewed;

  /// Get progress percentage
  double get progressPercentage =>
      totalCards > 0 ? (cardsReviewed / totalCards) * 100 : 0;

  /// Check if on last card
  bool get isLastCard => currentCardIndex == cards.length - 1;

  /// Check if all cards answered
  bool get isComplete => cardsReviewed >= totalCards;

  /// Get correct count
  int get correctCount => answers.values.where((a) => a.wasCorrect).length;

  /// Get incorrect count
  int get incorrectCount => answers.values.where((a) => !a.wasCorrect).length;

  /// Get time spent on current card (seconds)
  int get currentCardTimeSpent =>
      DateTime.now().difference(cardStartTime).inSeconds;

  ReviewActive copyWith({
    ReviewSessionEntity? session,
    List<FlashcardEntity>? cards,
    int? currentCardIndex,
    bool? isCardFlipped,
    Map<int, AnswerResult>? answers,
    DateTime? sessionStartTime,
    DateTime? cardStartTime,
    int? elapsedSeconds,
    bool? browseMode,
  }) {
    return ReviewActive(
      session: session ?? this.session,
      cards: cards ?? this.cards,
      currentCardIndex: currentCardIndex ?? this.currentCardIndex,
      isCardFlipped: isCardFlipped ?? this.isCardFlipped,
      answers: answers ?? this.answers,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      cardStartTime: cardStartTime ?? this.cardStartTime,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      browseMode: browseMode ?? this.browseMode,
    );
  }

  @override
  List<Object?> get props => [
        session,
        cards,
        currentCardIndex,
        isCardFlipped,
        answers,
        elapsedSeconds,
        browseMode,
      ];
}

/// Review session completed
class ReviewCompleted extends ReviewState {
  final ReviewSessionEntity session;
  final Map<int, AnswerResult> answers;
  final int totalCards;
  final int correctCount;
  final int incorrectCount;
  final Duration duration;

  const ReviewCompleted({
    required this.session,
    required this.answers,
    required this.totalCards,
    required this.correctCount,
    required this.incorrectCount,
    required this.duration,
  });

  double get accuracy =>
      totalCards > 0 ? (correctCount / totalCards) * 100 : 0;

  @override
  List<Object?> get props => [
        session,
        totalCards,
        correctCount,
        incorrectCount,
        duration,
      ];
}

/// Submitting answer
class ReviewSubmitting extends ReviewState {
  final ReviewActive previousState;

  const ReviewSubmitting({required this.previousState});

  @override
  List<Object?> get props => [previousState];
}

/// Error state
class ReviewError extends ReviewState {
  final String message;
  final ReviewState? previousState;

  const ReviewError({
    required this.message,
    this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}
