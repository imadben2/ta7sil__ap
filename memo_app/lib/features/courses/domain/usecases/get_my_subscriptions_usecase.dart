import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_subscription_entity.dart';
import '../repositories/subscription_repository.dart';

/// Use Case: الحصول على اشتراكات المستخدم
class GetMySubscriptionsUseCase
    implements UseCase<List<UserSubscriptionEntity>, GetMySubscriptionsParams> {
  final SubscriptionRepository repository;

  GetMySubscriptionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<UserSubscriptionEntity>>> call(
    GetMySubscriptionsParams params,
  ) async {
    return await repository.getMySubscriptions(activeOnly: params.activeOnly);
  }
}

class GetMySubscriptionsParams {
  final bool? activeOnly;

  GetMySubscriptionsParams({this.activeOnly});
}
