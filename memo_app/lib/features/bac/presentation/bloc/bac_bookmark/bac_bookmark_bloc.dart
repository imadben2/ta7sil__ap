import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/bac_remote_datasource.dart';
import 'bac_bookmark_event.dart';
import 'bac_bookmark_state.dart';

/// BLoC for managing BAC subject bookmarks
class BacBookmarkBloc extends Bloc<BacBookmarkEvent, BacBookmarkState> {
  final BacRemoteDataSource dataSource;

  /// Track bookmark status for each BAC subject
  final Map<int, bool> _bookmarkStatus = {};

  BacBookmarkBloc({required this.dataSource}) : super(const BacBookmarkInitial()) {
    on<LoadBacBookmarks>(_onLoadBacBookmarks);
    on<ToggleBacBookmark>(_onToggleBacBookmark);
    on<CheckBacBookmarkStatus>(_onCheckBacBookmarkStatus);
    on<RefreshBacBookmarks>(_onRefreshBacBookmarks);
  }

  /// Check if a BAC subject is bookmarked (from cache)
  bool isBookmarked(int bacSubjectId) {
    return _bookmarkStatus[bacSubjectId] ?? false;
  }

  Future<void> _onLoadBacBookmarks(
    LoadBacBookmarks event,
    Emitter<BacBookmarkState> emit,
  ) async {
    debugPrint('📚 BacBookmarkBloc: Loading BAC bookmarks...');
    emit(const BacBookmarkLoading());

    try {
      final bookmarks = await dataSource.getBookmarkedBacSubjects();

      // Update cache - all loaded bookmarks are bookmarked
      for (final subject in bookmarks) {
        _bookmarkStatus[subject.id] = true;
      }

      debugPrint('✅ BacBookmarkBloc: Loaded ${bookmarks.length} BAC bookmarks');
      emit(BacBookmarksLoaded(
        bookmarks: bookmarks,
        totalCount: bookmarks.length,
        bookmarkStatus: Map.from(_bookmarkStatus),
      ));
    } catch (e) {
      debugPrint('❌ BacBookmarkBloc: Failed to load BAC bookmarks: $e');
      emit(BacBookmarkError(e.toString()));
    }
  }

  Future<void> _onToggleBacBookmark(
    ToggleBacBookmark event,
    Emitter<BacBookmarkState> emit,
  ) async {
    debugPrint('🔖 BacBookmarkBloc: Toggling BAC bookmark for subject ${event.bacSubjectId}');

    // Store current state to restore if needed
    final previousState = state;

    emit(BacBookmarkToggling(event.bacSubjectId));

    try {
      final isNowBookmarked = await dataSource.toggleBacBookmark(event.bacSubjectId);

      debugPrint('✅ BacBookmarkBloc: BAC bookmark toggled, isBookmarked: $isNowBookmarked');

      // Update cache
      _bookmarkStatus[event.bacSubjectId] = isNowBookmarked;

      final message = isNowBookmarked
          ? 'تمت إضافة العلامة المرجعية'
          : 'تم إزالة العلامة المرجعية';

      emit(BacBookmarkToggled(
        bacSubjectId: event.bacSubjectId,
        isBookmarked: isNowBookmarked,
        message: message,
      ));

      // If we had loaded bookmarks before, reload them
      if (previousState is BacBookmarksLoaded) {
        add(const LoadBacBookmarks());
      }
    } catch (e) {
      debugPrint('❌ BacBookmarkBloc: Failed to toggle BAC bookmark: $e');
      emit(BacBookmarkError(e.toString()));
      // Restore previous state after error
      if (previousState is BacBookmarksLoaded) {
        emit(previousState);
      }
    }
  }

  Future<void> _onCheckBacBookmarkStatus(
    CheckBacBookmarkStatus event,
    Emitter<BacBookmarkState> emit,
  ) async {
    debugPrint('🔍 BacBookmarkBloc: Checking BAC bookmark status for ${event.bacSubjectId}');

    // Check cache first
    if (_bookmarkStatus.containsKey(event.bacSubjectId)) {
      debugPrint('📋 BacBookmarkBloc: Found in cache: ${_bookmarkStatus[event.bacSubjectId]}');
      emit(BacBookmarkStatusChecked(
        bacSubjectId: event.bacSubjectId,
        isBookmarked: _bookmarkStatus[event.bacSubjectId]!,
      ));
      return;
    }

    // If not in cache, check via API
    debugPrint('🌐 BacBookmarkBloc: Not in cache, checking via API...');
    try {
      final isBookmarked = await dataSource.isBacSubjectBookmarked(event.bacSubjectId);

      debugPrint('✅ BacBookmarkBloc: API returned isBookmarked: $isBookmarked');
      // Update cache
      _bookmarkStatus[event.bacSubjectId] = isBookmarked;
      emit(BacBookmarkStatusChecked(
        bacSubjectId: event.bacSubjectId,
        isBookmarked: isBookmarked,
      ));
    } catch (e) {
      debugPrint('❌ BacBookmarkBloc: Failed to check BAC bookmark status: $e');
      // On error, assume not bookmarked
      _bookmarkStatus[event.bacSubjectId] = false;
      emit(BacBookmarkStatusChecked(
        bacSubjectId: event.bacSubjectId,
        isBookmarked: false,
      ));
    }
  }

  Future<void> _onRefreshBacBookmarks(
    RefreshBacBookmarks event,
    Emitter<BacBookmarkState> emit,
  ) async {
    debugPrint('🔄 BacBookmarkBloc: Refreshing BAC bookmarks...');
    add(const LoadBacBookmarks());
  }
}
