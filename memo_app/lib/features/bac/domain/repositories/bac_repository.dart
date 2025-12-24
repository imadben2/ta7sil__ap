import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bac_year_entity.dart';
import '../entities/bac_session_entity.dart';
import '../entities/bac_subject_entity.dart';
import '../entities/bac_chapter_info_entity.dart';
import '../entities/bac_simulation_entity.dart';
import '../entities/simulation_results_entity.dart';
import '../entities/bac_enums.dart';

/// Repository interface for BAC feature
/// Defines contracts for all data operations
abstract class BacRepository {
  /// Get all available BAC years
  /// GET /api/v1/bac/years
  /// [forceRefresh] - bypass cache and fetch from API
  Future<Either<Failure, List<BacYearEntity>>> getBacYears({
    bool forceRefresh = false,
  });

  /// Get sessions for a specific BAC year
  /// GET /api/v1/bac/years/{yearSlug}/sessions
  Future<Either<Failure, List<BacSessionEntity>>> getBacSessions(
    String yearSlug,
  );

  /// Get subjects for a specific session
  /// GET /api/v1/bac/sessions/{sessionSlug}/subjects
  Future<Either<Failure, List<BacSubjectEntity>>> getBacSubjects(
    String sessionSlug,
  );

  /// Get subjects for a specific year (directly, without session)
  /// GET /api/v1/bac/years/{yearSlug}/subjects
  /// [streamId] - Optional: filter by academic stream
  Future<Either<Failure, List<BacSubjectEntity>>> getSubjectsByYear(
    String yearSlug, {
    int? streamId,
  });

  /// Get chapter information for a specific BAC subject
  /// GET /api/v1/bac/subjects/{subjectSlug}/chapters
  Future<Either<Failure, List<BacChapterInfoEntity>>> getBacChapters(
    String subjectSlug,
  );

  /// Get BAC exams for a specific content library subject and year
  /// GET /api/v1/bac/exams-by-subject?subject_id=X&year_slug=Y
  /// [subjectId] - content library subject ID
  /// [yearSlug] - BAC year (e.g., "2024")
  /// [streamId] - Optional: filter by academic stream
  Future<Either<Failure, List<BacSubjectEntity>>> getExamsBySubject({
    required int subjectId,
    required String yearSlug,
    int? streamId,
  });

  /// Create a new simulation
  /// POST /api/v1/bac/simulations
  /// Body: {
  ///   bac_subject_id, mode, difficulty (optional),
  ///   chapter_ids[] (optional), total_questions, duration_minutes
  /// }
  Future<Either<Failure, BacSimulationEntity>> createSimulation({
    required int bacSubjectId,
    required SimulationMode mode,
    DifficultyLevel? difficulty,
    List<int>? chapterIds,
    required int totalQuestions,
    required int durationMinutes,
  });

  /// Start a simulation (mark as in_progress)
  /// POST /api/v1/bac/simulations/{id}/start
  Future<Either<Failure, BacSimulationEntity>> startSimulation(
    int simulationId,
  );

  /// Pause a simulation
  /// POST /api/v1/bac/simulations/{id}/pause
  Future<Either<Failure, BacSimulationEntity>> pauseSimulation(
    int simulationId,
  );

  /// Resume a paused simulation
  /// POST /api/v1/bac/simulations/{id}/resume
  Future<Either<Failure, BacSimulationEntity>> resumeSimulation(
    int simulationId,
  );

  /// Submit simulation answers and complete
  /// POST /api/v1/bac/simulations/{id}/submit
  /// Body: {
  ///   answers: [{question_id, answer_id, time_spent}],
  ///   elapsed_seconds, notes (optional)
  /// }
  Future<Either<Failure, SimulationResultsEntity>> submitSimulation({
    required int simulationId,
    required List<Map<String, dynamic>> answers,
    required int elapsedSeconds,
    String? notes,
  });

  /// Get user's simulation history
  /// GET /api/v1/bac/simulations?filter[status]=completed
  Future<Either<Failure, List<BacSimulationEntity>>> getSimulationHistory({
    int? bacSubjectId,
    SimulationStatus? status,
    int? limit,
  });

  /// Get detailed results for a specific simulation
  /// GET /api/v1/bac/simulations/{id}/results
  Future<Either<Failure, SimulationResultsEntity>> getSimulationResults(
    int simulationId,
  );

  /// Get user's performance statistics for a subject
  /// GET /api/v1/bac/subjects/{subjectSlug}/performance
  Future<Either<Failure, Map<String, dynamic>>> getSubjectPerformance(
    String subjectSlug,
  );

  /// Download exam PDF
  /// GET /api/v1/bac/exams/{examId}/download
  /// Returns the file path where PDF is saved
  Future<Either<Failure, String>> downloadExamPdf(int examId, String examTitle);

  /// Get all saved simulations from local storage
  Future<Either<Failure, List<BacSimulationEntity>>> getAllSavedSimulations();

  /// Clear all cached data
  Future<Either<Failure, void>> clearCache();
}
