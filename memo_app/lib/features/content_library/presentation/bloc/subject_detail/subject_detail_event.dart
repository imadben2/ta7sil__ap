import 'package:equatable/equatable.dart';
import '../../../domain/entities/subject_entity.dart';

/// Events for SubjectDetailBloc
abstract class SubjectDetailEvent extends Equatable {
  const SubjectDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load subject details including chapters
class LoadSubjectDetail extends SubjectDetailEvent {
  final int subjectId;

  const LoadSubjectDetail(this.subjectId);

  @override
  List<Object?> get props => [subjectId];
}

/// Event to load content for a specific chapter and type
class LoadChapterContent extends SubjectDetailEvent {
  final int chapterId;
  final String contentType;

  const LoadChapterContent({
    required this.chapterId,
    required this.contentType,
  });

  @override
  List<Object?> get props => [chapterId, contentType];
}

/// Event to refresh subject details
class RefreshSubjectDetail extends SubjectDetailEvent {
  final int subjectId;

  const RefreshSubjectDetail(this.subjectId);

  @override
  List<Object?> get props => [subjectId];
}

/// Event to refresh content for a specific chapter (forces reload, ignores cache)
class RefreshChapterContent extends SubjectDetailEvent {
  final int chapterId;
  final String contentType;

  const RefreshChapterContent({
    required this.chapterId,
    required this.contentType,
  });

  @override
  List<Object?> get props => [chapterId, contentType];
}

/// Event to load all contents for a subject (without chapters)
class LoadSubjectContents extends SubjectDetailEvent {
  final SubjectEntity subject;

  const LoadSubjectContents(this.subject);

  @override
  List<Object?> get props => [subject];
}
