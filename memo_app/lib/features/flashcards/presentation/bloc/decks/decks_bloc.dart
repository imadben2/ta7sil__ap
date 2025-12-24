import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_deck_details_usecase.dart';
import '../../../domain/usecases/get_decks_usecase.dart';
import 'decks_event.dart';
import 'decks_state.dart';

class DecksBloc extends Bloc<DecksEvent, DecksState> {
  final GetDecksUseCase getDecksUseCase;
  final GetDeckDetailsUseCase getDeckDetailsUseCase;

  static const int _perPage = 20;

  DecksBloc({
    required this.getDecksUseCase,
    required this.getDeckDetailsUseCase,
  }) : super(const DecksInitial()) {
    on<LoadDecks>(_onLoadDecks);
    on<LoadMoreDecks>(_onLoadMoreDecks);
    on<LoadDeckDetails>(_onLoadDeckDetails);
    on<RefreshDecks>(_onRefreshDecks);
    on<ClearDeckDetails>(_onClearDeckDetails);
  }

  Future<void> _onLoadDecks(
    LoadDecks event,
    Emitter<DecksState> emit,
  ) async {
    // If refreshing, keep current data visible
    if (!event.refresh) {
      emit(const DecksLoading());
    }

    final result = await getDecksUseCase(GetDecksParams(
      subjectId: event.subjectId,
      chapterId: event.chapterId,
      search: event.search,
      page: 1,
      perPage: _perPage,
    ));

    result.fold(
      (failure) => emit(DecksError(message: failure.message)),
      (decks) => emit(DecksLoaded(
        decks: decks,
        hasMore: decks.length >= _perPage,
        currentPage: 1,
        subjectId: event.subjectId,
        search: event.search,
      )),
    );
  }

  Future<void> _onLoadMoreDecks(
    LoadMoreDecks event,
    Emitter<DecksState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DecksLoaded || !currentState.hasMore || currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;

    final result = await getDecksUseCase(GetDecksParams(
      subjectId: currentState.subjectId,
      search: currentState.search,
      page: nextPage,
      perPage: _perPage,
    ));

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (newDecks) {
        final allDecks = [...currentState.decks, ...newDecks];
        emit(currentState.copyWith(
          decks: allDecks,
          hasMore: newDecks.length >= _perPage,
          currentPage: nextPage,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onLoadDeckDetails(
    LoadDeckDetails event,
    Emitter<DecksState> emit,
  ) async {
    emit(const DeckDetailsLoading());

    final result = await getDeckDetailsUseCase(event.deckId);

    result.fold(
      (failure) => emit(DecksError(message: failure.message)),
      (deck) => emit(DeckDetailsLoaded(deck: deck)),
    );
  }

  Future<void> _onRefreshDecks(
    RefreshDecks event,
    Emitter<DecksState> emit,
  ) async {
    final currentState = state;
    int? subjectId;
    String? search;

    if (currentState is DecksLoaded) {
      subjectId = currentState.subjectId;
      search = currentState.search;
    }

    add(LoadDecks(
      subjectId: subjectId,
      search: search,
      refresh: true,
    ));
  }

  void _onClearDeckDetails(
    ClearDeckDetails event,
    Emitter<DecksState> emit,
  ) {
    emit(const DecksInitial());
  }
}
