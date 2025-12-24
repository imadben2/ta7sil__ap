import 'package:equatable/equatable.dart';

/// Base class for promo events
abstract class PromoEvent extends Equatable {
  const PromoEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load promos from API
class LoadPromos extends PromoEvent {
  const LoadPromos();
}

/// Event to refresh promos (pull to refresh)
class RefreshPromos extends PromoEvent {
  const RefreshPromos();
}

/// Event to record a promo click (analytics)
class RecordPromoClick extends PromoEvent {
  final int promoId;

  const RecordPromoClick({required this.promoId});

  @override
  List<Object?> get props => [promoId];
}
