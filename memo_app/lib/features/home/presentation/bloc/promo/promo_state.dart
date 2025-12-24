import 'package:equatable/equatable.dart';
import '../../../domain/entities/promo_entity.dart';

/// Base class for promo states
abstract class PromoState extends Equatable {
  const PromoState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class PromoInitial extends PromoState {
  const PromoInitial();
}

/// Loading state while fetching promos
class PromoLoading extends PromoState {
  const PromoLoading();
}

/// State when promos are successfully loaded
class PromoLoaded extends PromoState {
  final List<PromoEntity> promos;
  final bool sectionEnabled;

  const PromoLoaded({
    required this.promos,
    this.sectionEnabled = true,
  });

  @override
  List<Object?> get props => [promos, sectionEnabled];
}

/// State when there's an error loading promos
class PromoError extends PromoState {
  final String message;
  final List<PromoEntity>? cachedPromos;

  const PromoError({
    required this.message,
    this.cachedPromos,
  });

  /// Whether we have cached data to show despite the error
  bool get hasCachedData => cachedPromos != null && cachedPromos!.isNotEmpty;

  @override
  List<Object?> get props => [message, cachedPromos];
}
