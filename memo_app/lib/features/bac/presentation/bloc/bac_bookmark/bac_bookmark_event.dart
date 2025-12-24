import 'package:equatable/equatable.dart';

/// Events for BacBookmarkBloc
abstract class BacBookmarkEvent extends Equatable {
  const BacBookmarkEvent();

  @override
  List<Object?> get props => [];
}

/// Load all BAC bookmarks
class LoadBacBookmarks extends BacBookmarkEvent {
  const LoadBacBookmarks();
}

/// Toggle bookmark for a BAC subject
class ToggleBacBookmark extends BacBookmarkEvent {
  final int bacSubjectId;

  const ToggleBacBookmark(this.bacSubjectId);

  @override
  List<Object?> get props => [bacSubjectId];
}

/// Check bookmark status for a specific BAC subject
class CheckBacBookmarkStatus extends BacBookmarkEvent {
  final int bacSubjectId;

  const CheckBacBookmarkStatus(this.bacSubjectId);

  @override
  List<Object?> get props => [bacSubjectId];
}

/// Refresh BAC bookmarks
class RefreshBacBookmarks extends BacBookmarkEvent {
  const RefreshBacBookmarks();
}
