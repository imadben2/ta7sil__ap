import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/courses_repository.dart';

/// Use Case: الحصول على رابط الفيديو الموقع
class GetSignedVideoUrlUseCase implements UseCase<String, int> {
  final CoursesRepository repository;

  GetSignedVideoUrlUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(int lessonId) async {
    if (lessonId <= 0) {
      return const Left(ValidationFailure('معرف الدرس غير صحيح'));
    }

    return await repository.getSignedVideoUrl(lessonId);
  }
}
