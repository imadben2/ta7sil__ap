import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/promo_entity.dart';
import '../../../domain/usecases/get_promos_usecase.dart';
import '../../../domain/usecases/record_promo_click_usecase.dart';
import 'promo_event.dart';
import 'promo_state.dart';

/// BLoC for managing promo slider state
class PromoBloc extends Bloc<PromoEvent, PromoState> {
  final GetPromosUseCase getPromosUseCase;
  final RecordPromoClickUseCase recordPromoClickUseCase;

  // Cache for showing data during errors
  List<PromoEntity>? _cachedPromos;

  PromoBloc({
    required this.getPromosUseCase,
    required this.recordPromoClickUseCase,
  }) : super(const PromoInitial()) {
    on<LoadPromos>(_onLoadPromos);
    on<RefreshPromos>(_onRefreshPromos);
    on<RecordPromoClick>(_onRecordPromoClick);
  }

  /// Handle LoadPromos event
  Future<void> _onLoadPromos(
    LoadPromos event,
    Emitter<PromoState> emit,
  ) async {
    emit(const PromoLoading());

    final result = await getPromosUseCase();

    result.fold(
      (failure) {
        emit(PromoError(
          message: failure.message,
          cachedPromos: _cachedPromos,
        ));
      },
      (response) {
        _cachedPromos = response.promos;
        emit(PromoLoaded(
          promos: response.promos,
          sectionEnabled: response.sectionEnabled,
        ));
      },
    );
  }

  /// Handle RefreshPromos event
  Future<void> _onRefreshPromos(
    RefreshPromos event,
    Emitter<PromoState> emit,
  ) async {
    // Keep current data while refreshing
    final currentPromos = _cachedPromos;

    final result = await getPromosUseCase();

    result.fold(
      (failure) {
        // On refresh failure, keep showing cached data if available
        if (currentPromos != null && currentPromos.isNotEmpty) {
          emit(PromoLoaded(
            promos: currentPromos,
            sectionEnabled: true,
          ));
        } else {
          emit(PromoError(
            message: failure.message,
            cachedPromos: currentPromos,
          ));
        }
      },
      (response) {
        _cachedPromos = response.promos;
        emit(PromoLoaded(
          promos: response.promos,
          sectionEnabled: response.sectionEnabled,
        ));
      },
    );
  }

  /// Handle RecordPromoClick event (fire-and-forget analytics)
  Future<void> _onRecordPromoClick(
    RecordPromoClick event,
    Emitter<PromoState> emit,
  ) async {
    // Fire-and-forget: don't change state, just record the click
    await recordPromoClickUseCase(event.promoId);
  }
}
