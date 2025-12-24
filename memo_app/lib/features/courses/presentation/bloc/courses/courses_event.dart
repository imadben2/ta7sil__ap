import 'package:equatable/equatable.dart';

abstract class CoursesEvent extends Equatable {
  const CoursesEvent();

  @override
  List<Object?> get props => [];
}

// ========== Browse & Discover ==========

/// Load all courses with optional filters
class LoadCoursesEvent extends CoursesEvent {
  final String? search;
  final int? subjectId;
  final String? level;
  final bool? featured;
  final bool? isFree;
  final String sortBy;
  final String sortOrder;
  final int page;
  final int perPage;

  const LoadCoursesEvent({
    this.search,
    this.subjectId,
    this.level,
    this.featured,
    this.isFree,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
    this.page = 1,
    this.perPage = 20,
  });

  @override
  List<Object?> get props => [
    search,
    subjectId,
    level,
    featured,
    isFree,
    sortBy,
    sortOrder,
    page,
    perPage,
  ];
}

/// Load featured courses
class LoadFeaturedCoursesEvent extends CoursesEvent {
  final int limit;

  const LoadFeaturedCoursesEvent({this.limit = 5});

  @override
  List<Object?> get props => [limit];
}

/// Load course details by ID
class LoadCourseDetailsEvent extends CoursesEvent {
  final int courseId;

  const LoadCourseDetailsEvent({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

/// Load course curriculum (modules and lessons)
class LoadCourseModulesEvent extends CoursesEvent {
  final int courseId;

  const LoadCourseModulesEvent({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

/// Search courses
class SearchCoursesEvent extends CoursesEvent {
  final String query;

  const SearchCoursesEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

// ========== Access Management ==========

/// Check course access
class CheckCourseAccessEvent extends CoursesEvent {
  final int courseId;

  const CheckCourseAccessEvent({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

// ========== My Learning ==========

/// Load my enrolled courses
class LoadMyCoursesEvent extends CoursesEvent {
  final String? status;

  const LoadMyCoursesEvent({this.status});

  @override
  List<Object?> get props => [status];
}

/// Load course progress
class LoadCourseProgressEvent extends CoursesEvent {
  final int courseId;

  const LoadCourseProgressEvent({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

/// Load next lesson
class LoadNextLessonEvent extends CoursesEvent {
  final int courseId;

  const LoadNextLessonEvent({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

// ========== Video Lessons ==========

/// Load lesson details
class LoadLessonDetailsEvent extends CoursesEvent {
  final int lessonId;

  const LoadLessonDetailsEvent({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}

/// Get signed video URL
class GetSignedVideoUrlEvent extends CoursesEvent {
  final int lessonId;

  const GetSignedVideoUrlEvent({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}

/// Update lesson progress
class UpdateLessonProgressEvent extends CoursesEvent {
  final int lessonId;
  final int watchTimeSeconds;
  final double progressPercentage;

  const UpdateLessonProgressEvent({
    required this.lessonId,
    required this.watchTimeSeconds,
    required this.progressPercentage,
  });

  @override
  List<Object?> get props => [lessonId, watchTimeSeconds, progressPercentage];
}

/// Mark lesson as completed
class MarkLessonCompletedEvent extends CoursesEvent {
  final int lessonId;

  const MarkLessonCompletedEvent({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}

// ========== Reviews ==========

/// Load course reviews
class LoadCourseReviewsEvent extends CoursesEvent {
  final int courseId;
  final int? rating;
  final int page;
  final int perPage;

  const LoadCourseReviewsEvent({
    required this.courseId,
    this.rating,
    this.page = 1,
    this.perPage = 20,
  });

  @override
  List<Object?> get props => [courseId, rating, page, perPage];
}

/// Submit course review
class SubmitCourseReviewEvent extends CoursesEvent {
  final int courseId;
  final int rating;
  final String reviewText;

  const SubmitCourseReviewEvent({
    required this.courseId,
    required this.rating,
    required this.reviewText,
  });

  @override
  List<Object?> get props => [courseId, rating, reviewText];
}

/// Check if user can review course
class CheckCanReviewCourseEvent extends CoursesEvent {
  final int courseId;

  const CheckCanReviewCourseEvent({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

// ========== Certificate ==========

/// Generate certificate
class GenerateCertificateEvent extends CoursesEvent {
  final int courseId;

  const GenerateCertificateEvent({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

// ========== Cache Management ==========

/// Clear cache
class ClearCourseCacheEvent extends CoursesEvent {}
