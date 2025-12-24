import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/course_entity.dart';
import '../repositories/courses_repository.dart';

/// Use Case: الحصول على دورات المستخدم
class GetMyCoursesUseCase
    implements UseCase<List<CourseEntity>, GetMyCoursesParams> {
  final CoursesRepository repository;

  GetMyCoursesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CourseEntity>>> call(
    GetMyCoursesParams params,
  ) async {
    return await repository.getMyCourses(status: params.status);
  }
}

class GetMyCoursesParams {
  final String? status; // 'active', 'completed'

  GetMyCoursesParams({this.status});
}
