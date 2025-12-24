import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_my_receipts_usecase.dart';
import '../../../domain/usecases/get_my_subscriptions_usecase.dart';
import '../../../domain/usecases/get_subscription_packages_usecase.dart';
import '../../../domain/usecases/redeem_subscription_code_usecase.dart';
import '../../../domain/usecases/submit_receipt_usecase.dart';
import '../../../domain/usecases/validate_subscription_code_usecase.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final GetSubscriptionPackagesUseCase getSubscriptionPackagesUseCase;
  final GetMySubscriptionsUseCase getMySubscriptionsUseCase;
  final ValidateSubscriptionCodeUseCase validateSubscriptionCodeUseCase;
  final RedeemSubscriptionCodeUseCase redeemSubscriptionCodeUseCase;
  final SubmitReceiptUseCase submitReceiptUseCase;
  final GetMyReceiptsUseCase getMyReceiptsUseCase;

  SubscriptionBloc({
    required this.getSubscriptionPackagesUseCase,
    required this.getMySubscriptionsUseCase,
    required this.validateSubscriptionCodeUseCase,
    required this.redeemSubscriptionCodeUseCase,
    required this.submitReceiptUseCase,
    required this.getMyReceiptsUseCase,
  }) : super(const SubscriptionDataLoaded()) {
    on<LoadSubscriptionPackagesEvent>(_onLoadPackages);
    on<LoadMySubscriptionsEvent>(_onLoadMySubscriptions);
    on<ValidateCodeEvent>(_onValidateCode);
    on<RedeemCodeEvent>(_onRedeemCode);
    on<SubmitPaymentReceiptEvent>(_onSubmitReceipt);
    on<LoadMyPaymentReceiptsEvent>(_onLoadMyReceipts);
    on<LoadAllSubscriptionDataEvent>(_onLoadAllData);
  }

  SubscriptionDataLoaded get _currentData {
    if (state is SubscriptionDataLoaded) {
      return state as SubscriptionDataLoaded;
    }
    return const SubscriptionDataLoaded();
  }

  Future<void> _onLoadAllData(
    LoadAllSubscriptionDataEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    // Set all loading states
    var currentState = const SubscriptionDataLoaded(
      isLoadingPackages: true,
      isLoadingSubscriptions: true,
      isLoadingReceipts: true,
    );
    emit(currentState);

    // Load packages
    final packagesResult = await getSubscriptionPackagesUseCase(
      GetSubscriptionPackagesParams(activeOnly: true),
    );

    packagesResult.fold(
      (failure) {
        currentState = currentState.copyWith(
          isLoadingPackages: false,
          packagesError: failure.message,
        );
      },
      (packages) {
        currentState = currentState.copyWith(
          isLoadingPackages: false,
          packages: packages,
          clearPackagesError: true,
        );
      },
    );
    emit(currentState);

    // Load subscriptions
    final subscriptionsResult = await getMySubscriptionsUseCase(
      GetMySubscriptionsParams(),
    );

    subscriptionsResult.fold(
      (failure) {
        currentState = currentState.copyWith(
          isLoadingSubscriptions: false,
          subscriptionsError: failure.message,
        );
      },
      (subscriptions) {
        currentState = currentState.copyWith(
          isLoadingSubscriptions: false,
          subscriptions: subscriptions,
          clearSubscriptionsError: true,
        );
      },
    );
    emit(currentState);

    // Load receipts
    final receiptsResult = await getMyReceiptsUseCase(
      GetMyReceiptsParams(),
    );

    receiptsResult.fold(
      (failure) {
        currentState = currentState.copyWith(
          isLoadingReceipts: false,
          receiptsError: failure.message,
        );
      },
      (receipts) {
        currentState = currentState.copyWith(
          isLoadingReceipts: false,
          receipts: receipts,
          clearReceiptsError: true,
        );
      },
    );
    emit(currentState);
  }

  Future<void> _onLoadPackages(
    LoadSubscriptionPackagesEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(_currentData.copyWith(
      isLoadingPackages: true,
      clearPackagesError: true,
    ));

    final result = await getSubscriptionPackagesUseCase(
      GetSubscriptionPackagesParams(activeOnly: event.activeOnly),
    );

    result.fold(
      (failure) => emit(_currentData.copyWith(
        isLoadingPackages: false,
        packagesError: failure.message,
      )),
      (packages) => emit(_currentData.copyWith(
        isLoadingPackages: false,
        packages: packages,
        clearPackagesError: true,
      )),
    );
  }

  Future<void> _onLoadMySubscriptions(
    LoadMySubscriptionsEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(_currentData.copyWith(
      isLoadingSubscriptions: true,
      clearSubscriptionsError: true,
    ));

    final result = await getMySubscriptionsUseCase(
      GetMySubscriptionsParams(activeOnly: event.activeOnly),
    );

    result.fold(
      (failure) => emit(_currentData.copyWith(
        isLoadingSubscriptions: false,
        subscriptionsError: failure.message,
      )),
      (subscriptions) => emit(_currentData.copyWith(
        isLoadingSubscriptions: false,
        subscriptions: subscriptions,
        clearSubscriptionsError: true,
      )),
    );
  }

  Future<void> _onValidateCode(
    ValidateCodeEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(
      const SubscriptionActionInProgress(message: 'جاري التحقق من الكود...'),
    );

    final result = await validateSubscriptionCodeUseCase(
      ValidateCodeParams(code: event.code),
    );

    result.fold(
      (failure) => emit(SubscriptionError(message: failure.message)),
      (validationResult) => emit(CodeValidated(validationResult: validationResult)),
    );
  }

  Future<void> _onRedeemCode(
    RedeemCodeEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionActionInProgress(message: 'جاري تفعيل الاشتراك...'));

    final result = await redeemSubscriptionCodeUseCase(
      RedeemCodeParams(code: event.code),
    );

    result.fold(
      (failure) => emit(SubscriptionError(message: failure.message)),
      (subscription) => emit(CodeRedeemed(subscription: subscription)),
    );
  }

  Future<void> _onSubmitReceipt(
    SubmitPaymentReceiptEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(
      const SubscriptionActionInProgress(message: 'جاري رفع إيصال الدفع...'),
    );

    final result = await submitReceiptUseCase(
      SubmitReceiptParams(
        courseId: event.courseId,
        packageId: event.packageId,
        receiptImage: event.receiptImage,
        amountDzd: event.amountDzd,
        paymentMethod: event.paymentMethod,
        transactionReference: event.transactionReference,
        userNotes: event.userNotes,
      ),
    );

    result.fold(
      (failure) => emit(SubscriptionError(message: failure.message)),
      (receipt) => emit(PaymentReceiptSubmitted(receipt: receipt)),
    );
  }

  Future<void> _onLoadMyReceipts(
    LoadMyPaymentReceiptsEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(_currentData.copyWith(
      isLoadingReceipts: true,
      clearReceiptsError: true,
    ));

    final result = await getMyReceiptsUseCase(
      GetMyReceiptsParams(status: event.status),
    );

    result.fold(
      (failure) => emit(_currentData.copyWith(
        isLoadingReceipts: false,
        receiptsError: failure.message,
      )),
      (receipts) => emit(_currentData.copyWith(
        isLoadingReceipts: false,
        receipts: receipts,
        clearReceiptsError: true,
      )),
    );
  }
}
