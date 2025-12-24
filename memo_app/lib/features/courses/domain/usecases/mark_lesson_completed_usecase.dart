import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/courses_repository.dart';

/// Use Case: وضع علامة إكمال على درس
class MarkLessonCompletedUseCase implements UseCase<void, int> {
  final CoursesRepository repository;

  MarkLessonCompletedUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int lessonId) async {
    if (lessonId <= 0) {
      return const Left(ValidationFailure('معرف الدرس غير صحيح'));
    }

    return await repository.markLessonCompleted(lessonId);
  }
}
