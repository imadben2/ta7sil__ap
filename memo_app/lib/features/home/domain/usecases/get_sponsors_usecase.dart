import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/sponsors_repository.dart';

/// Use case to get all active sponsors with section enabled status
class GetSponsorsUseCase {
  final SponsorsRepository repository;

  GetSponsorsUseCase({required this.repository});

  /// Execute the use case
  /// Returns SponsorsResponse containing both section_enabled flag and sponsors list
  Future<Either<Failure, SponsorsResponse>> call() async {
    return await repository.getSponsors();
  }
}
