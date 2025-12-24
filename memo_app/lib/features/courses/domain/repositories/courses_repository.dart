import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/certificate_entity.dart';
import '../entities/course_entity.dart';
import '../entities/course_lesson_entity.dart';
import '../entities/course_module_entity.dart';
import '../entities/course_progress_entity.dart';
import '../entities/course_review_entity.dart';
import '../entities/lesson_progress_entity.dart';

/// Courses Repository Interface
/// يحدد العقد للعمليات المتعلقة بالدورات
abstract class CoursesRepository {
  // ========== Browse & Discover ==========

  /// الحصول على قائمة الدورات مع الفلترة والبحث
  Future<Either<Failure, List<CourseEntity>>> getCourses({
    String? search,
    int? subjectId,
    String? level,
    bool? featured,
    bool? isFree,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    int perPage = 20,
  });

  /// الحصول على الدورات المميزة
  Future<Either<Failure, List<CourseEntity>>> getFeaturedCourses({
    int limit = 5,
  });

  /// الحصول على تفاصيل دورة معينة
  Future<Either<Failure, CourseEntity>> getCourseDetails(int courseId);

  /// الحصول على منهج الدورة (الفصول والدروس)
  Future<Either<Failure, List<CourseModuleEntity>>> getCourseModules(
    int courseId,
  );

  /// البحث في الدورات
  Future<Either<Failure, List<CourseEntity>>> searchCourses(String query);

  // ========== Access Management ==========

  /// التحقق من وصول المستخدم للدورة
  Future<Either<Failure, bool>> checkCourseAccess(int courseId);

  // ========== Video Lessons ==========

  /// الحصول على تفاصيل درس معين
  Future<Either<Failure, CourseLessonEntity>> getLessonDetails(int lessonId);

  /// الحصول على رابط الفيديو الموقع (Signed URL)
  Future<Either<Failure, String>> getSignedVideoUrl(int lessonId);

  // ========== Progress Tracking ==========

  /// الحصول على تقدم المستخدم في دورة
  Future<Either<Failure, CourseProgressEntity>> getCourseProgress(int courseId);

  /// الحصول على تقدم المستخدم في درس معين
  Future<Either<Failure, LessonProgressEntity?>> getLessonProgress(int lessonId);

  /// تحديث تقدم المستخدم في درس
  Future<Either<Failure, LessonProgressEntity>> updateLessonProgress({
    required int lessonId,
    required int watchTimeSeconds,
    required double progressPercentage,
  });

  /// وضع علامة إكمال على درس
  Future<Either<Failure, void>> markLessonCompleted(int lessonId);

  /// الحصول على الدرس التالي في الدورة
  Future<Either<Failure, CourseLessonEntity?>> getNextLesson(int courseId);

  /// الحصول على دورات المستخدم
  Future<Either<Failure, List<CourseEntity>>> getMyCourses({
    String? status, // 'active', 'completed'
  });

  // ========== Certificate ==========

  /// إنشاء شهادة إتمام الدورة
  Future<Either<Failure, CertificateEntity>> generateCertificate(int courseId);

  /// تحميل شهادة PDF
  Future<Either<Failure, File>> downloadCertificate(String pdfUrl);

  // ========== Reviews ==========

  /// الحصول على مراجعات الدورة
  Future<Either<Failure, List<CourseReviewEntity>>> getCourseReviews(
    int courseId, {
    int? rating,
    int page = 1,
    int perPage = 20,
  });

  /// إرسال مراجعة للدورة
  Future<Either<Failure, CourseReviewEntity>> submitReview({
    required int courseId,
    required int rating,
    required String reviewText,
  });

  /// التحقق من إمكانية المستخدم لكتابة مراجعة
  Future<Either<Failure, bool>> canReviewCourse(int courseId);

  // ========== Cache Management ==========

  /// مسح الكاش المحلي
  Future<Either<Failure, void>> clearCache();
}
