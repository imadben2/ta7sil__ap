import 'package:equatable/equatable.dart';

/// Academic Setup Events
abstract class AcademicSetupEvent extends Equatable {
  const AcademicSetupEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load academic phases
class LoadAcademicPhases extends AcademicSetupEvent {
  const LoadAcademicPhases();
}

/// Event to load academic years for a specific phase
class LoadAcademicYears extends AcademicSetupEvent {
  final int phaseId;

  const LoadAcademicYears(this.phaseId);

  @override
  List<Object?> get props => [phaseId];
}

/// Event to load academic streams for a specific year
class LoadAcademicStreams extends AcademicSetupEvent {
  final int yearId;

  const LoadAcademicStreams(this.yearId);

  @override
  List<Object?> get props => [yearId];
}

/// Event to submit academic profile
class SubmitAcademicProfile extends AcademicSetupEvent {
  final int phaseId;
  final int yearId;
  final int streamId;

  const SubmitAcademicProfile({
    required this.phaseId,
    required this.yearId,
    required this.streamId,
  });

  @override
  List<Object?> get props => [phaseId, yearId, streamId];
}

/// Event to reset to initial state
class ResetAcademicSetup extends AcademicSetupEvent {
  const ResetAcademicSetup();
}
