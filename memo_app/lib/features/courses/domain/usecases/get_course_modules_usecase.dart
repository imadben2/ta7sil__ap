import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/course_module_entity.dart';
import '../repositories/courses_repository.dart';

/// Use Case: الحصول على منهج الدورة (الفصول والدروس)
class GetCourseModulesUseCase {
  final CoursesRepository repository;

  GetCourseModulesUseCase(this.repository);

  Future<Either<Failure, List<CourseModuleEntity>>> call(int courseId) async {
    if (courseId <= 0) {
      return Left(ValidationFailure('معرف الدورة غير صالح'));
    }

    return await repository.getCourseModules(courseId);
  }
}
