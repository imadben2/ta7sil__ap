import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bac_subject_entity.dart';
import '../repositories/bac_repository.dart';

/// Use case to get subjects for a specific session
class GetBacSubjects {
  final BacRepository repository;

  GetBacSubjects(this.repository);

  Future<Either<Failure, List<BacSubjectEntity>>> call(
    String sessionSlug,
  ) async {
    return await repository.getBacSubjects(sessionSlug);
  }
}
