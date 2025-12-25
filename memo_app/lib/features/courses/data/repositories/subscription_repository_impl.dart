import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/payment_receipt_entity.dart';
import '../../domain/entities/subscription_package_entity.dart';
import '../../domain/entities/user_subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/usecases/validate_subscription_code_usecase.dart';
import '../datasources/courses_remote_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final CoursesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SubscriptionRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // ========== User Subscriptions ==========

  @override
  Future<Either<Failure, List<UserSubscriptionEntity>>> getMySubscriptions({
    bool? activeOnly,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final subscriptions = await remoteDataSource.getMySubscriptions(
        activeOnly: activeOnly,
      );
      return Right(subscriptions.map((s) => s.toEntity()).toList());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMyStats() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final stats = await remoteDataSource.getMyStats();
      return Right(stats);
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  // ========== Subscription Codes ==========

  @override
  Future<Either<Failure, SubscriptionCodeValidationResult>>
      validateSubscriptionCode(String code) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final result = await remoteDataSource.validateSubscriptionCode(code);
      return Right(SubscriptionCodeValidationResult.fromJson(result));
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, UserSubscriptionEntity>> redeemSubscriptionCode(
    String code,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final subscription = await remoteDataSource.redeemSubscriptionCode(code);
      return Right(subscription.toEntity());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  // ========== Packages ==========

  @override
  Future<Either<Failure, List<SubscriptionPackageEntity>>> getPackages({
    bool? activeOnly,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final packages = await remoteDataSource.getPackages(
        activeOnly: activeOnly,
      );
      return Right(packages.map((p) => p.toEntity()).toList());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, SubscriptionPackageEntity>> getPackageDetails(
    int packageId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final package = await remoteDataSource.getPackageDetails(packageId);
      return Right(package.toEntity());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  // ========== Payment Receipts ==========

  @override
  Future<Either<Failure, PaymentReceiptEntity>> submitReceipt({
    int? courseId,
    int? packageId,
    required File receiptImage,
    required int amountDzd,
    String? paymentMethod,
    String? transactionReference,
    String? userNotes,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final receipt = await remoteDataSource.submitReceipt(
        courseId: courseId,
        packageId: packageId,
        receiptImage: receiptImage,
        amountDzd: amountDzd,
        paymentMethod: paymentMethod,
        transactionReference: transactionReference,
        userNotes: userNotes,
      );
      return Right(receipt.toEntity());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<PaymentReceiptEntity>>> getMyPaymentReceipts({
    String? status,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final receipts = await remoteDataSource.getMyPaymentReceipts(
        status: status,
      );
      return Right(receipts.map((r) => r.toEntity()).toList());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, PaymentReceiptEntity>> getReceiptDetails(
    int receiptId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }

    try {
      final receipt = await remoteDataSource.getReceiptDetails(receiptId);
      return Right(receipt.toEntity());
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  // ========== Cache Management ==========

  @override
  Future<Either<Failure, void>> clearCache() async {
    // No cache to clear - using direct API
    return const Right(null);
  }

  // ========== Helper Methods ==========

  Failure _handleException(Exception e) {
    final message = e.toString().replaceAll('Exception: ', '');

    if (message.contains('يجب تسجيل الدخول')) {
      return AuthenticationFailure(message);
    } else if (message.contains('الكود')) {
      return InvalidSubscriptionCodeFailure(message);
    } else if (message.contains('إيصال') || message.contains('الدفع')) {
      return ReceiptValidationFailure(message);
    } else if (message.contains('اتصال') || message.contains('الإنترنت')) {
      return NetworkFailure(message);
    } else {
      return ServerFailure(message);
    }
  }
}
