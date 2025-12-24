import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/academic_entities.dart';
import '../repositories/auth_repository.dart';

/// Use case to get academic years for a specific phase
class GetAcademicYearsUseCase {
  final AuthRepository repository;

  GetAcademicYearsUseCase(this.repository);

  Future<Either<Failure, AcademicYearsResponse>> call(int phaseId) async {
    return await repository.getAcademicYears(phaseId);
  }
}
