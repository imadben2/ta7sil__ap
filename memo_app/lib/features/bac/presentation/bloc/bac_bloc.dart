import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_bac_years.dart';
import '../../domain/usecases/get_bac_sessions.dart';
import '../../domain/usecases/get_bac_subjects.dart';
import '../../domain/usecases/get_bac_chapters.dart';
import '../../domain/usecases/create_simulation.dart';
import '../../domain/usecases/manage_simulation.dart';
import '../../domain/usecases/submit_simulation.dart';
import '../../domain/usecases/get_simulation_history.dart';
import '../../domain/usecases/get_simulation_results.dart';
import '../../domain/usecases/get_subject_performance.dart';
import '../../domain/usecases/download_exam_pdf.dart';
import '../../domain/repositories/bac_repository.dart';
import 'bac_event.dart';
import 'bac_state.dart';

/// BLoC for managing BAC feature state
class BacBloc extends Bloc<BacEvent, BacState> {
  final GetBacYears getBacYears;
  final GetBacSessions getBacSessions;
  final GetBacSubjects getBacSubjects;
  final GetBacChapters getBacChapters;
  final CreateSimulation createSimulation;
  final StartSimulation startSimulation;
  final PauseSimulation pauseSimulation;
  final ResumeSimulation resumeSimulation;
  final SubmitSimulation submitSimulation;
  final GetSimulationHistory getSimulationHistory;
  final GetSimulationResults getSimulationResults;
  final GetSubjectPerformance getSubjectPerformance;
  final DownloadExamPdf downloadExamPdf;
  final BacRepository repository;

  BacBloc({
    required this.getBacYears,
    required this.getBacSessions,
    required this.getBacSubjects,
    required this.getBacChapters,
    required this.createSimulation,
    required this.startSimulation,
    required this.pauseSimulation,
    required this.resumeSimulation,
    required this.submitSimulation,
    required this.getSimulationHistory,
    required this.getSimulationResults,
    required this.getSubjectPerformance,
    required this.downloadExamPdf,
    required this.repository,
  }) : super(const BacInitial()) {
    on<LoadBacYearsEvent>(_onLoadBacYears);
    on<LoadBacSessionsEvent>(_onLoadBacSessions);
    on<LoadBacSubjectsEvent>(_onLoadBacSubjects);
    on<LoadSubjectsByYearEvent>(_onLoadSubjectsByYear);
    on<LoadExamsBySubjectAndYearEvent>(_onLoadExamsBySubjectAndYear);
    on<LoadBacChaptersEvent>(_onLoadBacChapters);
    on<CreateSimulationEvent>(_onCreateSimulation);
    on<StartSimulationEvent>(_onStartSimulation);
    on<PauseSimulationEvent>(_onPauseSimulation);
    on<ResumeSimulationEvent>(_onResumeSimulation);
    on<SubmitSimulationEvent>(_onSubmitSimulation);
    on<LoadSimulationHistoryEvent>(_onLoadSimulationHistory);
    on<LoadSimulationResultsEvent>(_onLoadSimulationResults);
    on<LoadSubjectPerformanceEvent>(_onLoadSubjectPerformance);
    on<DownloadExamPdfEvent>(_onDownloadExamPdf);
    on<LoadSavedSimulationsEvent>(_onLoadSavedSimulations);
    on<ClearBacCacheEvent>(_onClearBacCache);
  }

  Future<void> _onLoadBacYears(
    LoadBacYearsEvent event,
    Emitter<BacState> emit,
  ) async {
    emit(const BacLoading());
    final result = await getBacYears(forceRefresh: event.forceRefresh);
    result.fold(
      (failure) => emit(BacError(failure.message)),
      (years) => emit(BacYearsLoaded(years)),
    );
  }

  Future<void> _onLoadBacSessions(
    LoadBacSessionsEvent event,
    Emitter<BacState> emit,
  ) async {
    emit(const BacLoading());
    final result = await getBacSessions(event.yearSlug);
    result.fold(
      (failure) => emit(BacError(failure.message)),
      (sessions) =>
          emit(BacSessionsLoaded(yearSlug: event.yearSlug, sessions: sessions)),
    );
  }

  Future<void> _onLoadBacSubjects(
    LoadBacSubjectsEvent event,
    Emitter<BacState> emit,
  ) async {
    emit(const BacLoading());
    final result = await getBacSubjects(event.sessionSlug);
    result.fold(
      (failure) => emit(BacError(failure.message)),
      (subjects) => emit(
        BacSubjectsLoaded(sessionSlug: event.sessionSlug, subjects: subjects),
      ),
    );
  }

  Future<void> _onLoadSubjectsByYear(
    LoadSubjectsByYearEvent event,
    Emitter<BacState> emit,
  ) async {
    emit(const BacLoading());
    final result = await repository.getSubjectsByYear(
      event.yearSlug,
      streamId: event.streamId,
    );
    result.fold(
      (failure) => emit(BacError(failure.message)),
      (subjects) => emit(
        BacSubjectsByYearLoaded(yearSlug: event.yearSlug, subjects: subjects),
      ),
    );
  }

  Future<void> _onLoadExamsBySubjectAndYear(
    LoadExamsBySubjectAndYearEvent event,
    Emitter<BacState> emit,
  ) async {
    emit(const BacLoading());
    final result = await repository.getExamsBySubject(
      subjectId: event.subjectId,
      yearSlug: event.yearSlug,
    );
    result.fold(
      (failure) => emit(BacError(failure.message)),
      (exams) => emit(
        BacExamsBySubjectLoaded(
          subjectId: event.subjectId,
          yearSlug: event.yearSlug,
          exams: exams,
        ),
      ),
    );
  }

  Future<void> _onLoadBacChapters(
    LoadBacChaptersEvent event,
    Emitter<BacState> emit,
  ) async {
    emit(const BacLoading());
    final result = await getBacChapters(event.subjectSlug);
    result.fold(
      (failure) => emit(BacError(failure.message)),
      (chapters) => emit(
        BacChaptersLoaded(subjectSlug: event.subjectSlug, chapters: chapters),
      ),
    );
  }

  Future<void> _onCreateSimulation(
    CreateSimulationEvent event,
    Emitter<BacState> emit,
  ) async {
    emit(const BacLoading());
    final result = await createSimulation(
      CreateSimulationParams(
        bacSubjectId: event.bacSubjectId,
        mode: event.mode,
        difficulty: event.difficulty,
        chapterIds: event.chapterIds,
        totalQuestions: event.totalQuestions,
        durationMinutes: event.durationMinutes,
      ),
    );
    result.fold(
      (failure) => emit(BacError(failure.message)),
      (simulation) => emit(SimulationCreated(simulation)),
    );
  }

  Future<void> _onStartSimulation(
    StartSimulationEvent event,
    Emitter<BacState> emit,
  ) async {
    emit(const BacLoading());
    final result = await startSimulation(event.simulationId);
    result.fold(
      (failure) => emit(BacError(failure.message)),
      (simulation) => emit(SimulationStarted(simulation)),
    );
  }

  Future<void> _onPauseSimulation(
    PauseSimulationEvent event,
    Emitter<BacState> emit,
  ) async {
    emit(const BacLoading());
    final result = await pauseSimulation(event.simulationId);
    result.fold(
      (failure) => emit(BacError(failure.message)),
      (simulation) => emit(SimulationPaused(simulation)),
    );
  }

  Future<void> _onResumeSimulation(
    ResumeSimulationEvent event,
    Emitter<BacState> emit,
  ) async {
    emit(const BacLoading());
    final result = await resumeSimulation(event.simulationId);
    result.fold(
      (failure) => emit(BacError(failure.message)),
      (simulation) => emit(SimulationResumed(simulation)),
    );
  }

  Future<void> _onSubmitSimulation(
    SubmitSimulationEvent event,
    Emitter<BacState> emit,
  ) async {
    emit(const BacLoading());
    final result = await submitSimulation(
      SubmitSimulationParams(
        simulationId: event.simulationId,
        answers: event.answers,
        elapsedSeconds: event.elapsedSeconds,
        notes: event.notes,
      ),
    );
    result.fold(
      (failure) => emit(BacError(failure.message)),
      (results) => emit(SimulationSubmitted(results)),
    );
  }

  Future<void> _onLoadSimulationHistory(
    LoadSimulationHistoryEvent event,
    Emitter<BacState> emit,
  ) async {
    emit(const BacLoading());
    final result = await getSimulationHistory(
      GetSimulationHistoryParams(
        bacSubjectId: event.bacSubjectId,
        status: event.status,
        limit: event.limit,
      ),
    );
    result.fold(
      (failure) => emit(BacError(failure.message)),
      (history) => emit(SimulationHistoryLoaded(history)),
    );
  }

  Future<void> _onLoadSimulationResults(
    LoadSimulationResultsEvent event,
    Emitter<BacState> emit,
  ) async {
    emit(const BacLoading());
    final result = await getSimulationResults(event.simulationId);
    result.fold(
      (failure) => emit(BacError(failure.message)),
      (results) => emit(SimulationResultsLoaded(results)),
    );
  }

  Future<void> _onLoadSubjectPerformance(
    LoadSubjectPerformanceEvent event,
    Emitter<BacState> emit,
  ) async {
    emit(const BacLoading());
    final result = await getSubjectPerformance(event.subjectSlug);
    result.fold(
      (failure) => emit(BacError(failure.message)),
      (performance) => emit(
        SubjectPerformanceLoaded(
          subjectSlug: event.subjectSlug,
          performance: performance,
        ),
      ),
    );
  }

  Future<void> _onDownloadExamPdf(
    DownloadExamPdfEvent event,
    Emitter<BacState> emit,
  ) async {
    emit(const ExamPdfDownloading(0));
    final result = await downloadExamPdf(
      DownloadExamPdfParams(examId: event.examId, examTitle: event.examTitle),
    );
    result.fold(
      (failure) => emit(BacError(failure.message)),
      (filePath) => emit(ExamPdfDownloaded(filePath)),
    );
  }

  Future<void> _onLoadSavedSimulations(
    LoadSavedSimulationsEvent event,
    Emitter<BacState> emit,
  ) async {
    emit(const BacLoading());
    final result = await repository.getAllSavedSimulations();
    result.fold(
      (failure) => emit(BacError(failure.message)),
      (simulations) => emit(SavedSimulationsLoaded(simulations)),
    );
  }

  Future<void> _onClearBacCache(
    ClearBacCacheEvent event,
    Emitter<BacState> emit,
  ) async {
    emit(const BacLoading());
    final result = await repository.clearCache();
    result.fold(
      (failure) => emit(BacError(failure.message)),
      (_) => emit(const BacCacheCleared()),
    );
  }
}
