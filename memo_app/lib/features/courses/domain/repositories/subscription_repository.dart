import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/payment_receipt_entity.dart';
import '../entities/subscription_package_entity.dart';
import '../entities/user_subscription_entity.dart';
import '../usecases/validate_subscription_code_usecase.dart';

/// Subscription Repository Interface
/// يحدد العقد للعمليات المتعلقة بالاشتراكات والدفع
abstract class SubscriptionRepository {
  // ========== User Subscriptions ==========

  /// الحصول على اشتراكات المستخدم
  Future<Either<Failure, List<UserSubscriptionEntity>>> getMySubscriptions({
    bool? activeOnly,
  });

  /// الحصول على إحصائيات اشتراكات المستخدم
  Future<Either<Failure, Map<String, dynamic>>> getMyStats();

  // ========== Subscription Codes ==========

  /// التحقق من صحة كود اشتراك
  /// Calls POST /api/v1/subscriptions/validate-code
  Future<Either<Failure, SubscriptionCodeValidationResult>>
      validateSubscriptionCode(String code);

  /// تفعيل اشتراك باستخدام كود
  /// Calls POST /api/v1/subscriptions/redeem-code
  Future<Either<Failure, UserSubscriptionEntity>> redeemSubscriptionCode(
    String code,
  );

  // ========== Packages ==========

  /// الحصول على الباقات المتاحة
  Future<Either<Failure, List<SubscriptionPackageEntity>>> getPackages({
    bool? activeOnly,
  });

  /// الحصول على تفاصيل باقة معينة
  Future<Either<Failure, SubscriptionPackageEntity>> getPackageDetails(
    int packageId,
  );

  // ========== Payment Receipts ==========

  /// رفع إيصال دفع
  Future<Either<Failure, PaymentReceiptEntity>> submitReceipt({
    int? courseId,
    int? packageId,
    required File receiptImage,
    required int amountDzd,
    String? paymentMethod,
    String? transactionReference,
    String? userNotes,
  });

  /// الحصول على إيصالات الدفع الخاصة بالمستخدم
  Future<Either<Failure, List<PaymentReceiptEntity>>> getMyPaymentReceipts({
    String? status, // 'pending', 'approved', 'rejected'
  });

  /// الحصول على تفاصيل إيصال معين
  Future<Either<Failure, PaymentReceiptEntity>> getReceiptDetails(
    int receiptId,
  );

  // ========== Cache Management ==========

  /// مسح الكاش المحلي
  Future<Either<Failure, void>> clearCache();
}
