import 'package:equatable/equatable.dart';
import '../../../domain/entities/sponsor_entity.dart';

/// Base class for all sponsors states
abstract class SponsorsState extends Equatable {
  const SponsorsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before sponsors are loaded
class SponsorsInitial extends SponsorsState {
  const SponsorsInitial();
}

/// State while sponsors are being loaded
class SponsorsLoading extends SponsorsState {
  const SponsorsLoading();
}

/// State when sponsors are successfully loaded
class SponsorsLoaded extends SponsorsState {
  final List<SponsorEntity> sponsors;
  /// Whether the sponsors section is enabled from admin settings
  final bool sectionEnabled;

  const SponsorsLoaded({
    required this.sponsors,
    this.sectionEnabled = true,
  });

  @override
  List<Object?> get props => [sponsors, sectionEnabled];

  SponsorsLoaded copyWith({
    List<SponsorEntity>? sponsors,
    bool? sectionEnabled,
  }) {
    return SponsorsLoaded(
      sponsors: sponsors ?? this.sponsors,
      sectionEnabled: sectionEnabled ?? this.sectionEnabled,
    );
  }
}

/// State when there's an error loading sponsors
class SponsorsError extends SponsorsState {
  final String message;

  const SponsorsError({required this.message});

  @override
  List<Object?> get props => [message];
}
