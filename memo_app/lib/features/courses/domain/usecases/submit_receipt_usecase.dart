import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/payment_receipt_entity.dart';
import '../repositories/subscription_repository.dart';

/// Use case for submitting a payment receipt
/// Calls POST /api/v1/payment-receipts
/// Returns the created PaymentReceiptEntity on success
class SubmitReceiptUseCase
    implements UseCase<PaymentReceiptEntity, SubmitReceiptParams> {
  final SubscriptionRepository repository;

  SubmitReceiptUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentReceiptEntity>> call(
    SubmitReceiptParams params,
  ) async {
    // Validate that at least one of courseId or packageId is provided
    if (params.courseId == null && params.packageId == null) {
      return Left(
        ValidationFailure('يجب تحديد الدورة أو الباقة'),
      );
    }

    // Validate amount
    if (params.amountDzd <= 0) {
      return Left(
        ValidationFailure('يجب إدخال مبلغ صحيح'),
      );
    }

    // Validate receipt image exists
    if (!await params.receiptImage.exists()) {
      return Left(
        ValidationFailure('لم يتم العثور على صورة الإيصال'),
      );
    }

    // Check file size (max 5MB)
    final fileSize = await params.receiptImage.length();
    if (fileSize > 5 * 1024 * 1024) {
      return Left(
        ValidationFailure('حجم الصورة يجب أن يكون أقل من 5 ميجابايت'),
      );
    }

    return await repository.submitReceipt(
      courseId: params.courseId,
      packageId: params.packageId,
      receiptImage: params.receiptImage,
      amountDzd: params.amountDzd,
      paymentMethod: params.paymentMethod,
      transactionReference: params.transactionReference,
      userNotes: params.userNotes,
    );
  }
}

/// Parameters for submitting a payment receipt
class SubmitReceiptParams {
  final int? courseId;
  final int? packageId;
  final File receiptImage;
  final int amountDzd;
  final String? paymentMethod;
  final String? transactionReference;
  final String? userNotes;

  SubmitReceiptParams({
    this.courseId,
    this.packageId,
    required this.receiptImage,
    required this.amountDzd,
    this.paymentMethod,
    this.transactionReference,
    this.userNotes,
  });
}
