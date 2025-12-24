import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/course_entity.dart';
import '../repositories/courses_repository.dart';

/// Use Case: الحصول على قائمة الدورات مع الفلترة
class GetCoursesUseCase {
  final CoursesRepository repository;

  GetCoursesUseCase(this.repository);

  Future<Either<Failure, List<CourseEntity>>> call(
    GetCoursesParams params,
  ) async {
    return await repository.getCourses(
      search: params.search,
      subjectId: params.subjectId,
      level: params.level,
      academicPhaseId: params.academicPhaseId,
      featured: params.featured,
      isFree: params.isFree,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
      page: params.page,
      perPage: params.perPage,
    );
  }
}

class GetCoursesParams {
  final String? search;
  final int? subjectId;
  final String? level;
  final int? academicPhaseId;
  final bool? featured;
  final bool? isFree;
  final String sortBy;
  final String sortOrder;
  final int page;
  final int perPage;

  GetCoursesParams({
    this.search,
    this.subjectId,
    this.level,
    this.academicPhaseId,
    this.featured,
    this.isFree,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
    this.page = 1,
    this.perPage = 20,
  });

  GetCoursesParams copyWith({
    String? search,
    int? subjectId,
    String? level,
    int? academicPhaseId,
    bool? featured,
    bool? isFree,
    String? sortBy,
    String? sortOrder,
    int? page,
    int? perPage,
  }) {
    return GetCoursesParams(
      search: search ?? this.search,
      subjectId: subjectId ?? this.subjectId,
      level: level ?? this.level,
      academicPhaseId: academicPhaseId ?? this.academicPhaseId,
      featured: featured ?? this.featured,
      isFree: isFree ?? this.isFree,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }
}
