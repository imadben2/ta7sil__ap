import 'package:equatable/equatable.dart';
import '../../../domain/entities/quiz_entity.dart';

/// States for QuizListBloc
abstract class QuizListState extends Equatable {
  const QuizListState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class QuizListInitial extends QuizListState {
  const QuizListInitial();
}

/// Loading state
class QuizListLoading extends QuizListState {
  const QuizListLoading();
}

/// Loading more (pagination)
class QuizListLoadingMore extends QuizListState {
  final List<QuizEntity> currentQuizzes;
  final QuizListFilters filters;

  const QuizListLoadingMore({
    required this.currentQuizzes,
    required this.filters,
  });

  @override
  List<Object?> get props => [currentQuizzes, filters];
}

/// Loaded state
class QuizListLoaded extends QuizListState {
  final List<QuizEntity> quizzes;
  final QuizListFilters filters;
  final int currentPage;
  final bool hasMore;
  final bool isRefreshing;

  const QuizListLoaded({
    required this.quizzes,
    required this.filters,
    required this.currentPage,
    this.hasMore = true,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [
    quizzes,
    filters,
    currentPage,
    hasMore,
    isRefreshing,
  ];

  QuizListLoaded copyWith({
    List<QuizEntity>? quizzes,
    QuizListFilters? filters,
    int? currentPage,
    bool? hasMore,
    bool? isRefreshing,
  }) {
    return QuizListLoaded(
      quizzes: quizzes ?? this.quizzes,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// Error state
class QuizListError extends QuizListState {
  final String message;
  final List<QuizEntity>? cachedQuizzes;
  final QuizListFilters? filters;

  const QuizListError({
    required this.message,
    this.cachedQuizzes,
    this.filters,
  });

  @override
  List<Object?> get props => [message, cachedQuizzes, filters];
}

/// Recommendations loaded state
class RecommendationsLoaded extends QuizListState {
  final List<QuizEntity> recommendations;

  const RecommendationsLoaded({required this.recommendations});

  @override
  List<Object?> get props => [recommendations];
}

/// Recommendations error state
class RecommendationsError extends QuizListState {
  final String message;

  const RecommendationsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Grouped quizzes by subject state
class QuizListGroupedLoaded extends QuizListState {
  final Map<SubjectInfo, List<QuizEntity>> groupedQuizzes;
  final List<SubjectInfo> allSubjects;
  final QuizListFilters filters;
  final Set<int> expandedSubjectIds;
  final bool isRefreshing;

  const QuizListGroupedLoaded({
    required this.groupedQuizzes,
    required this.allSubjects,
    required this.filters,
    this.expandedSubjectIds = const {},
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [
    groupedQuizzes,
    allSubjects,
    filters,
    expandedSubjectIds,
    isRefreshing,
  ];

  QuizListGroupedLoaded copyWith({
    Map<SubjectInfo, List<QuizEntity>>? groupedQuizzes,
    List<SubjectInfo>? allSubjects,
    QuizListFilters? filters,
    Set<int>? expandedSubjectIds,
    bool? isRefreshing,
  }) {
    return QuizListGroupedLoaded(
      groupedQuizzes: groupedQuizzes ?? this.groupedQuizzes,
      allSubjects: allSubjects ?? this.allSubjects,
      filters: filters ?? this.filters,
      expandedSubjectIds: expandedSubjectIds ?? this.expandedSubjectIds,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  /// Get total quiz count across all subjects
  int get totalQuizCount {
    return groupedQuizzes.values.fold(0, (sum, list) => sum + list.length);
  }
}

/// Subject quizzes loaded state (flat list for a single subject)
class SubjectQuizzesLoaded extends QuizListState {
  final SubjectInfo subject;
  final List<QuizEntity> quizzes;

  const SubjectQuizzesLoaded({
    required this.subject,
    required this.quizzes,
  });

  @override
  List<Object?> get props => [subject, quizzes];
}

/// Quiz list filters model
class QuizListFilters extends Equatable {
  final bool academicFilter;
  final bool mySubjectsOnly;
  final int? streamId;
  final int? subjectId;
  final int? chapterId;
  final String? quizType;
  final String? difficulty;

  const QuizListFilters({
    this.academicFilter = true,
    this.mySubjectsOnly = false,
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

  QuizListFilters copyWith({
    bool? academicFilter,
    bool? mySubjectsOnly,
    int? streamId,
    int? subjectId,
    int? chapterId,
    String? quizType,
    String? difficulty,
    bool clearStreamId = false,
    bool clearSubjectId = false,
    bool clearChapterId = false,
    bool clearQuizType = false,
    bool clearDifficulty = false,
  }) {
    return QuizListFilters(
      academicFilter: academicFilter ?? this.academicFilter,
      mySubjectsOnly: mySubjectsOnly ?? this.mySubjectsOnly,
      streamId: clearStreamId ? null : (streamId ?? this.streamId),
      subjectId: clearSubjectId ? null : (subjectId ?? this.subjectId),
      chapterId: clearChapterId ? null : (chapterId ?? this.chapterId),
      quizType: clearQuizType ? null : (quizType ?? this.quizType),
      difficulty: clearDifficulty ? null : (difficulty ?? this.difficulty),
    );
  }

  QuizListFilters clear() {
    return const QuizListFilters(academicFilter: true, mySubjectsOnly: false);
  }

  bool get hasActiveFilters {
    return !academicFilter ||
        mySubjectsOnly ||
        streamId != null ||
        subjectId != null ||
        chapterId != null ||
        quizType != null ||
        difficulty != null;
  }
}
