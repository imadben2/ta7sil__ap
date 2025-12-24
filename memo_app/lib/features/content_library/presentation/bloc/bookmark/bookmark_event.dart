import 'package:equatable/equatable.dart';

/// Events for BookmarkBloc
abstract class BookmarkEvent extends Equatable {
  const BookmarkEvent();

  @override
  List<Object?> get props => [];
}

/// Load all bookmarks for the current user
class LoadBookmarks extends BookmarkEvent {
  const LoadBookmarks();
}

/// Toggle bookmark status for a content
class ToggleBookmark extends BookmarkEvent {
  final int contentId;

  const ToggleBookmark(this.contentId);

  @override
  List<Object?> get props => [contentId];
}

/// Check if a content is bookmarked
class CheckBookmarkStatus extends BookmarkEvent {
  final int contentId;

  const CheckBookmarkStatus(this.contentId);

  @override
  List<Object?> get props => [contentId];
}

/// Refresh bookmarks list
class RefreshBookmarks extends BookmarkEvent {
  const RefreshBookmarks();
}
