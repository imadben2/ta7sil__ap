import 'package:equatable/equatable.dart';

/// Card types supported
enum FlashcardType {
  basic,
  cloze,
  image,
  audio;

  static FlashcardType fromString(String type) {
    return FlashcardType.values.firstWhere(
      (e) => e.name == type.toLowerCase(),
      orElse: () => FlashcardType.basic,
    );
  }
}

/// Represents a single flashcard
class FlashcardEntity extends Equatable {
  final int id;
  final int deckId;
  final FlashcardType type;
  final String frontTextAr;
  final String? frontTextFr;
  final String? frontImageUrl;
  final String? frontAudioUrl;
  final String backTextAr;
  final String? backTextFr;
  final String? backImageUrl;
  final String? backAudioUrl;
  final String? clozeTemplate;
  final List<ClozeItem>? clozeDeletions;
  final String? hintAr;
  final String? explanationAr;
  final List<String>? tags;
  final String difficultyLevel;
  final int order;
  final CardReviewData? reviewData;

  const FlashcardEntity({
    required this.id,
    required this.deckId,
    required this.type,
    required this.frontTextAr,
    this.frontTextFr,
    this.frontImageUrl,
    this.frontAudioUrl,
    required this.backTextAr,
    this.backTextFr,
    this.backImageUrl,
    this.backAudioUrl,
    this.clozeTemplate,
    this.clozeDeletions,
    this.hintAr,
    this.explanationAr,
    this.tags,
    this.difficultyLevel = 'medium',
    this.order = 0,
    this.reviewData,
  });

  /// For cloze cards: get the question with blanks
  String get clozeQuestion {
    if (type != FlashcardType.cloze || clozeTemplate == null) {
      return frontTextAr;
    }
    // Replace {{c1::answer}} or {{c1::answer::hint}} with ______
    return clozeTemplate!.replaceAll(
      RegExp(r'\{\{c\d+::([^}:]+)(?:::[^}]+)?\}\}'),
      '______',
    );
  }

  /// For cloze cards: get the answer text
  String get clozeAnswer {
    if (clozeDeletions != null && clozeDeletions!.isNotEmpty) {
      return clozeDeletions!.first.answer;
    }
    // Extract from template
    final match = RegExp(r'\{\{c\d+::([^}:]+)').firstMatch(clozeTemplate ?? '');
    return match?.group(1) ?? backTextAr;
  }

  /// Check if this is a new card (never reviewed)
  bool get isNew => reviewData == null || reviewData!.totalReviews == 0;

  /// Check if card is due for review
  bool get isDue => reviewData?.isDue ?? true;

  /// Check if card is mastered (interval >= 21 days)
  bool get isMastered => (reviewData?.interval ?? 0) >= 21;

  @override
  List<Object?> get props => [
        id,
        deckId,
        type,
        frontTextAr,
        backTextAr,
        clozeTemplate,
        order,
        reviewData,
      ];
}

/// Cloze deletion item
class ClozeItem extends Equatable {
  final String id;
  final String answer;
  final String? hint;

  const ClozeItem({
    required this.id,
    required this.answer,
    this.hint,
  });

  @override
  List<Object?> get props => [id, answer, hint];
}

/// SM-2 review data for a card
class CardReviewData extends Equatable {
  final double easeFactor;
  final int interval;
  final int repetitions;
  final DateTime? nextReviewDate;
  final DateTime? lastReviewDate;
  final int totalReviews;
  final int correctReviews;
  final String learningState;

  const CardReviewData({
    this.easeFactor = 2.50,
    this.interval = 0,
    this.repetitions = 0,
    this.nextReviewDate,
    this.lastReviewDate,
    this.totalReviews = 0,
    this.correctReviews = 0,
    this.learningState = 'new',
  });

  /// Retention rate as percentage
  double get retentionRate {
    if (totalReviews == 0) return 0;
    return (correctReviews / totalReviews) * 100;
  }

  /// Check if card is due for review
  bool get isDue {
    if (nextReviewDate == null) return true;
    return nextReviewDate!.isBefore(DateTime.now()) ||
        nextReviewDate!.isAtSameMomentAs(DateTime.now());
  }

  /// Check if card is mastered
  bool get isMastered => interval >= 21;

  @override
  List<Object?> get props => [
        easeFactor,
        interval,
        repetitions,
        nextReviewDate,
        lastReviewDate,
        totalReviews,
        correctReviews,
        learningState,
      ];
}

/// Next interval preview for each response type
class IntervalPreview extends Equatable {
  final int intervalDays;
  final String intervalText;
  final DateTime nextDate;

  const IntervalPreview({
    required this.intervalDays,
    required this.intervalText,
    required this.nextDate,
  });

  @override
  List<Object?> get props => [intervalDays, intervalText, nextDate];
}
