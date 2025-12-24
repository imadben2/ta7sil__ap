import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/course_entity.dart';
import '../repositories/courses_repository.dart';

/// Use Case: الحصول على الدورات المميزة
class GetFeaturedCoursesUseCase {
  final CoursesRepository repository;

  GetFeaturedCoursesUseCase(this.repository);

  Future<Either<Failure, List<CourseEntity>>> call({int limit = 5}) async {
    return await repository.getFeaturedCourses(limit: limit);
  }
}
