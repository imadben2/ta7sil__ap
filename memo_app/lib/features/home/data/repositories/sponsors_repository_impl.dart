import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/sponsors_repository.dart';
import '../datasources/sponsors_remote_datasource.dart';

/// Implementation of SponsorsRepository
/// Handles fetching sponsors from API and recording clicks
class SponsorsRepositoryImpl implements SponsorsRepository {
  final SponsorsRemoteDataSource remoteDataSource;

  SponsorsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SponsorsResponse>> getSponsors() async {
    try {
      final response = await remoteDataSource.getSponsors();
      // Convert models to entities
      final entities = response.sponsors.map((model) => model.toEntity()).toList();
      return Right(SponsorsResponse(
        sectionEnabled: response.sectionEnabled,
        sponsors: entities,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ParseException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to load sponsors: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> recordClick(int sponsorId, {String platform = 'general'}) async {
    try {
      final clickCount = await remoteDataSource.recordSponsorClick(
        sponsorId,
        platform: platform,
      );
      return Right(clickCount);
    } catch (e) {
      // For click tracking, we return success with 0 even on error
      // This ensures the user experience isn't affected
      return const Right(0);
    }
  }
}
