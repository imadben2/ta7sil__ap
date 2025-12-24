import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

// ========== Load All Data ==========

/// Load all subscription data (packages, subscriptions, receipts)
class LoadAllSubscriptionDataEvent extends SubscriptionEvent {
  const LoadAllSubscriptionDataEvent();
}

// ========== Packages ==========

/// Load subscription packages
class LoadSubscriptionPackagesEvent extends SubscriptionEvent {
  final bool? activeOnly;

  const LoadSubscriptionPackagesEvent({this.activeOnly = true});

  @override
  List<Object?> get props => [activeOnly];
}

// ========== My Subscriptions ==========

/// Load user subscriptions
class LoadMySubscriptionsEvent extends SubscriptionEvent {
  final bool? activeOnly;

  const LoadMySubscriptionsEvent({this.activeOnly});

  @override
  List<Object?> get props => [activeOnly];
}

/// Load subscription stats
class LoadMyStatsEvent extends SubscriptionEvent {}

// ========== Subscription Code ==========

/// Validate subscription code
class ValidateCodeEvent extends SubscriptionEvent {
  final String code;

  const ValidateCodeEvent({required this.code});

  @override
  List<Object?> get props => [code];
}

/// Redeem subscription code
class RedeemCodeEvent extends SubscriptionEvent {
  final String code;

  const RedeemCodeEvent({required this.code});

  @override
  List<Object?> get props => [code];
}

// ========== Payment Receipt ==========

/// Submit payment receipt
class SubmitPaymentReceiptEvent extends SubscriptionEvent {
  final int? courseId;
  final int? packageId;
  final File receiptImage;
  final int amountDzd;
  final String? paymentMethod;
  final String? transactionReference;
  final String? userNotes;

  const SubmitPaymentReceiptEvent({
    this.courseId,
    this.packageId,
    required this.receiptImage,
    required this.amountDzd,
    this.paymentMethod,
    this.transactionReference,
    this.userNotes,
  });

  @override
  List<Object?> get props => [
    courseId,
    packageId,
    receiptImage,
    amountDzd,
    paymentMethod,
    transactionReference,
    userNotes,
  ];
}

/// Load my payment receipts
class LoadMyPaymentReceiptsEvent extends SubscriptionEvent {
  final String? status;

  const LoadMyPaymentReceiptsEvent({this.status});

  @override
  List<Object?> get props => [status];
}
