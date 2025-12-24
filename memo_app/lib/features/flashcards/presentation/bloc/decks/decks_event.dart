import 'package:equatable/equatable.dart';

abstract class DecksEvent extends Equatable {
  const DecksEvent();

  @override
  List<Object?> get props => [];
}

/// Load decks with optional filters
class LoadDecks extends DecksEvent {
  final int? subjectId;
  final int? chapterId;
  final String? search;
  final bool refresh;

  const LoadDecks({
    this.subjectId,
    this.chapterId,
    this.search,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [subjectId, chapterId, search, refresh];
}

/// Load more decks (pagination)
class LoadMoreDecks extends DecksEvent {
  const LoadMoreDecks();
}

/// Load a single deck's details
class LoadDeckDetails extends DecksEvent {
  final int deckId;

  const LoadDeckDetails(this.deckId);

  @override
  List<Object?> get props => [deckId];
}

/// Refresh decks
class RefreshDecks extends DecksEvent {
  const RefreshDecks();
}

/// Load decks that have due cards
class LoadDecksWithDue extends DecksEvent {
  const LoadDecksWithDue();
}

/// Clear deck details
class ClearDeckDetails extends DecksEvent {
  const ClearDeckDetails();
}
