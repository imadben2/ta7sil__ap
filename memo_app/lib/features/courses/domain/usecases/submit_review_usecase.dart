import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/course_review_entity.dart';
import '../repositories/courses_repository.dart';

/// Use Case: إرسال مراجعة للدورة
class SubmitReviewUseCase
    implements UseCase<CourseReviewEntity, SubmitReviewParams> {
  final CoursesRepository repository;

  SubmitReviewUseCase(this.repository);

  @override
  Future<Either<Failure, CourseReviewEntity>> call(
    SubmitReviewParams params,
  ) async {
    // Validation
    if (params.courseId <= 0) {
      return const Left(ValidationFailure('معرف الدورة غير صحيح'));
    }

    if (params.rating < 1 || params.rating > 5) {
      return const Left(ValidationFailure('التقييم يجب أن يكون بين 1 و 5'));
    }

    if (params.reviewText.trim().isEmpty) {
      return const Left(ValidationFailure('يرجى كتابة نص المراجعة'));
    }

    if (params.reviewText.trim().length < 10) {
      return const Left(
        ValidationFailure('المراجعة يجب أن تحتوي على 10 أحرف على الأقل'),
      );
    }

    return await repository.submitReview(
      courseId: params.courseId,
      rating: params.rating,
      reviewText: params.reviewText.trim(),
    );
  }
}

class SubmitReviewParams {
  final int courseId;
  final int rating;
  final String reviewText;

  SubmitReviewParams({
    required this.courseId,
    required this.rating,
    required this.reviewText,
  });
}
