import 'package:equatable/equatable.dart';
import '../../domain/entities/bac_enums.dart';

/// Base class for BAC events
abstract class BacEvent extends Equatable {
  const BacEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load BAC years
class LoadBacYearsEvent extends BacEvent {
  final bool forceRefresh;

  const LoadBacYearsEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Event to load sessions for a specific year
class LoadBacSessionsEvent extends BacEvent {
  final String yearSlug;

  const LoadBacSessionsEvent(this.yearSlug);

  @override
  List<Object?> get props => [yearSlug];
}

/// Event to load subjects for a specific session
class LoadBacSubjectsEvent extends BacEvent {
  final String sessionSlug;

  const LoadBacSubjectsEvent(this.sessionSlug);

  @override
  List<Object?> get props => [sessionSlug];
}

/// Event to load subjects for a specific year (directly, without session)
class LoadSubjectsByYearEvent extends BacEvent {
  final String yearSlug;
  final int? streamId;

  const LoadSubjectsByYearEvent(this.yearSlug, {this.streamId});

  @override
  List<Object?> get props => [yearSlug, streamId];
}

/// Event to load chapters for a specific subject
class LoadBacChaptersEvent extends BacEvent {
  final String subjectSlug;

  const LoadBacChaptersEvent(this.subjectSlug);

  @override
  List<Object?> get props => [subjectSlug];
}

/// Event to create a new simulation
class CreateSimulationEvent extends BacEvent {
  final int bacSubjectId;
  final SimulationMode mode;
  final DifficultyLevel? difficulty;
  final List<int>? chapterIds;
  final int totalQuestions;
  final int durationMinutes;

  const CreateSimulationEvent({
    required this.bacSubjectId,
    required this.mode,
    this.difficulty,
    this.chapterIds,
    required this.totalQuestions,
    required this.durationMinutes,
  });

  @override
  List<Object?> get props => [
    bacSubjectId,
    mode,
    difficulty,
    chapterIds,
    totalQuestions,
    durationMinutes,
  ];
}

/// Event to start a simulation
class StartSimulationEvent extends BacEvent {
  final int simulationId;

  const StartSimulationEvent(this.simulationId);

  @override
  List<Object?> get props => [simulationId];
}

/// Event to pause a simulation
class PauseSimulationEvent extends BacEvent {
  final int simulationId;

  const PauseSimulationEvent(this.simulationId);

  @override
  List<Object?> get props => [simulationId];
}

/// Event to resume a paused simulation
class ResumeSimulationEvent extends BacEvent {
  final int simulationId;

  const ResumeSimulationEvent(this.simulationId);

  @override
  List<Object?> get props => [simulationId];
}

/// Event to submit simulation answers
class SubmitSimulationEvent extends BacEvent {
  final int simulationId;
  final List<Map<String, dynamic>> answers;
  final int elapsedSeconds;
  final String? notes;

  const SubmitSimulationEvent({
    required this.simulationId,
    required this.answers,
    required this.elapsedSeconds,
    this.notes,
  });

  @override
  List<Object?> get props => [simulationId, answers, elapsedSeconds, notes];
}

/// Event to load simulation history
class LoadSimulationHistoryEvent extends BacEvent {
  final int? bacSubjectId;
  final SimulationStatus? status;
  final int? limit;

  const LoadSimulationHistoryEvent({
    this.bacSubjectId,
    this.status,
    this.limit,
  });

  @override
  List<Object?> get props => [bacSubjectId, status, limit];
}

/// Event to load specific simulation results
class LoadSimulationResultsEvent extends BacEvent {
  final int simulationId;

  const LoadSimulationResultsEvent(this.simulationId);

  @override
  List<Object?> get props => [simulationId];
}

/// Event to load subject performance statistics
class LoadSubjectPerformanceEvent extends BacEvent {
  final String subjectSlug;

  const LoadSubjectPerformanceEvent(this.subjectSlug);

  @override
  List<Object?> get props => [subjectSlug];
}

/// Event to download an exam PDF
class DownloadExamPdfEvent extends BacEvent {
  final int examId;
  final String examTitle;

  const DownloadExamPdfEvent({required this.examId, required this.examTitle});

  @override
  List<Object?> get props => [examId, examTitle];
}

/// Event to load saved simulations from local storage
class LoadSavedSimulationsEvent extends BacEvent {
  const LoadSavedSimulationsEvent();
}

/// Event to clear BAC cache
class ClearBacCacheEvent extends BacEvent {
  const ClearBacCacheEvent();
}

/// Event to load exams for a specific subject and year
class LoadExamsBySubjectAndYearEvent extends BacEvent {
  final int subjectId;
  final String subjectSlug;
  final String yearSlug;

  const LoadExamsBySubjectAndYearEvent({
    required this.subjectId,
    required this.subjectSlug,
    required this.yearSlug,
  });

  @override
  List<Object?> get props => [subjectId, subjectSlug, yearSlug];
}
