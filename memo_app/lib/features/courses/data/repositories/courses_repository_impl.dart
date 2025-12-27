import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/certificate_entity.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/course_lesson_entity.dart';
import '../../domain/entities/course_module_entity.dart';
import '../../domain/entities/course_progress_entity.dart';
import '../../domain/entities/course_review_entity.dart';
import '../../domain/entities/lesson_progress_entity.dart';
import '../../domain/repositories/courses_repository.dart';
import '../../domain/usecases/get_complete_courses_usecase.dart';
import '../datasources/courses_remote_datasource.dart';

class CoursesRepositoryImpl implements CoursesRepository {
  final CoursesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CoursesRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // ========== Browse & Discover ==========

  @override
  Future<Either<Failure, CompleteCoursesData>> getCompleteCourses({
    String? search,
    int? subjectId,
    String? level,
    bool? isFree,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final data = await remoteDataSource.getCompleteCourses(
        search: search,
        subjectId: subjectId,
        level: level,
        isFree: isFree,
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: page,
        perPage: perPage,
      );
      return Right(CompleteCoursesData(
        featuredCourses: data.featuredCourses.map((m) => m.toEntity()).toList(),
        courses: data.courses.map((m) => m.toEntity()).toList(),
        currentPage: data.currentPage,
        lastPage: data.lastPage,
        total: data.total,
      ));
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> getCourses({
    String? search,
    int? subjectId,
    String? level,
    int? academicPhaseId,
    bool? featured,
    bool? isFree,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final courses = await remoteDataSource.getCourses(
        search: search,
        subjectId: subjectId,
        level: level,
        academicPhaseId: academicPhaseId,
        featured: featured,
        isFree: isFree,
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: page,
        perPage: perPage,
      );
      return Right(courses.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> getFeaturedCourses({
    int limit = 5,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final courses = await remoteDataSource.getFeaturedCourses(limit: limit);
      return Right(courses.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, CourseEntity>> getCourseDetails(int courseId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final course = await remoteDataSource.getCourseDetails(courseId);
      return Right(course.toEntity());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<CourseModuleEntity>>> getCourseModules(
    int courseId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final modules = await remoteDataSource.getCourseModules(courseId);
      return Right(modules.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> searchCourses(
    String query,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final courses = await remoteDataSource.searchCourses(query);
      return Right(courses.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  // ========== Access Management ==========

  @override
  Future<Either<Failure, bool>> checkCourseAccess(int courseId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final hasAccess = await remoteDataSource.checkCourseAccess(courseId);
      return Right(hasAccess);
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  // ========== Video Lessons ==========

  @override
  Future<Either<Failure, CourseLessonEntity>> getLessonDetails(
    int lessonId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final lesson = await remoteDataSource.getLessonDetails(lessonId);
      return Right(lesson.toEntity());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, String>> getSignedVideoUrl(int lessonId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final url = await remoteDataSource.getSignedVideoUrl(lessonId);
      return Right(url);
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  // ========== Progress Tracking ==========

  @override
  Future<Either<Failure, CourseProgressEntity>> getCourseProgress(
    int courseId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final progress = await remoteDataSource.getCourseProgress(courseId);
      return Right(progress.toEntity());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, LessonProgressEntity?>> getLessonProgress(
    int lessonId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final progress = await remoteDataSource.getLessonProgress(lessonId);
      return Right(progress?.toEntity());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, LessonProgressEntity>> updateLessonProgress({
    required int lessonId,
    required int watchTimeSeconds,
    required double progressPercentage,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final progress = await remoteDataSource.updateLessonProgress(
        lessonId: lessonId,
        watchTimeSeconds: watchTimeSeconds,
        progressPercentage: progressPercentage,
      );
      return Right(progress.toEntity());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> markLessonCompleted(int lessonId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      await remoteDataSource.markLessonCompleted(lessonId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, CourseLessonEntity?>> getNextLesson(
    int courseId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final lesson = await remoteDataSource.getNextLesson(courseId);
      return Right(lesson?.toEntity());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> getMyCourses({
    String? status,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final courses = await remoteDataSource.getMyCourses(status: status);
      return Right(courses.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  // ========== Certificate ==========

  @override
  Future<Either<Failure, CertificateEntity>> generateCertificate(
    int courseId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final certificate = await remoteDataSource.generateCertificate(courseId);
      return Right(certificate.toEntity());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, File>> downloadCertificate(String pdfUrl) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      return Left(ServerFailure('لم يتم تطبيق تحميل الشهادة بعد'));
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  // ========== Reviews ==========

  @override
  Future<Either<Failure, List<CourseReviewEntity>>> getCourseReviews(
    int courseId, {
    int? rating,
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final reviews = await remoteDataSource.getCourseReviews(
        courseId,
        rating: rating,
        page: page,
        perPage: perPage,
      );
      return Right(reviews.map((r) => r.toEntity()).toList());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, CourseReviewEntity>> submitReview({
    required int courseId,
    required int rating,
    required String reviewText,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final review = await remoteDataSource.submitReview(
        courseId: courseId,
        rating: rating,
        reviewText: reviewText,
      );
      return Right(review.toEntity());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> canReviewCourse(int courseId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final canReview = await remoteDataSource.canReviewCourse(courseId);
      return Right(canReview);
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  // ========== Cache Management ==========

  @override
  Future<Either<Failure, void>> clearCache() async {
    // No cache to clear - using direct API
    return const Right(null);
  }

  // ========== Helper Methods ==========

  Failure _handleException(Exception e) {
    final message = e.toString().replaceAll('Exception: ', '');

    if (message.contains('يجب تسجيل الدخول')) {
      return AuthenticationFailure(message);
    } else if (message.contains('ليس لديك صلاحية') ||
        message.contains('ليس لديك وصول')) {
      return CourseAccessDeniedFailure(message);
    } else if (message.contains('غير موجودة') ||
        message.contains('غير موجود')) {
      return CourseNotFoundFailure(message);
    } else if (message.contains('الفيديو')) {
      return VideoPlaybackFailure(message);
    } else if (message.contains('الشهادة')) {
      return CertificateGenerationFailure(message);
    } else if (message.contains('المراجعة')) {
      return ReviewSubmissionFailure(message);
    } else if (message.contains('الكود')) {
      return InvalidSubscriptionCodeFailure(message);
    } else if (message.contains('إيصال') || message.contains('الدفع')) {
      return ReceiptValidationFailure(message);
    } else if (message.contains('اتصال') || message.contains('الإنترنت')) {
      return NetworkFailure(message);
    } else {
      return ServerFailure(message);
    }
  }
}
