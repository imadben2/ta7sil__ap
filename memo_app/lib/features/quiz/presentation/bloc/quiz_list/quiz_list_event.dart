import 'package:equatable/equatable.dart';

/// Events for QuizListBloc
abstract class QuizListEvent extends Equatable {
  const QuizListEvent();

  @override
  List<Object?> get props => [];
}

/// Load quizzes with filters
class LoadQuizzes extends QuizListEvent {
  final bool academicFilter;
  final bool mySubjectsOnly;
  final int? streamId;
  final int? subjectId;
  final int? chapterId;
  final String? quizType;
  final String? difficulty;
  final int page;
  final bool isRefresh;

  const LoadQuizzes({
    this.academicFilter = true,
    this.mySubjectsOnly = false,
    this.streamId,
    this.subjectId,
    this.chapterId,
    this.quizType,
    this.difficulty,
    this.page = 1,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [
    academicFilter,
    mySubjectsOnly,
    streamId,
    subjectId,
    chapterId,
    quizType,
    difficulty,
    page,
    isRefresh,
  ];
}

/// Load more quizzes (pagination)
class LoadMoreQuizzes extends QuizListEvent {
  const LoadMoreQuizzes();
}

/// Refresh quizzes (pull to refresh)
class RefreshQuizzes extends QuizListEvent {
  const RefreshQuizzes();
}

/// Update filters
class UpdateFilters extends QuizListEvent {
  final bool? academicFilter;
  final bool? mySubjectsOnly;
  final int? streamId;
  final int? subjectId;
  final int? chapterId;
  final String? quizType;
  final String? difficulty;

  const UpdateFilters({
    this.academicFilter,
    this.mySubjectsOnly,
    this.streamId,
    this.subjectId,
    this.chapterId,
    this.quizType,
    this.difficulty,
  });

  @override
  List<Object?> get props => [
    academicFilter,
    mySubjectsOnly,
    streamId,
    subjectId,
    chapterId,
    quizType,
    difficulty,
  ];
}

/// Clear all filters
class ClearFilters extends QuizListEvent {
  const ClearFilters();
}

/// Load recommended quizzes
class LoadRecommendations extends QuizListEvent {
  final int limit;

  const LoadRecommendations({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Toggle subject section expansion
class ToggleSubjectExpansion extends QuizListEvent {
  final int subjectId;

  const ToggleSubjectExpansion(this.subjectId);

  @override
  List<Object?> get props => [subjectId];
}

/// Expand all subject sections
class ExpandAllSubjects extends QuizListEvent {
  const ExpandAllSubjects();
}

/// Collapse all subject sections
class CollapseAllSubjects extends QuizListEvent {
  const CollapseAllSubjects();
}

/// Load quizzes for a specific subject (returns flat list, not grouped)
class LoadSubjectQuizzes extends QuizListEvent {
  final int subjectId;
  final String subjectName;
  final String? subjectColor;
  final String? subjectIcon;

  const LoadSubjectQuizzes({
    required this.subjectId,
    required this.subjectName,
    this.subjectColor,
    this.subjectIcon,
  });

  @override
  List<Object?> get props => [subjectId, subjectName, subjectColor, subjectIcon];
}
