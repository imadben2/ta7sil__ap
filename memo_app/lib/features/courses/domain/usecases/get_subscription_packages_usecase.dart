import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/subscription_package_entity.dart';
import '../repositories/subscription_repository.dart';

/// Use Case: الحصول على باقات الاشتراك المتاحة
class GetSubscriptionPackagesUseCase
    implements
        UseCase<
          List<SubscriptionPackageEntity>,
          GetSubscriptionPackagesParams
        > {
  final SubscriptionRepository repository;

  GetSubscriptionPackagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<SubscriptionPackageEntity>>> call(
    GetSubscriptionPackagesParams params,
  ) async {
    return await repository.getPackages(activeOnly: params.activeOnly);
  }
}

class GetSubscriptionPackagesParams {
  final bool? activeOnly;

  GetSubscriptionPackagesParams({this.activeOnly = true});
}
