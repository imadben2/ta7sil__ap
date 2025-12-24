import 'package:equatable/equatable.dart';
import '../../../domain/entities/content_entity.dart';

/// States for BookmarkBloc
abstract class BookmarkState extends Equatable {
  const BookmarkState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BookmarkInitial extends BookmarkState {
  const BookmarkInitial();
}

/// Loading bookmarks list
class BookmarkLoading extends BookmarkState {
  const BookmarkLoading();
}

/// Bookmarks loaded successfully
class BookmarksLoaded extends BookmarkState {
  final List<ContentEntity> bookmarks;
  final int totalCount;
  final Map<int, bool> bookmarkStatus;

  const BookmarksLoaded({
    required this.bookmarks,
    required this.totalCount,
    this.bookmarkStatus = const {},
  });

  @override
  List<Object?> get props => [bookmarks, totalCount, bookmarkStatus];

  BookmarksLoaded copyWith({
    List<ContentEntity>? bookmarks,
    int? totalCount,
    Map<int, bool>? bookmarkStatus,
  }) {
    return BookmarksLoaded(
      bookmarks: bookmarks ?? this.bookmarks,
      totalCount: totalCount ?? this.totalCount,
      bookmarkStatus: bookmarkStatus ?? this.bookmarkStatus,
    );
  }
}

/// Bookmark toggled (add/remove)
class BookmarkToggled extends BookmarkState {
  final int contentId;
  final bool isBookmarked;
  final String message;

  const BookmarkToggled({
    required this.contentId,
    required this.isBookmarked,
    required this.message,
  });

  @override
  List<Object?> get props => [contentId, isBookmarked, message];
}

/// Toggling bookmark in progress
class BookmarkToggling extends BookmarkState {
  final int contentId;

  const BookmarkToggling(this.contentId);

  @override
  List<Object?> get props => [contentId];
}

/// Bookmark status checked
class BookmarkStatusChecked extends BookmarkState {
  final int contentId;
  final bool isBookmarked;

  const BookmarkStatusChecked({
    required this.contentId,
    required this.isBookmarked,
  });

  @override
  List<Object?> get props => [contentId, isBookmarked];
}

/// Error state
class BookmarkError extends BookmarkState {
  final String message;

  const BookmarkError(this.message);

  @override
  List<Object?> get props => [message];
}
