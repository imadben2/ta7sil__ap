import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bac_session_entity.dart';
import '../repositories/bac_repository.dart';

/// Use case to get sessions for a specific BAC year
class GetBacSessions {
  final BacRepository repository;

  GetBacSessions(this.repository);

  Future<Either<Failure, List<BacSessionEntity>>> call(String yearSlug) async {
    return await repository.getBacSessions(yearSlug);
  }
}
