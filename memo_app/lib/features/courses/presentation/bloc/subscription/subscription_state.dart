import 'package:equatable/equatable.dart';
import '../../../domain/entities/payment_receipt_entity.dart';
import '../../../domain/entities/subscription_package_entity.dart';
import '../../../domain/entities/user_subscription_entity.dart';
import '../../../domain/usecases/validate_subscription_code_usecase.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

// ========== Initial & Loading ==========

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionActionInProgress extends SubscriptionState {
  final String message;

  const SubscriptionActionInProgress({required this.message});

  @override
  List<Object?> get props => [message];
}

// ========== Combined Data State ==========

class SubscriptionDataLoaded extends SubscriptionState {
  final List<SubscriptionPackageEntity> packages;
  final List<UserSubscriptionEntity> subscriptions;
  final List<PaymentReceiptEntity> receipts;
  final bool isLoadingPackages;
  final bool isLoadingSubscriptions;
  final bool isLoadingReceipts;
  final String? packagesError;
  final String? subscriptionsError;
  final String? receiptsError;

  const SubscriptionDataLoaded({
    this.packages = const [],
    this.subscriptions = const [],
    this.receipts = const [],
    this.isLoadingPackages = false,
    this.isLoadingSubscriptions = false,
    this.isLoadingReceipts = false,
    this.packagesError,
    this.subscriptionsError,
    this.receiptsError,
  });

  SubscriptionDataLoaded copyWith({
    List<SubscriptionPackageEntity>? packages,
    List<UserSubscriptionEntity>? subscriptions,
    List<PaymentReceiptEntity>? receipts,
    bool? isLoadingPackages,
    bool? isLoadingSubscriptions,
    bool? isLoadingReceipts,
    String? packagesError,
    String? subscriptionsError,
    String? receiptsError,
    bool clearPackagesError = false,
    bool clearSubscriptionsError = false,
    bool clearReceiptsError = false,
  }) {
    return SubscriptionDataLoaded(
      packages: packages ?? this.packages,
      subscriptions: subscriptions ?? this.subscriptions,
      receipts: receipts ?? this.receipts,
      isLoadingPackages: isLoadingPackages ?? this.isLoadingPackages,
      isLoadingSubscriptions: isLoadingSubscriptions ?? this.isLoadingSubscriptions,
      isLoadingReceipts: isLoadingReceipts ?? this.isLoadingReceipts,
      packagesError: clearPackagesError ? null : (packagesError ?? this.packagesError),
      subscriptionsError: clearSubscriptionsError ? null : (subscriptionsError ?? this.subscriptionsError),
      receiptsError: clearReceiptsError ? null : (receiptsError ?? this.receiptsError),
    );
  }

  @override
  List<Object?> get props => [
        packages,
        subscriptions,
        receipts,
        isLoadingPackages,
        isLoadingSubscriptions,
        isLoadingReceipts,
        packagesError,
        subscriptionsError,
        receiptsError,
      ];
}

// ========== Legacy Packages States (kept for backwards compatibility) ==========

class SubscriptionPackagesLoaded extends SubscriptionState {
  final List<SubscriptionPackageEntity> packages;

  const SubscriptionPackagesLoaded({required this.packages});

  @override
  List<Object?> get props => [packages];
}

// ========== My Subscriptions States ==========

class MySubscriptionsLoaded extends SubscriptionState {
  final List<UserSubscriptionEntity> subscriptions;

  const MySubscriptionsLoaded({required this.subscriptions});

  @override
  List<Object?> get props => [subscriptions];
}

class MyStatsLoaded extends SubscriptionState {
  final Map<String, dynamic> stats;

  const MyStatsLoaded({required this.stats});

  @override
  List<Object?> get props => [stats];
}

// ========== Code States ==========

class CodeValidated extends SubscriptionState {
  final SubscriptionCodeValidationResult validationResult;
  final String message;

  const CodeValidated({
    required this.validationResult,
    this.message = 'الكود صحيح',
  });

  @override
  List<Object?> get props => [validationResult, message];
}

class CodeRedeemed extends SubscriptionState {
  final UserSubscriptionEntity subscription;
  final String message;

  const CodeRedeemed({
    required this.subscription,
    this.message = 'تم تفعيل الاشتراك بنجاح',
  });

  @override
  List<Object?> get props => [subscription, message];
}

// ========== Payment Receipt States ==========

class PaymentReceiptSubmitted extends SubscriptionState {
  final PaymentReceiptEntity receipt;
  final String message;

  const PaymentReceiptSubmitted({
    required this.receipt,
    this.message = 'تم إرسال إيصال الدفع بنجاح. سيتم مراجعته قريباً',
  });

  @override
  List<Object?> get props => [receipt, message];
}

class MyPaymentReceiptsLoaded extends SubscriptionState {
  final List<PaymentReceiptEntity> receipts;

  const MyPaymentReceiptsLoaded({required this.receipts});

  @override
  List<Object?> get props => [receipts];
}

// ========== Error State ==========

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError({required this.message});

  @override
  List<Object?> get props => [message];
}
