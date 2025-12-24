import 'package:equatable/equatable.dart';

import 'flashcard_deck_entity.dart';

/// Represents a review session
class ReviewSessionEntity extends Equatable {
  final int id;
  final int? deckId;
  final FlashcardDeckEntity? deck;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int durationSeconds;
  final int totalCardsReviewed;
  final int newCardsStudied;
  final int reviewCardsStudied;
  final int againCount;
  final int hardCount;
  final int goodCount;
  final int easyCount;
  final double? averageResponseTimeSeconds;
  final double sessionRetentionRate;
  final String status;
  final List<int>? cardsReviewed;

  const ReviewSessionEntity({
    required this.id,
    this.deckId,
    this.deck,
    required this.startedAt,
    this.completedAt,
    this.durationSeconds = 0,
    this.totalCardsReviewed = 0,
    this.newCardsStudied = 0,
    this.reviewCardsStudied = 0,
    this.againCount = 0,
    this.hardCount = 0,
    this.goodCount = 0,
    this.easyCount = 0,
    this.averageResponseTimeSeconds,
    this.sessionRetentionRate = 0,
    this.status = 'in_progress',
    this.cardsReviewed,
  });

  /// Check if session is in progress
  bool get isInProgress => status == 'in_progress';

  /// Check if session is completed
  bool get isCompleted => status == 'completed';

  /// Get accuracy percentage
  double get accuracy {
    if (totalCardsReviewed == 0) return 0;
    return ((goodCount + easyCount) / totalCardsReviewed) * 100;
  }

  /// Get duration as Duration object
  Duration get duration => Duration(seconds: durationSeconds);

  /// Get formatted duration string
  String get durationFormatted {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get quality distribution as percentages
  Map<String, double> get qualityDistribution {
    if (totalCardsReviewed == 0) {
      return {'again': 0, 'hard': 0, 'good': 0, 'easy': 0};
    }
    return {
      'again': (againCount / totalCardsReviewed) * 100,
      'hard': (hardCount / totalCardsReviewed) * 100,
      'good': (goodCount / totalCardsReviewed) * 100,
      'easy': (easyCount / totalCardsReviewed) * 100,
    };
  }

  @override
  List<Object?> get props => [
        id,
        deckId,
        startedAt,
        completedAt,
        status,
        totalCardsReviewed,
        sessionRetentionRate,
      ];
}

/// Result of submitting an answer
class AnswerResult extends Equatable {
  final int cardId;
  final int qualityRating;
  final bool wasCorrect;
  final CardReviewResult reviewData;
  final SessionProgress sessionProgress;
  final Map<String, IntervalPreviewData> nextIntervalPreview;

  const AnswerResult({
    required this.cardId,
    required this.qualityRating,
    required this.wasCorrect,
    required this.reviewData,
    required this.sessionProgress,
    required this.nextIntervalPreview,
  });

  @override
  List<Object?> get props => [
        cardId,
        qualityRating,
        wasCorrect,
        reviewData,
        sessionProgress,
      ];
}

/// Review data after submitting answer
class CardReviewResult extends Equatable {
  final double easeFactor;
  final int interval;
  final int repetitions;
  final String? nextReviewDate;
  final String learningState;
  final double retentionRate;

  const CardReviewResult({
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
    this.nextReviewDate,
    required this.learningState,
    required this.retentionRate,
  });

  @override
  List<Object?> get props => [
        easeFactor,
        interval,
        repetitions,
        nextReviewDate,
        learningState,
      ];
}

/// Current session progress
class SessionProgress extends Equatable {
  final int cardsReviewed;
  final int againCount;
  final int hardCount;
  final int goodCount;
  final int easyCount;

  const SessionProgress({
    required this.cardsReviewed,
    required this.againCount,
    required this.hardCount,
    required this.goodCount,
    required this.easyCount,
  });

  int get correctCount => goodCount + easyCount;
  int get incorrectCount => againCount + hardCount;

  @override
  List<Object?> get props => [
        cardsReviewed,
        againCount,
        hardCount,
        goodCount,
        easyCount,
      ];
}

/// Interval preview data for a response type
class IntervalPreviewData extends Equatable {
  final int intervalDays;
  final String intervalText;
  final String nextDate;

  const IntervalPreviewData({
    required this.intervalDays,
    required this.intervalText,
    required this.nextDate,
  });

  @override
  List<Object?> get props => [intervalDays, intervalText, nextDate];
}
