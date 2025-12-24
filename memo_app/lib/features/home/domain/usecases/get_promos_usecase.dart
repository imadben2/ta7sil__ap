import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/promo_entity.dart';
import '../repositories/promo_repository.dart';

/// Use case for fetching promos
class GetPromosUseCase {
  final PromoRepository repository;

  GetPromosUseCase({required this.repository});

  Future<Either<Failure, PromosResponse>> call() async {
    return await repository.getPromos();
  }
}
