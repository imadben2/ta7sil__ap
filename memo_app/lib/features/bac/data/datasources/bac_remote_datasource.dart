import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/bac_enums.dart';
import '../models/bac_year_model.dart';
import '../models/bac_session_model.dart';
import '../models/bac_subject_model.dart';
import '../models/bac_chapter_info_model.dart';
import '../models/bac_simulation_model.dart';
import '../models/simulation_results_model.dart';

/// Remote data source for BAC feature using Laravel API
class BacRemoteDataSource {
  final Dio dio;

  BacRemoteDataSource({required this.dio});

  /// Get all available BAC years
  /// GET /api/v1/bac/years
  Future<List<BacYearModel>> getBacYears() async {
    final response = await dio.get(ApiConstants.bacYears);
    final data = response.data['data'] as List;
    return data.map((json) => BacYearModel.fromJson(json)).toList();
  }

  /// Get sessions for a specific BAC year
  /// GET /api/v1/bac/years/{yearSlug}/sessions
  Future<List<BacSessionModel>> getBacSessions(String yearSlug) async {
    final response = await dio.get(
      '${ApiConstants.bacYears}/$yearSlug/sessions',
    );
    final data = response.data['data'] as List;
    return data.map((json) => BacSessionModel.fromJson(json)).toList();
  }

  /// Get subjects for a specific session
  /// GET /api/v1/bac/sessions/{sessionSlug}/subjects
  Future<List<BacSubjectModel>> getBacSubjects(String sessionSlug) async {
    final response = await dio.get(
      '${ApiConstants.bacSessions}/$sessionSlug/subjects',
    );
    final data = response.data['data'] as List;
    return data.map((json) => BacSubjectModel.fromJson(json)).toList();
  }

  /// Get subjects for a specific year (directly, without session)
  /// GET /api/v1/bac/years/{yearSlug}/subjects
  /// [streamId] - Optional: filter by academic stream
  Future<List<BacSubjectModel>> getSubjectsByYear(String yearSlug, {int? streamId}) async {
    final queryParams = <String, dynamic>{};
    if (streamId != null) {
      queryParams['stream_id'] = streamId;
    }

    final response = await dio.get(
      '${ApiConstants.bacYears}/$yearSlug/subjects',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final data = response.data['data'] as List;
    return data.map((json) => BacSubjectModel.fromJson(json)).toList();
  }

  /// Get chapter information for a specific BAC subject
  /// GET /api/v1/bac/subjects/{subjectSlug}/chapters
  Future<List<BacChapterInfoModel>> getBacChapters(String subjectSlug) async {
    final response = await dio.get(
      '${ApiConstants.bacSubjects}/$subjectSlug/chapters',
    );
    final data = response.data['data'] as List;
    return data.map((json) => BacChapterInfoModel.fromJson(json)).toList();
  }

  /// Get BAC exams for a specific content library subject and year
  /// GET /api/v1/bac/exams-by-subject?subject_id=X&year_slug=Y
  /// [subjectId] - content library subject ID
  /// [yearSlug] - BAC year (e.g., "2024")
  /// [streamId] - Optional: filter by academic stream
  Future<List<BacSubjectModel>> getExamsBySubject({
    required int subjectId,
    required String yearSlug,
    int? streamId,
  }) async {
    final queryParams = <String, dynamic>{
      'subject_id': subjectId,
      'year_slug': yearSlug,
    };
    if (streamId != null) {
      queryParams['stream_id'] = streamId;
    }

    final response = await dio.get(
      ApiConstants.bacExamsBySubject,
      queryParameters: queryParams,
    );
    final data = response.data['data'] as List;
    return data.map((json) => BacSubjectModel.fromJson(json)).toList();
  }

  /// Create a new simulation
  /// POST /api/v1/bac/simulations
  Future<BacSimulationModel> createSimulation({
    required int bacSubjectId,
    required SimulationMode mode,
    DifficultyLevel? difficulty,
    List<int>? chapterIds,
    required int totalQuestions,
    required int durationMinutes,
  }) async {
    final response = await dio.post(
      ApiConstants.bacSimulations,
      data: {
        'bac_subject_id': bacSubjectId,
        'mode': _simulationModeToString(mode),
        if (difficulty != null)
          'difficulty': _difficultyLevelToString(difficulty),
        if (chapterIds != null && chapterIds.isNotEmpty)
          'chapter_ids': chapterIds,
        'total_questions': totalQuestions,
        'duration_minutes': durationMinutes,
      },
    );
    return BacSimulationModel.fromJson(response.data['data']);
  }

  /// Start a simulation (mark as in_progress)
  /// POST /api/v1/bac/simulations/{id}/start
  Future<BacSimulationModel> startSimulation(int simulationId) async {
    final response = await dio.post(
      '${ApiConstants.bacSimulations}/$simulationId/start',
    );
    return BacSimulationModel.fromJson(response.data['data']);
  }

  /// Pause a simulation
  /// POST /api/v1/bac/simulations/{id}/pause
  Future<BacSimulationModel> pauseSimulation(int simulationId) async {
    final response = await dio.post(
      '${ApiConstants.bacSimulations}/$simulationId/pause',
    );
    return BacSimulationModel.fromJson(response.data['data']);
  }

  /// Resume a paused simulation
  /// POST /api/v1/bac/simulations/{id}/resume
  Future<BacSimulationModel> resumeSimulation(int simulationId) async {
    final response = await dio.post(
      '${ApiConstants.bacSimulations}/$simulationId/resume',
    );
    return BacSimulationModel.fromJson(response.data['data']);
  }

  /// Submit simulation answers and complete
  /// POST /api/v1/bac/simulations/{id}/submit
  Future<SimulationResultsModel> submitSimulation({
    required int simulationId,
    required List<Map<String, dynamic>> answers,
    required int elapsedSeconds,
    String? notes,
  }) async {
    final response = await dio.post(
      '${ApiConstants.bacSimulations}/$simulationId/submit',
      data: {
        'answers': answers,
        'elapsed_seconds': elapsedSeconds,
        if (notes != null) 'notes': notes,
      },
    );
    return SimulationResultsModel.fromJson(response.data['data']);
  }

  /// Get user's simulation history
  /// GET /api/v1/bac/simulations?filter[status]=completed
  Future<List<BacSimulationModel>> getSimulationHistory({
    int? bacSubjectId,
    SimulationStatus? status,
    int? limit,
  }) async {
    final queryParameters = <String, dynamic>{};

    if (bacSubjectId != null) {
      queryParameters['filter[bac_subject_id]'] = bacSubjectId;
    }
    if (status != null) {
      queryParameters['filter[status]'] = _simulationStatusToString(status);
    }
    if (limit != null) {
      queryParameters['limit'] = limit;
    }

    final response = await dio.get(
      ApiConstants.bacSimulations,
      queryParameters: queryParameters,
    );
    final data = response.data['data'] as List;
    return data.map((json) => BacSimulationModel.fromJson(json)).toList();
  }

  /// Get detailed results for a specific simulation
  /// GET /api/v1/bac/simulations/{id}/results
  Future<SimulationResultsModel> getSimulationResults(int simulationId) async {
    final response = await dio.get(
      '${ApiConstants.bacSimulations}/$simulationId/results',
    );
    return SimulationResultsModel.fromJson(response.data['data']);
  }

  /// Get user's performance statistics for a subject
  /// GET /api/v1/bac/subjects/{subjectSlug}/performance
  Future<Map<String, dynamic>> getSubjectPerformance(String subjectSlug) async {
    final response = await dio.get(
      '${ApiConstants.bacSubjects}/$subjectSlug/performance',
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  /// Download exam PDF
  /// GET /api/v1/bac/exams/{examId}/download
  Future<String> downloadExamPdf(int examId, String examTitle) async {
    // Get the downloads directory
    final directory = await getApplicationDocumentsDirectory();
    final downloadsPath = '${directory.path}/bac_exams';

    // Create directory if it doesn't exist
    final downloadsDir = Directory(downloadsPath);
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    // Generate file path
    final fileName = '${examTitle.replaceAll(' ', '_')}_$examId.pdf';
    final filePath = '$downloadsPath/$fileName';

    // Download the file
    await dio.download(
      '${ApiConstants.bacExamDownload}/$examId',
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          final progress = (received / total * 100).toStringAsFixed(0);
          print('Download progress: $progress%');
        }
      },
    );

    return filePath;
  }

  // ===== BAC BOOKMARK METHODS =====

  /// Toggle bookmark for a BAC subject
  /// POST /api/v1/bac-bookmarks/bac-subject/{bacSubjectId}
  Future<bool> toggleBacBookmark(int bacSubjectId) async {
    final response = await dio.post(
      '${ApiConstants.baseUrl}/v1/bac-bookmarks/bac-subject/$bacSubjectId',
    );
    return response.data['data']['is_bookmarked'] as bool;
  }

  /// Check if a BAC subject is bookmarked
  /// GET /api/v1/bac-bookmarks/bac-subject/{bacSubjectId}/check
  Future<bool> isBacSubjectBookmarked(int bacSubjectId) async {
    final response = await dio.get(
      '${ApiConstants.baseUrl}/v1/bac-bookmarks/bac-subject/$bacSubjectId/check',
    );
    return response.data['data']['is_bookmarked'] as bool;
  }

  /// Get all bookmarked BAC subjects
  /// GET /api/v1/bac-bookmarks
  Future<List<BacSubjectModel>> getBookmarkedBacSubjects() async {
    final response = await dio.get(
      '${ApiConstants.baseUrl}/v1/bac-bookmarks',
    );
    final data = response.data['data'] as List;
    // Extract bac_subject from each bookmark
    return data.map((bookmark) {
      final bacSubjectJson = bookmark['bac_subject'] as Map<String, dynamic>;
      return BacSubjectModel.fromJson(bacSubjectJson);
    }).toList();
  }

  /// Helper methods for enum conversion
  String _simulationModeToString(SimulationMode mode) {
    switch (mode) {
      case SimulationMode.practice:
        return 'practice';
      case SimulationMode.exam:
        return 'exam';
      case SimulationMode.quick:
        return 'quick';
    }
  }

  String _difficultyLevelToString(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.easy:
        return 'easy';
      case DifficultyLevel.medium:
        return 'medium';
      case DifficultyLevel.hard:
        return 'hard';
      case DifficultyLevel.mixed:
        return 'mixed';
    }
  }

  String _simulationStatusToString(SimulationStatus status) {
    switch (status) {
      case SimulationStatus.notStarted:
        return 'not_started';
      case SimulationStatus.inProgress:
        return 'in_progress';
      case SimulationStatus.paused:
        return 'paused';
      case SimulationStatus.completed:
        return 'completed';
      case SimulationStatus.abandoned:
        return 'abandoned';
    }
  }
}
