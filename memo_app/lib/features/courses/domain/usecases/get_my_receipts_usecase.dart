import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/payment_receipt_entity.dart';
import '../repositories/subscription_repository.dart';

/// Use case for getting user's payment receipts
/// Calls GET /api/v1/payment-receipts/my-receipts
/// Returns list of PaymentReceiptEntity
class GetMyReceiptsUseCase
    implements UseCase<List<PaymentReceiptEntity>, GetMyReceiptsParams> {
  final SubscriptionRepository repository;

  GetMyReceiptsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PaymentReceiptEntity>>> call(
    GetMyReceiptsParams params,
  ) async {
    return await repository.getMyPaymentReceipts(
      status: params.status,
    );
  }
}

/// Parameters for getting user's receipts
class GetMyReceiptsParams {
  final String? status; // 'pending', 'approved', 'rejected', or null for all

  GetMyReceiptsParams({this.status});

  /// Get all receipts regardless of status
  factory GetMyReceiptsParams.all() => GetMyReceiptsParams(status: null);

  /// Get only pending receipts
  factory GetMyReceiptsParams.pending() =>
      GetMyReceiptsParams(status: 'pending');

  /// Get only approved receipts
  factory GetMyReceiptsParams.approved() =>
      GetMyReceiptsParams(status: 'approved');

  /// Get only rejected receipts
  factory GetMyReceiptsParams.rejected() =>
      GetMyReceiptsParams(status: 'rejected');
}
