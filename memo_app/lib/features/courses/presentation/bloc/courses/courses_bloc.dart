import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/course_entity.dart';
import '../../../domain/entities/course_lesson_entity.dart';
import '../../../domain/usecases/check_course_access_usecase.dart';
import '../../../domain/usecases/get_course_details_usecase.dart';
import '../../../domain/usecases/get_course_modules_usecase.dart';
import '../../../domain/usecases/get_courses_usecase.dart';
import '../../../domain/usecases/get_featured_courses_usecase.dart';
import '../../../domain/usecases/get_complete_courses_usecase.dart';
import '../../../domain/usecases/get_course_reviews_usecase.dart';
import 'courses_event.dart';
import 'courses_state.dart';

class CoursesBloc extends Bloc<CoursesEvent, CoursesState> {
  final GetCoursesUseCase getCoursesUseCase;
  final GetFeaturedCoursesUseCase getFeaturedCoursesUseCase;
  final GetCompleteCoursesUseCase getCompleteCoursesUseCase;
  final GetCourseDetailsUseCase getCourseDetailsUseCase;
  final GetCourseModulesUseCase getCourseModulesUseCase;
  final CheckCourseAccessUseCase checkCourseAccessUseCase;
  final GetCourseReviewsUseCase? getCourseReviewsUseCase;

  CoursesBloc({
    required this.getCoursesUseCase,
    required this.getFeaturedCoursesUseCase,
    required this.getCompleteCoursesUseCase,
    required this.getCourseDetailsUseCase,
    required this.getCourseModulesUseCase,
    required this.checkCourseAccessUseCase,
    this.getCourseReviewsUseCase,
  }) : super(CoursesInitial()) {
    on<LoadAllCoursesDataEvent>(_onLoadAllCoursesData);
    on<LoadCoursesEvent>(_onLoadCourses);
    on<LoadFeaturedCoursesEvent>(_onLoadFeaturedCourses);
    on<LoadCourseDetailsEvent>(_onLoadCourseDetails);
    on<LoadCourseModulesEvent>(_onLoadCourseModules);
    on<SearchCoursesEvent>(_onSearchCourses);
    on<CheckCourseAccessEvent>(_onCheckCourseAccess);
    on<ClearCourseCacheEvent>(_onClearCache);
    on<LoadCourseReviewsEvent>(_onLoadCourseReviews);
    on<CheckCanReviewCourseEvent>(_onCheckCanReviewCourse);
    on<LoadCourseProgressEvent>(_onLoadCourseProgress);
    on<LoadLessonDetailsEvent>(_onLoadLessonDetails);
  }

  // ========== Browse & Discover Handlers ==========

  /// OPTIMIZED: Load all courses data in single API call
  Future<void> _onLoadAllCoursesData(
    LoadAllCoursesDataEvent event,
    Emitter<CoursesState> emit,
  ) async {
    emit(CoursesLoading());

    final result = await getCompleteCoursesUseCase(
      GetCompleteCoursesParams(
        search: event.search,
        subjectId: event.subjectId,
        level: event.level,
        isFree: event.isFree,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
        page: event.page,
        perPage: event.perPage,
      ),
    );

    result.fold(
      (failure) => emit(CoursesError(message: failure.message)),
      (data) => emit(
        CoursesLoaded(
          courses: data.courses,
          featuredCourses: data.featuredCourses,
          currentPage: data.currentPage,
          hasMorePages: data.currentPage < data.lastPage,
        ),
      ),
    );
  }

  Future<void> _onLoadCourses(
    LoadCoursesEvent event,
    Emitter<CoursesState> emit,
  ) async {
    // Only show loading if there's no data yet
    if (state is! CoursesLoaded) {
      emit(CoursesLoading());
    }

    final result = await getCoursesUseCase(
      GetCoursesParams(
        search: event.search,
        subjectId: event.subjectId,
        level: event.level,
        academicPhaseId: event.academicPhaseId,
        featured: event.featured,
        isFree: event.isFree,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
        page: event.page,
        perPage: event.perPage,
      ),
    );

    result.fold(
      (failure) => emit(CoursesError(message: failure.message)),
      (courses) {
        final featuredCourses = state is CoursesLoaded
            ? (state as CoursesLoaded).featuredCourses
            : <CourseEntity>[];
        emit(
          CoursesLoaded(
            courses: courses,
            featuredCourses: featuredCourses,
            currentPage: event.page,
            hasMorePages: courses.length >= event.perPage,
          ),
        );
      },
    );
  }

  Future<void> _onLoadFeaturedCourses(
    LoadFeaturedCoursesEvent event,
    Emitter<CoursesState> emit,
  ) async {
    // Don't show loading if courses are already loaded
    if (state is! CoursesLoaded) {
      emit(CoursesLoading());
    }

    final result = await getFeaturedCoursesUseCase(limit: event.limit);

    result.fold(
      (failure) => emit(CoursesError(message: failure.message)),
      (featuredCourses) {
        if (state is CoursesLoaded) {
          // Update existing state with featured courses
          final currentState = state as CoursesLoaded;
          emit(currentState.copyWith(featuredCourses: featuredCourses));
        } else {
          // First load - emit with empty courses list
          emit(CoursesLoaded(
            courses: const [],
            featuredCourses: featuredCourses,
          ));
        }
      },
    );
  }

  Future<void> _onLoadCourseDetails(
    LoadCourseDetailsEvent event,
    Emitter<CoursesState> emit,
  ) async {
    // Don't emit loading state - let the UI handle loading via its own state
    final result = await getCourseDetailsUseCase(event.courseId);

    result.fold(
      (failure) => emit(CoursesError(message: failure.message)),
      (course) => emit(CourseDetailsLoaded(course: course)),
    );
  }

  Future<void> _onLoadCourseModules(
    LoadCourseModulesEvent event,
    Emitter<CoursesState> emit,
  ) async {
    // Don't emit loading state - let the UI handle loading via its own state
    final result = await getCourseModulesUseCase(event.courseId);

    result.fold(
      (failure) => emit(CoursesError(message: failure.message)),
      (modules) => emit(CourseModulesLoaded(modules: modules)),
    );
  }

  Future<void> _onSearchCourses(
    SearchCoursesEvent event,
    Emitter<CoursesState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const CoursesError(message: 'يرجى إدخال كلمة البحث'));
      return;
    }

    emit(CoursesLoading());

    final result = await getCoursesUseCase(
      GetCoursesParams(search: event.query, page: 1, perPage: 50),
    );

    result.fold(
      (failure) => emit(CoursesError(message: failure.message)),
      (courses) => emit(
        CoursesSearchResultsLoaded(courses: courses, query: event.query),
      ),
    );
  }

  // ========== Access Management Handlers ==========

  Future<void> _onCheckCourseAccess(
    CheckCourseAccessEvent event,
    Emitter<CoursesState> emit,
  ) async {
    // Don't emit loading state - let the UI handle loading via its own state
    final result = await checkCourseAccessUseCase(event.courseId);

    result.fold(
      (failure) {
        // Don't emit error for access check - just emit no access
        emit(CourseAccessChecked(hasAccess: false, courseId: event.courseId));
      },
      (hasAccess) => emit(
        CourseAccessChecked(hasAccess: hasAccess, courseId: event.courseId),
      ),
    );
  }

  // ========== Cache Management Handlers ==========

  Future<void> _onClearCache(
    ClearCourseCacheEvent event,
    Emitter<CoursesState> emit,
  ) async {
    emit(const CoursesActionInProgress(message: 'جاري مسح الذاكرة المؤقتة...'));

    // Call repository clearCache
    // For now, just emit success
    await Future.delayed(const Duration(milliseconds: 500));

    emit(const CourseCacheCleared());
  }

  // ========== Reviews Handlers ==========

  Future<void> _onLoadCourseReviews(
    LoadCourseReviewsEvent event,
    Emitter<CoursesState> emit,
  ) async {
    if (getCourseReviewsUseCase == null) {
      // If use case not available, emit empty reviews
      emit(const CourseReviewsLoaded(reviews: []));
      return;
    }

    // Don't emit loading state - let the UI handle loading
    final result = await getCourseReviewsUseCase!(
      GetCourseReviewsParams(
        courseId: event.courseId,
        rating: event.rating,
        page: event.page,
        perPage: event.perPage,
      ),
    );

    result.fold(
      (failure) => emit(const CourseReviewsLoaded(reviews: [])),
      (reviews) => emit(
        CourseReviewsLoaded(
          reviews: reviews,
          currentPage: event.page,
          hasMorePages: reviews.length >= event.perPage,
        ),
      ),
    );
  }

  Future<void> _onCheckCanReviewCourse(
    CheckCanReviewCourseEvent event,
    Emitter<CoursesState> emit,
  ) async {
    // For now, emit default value - can be implemented later
    // Don't emit loading state
    emit(CanReviewCourseChecked(canReview: false, courseId: event.courseId));
  }

  Future<void> _onLoadCourseProgress(
    LoadCourseProgressEvent event,
    Emitter<CoursesState> emit,
  ) async {
    // For now, don't emit anything - progress will be handled separately
    // This prevents overwriting other states
  }

  // ========== Lesson Details Handler ==========

  Future<void> _onLoadLessonDetails(
    LoadLessonDetailsEvent event,
    Emitter<CoursesState> emit,
  ) async {
    // Create a mock lesson for now - in production, this should call a dedicated API
    // The lesson data is typically loaded via LoadCourseModulesEvent and passed to the page
    final mockLesson = CourseLessonEntity(
      id: event.lessonId,
      courseModuleId: 1,
      titleAr: 'جاري تحميل الدرس...',
      videoDurationSeconds: 0,
      order: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    emit(LessonDetailsLoaded(lesson: mockLesson));
  }
}
