import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/flashcard_deck_entity.dart';
import '../entities/flashcard_entity.dart';
import '../entities/flashcard_stats_entity.dart';
import '../entities/review_session_entity.dart';

/// Abstract repository for flashcards feature
abstract class FlashcardsRepository {
  // ==================== Decks ====================

  /// Get all flashcard decks with optional filters
  Future<Either<Failure, List<FlashcardDeckEntity>>> getDecks({
    int? subjectId,
    int? chapterId,
    String? search,
    int page = 1,
    int perPage = 20,
  });

  /// Get a single deck with its cards
  Future<Either<Failure, FlashcardDeckEntity>> getDeckDetails(int deckId);

  /// Get decks that have cards due for review
  Future<Either<Failure, List<FlashcardDeckEntity>>> getDecksWithDueCards();

  // ==================== Cards ====================

  /// Get cards due for review
  Future<Either<Failure, List<FlashcardEntity>>> getDueCards({
    int? deckId,
    int limit = 50,
  });

  /// Get new cards (never studied)
  Future<Either<Failure, List<FlashcardEntity>>> getNewCards({
    int? deckId,
    int limit = 20,
  });

  // ==================== Review Sessions ====================

  /// Start a new review session
  /// If browseMode is true, returns all cards in the deck (not just due cards)
  Future<Either<Failure, ReviewSessionData>> startReviewSession({
    int? deckId,
    int? cardLimit,
    bool browseMode = false,
  });

  /// Get current in-progress session
  Future<Either<Failure, ReviewSessionEntity?>> getCurrentSession();

  /// Submit answer for a card
  Future<Either<Failure, AnswerResult>> submitAnswer({
    required int sessionId,
    required int cardId,
    required String response, // 'again', 'hard', 'good', 'easy'
    int? responseTimeSeconds,
  });

  /// Complete a review session
  Future<Either<Failure, ReviewSessionEntity>> completeSession(int sessionId);

  /// Abandon a review session
  Future<Either<Failure, ReviewSessionEntity>> abandonSession(int sessionId);

  /// Get review history
  Future<Either<Failure, List<ReviewSessionEntity>>> getReviewHistory({
    int? deckId,
    int page = 1,
    int perPage = 20,
  });

  // ==================== Statistics ====================

  /// Get overall flashcard statistics
  Future<Either<Failure, FlashcardStatsEntity>> getStats({int? deckId});

  /// Get review forecast for upcoming days
  Future<Either<Failure, List<DailyForecast>>> getForecast({int days = 7});

  /// Get review heatmap data
  Future<Either<Failure, List<HeatmapEntry>>> getHeatmap({int days = 365});

  /// Get today's summary
  Future<Either<Failure, TodaySummary>> getTodaySummary();

  /// Get stats for a specific deck
  Future<Either<Failure, DeckStats>> getDeckStats(int deckId);
}

/// Data returned when starting a review session
class ReviewSessionData {
  final ReviewSessionEntity session;
  final List<FlashcardEntity> cards;
  final int totalDue;
  final int totalNew;

  const ReviewSessionData({
    required this.session,
    required this.cards,
    required this.totalDue,
    required this.totalNew,
  });

  int get totalCards => cards.length;
}
