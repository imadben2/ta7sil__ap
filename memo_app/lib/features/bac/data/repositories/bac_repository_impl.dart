import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/bac_year_entity.dart';
import '../../domain/entities/bac_session_entity.dart';
import '../../domain/entities/bac_subject_entity.dart';
import '../../domain/entities/bac_chapter_info_entity.dart';
import '../../domain/entities/bac_simulation_entity.dart';
import '../../domain/entities/simulation_results_entity.dart';
import '../../domain/entities/bac_enums.dart';
import '../../domain/repositories/bac_repository.dart';
import '../datasources/bac_remote_datasource.dart';
import '../datasources/bac_local_datasource.dart';

/// Implementation of BacRepository
/// Implements offline-first pattern: check cache → fetch from API → update cache
class BacRepositoryImpl implements BacRepository {
  final BacRemoteDataSource remoteDataSource;
  final BacLocalDataSource localDataSource;

  BacRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<BacYearEntity>>> getBacYears({
    bool forceRefresh = false,
  }) async {
    try {
      // Try to get from cache first (unless force refresh)
      if (!forceRefresh) {
        final cachedYears = await localDataSource.getCachedBacYears();
        if (cachedYears != null) {
          return Right(cachedYears);
        }
      }

      // If cache is invalid, empty, or force refresh, fetch from API
      final years = await remoteDataSource.getBacYears();

      // Update cache
      await localDataSource.cacheBacYears(years);

      return Right(years);
    } catch (e) {
      // If API fails and we have cache, return cached data
      if (!forceRefresh) {
        final cachedYears = await localDataSource.getCachedBacYears();
        if (cachedYears != null) {
          return Right(cachedYears);
        }
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BacSessionEntity>>> getBacSessions(
    String yearSlug,
  ) async {
    try {
      // Try to get from cache first
      final cachedSessions = await localDataSource.getCachedBacSessions(
        yearSlug,
      );
      if (cachedSessions != null) {
        return Right(cachedSessions);
      }

      // If cache is invalid or empty, fetch from API
      final sessions = await remoteDataSource.getBacSessions(yearSlug);

      // Update cache
      await localDataSource.cacheBacSessions(yearSlug, sessions);

      return Right(sessions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BacSubjectEntity>>> getBacSubjects(
    String sessionSlug,
  ) async {
    try {
      // Try to get from cache first
      final cachedSubjects = await localDataSource.getCachedBacSubjects(
        sessionSlug,
      );
      if (cachedSubjects != null) {
        return Right(cachedSubjects);
      }

      // If cache is invalid or empty, fetch from API
      final subjects = await remoteDataSource.getBacSubjects(sessionSlug);

      // Update cache
      await localDataSource.cacheBacSubjects(sessionSlug, subjects);

      return Right(subjects);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BacSubjectEntity>>> getSubjectsByYear(
    String yearSlug, {
    int? streamId,
  }) async {
    try {
      // Try to get from cache first (using year+stream specific key)
      final cacheKey = streamId != null ? 'year_${yearSlug}_stream_$streamId' : 'year_$yearSlug';
      final cachedSubjects = await localDataSource.getCachedBacSubjects(
        cacheKey,
      );
      if (cachedSubjects != null) {
        return Right(cachedSubjects);
      }

      // If cache is invalid or empty, fetch from API
      final subjects = await remoteDataSource.getSubjectsByYear(yearSlug, streamId: streamId);

      // Update cache
      await localDataSource.cacheBacSubjects(cacheKey, subjects);

      return Right(subjects);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BacChapterInfoEntity>>> getBacChapters(
    String subjectSlug,
  ) async {
    try {
      // Try to get from cache first
      final cachedChapters = await localDataSource.getCachedBacChapters(
        subjectSlug,
      );
      if (cachedChapters != null) {
        return Right(cachedChapters);
      }

      // If cache is invalid or empty, fetch from API
      final chapters = await remoteDataSource.getBacChapters(subjectSlug);

      // Update cache
      await localDataSource.cacheBacChapters(subjectSlug, chapters);

      return Right(chapters);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BacSubjectEntity>>> getExamsBySubject({
    required int subjectId,
    required String yearSlug,
    int? streamId,
  }) async {
    try {
      // Use a specific cache key for subject+year combination
      final cacheKey = 'exams_subject_${subjectId}_year_$yearSlug${streamId != null ? '_stream_$streamId' : ''}';
      final cachedExams = await localDataSource.getCachedBacSubjects(cacheKey);
      if (cachedExams != null) {
        return Right(cachedExams);
      }

      // If cache is invalid or empty, fetch from API
      final exams = await remoteDataSource.getExamsBySubject(
        subjectId: subjectId,
        yearSlug: yearSlug,
        streamId: streamId,
      );

      // Update cache
      await localDataSource.cacheBacSubjects(cacheKey, exams);

      return Right(exams);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BacSimulationEntity>> createSimulation({
    required int bacSubjectId,
    required SimulationMode mode,
    DifficultyLevel? difficulty,
    List<int>? chapterIds,
    required int totalQuestions,
    required int durationMinutes,
  }) async {
    try {
      final simulation = await remoteDataSource.createSimulation(
        bacSubjectId: bacSubjectId,
        mode: mode,
        difficulty: difficulty,
        chapterIds: chapterIds,
        totalQuestions: totalQuestions,
        durationMinutes: durationMinutes,
      );

      // Save simulation locally for resume capability
      await localDataSource.saveSimulation(simulation);

      return Right(simulation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BacSimulationEntity>> startSimulation(
    int simulationId,
  ) async {
    try {
      final simulation = await remoteDataSource.startSimulation(simulationId);

      // Update local state
      await localDataSource.saveSimulation(simulation);

      return Right(simulation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BacSimulationEntity>> pauseSimulation(
    int simulationId,
  ) async {
    try {
      final simulation = await remoteDataSource.pauseSimulation(simulationId);

      // Update local state
      await localDataSource.saveSimulation(simulation);

      return Right(simulation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BacSimulationEntity>> resumeSimulation(
    int simulationId,
  ) async {
    try {
      final simulation = await remoteDataSource.resumeSimulation(simulationId);

      // Update local state
      await localDataSource.saveSimulation(simulation);

      return Right(simulation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SimulationResultsEntity>> submitSimulation({
    required int simulationId,
    required List<Map<String, dynamic>> answers,
    required int elapsedSeconds,
    String? notes,
  }) async {
    try {
      final results = await remoteDataSource.submitSimulation(
        simulationId: simulationId,
        answers: answers,
        elapsedSeconds: elapsedSeconds,
        notes: notes,
      );

      // Delete saved simulation state after completion
      await localDataSource.deleteSavedSimulation(simulationId);

      return Right(results);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BacSimulationEntity>>> getSimulationHistory({
    int? bacSubjectId,
    SimulationStatus? status,
    int? limit,
  }) async {
    try {
      // First, try to get from local storage (offline-first)
      var localSimulations = await localDataSource.getAllSavedSimulations();

      // Try to get from API and merge with local
      try {
        final remoteHistory = await remoteDataSource.getSimulationHistory(
          bacSubjectId: bacSubjectId,
          status: status,
          limit: limit,
        );

        // Merge remote with local, avoiding duplicates
        final mergedIds = <int>{};
        final mergedHistory = <BacSimulationEntity>[];

        for (final sim in remoteHistory) {
          if (!mergedIds.contains(sim.id)) {
            mergedIds.add(sim.id);
            mergedHistory.add(sim);
          }
        }

        for (final sim in localSimulations) {
          if (!mergedIds.contains(sim.id)) {
            mergedIds.add(sim.id);
            mergedHistory.add(sim);
          }
        }

        // Sort by startedAt descending
        mergedHistory.sort((a, b) => b.startedAt.compareTo(a.startedAt));

        return Right(mergedHistory);
      } catch (_) {
        // API failed, use local simulations only
      }

      // Filter local simulations based on parameters
      List<BacSimulationEntity> filteredSimulations = localSimulations;

      if (bacSubjectId != null) {
        filteredSimulations = filteredSimulations
            .where((s) => s.bacSubjectId == bacSubjectId)
            .toList();
      }

      if (status != null) {
        filteredSimulations = filteredSimulations
            .where((s) => s.status == status)
            .toList();
      }

      // Sort by startedAt descending
      filteredSimulations.sort((a, b) => b.startedAt.compareTo(a.startedAt));

      if (limit != null && filteredSimulations.length > limit) {
        filteredSimulations = filteredSimulations.take(limit).toList();
      }

      return Right(filteredSimulations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SimulationResultsEntity>> getSimulationResults(
    int simulationId,
  ) async {
    try {
      final results = await remoteDataSource.getSimulationResults(simulationId);

      return Right(results);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSubjectPerformance(
    String subjectSlug,
  ) async {
    try {
      final performance = await remoteDataSource.getSubjectPerformance(
        subjectSlug,
      );

      return Right(performance);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> downloadExamPdf(
    int examId,
    String examTitle,
  ) async {
    try {
      final filePath = await remoteDataSource.downloadExamPdf(
        examId,
        examTitle,
      );

      return Right(filePath);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Get saved simulation from local storage (for resume after app restart)
  Future<Either<Failure, BacSimulationEntity?>> getSavedSimulation(
    int simulationId,
  ) async {
    try {
      final simulation = await localDataSource.getSavedSimulation(simulationId);
      return Right(simulation);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Get all saved simulations from local storage
  Future<Either<Failure, List<BacSimulationEntity>>>
  getAllSavedSimulations() async {
    try {
      final simulations = await localDataSource.getAllSavedSimulations();
      return Right(simulations);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Clear all BAC cache
  Future<Either<Failure, void>> clearCache() async {
    try {
      await localDataSource.clearAllCache();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
