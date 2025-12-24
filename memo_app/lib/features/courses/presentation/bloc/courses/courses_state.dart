import 'package:equatable/equatable.dart';
import '../../../domain/entities/certificate_entity.dart';
import '../../../domain/entities/course_entity.dart';
import '../../../domain/entities/course_lesson_entity.dart';
import '../../../domain/entities/course_module_entity.dart';
import '../../../domain/entities/course_progress_entity.dart';
import '../../../domain/entities/course_review_entity.dart';
import '../../../domain/entities/lesson_progress_entity.dart';

abstract class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object?> get props => [];
}

// ========== Initial & Loading ==========

/// Initial state
class CoursesInitial extends CoursesState {}

/// Loading state
class CoursesLoading extends CoursesState {}

/// Action in progress (like updating progress)
class CoursesActionInProgress extends CoursesState {
  final String message;

  const CoursesActionInProgress({required this.message});

  @override
  List<Object?> get props => [message];
}

// ========== Browse & Discover States ==========

/// Courses loaded successfully
class CoursesLoaded extends CoursesState {
  final List<CourseEntity> courses;
  final List<CourseEntity> featuredCourses;
  final int currentPage;
  final bool hasMorePages;

  const CoursesLoaded({
    required this.courses,
    this.featuredCourses = const [],
    this.currentPage = 1,
    this.hasMorePages = true,
  });

  CoursesLoaded copyWith({
    List<CourseEntity>? courses,
    List<CourseEntity>? featuredCourses,
    int? currentPage,
    bool? hasMorePages,
  }) {
    return CoursesLoaded(
      courses: courses ?? this.courses,
      featuredCourses: featuredCourses ?? this.featuredCourses,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }

  @override
  List<Object?> get props => [courses, featuredCourses, currentPage, hasMorePages];
}

/// Featured courses loaded
class FeaturedCoursesLoaded extends CoursesState {
  final List<CourseEntity> courses;

  const FeaturedCoursesLoaded({required this.courses});

  @override
  List<Object?> get props => [courses];
}

/// Course details loaded
class CourseDetailsLoaded extends CoursesState {
  final CourseEntity course;

  const CourseDetailsLoaded({required this.course});

  @override
  List<Object?> get props => [course];
}

/// Course modules loaded
class CourseModulesLoaded extends CoursesState {
  final List<CourseModuleEntity> modules;

  const CourseModulesLoaded({required this.modules});

  @override
  List<Object?> get props => [modules];
}

/// Search results loaded
class CoursesSearchResultsLoaded extends CoursesState {
  final List<CourseEntity> courses;
  final String query;

  const CoursesSearchResultsLoaded({
    required this.courses,
    required this.query,
  });

  @override
  List<Object?> get props => [courses, query];
}

// ========== Access Management States ==========

/// Course access checked
class CourseAccessChecked extends CoursesState {
  final bool hasAccess;
  final int courseId;

  const CourseAccessChecked({required this.hasAccess, required this.courseId});

  @override
  List<Object?> get props => [hasAccess, courseId];
}

// ========== My Learning States ==========

/// My courses loaded
class MyCoursesLoaded extends CoursesState {
  final List<CourseEntity> courses;

  const MyCoursesLoaded({required this.courses});

  @override
  List<Object?> get props => [courses];
}

/// Course progress loaded
class CourseProgressLoaded extends CoursesState {
  final CourseProgressEntity progress;

  const CourseProgressLoaded({required this.progress});

  @override
  List<Object?> get props => [progress];
}

/// Next lesson loaded
class NextLessonLoaded extends CoursesState {
  final CourseLessonEntity? lesson;

  const NextLessonLoaded({this.lesson});

  @override
  List<Object?> get props => [lesson];
}

// ========== Video Lessons States ==========

/// Lesson details loaded
class LessonDetailsLoaded extends CoursesState {
  final CourseLessonEntity lesson;

  const LessonDetailsLoaded({required this.lesson});

  @override
  List<Object?> get props => [lesson];
}

/// Signed video URL loaded
class SignedVideoUrlLoaded extends CoursesState {
  final String videoUrl;
  final int lessonId;

  const SignedVideoUrlLoaded({required this.videoUrl, required this.lessonId});

  @override
  List<Object?> get props => [videoUrl, lessonId];
}

/// Lesson progress updated
class LessonProgressUpdated extends CoursesState {
  final LessonProgressEntity progress;

  const LessonProgressUpdated({required this.progress});

  @override
  List<Object?> get props => [progress];
}

/// Lesson completed successfully
class LessonCompletedSuccess extends CoursesState {
  final int lessonId;
  final String message;

  const LessonCompletedSuccess({
    required this.lessonId,
    this.message = 'تم إكمال الدرس بنجاح',
  });

  @override
  List<Object?> get props => [lessonId, message];
}

// ========== Reviews States ==========

/// Course reviews loaded
class CourseReviewsLoaded extends CoursesState {
  final List<CourseReviewEntity> reviews;
  final int currentPage;
  final bool hasMorePages;

  const CourseReviewsLoaded({
    required this.reviews,
    this.currentPage = 1,
    this.hasMorePages = true,
  });

  @override
  List<Object?> get props => [reviews, currentPage, hasMorePages];
}

/// Review submitted successfully
class CourseReviewSubmitted extends CoursesState {
  final CourseReviewEntity review;
  final String message;

  const CourseReviewSubmitted({
    required this.review,
    this.message = 'تم إرسال المراجعة بنجاح',
  });

  @override
  List<Object?> get props => [review, message];
}

/// Can review course checked
class CanReviewCourseChecked extends CoursesState {
  final bool canReview;
  final int courseId;

  const CanReviewCourseChecked({
    required this.canReview,
    required this.courseId,
  });

  @override
  List<Object?> get props => [canReview, courseId];
}

// ========== Certificate States ==========

/// Certificate generated successfully
class CertificateGenerated extends CoursesState {
  final CertificateEntity certificate;
  final String message;

  const CertificateGenerated({
    required this.certificate,
    this.message = 'تم إنشاء الشهادة بنجاح',
  });

  @override
  List<Object?> get props => [certificate, message];
}

// ========== Cache Management States ==========

/// Cache cleared successfully
class CourseCacheCleared extends CoursesState {
  final String message;

  const CourseCacheCleared({this.message = 'تم مسح الذاكرة المؤقتة بنجاح'});

  @override
  List<Object?> get props => [message];
}

// ========== Error State ==========

/// Error state
class CoursesError extends CoursesState {
  final String message;

  const CoursesError({required this.message});

  @override
  List<Object?> get props => [message];
}
