import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/sponsors_repository.dart';

/// Use case to record a click on a sponsor's social link
class RecordSponsorClickUseCase {
  final SponsorsRepository repository;

  RecordSponsorClickUseCase({required this.repository});

  /// Execute the use case
  /// [platform] can be: youtube, facebook, instagram, telegram, or general
  /// Returns the new click count on success
  Future<Either<Failure, int>> call(int sponsorId, {String platform = 'general'}) async {
    return await repository.recordClick(sponsorId, platform: platform);
  }
}
