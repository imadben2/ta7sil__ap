import 'package:equatable/equatable.dart';

import '../../../domain/entities/flashcard_deck_entity.dart';

abstract class DecksState extends Equatable {
  const DecksState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DecksInitial extends DecksState {
  const DecksInitial();
}

/// Loading decks
class DecksLoading extends DecksState {
  const DecksLoading();
}

/// Decks loaded successfully
class DecksLoaded extends DecksState {
  final List<FlashcardDeckEntity> decks;
  final bool hasMore;
  final int currentPage;
  final int? subjectId;
  final String? search;
  final bool isLoadingMore;

  const DecksLoaded({
    required this.decks,
    this.hasMore = false,
    this.currentPage = 1,
    this.subjectId,
    this.search,
    this.isLoadingMore = false,
  });

  DecksLoaded copyWith({
    List<FlashcardDeckEntity>? decks,
    bool? hasMore,
    int? currentPage,
    int? subjectId,
    String? search,
    bool? isLoadingMore,
  }) {
    return DecksLoaded(
      decks: decks ?? this.decks,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      subjectId: subjectId ?? this.subjectId,
      search: search ?? this.search,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        decks,
        hasMore,
        currentPage,
        subjectId,
        search,
        isLoadingMore,
      ];
}

/// Deck details loaded
class DeckDetailsLoaded extends DecksState {
  final FlashcardDeckEntity deck;

  const DeckDetailsLoaded({required this.deck});

  @override
  List<Object?> get props => [deck];
}

/// Loading deck details
class DeckDetailsLoading extends DecksState {
  const DeckDetailsLoading();
}

/// Error state
class DecksError extends DecksState {
  final String message;
  final DecksState? previousState;

  const DecksError({
    required this.message,
    this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}
