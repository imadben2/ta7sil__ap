import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

/// Start a new review session
class StartReviewSession extends ReviewEvent {
  final int? deckId;
  final int? cardLimit;
  final bool browseMode;
  final bool shuffle;

  const StartReviewSession({
    this.deckId,
    this.cardLimit,
    this.browseMode = false,
    this.shuffle = false,
  });

  @override
  List<Object?> get props => [deckId, cardLimit, browseMode, shuffle];
}

/// Flip the current card
class FlipCard extends ReviewEvent {
  const FlipCard();
}

/// Submit answer for current card
class SubmitCardAnswer extends ReviewEvent {
  final int cardId;
  final String response; // 'again', 'hard', 'good', 'easy'

  const SubmitCardAnswer({
    required this.cardId,
    required this.response,
  });

  @override
  List<Object?> get props => [cardId, response];
}

/// Move to next card
class NextCard extends ReviewEvent {
  const NextCard();
}

/// Move to previous card (for review)
class PreviousCard extends ReviewEvent {
  const PreviousCard();
}

/// Complete the review session
class CompleteReview extends ReviewEvent {
  const CompleteReview();
}

/// Abandon the review session
class AbandonReview extends ReviewEvent {
  const AbandonReview();
}

/// Resume existing session
class ResumeSession extends ReviewEvent {
  const ResumeSession();
}

/// Update timer (called every second during review)
class UpdateTimer extends ReviewEvent {
  const UpdateTimer();
}

/// Reset review state
class ResetReview extends ReviewEvent {
  const ResetReview();
}
