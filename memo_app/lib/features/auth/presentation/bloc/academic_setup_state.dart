import 'package:equatable/equatable.dart';
import '../../domain/entities/academic_entities.dart';

/// Academic Setup States
abstract class AcademicSetupState extends Equatable {
  const AcademicSetupState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AcademicSetupInitial extends AcademicSetupState {
  const AcademicSetupInitial();
}

/// Loading state
class AcademicSetupLoading extends AcademicSetupState {
  const AcademicSetupLoading();
}

/// Phases loaded state
class AcademicPhasesLoaded extends AcademicSetupState {
  final List<AcademicPhase> phases;

  const AcademicPhasesLoaded(this.phases);

  @override
  List<Object?> get props => [phases];
}

/// Years loaded state
class AcademicYearsLoaded extends AcademicSetupState {
  final AcademicPhase selectedPhase;
  final List<AcademicYear> years;

  const AcademicYearsLoaded({required this.selectedPhase, required this.years});

  @override
  List<Object?> get props => [selectedPhase, years];
}

/// Streams loaded state
class AcademicStreamsLoaded extends AcademicSetupState {
  final AcademicPhase selectedPhase;
  final AcademicYear selectedYear;
  final List<AcademicStream> streams;

  const AcademicStreamsLoaded({
    required this.selectedPhase,
    required this.selectedYear,
    required this.streams,
  });

  @override
  List<Object?> get props => [selectedPhase, selectedYear, streams];
}

/// Profile updated successfully
class AcademicProfileUpdated extends AcademicSetupState {
  const AcademicProfileUpdated();
}

/// Error state
class AcademicSetupError extends AcademicSetupState {
  final String message;

  const AcademicSetupError(this.message);

  @override
  List<Object?> get props => [message];
}
