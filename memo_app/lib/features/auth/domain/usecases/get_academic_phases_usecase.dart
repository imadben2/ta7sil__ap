import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/academic_entities.dart';
import '../repositories/auth_repository.dart';

/// Use case to get all academic phases
class GetAcademicPhasesUseCase {
  final AuthRepository repository;

  GetAcademicPhasesUseCase(this.repository);

  Future<Either<Failure, AcademicPhasesResponse>> call() async {
    return await repository.getAcademicPhases();
  }
}
