import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/courses_repository.dart';

/// Use Case: التحقق من وصول المستخدم للدورة
class CheckCourseAccessUseCase {
  final CoursesRepository repository;

  CheckCourseAccessUseCase(this.repository);

  Future<Either<Failure, bool>> call(int courseId) async {
    if (courseId <= 0) {
      return Left(ValidationFailure('معرف الدورة غير صالح'));
    }

    return await repository.checkCourseAccess(courseId);
  }
}
