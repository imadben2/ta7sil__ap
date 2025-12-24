import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/lesson_progress_entity.dart';
import '../repositories/courses_repository.dart';

/// Use Case: تحديث تقدم الدرس
class UpdateLessonProgressUseCase
    implements UseCase<LessonProgressEntity, UpdateLessonProgressParams> {
  final CoursesRepository repository;

  UpdateLessonProgressUseCase(this.repository);

  @override
  Future<Either<Failure, LessonProgressEntity>> call(
    UpdateLessonProgressParams params,
  ) async {
    // Validation
    if (params.watchTimeSeconds < 0) {
      return const Left(ValidationFailure('وقت المشاهدة يجب أن يكون موجباً'));
    }

    if (params.progressPercentage < 0 || params.progressPercentage > 100) {
      return const Left(
        ValidationFailure('نسبة التقدم يجب أن تكون بين 0 و 100'),
      );
    }

    return await repository.updateLessonProgress(
      lessonId: params.lessonId,
      watchTimeSeconds: params.watchTimeSeconds,
      progressPercentage: params.progressPercentage,
    );
  }
}

class UpdateLessonProgressParams {
  final int lessonId;
  final int watchTimeSeconds;
  final double progressPercentage;

  UpdateLessonProgressParams({
    required this.lessonId,
    required this.watchTimeSeconds,
    required this.progressPercentage,
  });
}
