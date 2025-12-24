import 'package:equatable/equatable.dart';
import '../../../domain/entities/subject_entity.dart';
import '../../../domain/entities/chapter_entity.dart';
import '../../../domain/entities/content_entity.dart';

/// States for SubjectDetailBloc
abstract class SubjectDetailState extends Equatable {
  const SubjectDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SubjectDetailInitial extends SubjectDetailState {
  const SubjectDetailInitial();
}

/// Loading state
class SubjectDetailLoading extends SubjectDetailState {
  const SubjectDetailLoading();
}

/// Loaded state with subject and chapters
class SubjectDetailLoaded extends SubjectDetailState {
  final SubjectEntity subject;
  final List<ChapterEntity> chapters;
  final Map<int, Map<String, List<ContentEntity>>> chapterContents;

  const SubjectDetailLoaded({
    required this.subject,
    required this.chapters,
    this.chapterContents = const {},
  });

  @override
  List<Object?> get props => [subject, chapters, chapterContents];

  SubjectDetailLoaded copyWith({
    SubjectEntity? subject,
    List<ChapterEntity>? chapters,
    Map<int, Map<String, List<ContentEntity>>>? chapterContents,
  }) {
    return SubjectDetailLoaded(
      subject: subject ?? this.subject,
      chapters: chapters ?? this.chapters,
      chapterContents: chapterContents ?? this.chapterContents,
    );
  }

  /// Get content for a specific chapter and type
  List<ContentEntity> getContent(int chapterId, String contentType) {
    return chapterContents[chapterId]?[contentType] ?? [];
  }

  /// Check if content is loaded for a chapter and type
  bool isContentLoaded(int chapterId, String contentType) {
    return chapterContents[chapterId]?.containsKey(contentType) ?? false;
  }
}

/// Loading content for a specific chapter
class SubjectDetailLoadingContent extends SubjectDetailState {
  final SubjectEntity subject;
  final List<ChapterEntity> chapters;
  final Map<int, Map<String, List<ContentEntity>>> chapterContents;
  final int loadingChapterId;
  final String loadingContentType;

  const SubjectDetailLoadingContent({
    required this.subject,
    required this.chapters,
    required this.chapterContents,
    required this.loadingChapterId,
    required this.loadingContentType,
  });

  @override
  List<Object?> get props => [
    subject,
    chapters,
    chapterContents,
    loadingChapterId,
    loadingContentType,
  ];
}

/// Error state
class SubjectDetailError extends SubjectDetailState {
  final String message;

  const SubjectDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when contents are loaded directly by subject (without chapters)
class SubjectContentsLoaded extends SubjectDetailState {
  final SubjectEntity subject;
  final List<ContentEntity> allContents;

  const SubjectContentsLoaded({
    required this.subject,
    required this.allContents,
  });

  @override
  List<Object?> get props => [subject, allContents];

  /// Get lessons
  List<ContentEntity> get lessons =>
      allContents.where((c) => c.type == ContentType.lesson).toList();

  /// Get summaries
  List<ContentEntity> get summaries =>
      allContents.where((c) => c.type == ContentType.summary).toList();

  /// Get exercises
  List<ContentEntity> get exercises =>
      allContents.where((c) => c.type == ContentType.exercise).toList();

  /// Get tests
  List<ContentEntity> get tests =>
      allContents.where((c) => c.type == ContentType.test).toList();
}
