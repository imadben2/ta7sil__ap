import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/lesson_progress_entity.dart';
import '../repositories/courses_repository.dart';

/// Use Case: الحصول على تقدم الدرس
/// Gets the user's progress for a specific lesson
class GetLessonProgressUseCase
    implements UseCase<LessonProgressEntity?, int> {
  final CoursesRepository repository;

  GetLessonProgressUseCase(this.repository);

  @override
  Future<Either<Failure, LessonProgressEntity?>> call(int lessonId) async {
    if (lessonId <= 0) {
      return const Left(ValidationFailure('معرف الدرس غير صحيح'));
    }

    return await repository.getLessonProgress(lessonId);
  }
}
