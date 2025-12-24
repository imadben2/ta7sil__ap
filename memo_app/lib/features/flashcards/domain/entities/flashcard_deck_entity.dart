import 'package:equatable/equatable.dart';

/// Represents a flashcard deck (collection of flashcards)
class FlashcardDeckEntity extends Equatable {
  final int id;
  final String titleAr;
  final String? titleFr;
  final String? descriptionAr;
  final String? descriptionFr;
  final int subjectId;
  final SubjectInfo? subject;
  final int? chapterId;
  final ChapterInfo? chapter;
  final int totalCards;
  final String? coverImageUrl;
  final String color;
  final String? icon;
  final String difficultyLevel;
  final int? estimatedStudyMinutes;
  final bool isPublished;
  final bool isPremium;
  final DateTime createdAt;
  final UserDeckProgress? userProgress;

  const FlashcardDeckEntity({
    required this.id,
    required this.titleAr,
    this.titleFr,
    this.descriptionAr,
    this.descriptionFr,
    required this.subjectId,
    this.subject,
    this.chapterId,
    this.chapter,
    required this.totalCards,
    this.coverImageUrl,
    this.color = '#6366F1',
    this.icon,
    this.difficultyLevel = 'medium',
    this.estimatedStudyMinutes,
    this.isPublished = true,
    this.isPremium = false,
    required this.createdAt,
    this.userProgress,
  });

  /// Mastery percentage (0-100)
  double get masteryPercentage {
    if (totalCards == 0) return 0;
    return ((userProgress?.cardsMastered ?? 0) / totalCards) * 100;
  }

  /// Check if deck has cards due for review
  bool get hasDueCards {
    return (userProgress?.cardsDue ?? 0) > 0 ||
        (userProgress?.cardsNew ?? 0) > 0;
  }

  /// Get total cards available for study today
  int get cardsAvailableToday {
    return (userProgress?.cardsDue ?? 0) + (userProgress?.cardsNew ?? 0);
  }

  @override
  List<Object?> get props => [
        id,
        titleAr,
        titleFr,
        descriptionAr,
        subjectId,
        chapterId,
        totalCards,
        coverImageUrl,
        color,
        difficultyLevel,
        isPublished,
        isPremium,
        createdAt,
        userProgress,
      ];
}

/// Subject information for deck
class SubjectInfo extends Equatable {
  final int id;
  final String nameAr;
  final String? color;
  final String? icon;

  const SubjectInfo({
    required this.id,
    required this.nameAr,
    this.color,
    this.icon,
  });

  @override
  List<Object?> get props => [id, nameAr, color, icon];
}

/// Chapter information for deck
class ChapterInfo extends Equatable {
  final int id;
  final String titleAr;

  const ChapterInfo({
    required this.id,
    required this.titleAr,
  });

  @override
  List<Object?> get props => [id, titleAr];
}

/// User's progress on a deck
class UserDeckProgress extends Equatable {
  final int cardsStudied;
  final int cardsMastered;
  final int cardsDue;
  final int cardsNew;
  final double masteryPercentage;
  final double averageRetention;
  final DateTime? lastStudiedAt;

  const UserDeckProgress({
    this.cardsStudied = 0,
    this.cardsMastered = 0,
    this.cardsDue = 0,
    this.cardsNew = 0,
    this.masteryPercentage = 0,
    this.averageRetention = 0,
    this.lastStudiedAt,
  });

  @override
  List<Object?> get props => [
        cardsStudied,
        cardsMastered,
        cardsDue,
        cardsNew,
        masteryPercentage,
        averageRetention,
        lastStudiedAt,
      ];
}
