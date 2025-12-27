import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/course_entity.dart';
import '../repositories/courses_repository.dart';

/// Complete courses data (featured + paginated list)
class CompleteCoursesData {
  final List<CourseEntity> featuredCourses;
  final List<CourseEntity> courses;
  final int currentPage;
  final int lastPage;
  final int total;

  CompleteCoursesData({
    required this.featuredCourses,
    required this.courses,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}

/// OPTIMIZED: Get all courses data in single API call
class GetCompleteCoursesUseCase {
  final CoursesRepository repository;

  GetCompleteCoursesUseCase(this.repository);

  Future<Either<Failure, CompleteCoursesData>> call(
    GetCompleteCoursesParams params,
  ) async {
    return await repository.getCompleteCourses(
      search: params.search,
      subjectId: params.subjectId,
      level: params.level,
      isFree: params.isFree,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
      page: params.page,
      perPage: params.perPage,
    );
  }
}

class GetCompleteCoursesParams {
  final String? search;
  final int? subjectId;
  final String? level;
  final bool? isFree;
  final String sortBy;
  final String sortOrder;
  final int page;
  final int perPage;

  GetCompleteCoursesParams({
    this.search,
    this.subjectId,
    this.level,
    this.isFree,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
    this.page = 1,
    this.perPage = 20,
  });
}
