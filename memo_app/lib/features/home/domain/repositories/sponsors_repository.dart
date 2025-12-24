import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sponsor_entity.dart';

/// Response from sponsors API including section visibility flag
class SponsorsResponse {
  final bool sectionEnabled;
  final List<SponsorEntity> sponsors;

  const SponsorsResponse({
    required this.sectionEnabled,
    required this.sponsors,
  });
}

/// Abstract repository interface for sponsors
abstract class SponsorsRepository {
  /// Get all active sponsors with section enabled status
  Future<Either<Failure, SponsorsResponse>> getSponsors();

  /// Record a click on a sponsor's social link
  /// [platform] can be: youtube, facebook, instagram, telegram, or general
  /// Returns the new click count on success
  Future<Either<Failure, int>> recordClick(int sponsorId, {String platform = 'general'});
}
