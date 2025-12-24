import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/promo_entity.dart';

/// Abstract repository for promo operations
abstract class PromoRepository {
  /// Get all active promos
  Future<Either<Failure, PromosResponse>> getPromos();

  /// Record a click on a promo (for analytics)
  Future<Either<Failure, void>> recordPromoClick(int promoId);
}
