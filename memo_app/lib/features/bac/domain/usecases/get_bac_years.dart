import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bac_year_entity.dart';
import '../repositories/bac_repository.dart';

/// Use case to get all available BAC years
class GetBacYears {
  final BacRepository repository;

  GetBacYears(this.repository);

  Future<Either<Failure, List<BacYearEntity>>> call({
    bool forceRefresh = false,
  }) async {
    return await repository.getBacYears(forceRefresh: forceRefresh);
  }
}
