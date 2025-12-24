import 'package:equatable/equatable.dart';
import '../../domain/entities/bac_year_entity.dart';
import '../../domain/entities/bac_session_entity.dart';
import '../../domain/entities/bac_subject_entity.dart';
import '../../domain/entities/bac_chapter_info_entity.dart';
import '../../domain/entities/bac_simulation_entity.dart';
import '../../domain/entities/simulation_results_entity.dart';

/// Base class for BAC states
abstract class BacState extends Equatable {
  const BacState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BacInitial extends BacState {
  const BacInitial();
}

/// Loading state
class BacLoading extends BacState {
  const BacLoading();
}

/// State when BAC years are loaded
class BacYearsLoaded extends BacState {
  final List<BacYearEntity> years;

  const BacYearsLoaded(this.years);

  @override
  List<Object?> get props => [years];
}

/// State when BAC sessions are loaded
class BacSessionsLoaded extends BacState {
  final String yearSlug;
  final List<BacSessionEntity> sessions;

  const BacSessionsLoaded({required this.yearSlug, required this.sessions});

  @override
  List<Object?> get props => [yearSlug, sessions];
}

/// State when BAC subjects are loaded
class BacSubjectsLoaded extends BacState {
  final String sessionSlug;
  final List<BacSubjectEntity> subjects;

  const BacSubjectsLoaded({required this.sessionSlug, required this.subjects});

  @override
  List<Object?> get props => [sessionSlug, subjects];
}

/// State when BAC subjects are loaded by year (directly)
class BacSubjectsByYearLoaded extends BacState {
  final String yearSlug;
  final List<BacSubjectEntity> subjects;

  const BacSubjectsByYearLoaded({required this.yearSlug, required this.subjects});

  @override
  List<Object?> get props => [yearSlug, subjects];
}

/// State when BAC exams are loaded by subject and year
class BacExamsBySubjectLoaded extends BacState {
  final int subjectId;
  final String yearSlug;
  final List<BacSubjectEntity> exams;

  const BacExamsBySubjectLoaded({
    required this.subjectId,
    required this.yearSlug,
    required this.exams,
  });

  @override
  List<Object?> get props => [subjectId, yearSlug, exams];
}

/// State when BAC chapters are loaded
class BacChaptersLoaded extends BacState {
  final String subjectSlug;
  final List<BacChapterInfoEntity> chapters;

  const BacChaptersLoaded({required this.subjectSlug, required this.chapters});

  @override
  List<Object?> get props => [subjectSlug, chapters];
}

/// State when a simulation is created
class SimulationCreated extends BacState {
  final BacSimulationEntity simulation;

  const SimulationCreated(this.simulation);

  @override
  List<Object?> get props => [simulation];
}

/// State when a simulation is started
class SimulationStarted extends BacState {
  final BacSimulationEntity simulation;

  const SimulationStarted(this.simulation);

  @override
  List<Object?> get props => [simulation];
}

/// State when a simulation is paused
class SimulationPaused extends BacState {
  final BacSimulationEntity simulation;

  const SimulationPaused(this.simulation);

  @override
  List<Object?> get props => [simulation];
}

/// State when a simulation is resumed
class SimulationResumed extends BacState {
  final BacSimulationEntity simulation;

  const SimulationResumed(this.simulation);

  @override
  List<Object?> get props => [simulation];
}

/// State when simulation is submitted and results are available
class SimulationSubmitted extends BacState {
  final SimulationResultsEntity results;

  const SimulationSubmitted(this.results);

  @override
  List<Object?> get props => [results];
}

/// State when simulation history is loaded
class SimulationHistoryLoaded extends BacState {
  final List<BacSimulationEntity> history;

  const SimulationHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

/// State when simulation results are loaded
class SimulationResultsLoaded extends BacState {
  final SimulationResultsEntity results;

  const SimulationResultsLoaded(this.results);

  @override
  List<Object?> get props => [results];
}

/// State when subject performance is loaded
class SubjectPerformanceLoaded extends BacState {
  final String subjectSlug;
  final Map<String, dynamic> performance;

  const SubjectPerformanceLoaded({
    required this.subjectSlug,
    required this.performance,
  });

  @override
  List<Object?> get props => [subjectSlug, performance];
}

/// State when exam PDF is downloaded
class ExamPdfDownloaded extends BacState {
  final String filePath;

  const ExamPdfDownloaded(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// State for PDF download progress
class ExamPdfDownloading extends BacState {
  final int progress; // 0-100

  const ExamPdfDownloading(this.progress);

  @override
  List<Object?> get props => [progress];
}

/// State when saved simulations are loaded
class SavedSimulationsLoaded extends BacState {
  final List<BacSimulationEntity> simulations;

  const SavedSimulationsLoaded(this.simulations);

  @override
  List<Object?> get props => [simulations];
}

/// State when cache is cleared
class BacCacheCleared extends BacState {
  const BacCacheCleared();
}

/// Error state
class BacError extends BacState {
  final String message;

  const BacError(this.message);

  @override
  List<Object?> get props => [message];
}
