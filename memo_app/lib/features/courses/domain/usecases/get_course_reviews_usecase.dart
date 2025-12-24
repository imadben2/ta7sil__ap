import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/course_review_entity.dart';
import '../repositories/courses_repository.dart';

/// Use Case: الحصول على مراجعات الدورة
class GetCourseReviewsUseCase
    implements UseCase<List<CourseReviewEntity>, GetCourseReviewsParams> {
  final CoursesRepository repository;

  GetCourseReviewsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CourseReviewEntity>>> call(
    GetCourseReviewsParams params,
  ) async {
    if (params.courseId <= 0) {
      return const Left(ValidationFailure('معرف الدورة غير صحيح'));
    }

    if (params.rating != null && (params.rating! < 1 || params.rating! > 5)) {
      return const Left(ValidationFailure('التقييم يجب أن يكون بين 1 و 5'));
    }

    return await repository.getCourseReviews(
      params.courseId,
      rating: params.rating,
      page: params.page,
      perPage: params.perPage,
    );
  }
}

class GetCourseReviewsParams {
  final int courseId;
  final int? rating;
  final int page;
  final int perPage;

  GetCourseReviewsParams({
    required this.courseId,
    this.rating,
    this.page = 1,
    this.perPage = 20,
  });
}
