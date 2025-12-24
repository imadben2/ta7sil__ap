import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/course_entity.dart';
import '../repositories/courses_repository.dart';

/// Use Case: الحصول على تفاصيل دورة معينة
class GetCourseDetailsUseCase {
  final CoursesRepository repository;

  GetCourseDetailsUseCase(this.repository);

  Future<Either<Failure, CourseEntity>> call(int courseId) async {
    if (courseId <= 0) {
      return Left(ValidationFailure('معرف الدورة غير صالح'));
    }

    return await repository.getCourseDetails(courseId);
  }
}
