import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/content_library_repository.dart';
import 'bookmark_event.dart';
import 'bookmark_state.dart';

/// BLoC for managing bookmarks
class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final ContentLibraryRepository repository;

  /// Track bookmark status for each content
  final Map<int, bool> _bookmarkStatus = {};

  BookmarkBloc({required this.repository}) : super(const BookmarkInitial()) {
    on<LoadBookmarks>(_onLoadBookmarks);
    on<ToggleBookmark>(_onToggleBookmark);
    on<CheckBookmarkStatus>(_onCheckBookmarkStatus);
    on<RefreshBookmarks>(_onRefreshBookmarks);
  }

  /// Check if a content is bookmarked (from cache)
  bool isBookmarked(int contentId) {
    return _bookmarkStatus[contentId] ?? false;
  }

  Future<void> _onLoadBookmarks(
    LoadBookmarks event,
    Emitter<BookmarkState> emit,
  ) async {
    debugPrint('📚 BookmarkBloc: Loading bookmarks...');
    emit(const BookmarkLoading());

    final result = await repository.getBookmarkedContent();

    result.fold(
      (failure) {
        debugPrint('❌ BookmarkBloc: Failed to load bookmarks: ${failure.message}');
        emit(BookmarkError(failure.message));
      },
      (bookmarks) {
        debugPrint('✅ BookmarkBloc: Loaded ${bookmarks.length} bookmarks');

        // Update cache - all loaded bookmarks are bookmarked
        for (final content in bookmarks) {
          _bookmarkStatus[content.id] = true;
        }

        emit(BookmarksLoaded(
          bookmarks: bookmarks,
          totalCount: bookmarks.length,
          bookmarkStatus: Map.from(_bookmarkStatus),
        ));
      },
    );
  }

  Future<void> _onToggleBookmark(
    ToggleBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    debugPrint('🔖 BookmarkBloc: Toggling bookmark for content ${event.contentId}');

    // Store current state to restore if needed
    final previousState = state;

    emit(BookmarkToggling(event.contentId));

    final result = await repository.toggleBookmark(event.contentId);

    result.fold(
      (failure) {
        debugPrint('❌ BookmarkBloc: Failed to toggle bookmark: ${failure.message}');
        emit(BookmarkError(failure.message));
        // Restore previous state after error
        if (previousState is BookmarksLoaded) {
          emit(previousState);
        }
      },
      (isNowBookmarked) {
        debugPrint('✅ BookmarkBloc: Bookmark toggled, isBookmarked: $isNowBookmarked');

        // Update cache
        _bookmarkStatus[event.contentId] = isNowBookmarked;

        final message = isNowBookmarked
            ? 'تمت إضافة العلامة المرجعية'
            : 'تم إزالة العلامة المرجعية';

        emit(BookmarkToggled(
          contentId: event.contentId,
          isBookmarked: isNowBookmarked,
          message: message,
        ));

        // If we had loaded bookmarks before, reload them
        if (previousState is BookmarksLoaded) {
          add(const LoadBookmarks());
        }
      },
    );
  }

  Future<void> _onCheckBookmarkStatus(
    CheckBookmarkStatus event,
    Emitter<BookmarkState> emit,
  ) async {
    debugPrint('🔍 BookmarkBloc: Checking bookmark status for ${event.contentId}');

    // Check cache first
    if (_bookmarkStatus.containsKey(event.contentId)) {
      debugPrint('📋 BookmarkBloc: Found in cache: ${_bookmarkStatus[event.contentId]}');
      emit(BookmarkStatusChecked(
        contentId: event.contentId,
        isBookmarked: _bookmarkStatus[event.contentId]!,
      ));
      return;
    }

    // If not in cache, check via API
    debugPrint('🌐 BookmarkBloc: Not in cache, checking via API...');
    final result = await repository.isContentBookmarked(event.contentId);

    result.fold(
      (failure) {
        debugPrint('❌ BookmarkBloc: Failed to check bookmark status: ${failure.message}');
        // On error, assume not bookmarked
        _bookmarkStatus[event.contentId] = false;
        emit(BookmarkStatusChecked(
          contentId: event.contentId,
          isBookmarked: false,
        ));
      },
      (isBookmarked) {
        debugPrint('✅ BookmarkBloc: API returned isBookmarked: $isBookmarked');
        // Update cache
        _bookmarkStatus[event.contentId] = isBookmarked;
        emit(BookmarkStatusChecked(
          contentId: event.contentId,
          isBookmarked: isBookmarked,
        ));
      },
    );
  }

  Future<void> _onRefreshBookmarks(
    RefreshBookmarks event,
    Emitter<BookmarkState> emit,
  ) async {
    debugPrint('🔄 BookmarkBloc: Refreshing bookmarks...');
    add(const LoadBookmarks());
  }
}
