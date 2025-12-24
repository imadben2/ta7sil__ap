import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/academic_entities.dart';
import '../repositories/auth_repository.dart';

/// Use case to get academic streams for a specific year
class GetAcademicStreamsUseCase {
  final AuthRepository repository;

  GetAcademicStreamsUseCase(this.repository);

  Future<Either<Failure, AcademicStreamsResponse>> call(int yearId) async {
    return await repository.getAcademicStreams(yearId);
  }
}
