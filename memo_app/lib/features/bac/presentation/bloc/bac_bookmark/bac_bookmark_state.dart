import 'package:equatable/equatable.dart';
import '../../../domain/entities/bac_subject_entity.dart';

/// States for BacBookmarkBloc
abstract class BacBookmarkState extends Equatable {
  const BacBookmarkState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BacBookmarkInitial extends BacBookmarkState {
  const BacBookmarkInitial();
}

/// Loading BAC bookmarks list
class BacBookmarkLoading extends BacBookmarkState {
  const BacBookmarkLoading();
}

/// BAC bookmarks loaded successfully
class BacBookmarksLoaded extends BacBookmarkState {
  final List<BacSubjectEntity> bookmarks;
  final int totalCount;
  final Map<int, bool> bookmarkStatus;

  const BacBookmarksLoaded({
    required this.bookmarks,
    required this.totalCount,
    this.bookmarkStatus = const {},
  });

  @override
  List<Object?> get props => [bookmarks, totalCount, bookmarkStatus];

  BacBookmarksLoaded copyWith({
    List<BacSubjectEntity>? bookmarks,
    int? totalCount,
    Map<int, bool>? bookmarkStatus,
  }) {
    return BacBookmarksLoaded(
      bookmarks: bookmarks ?? this.bookmarks,
      totalCount: totalCount ?? this.totalCount,
      bookmarkStatus: bookmarkStatus ?? this.bookmarkStatus,
    );
  }
}

/// BAC bookmark toggled (add/remove)
class BacBookmarkToggled extends BacBookmarkState {
  final int bacSubjectId;
  final bool isBookmarked;
  final String message;

  const BacBookmarkToggled({
    required this.bacSubjectId,
    required this.isBookmarked,
    required this.message,
  });

  @override
  List<Object?> get props => [bacSubjectId, isBookmarked, message];
}

/// Toggling BAC bookmark in progress
class BacBookmarkToggling extends BacBookmarkState {
  final int bacSubjectId;

  const BacBookmarkToggling(this.bacSubjectId);

  @override
  List<Object?> get props => [bacSubjectId];
}

/// BAC bookmark status checked
class BacBookmarkStatusChecked extends BacBookmarkState {
  final int bacSubjectId;
  final bool isBookmarked;

  const BacBookmarkStatusChecked({
    required this.bacSubjectId,
    required this.isBookmarked,
  });

  @override
  List<Object?> get props => [bacSubjectId, isBookmarked];
}

/// Error state
class BacBookmarkError extends BacBookmarkState {
  final String message;

  const BacBookmarkError(this.message);

  @override
  List<Object?> get props => [message];
}
