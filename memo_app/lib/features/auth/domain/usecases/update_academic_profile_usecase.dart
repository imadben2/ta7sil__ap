import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case to update user's academic profile
class UpdateAcademicProfileUseCase {
  final AuthRepository repository;

  UpdateAcademicProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required int phaseId,
    required int yearId,
    required int streamId,
  }) async {
    return await repository.updateAcademicProfile(
      phaseId: phaseId,
      yearId: yearId,
      streamId: streamId,
    );
  }
}
