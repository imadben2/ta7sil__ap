import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/certificate_entity.dart';
import '../repositories/courses_repository.dart';

/// Use Case: إنشاء شهادة إتمام الدورة
class GenerateCertificateUseCase implements UseCase<CertificateEntity, int> {
  final CoursesRepository repository;

  GenerateCertificateUseCase(this.repository);

  @override
  Future<Either<Failure, CertificateEntity>> call(int courseId) async {
    if (courseId <= 0) {
      return const Left(ValidationFailure('معرف الدورة غير صحيح'));
    }

    return await repository.generateCertificate(courseId);
  }
}
