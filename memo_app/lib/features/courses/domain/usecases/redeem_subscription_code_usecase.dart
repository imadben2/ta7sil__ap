import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_subscription_entity.dart';
import '../repositories/subscription_repository.dart';

/// Use case for redeeming a subscription code
/// Calls POST /api/v1/subscriptions/redeem-code
/// Returns the created UserSubscriptionEntity on success
class RedeemSubscriptionCodeUseCase
    implements UseCase<UserSubscriptionEntity, RedeemCodeParams> {
  final SubscriptionRepository repository;

  RedeemSubscriptionCodeUseCase(this.repository);

  @override
  Future<Either<Failure, UserSubscriptionEntity>> call(
    RedeemCodeParams params,
  ) async {
    // Trim whitespace from code
    final trimmedCode = params.code.trim().toUpperCase();

    // Basic validation
    if (trimmedCode.isEmpty) {
      return Left(ValidationFailure('يرجى إدخال رمز الاشتراك'));
    }

    if (trimmedCode.length < 6) {
      return Left(ValidationFailure('رمز الاشتراك يجب أن يكون 6 أحرف على الأقل'));
    }

    return await repository.redeemSubscriptionCode(trimmedCode);
  }
}

/// Parameters for redeeming a subscription code
class RedeemCodeParams {
  final String code;

  RedeemCodeParams({required this.code});
}
