import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../../../domain/usecases/get_quizzes_usecase.dart';
import '../../../domain/usecases/get_recommendations_usecase.dart';
import '../../../../planner/domain/usecases/get_centralized_subjects.dart';
import '../../../../auth/domain/repositories/auth_repository.dart';
import 'quiz_list_event.dart';
import 'quiz_list_state.dart';

/// BLoC for managing quiz list
class QuizListBloc extends Bloc<QuizListEvent, QuizListState> {
  final GetQuizzesUseCase getQuizzesUseCase;
  final GetRecommendationsUseCase getRecommendationsUseCase;
  final GetCentralizedSubjects getCentralizedSubjectsUseCase;
  final AuthRepository authRepository;

  QuizListBloc({
    required this.getQuizzesUseCase,
    required this.getRecommendationsUseCase,
    required this.getCentralizedSubjectsUseCase,
    required this.authRepository,
  }) : super(const QuizListInitial()) {
    on<LoadQuizzes>(_onLoadQuizzes);
    on<LoadMoreQuizzes>(_onLoadMoreQuizzes);
    on<RefreshQuizzes>(_onRefreshQuizzes);
    on<UpdateFilters>(_onUpdateFilters);
    on<ClearFilters>(_onClearFilters);
    on<LoadRecommendations>(_onLoadRecommendations);
    on<ToggleSubjectExpansion>(_onToggleSubjectExpansion);
    on<ExpandAllSubjects>(_onExpandAllSubjects);
    on<CollapseAllSubjects>(_onCollapseAllSubjects);
    on<LoadSubjectQuizzes>(_onLoadSubjectQuizzes);
  }

  /// Load quizzes with filters and group by subject
  Future<void> _onLoadQuizzes(
    LoadQuizzes event,
    Emitter<QuizListState> emit,
  ) async {
    // Show cached data first while loading, if available
    final hasCachedData = state is QuizListGroupedLoaded;

    if (!event.isRefresh && !hasCachedData) {
      emit(const QuizListLoading());
    } else if (event.isRefresh && hasCachedData) {
      final currentState = state as QuizListGroupedLoaded;
      emit(currentState.copyWith(isRefreshing: true));
    }

    // Get user's academic stream ID if not explicitly provided
    int? streamId = event.streamId;
    if (streamId == null && event.academicFilter) {
      final userResult = await authRepository.getCachedUser();
      userResult.fold(
        (failure) => null, // Keep streamId as null on failure
        (user) {
          streamId = user.academicProfile?.streamId;
        },
      );
    }

    // Fetch subjects first (usually cached and fast)
    final subjectsResult = await getCentralizedSubjectsUseCase(
      const GetCentralizedSubjectsParams(activeOnly: true),
    );

    // Convert centralized subjects to SubjectInfo early
    final allSubjects = subjectsResult.fold(
      (failure) => <SubjectInfo>[],
      (subjects) => subjects
          .map((s) => SubjectInfo(
                id: s.id,
                nameAr: s.nameAr,
                color: s.color,
                icon: s.icon,
              ))
          .toList(),
    );

    // Fetch quizzes (can be slower)
    final quizzesResult = await getQuizzesUseCase(
      GetQuizzesParams(
        academicFilter: event.academicFilter,
        mySubjectsOnly: event.mySubjectsOnly,
        streamId: streamId,
        subjectId: event.subjectId,
        chapterId: event.chapterId,
        quizType: event.quizType,
        difficulty: event.difficulty,
        page: event.page,
        perPage: 100, // Fetch more to group by subject
      ),
    );

    quizzesResult.fold(
      (failure) {
        // Try to show cached data if available
        if (hasCachedData) {
          final currentState = state as QuizListGroupedLoaded;
          emit(
            QuizListError(
              message: failure.message,
              cachedQuizzes: currentState.groupedQuizzes.values
                  .expand((list) => list)
                  .toList(),
              filters: currentState.filters,
            ),
          );
        } else {
          emit(QuizListError(message: failure.message));
        }
      },
      (quizzes) {
        final filters = QuizListFilters(
          academicFilter: event.academicFilter,
          mySubjectsOnly: event.mySubjectsOnly,
          streamId: streamId,
          subjectId: event.subjectId,
          chapterId: event.chapterId,
          quizType: event.quizType,
          difficulty: event.difficulty,
        );

        // Group quizzes by subject (optimized)
        final grouped = _groupQuizzesBySubject(quizzes, allSubjects);

        // Don't auto-expand subjects - let user choose (faster rendering)
        Set<int> initialExpanded = {};

        emit(
          QuizListGroupedLoaded(
            groupedQuizzes: grouped,
            allSubjects: allSubjects,
            filters: filters,
            expandedSubjectIds: initialExpanded,
            isRefreshing: false,
          ),
        );
      },
    );
  }

  /// Group quizzes by subject
  Map<SubjectInfo, List<QuizEntity>> _groupQuizzesBySubject(
    List<QuizEntity> quizzes,
    List<SubjectInfo> allSubjects,
  ) {
    // Use subject ID as key for reliable matching
    final Map<int, SubjectInfo> subjectById = {};
    final Map<int, List<QuizEntity>> groupedById = {};

    // Initialize all subjects with empty lists
    for (final subject in allSubjects) {
      subjectById[subject.id] = subject;
      groupedById[subject.id] = [];
    }

    // Add quizzes to their subject groups by ID
    for (final quiz in quizzes) {
      if (quiz.subject != null) {
        final subjectId = quiz.subject!.id;
        if (groupedById.containsKey(subjectId)) {
          groupedById[subjectId]!.add(quiz);
        } else {
          // Subject not in allSubjects, add it
          subjectById[subjectId] = quiz.subject!;
          groupedById[subjectId] = [quiz];
        }
      }
    }

    // Convert back to Map<SubjectInfo, List<QuizEntity>>
    final Map<SubjectInfo, List<QuizEntity>> grouped = {};
    for (final entry in groupedById.entries) {
      final subject = subjectById[entry.key];
      if (subject != null) {
        grouped[subject] = entry.value;
      }
    }

    // Sort subjects: subjects with quizzes first, then by name
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        // First by quiz count (descending)
        final countCompare = b.value.length.compareTo(a.value.length);
        if (countCompare != 0) return countCompare;
        // Then alphabetically by name
        return a.key.nameAr.compareTo(b.key.nameAr);
      });

    return Map.fromEntries(sortedEntries);
  }

  /// Load more quizzes (pagination)
  Future<void> _onLoadMoreQuizzes(
    LoadMoreQuizzes event,
    Emitter<QuizListState> emit,
  ) async {
    if (state is! QuizListLoaded) return;

    final currentState = state as QuizListLoaded;
    if (!currentState.hasMore) return;

    // Show loading more state
    emit(
      QuizListLoadingMore(
        currentQuizzes: currentState.quizzes,
        filters: currentState.filters,
      ),
    );

    final nextPage = currentState.currentPage + 1;

    // Execute use case
    final result = await getQuizzesUseCase(
      GetQuizzesParams(
        academicFilter: currentState.filters.academicFilter,
        mySubjectsOnly: currentState.filters.mySubjectsOnly,
        streamId: currentState.filters.streamId,
        subjectId: currentState.filters.subjectId,
        chapterId: currentState.filters.chapterId,
        quizType: currentState.filters.quizType,
        difficulty: currentState.filters.difficulty,
        page: nextPage,
      ),
    );

    result.fold(
      (failure) {
        // Return to loaded state with error
        emit(currentState.copyWith()); // Keep current state
        emit(
          QuizListError(
            message: failure.message,
            cachedQuizzes: currentState.quizzes,
            filters: currentState.filters,
          ),
        );
      },
      (newQuizzes) {
        // Append new quizzes
        final allQuizzes = [...currentState.quizzes, ...newQuizzes];

        emit(
          QuizListLoaded(
            quizzes: allQuizzes,
            filters: currentState.filters,
            currentPage: nextPage,
            hasMore: newQuizzes.length >= 15,
          ),
        );
      },
    );
  }

  /// Refresh quizzes (pull to refresh)
  Future<void> _onRefreshQuizzes(
    RefreshQuizzes event,
    Emitter<QuizListState> emit,
  ) async {
    if (state is! QuizListGroupedLoaded) {
      // If not loaded yet, do initial load
      add(const LoadQuizzes());
      return;
    }

    final currentState = state as QuizListGroupedLoaded;

    // Reload with current filters
    add(
      LoadQuizzes(
        academicFilter: currentState.filters.academicFilter,
        mySubjectsOnly: currentState.filters.mySubjectsOnly,
        streamId: currentState.filters.streamId,
        subjectId: currentState.filters.subjectId,
        chapterId: currentState.filters.chapterId,
        quizType: currentState.filters.quizType,
        difficulty: currentState.filters.difficulty,
        page: 1,
        isRefresh: true,
      ),
    );
  }

  /// Update filters
  Future<void> _onUpdateFilters(
    UpdateFilters event,
    Emitter<QuizListState> emit,
  ) async {
    // Get current filters or create new
    QuizListFilters currentFilters;
    if (state is QuizListLoaded) {
      currentFilters = (state as QuizListLoaded).filters;
    } else if (state is QuizListGroupedLoaded) {
      currentFilters = (state as QuizListGroupedLoaded).filters;
    } else {
      currentFilters = const QuizListFilters();
    }

    // Update filters
    final newFilters = currentFilters.copyWith(
      academicFilter: event.academicFilter,
      mySubjectsOnly: event.mySubjectsOnly,
      streamId: event.streamId,
      subjectId: event.subjectId,
      chapterId: event.chapterId,
      quizType: event.quizType,
      difficulty: event.difficulty,
    );

    // Reload quizzes with new filters
    add(
      LoadQuizzes(
        academicFilter: newFilters.academicFilter,
        mySubjectsOnly: newFilters.mySubjectsOnly,
        streamId: newFilters.streamId,
        subjectId: newFilters.subjectId,
        chapterId: newFilters.chapterId,
        quizType: newFilters.quizType,
        difficulty: newFilters.difficulty,
        page: 1,
      ),
    );
  }

  /// Clear all filters
  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<QuizListState> emit,
  ) async {
    // Reload with default filters
    add(
      const LoadQuizzes(academicFilter: true, mySubjectsOnly: false, page: 1),
    );
  }

  /// Load recommendations
  Future<void> _onLoadRecommendations(
    LoadRecommendations event,
    Emitter<QuizListState> emit,
  ) async {
    emit(const QuizListLoading());

    final result = await getRecommendationsUseCase(limit: event.limit);

    result.fold(
      (failure) {
        emit(RecommendationsError(message: failure.message));
      },
      (recommendations) {
        emit(RecommendationsLoaded(recommendations: recommendations));
      },
    );
  }

  /// Toggle subject section expansion
  void _onToggleSubjectExpansion(
    ToggleSubjectExpansion event,
    Emitter<QuizListState> emit,
  ) {
    if (state is QuizListGroupedLoaded) {
      final current = state as QuizListGroupedLoaded;
      final newExpanded = Set<int>.from(current.expandedSubjectIds);

      if (newExpanded.contains(event.subjectId)) {
        newExpanded.remove(event.subjectId);
      } else {
        newExpanded.add(event.subjectId);
      }

      emit(current.copyWith(expandedSubjectIds: newExpanded));
    }
  }

  /// Expand all subject sections
  void _onExpandAllSubjects(
    ExpandAllSubjects event,
    Emitter<QuizListState> emit,
  ) {
    if (state is QuizListGroupedLoaded) {
      final current = state as QuizListGroupedLoaded;
      final allIds = current.allSubjects.map((s) => s.id).toSet();
      emit(current.copyWith(expandedSubjectIds: allIds));
    }
  }

  /// Collapse all subject sections
  void _onCollapseAllSubjects(
    CollapseAllSubjects event,
    Emitter<QuizListState> emit,
  ) {
    if (state is QuizListGroupedLoaded) {
      final current = state as QuizListGroupedLoaded;
      emit(current.copyWith(expandedSubjectIds: {}));
    }
  }

  /// Load quizzes for a specific subject (flat list, not grouped)
  Future<void> _onLoadSubjectQuizzes(
    LoadSubjectQuizzes event,
    Emitter<QuizListState> emit,
  ) async {
    emit(const QuizListLoading());

    final result = await getQuizzesUseCase(
      GetQuizzesParams(
        subjectId: event.subjectId,
        perPage: 100,
      ),
    );

    result.fold(
      (failure) {
        emit(QuizListError(message: failure.message));
      },
      (quizzes) {
        final subject = SubjectInfo(
          id: event.subjectId,
          nameAr: event.subjectName,
          color: event.subjectColor,
          icon: event.subjectIcon,
        );

        emit(SubjectQuizzesLoaded(
          subject: subject,
          quizzes: quizzes,
        ));
      },
    );
  }
}
