import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/promo_repository.dart';

/// Use case for recording promo clicks (analytics)
class RecordPromoClickUseCase {
  final PromoRepository repository;

  RecordPromoClickUseCase({required this.repository});

  Future<Either<Failure, void>> call(int promoId) async {
    return await repository.recordPromoClick(promoId);
  }
}
