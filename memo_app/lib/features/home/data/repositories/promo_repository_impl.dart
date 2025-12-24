import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/promo_entity.dart';
import '../../domain/repositories/promo_repository.dart';
import '../datasources/promo_remote_datasource.dart';

/// Implementation of PromoRepository
class PromoRepositoryImpl implements PromoRepository {
  final PromoRemoteDataSource remoteDataSource;

  PromoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PromosResponse>> getPromos() async {
    try {
      final response = await remoteDataSource.getPromos();

      // Convert models to entities
      final entities = response.promos
          .map((model) => model.toEntity())
          .where((promo) => promo.isActive) // Filter active only
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)); // Sort by order

      return Right(PromosResponse(
        promos: entities,
        sectionEnabled: response.sectionEnabled,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ParseException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('فشل في تحميل العروض: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> recordPromoClick(int promoId) async {
    try {
      await remoteDataSource.recordPromoClick(promoId);
      return const Right(null);
    } catch (e) {
      // Silent fail for analytics - return success anyway
      return const Right(null);
    }
  }
}
