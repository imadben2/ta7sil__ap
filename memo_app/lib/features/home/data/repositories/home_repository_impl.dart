import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/stats_entity.dart';
import '../../domain/entities/study_session_entity.dart';
import '../../domain/entities/subject_progress_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';
import '../datasources/home_remote_datasource.dart';
import '../../../planner/data/datasources/planner_local_datasource.dart';
import '../../../planner/domain/entities/study_session.dart' as planner;

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;
  final Connectivity connectivity;
  final PlannerLocalDataSource? plannerLocalDataSource;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
    this.plannerLocalDataSource,
  });

  /// OPTIMIZED: Get all dashboard data in a single API call
  @override
  Future<Either<Failure, CompleteDashboardEntity>> getCompleteDashboard() async {
    try {
      debugPrint('[HomeRepository] 🚀 Fetching complete dashboard from unified endpoint');

      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        debugPrint('[HomeRepository] ❌ No internet connection');
        return const Left(NetworkFailure('No internet connection'));
      }

      // Fetch from unified endpoint
      final data = await remoteDataSource.getCompleteDashboard();

      // Convert stats model to entity
      final statsEntity = data.stats.toEntity();

      // Convert subjects progress models to entities
      final subjectsProgress = data.subjectsProgress.map((model) => model.toEntity()).toList();

      // For today's sessions, we still prefer local planner data if available
      List<StudySessionEntity> todaySessions = [];
      if (plannerLocalDataSource != null) {
        final plannerSessions = await plannerLocalDataSource!.getTodaysSessions();
        // Filter out breaks
        final studySessions = plannerSessions.where((s) => !s.isBreak).toList();
        todaySessions = studySessions.map((session) => _convertPlannerSession(session)).toList();
        debugPrint('[HomeRepository] ✓ Using ${todaySessions.length} local planner sessions');
      } else {
        // Convert from API response if no local planner
        todaySessions = data.todaySessions.map((model) => model.toEntity()).toList();
        debugPrint('[HomeRepository] ✓ Using ${todaySessions.length} API sessions');
      }

      debugPrint('[HomeRepository] ✅ Complete dashboard loaded - '
          'stats: ✓, sessions: ${todaySessions.length}, '
          'subjects: ${subjectsProgress.length}, '
          'courses: ${data.featuredCourses.length}, '
          'sponsors: ${data.sponsors.length}, '
          'promos: ${data.promos.length}');

      return Right(CompleteDashboardEntity(
        stats: statsEntity,
        todaySessions: todaySessions,
        subjectsProgress: subjectsProgress,
        featuredCourses: data.featuredCourses,
        sponsors: data.sponsors,
        promos: data.promos,
      ));
    } on ServerException catch (e) {
      debugPrint('[HomeRepository] ❌ Server error: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      debugPrint('[HomeRepository] ❌ Network error: ${e.message}');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      debugPrint('[HomeRepository] ❌ Error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Helper to convert planner session to home entity
  StudySessionEntity _convertPlannerSession(planner.StudySession session) {
    final subjectId = int.tryParse(session.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final int? colorValue = session.subjectColor?.value;
    final colorHex = colorValue?.toRadixString(16).padLeft(8, '0').substring(2) ?? 'FFB74D';

    final startDateTime = DateTime(
      session.scheduledDate.year,
      session.scheduledDate.month,
      session.scheduledDate.day,
      session.scheduledStartTime.hour,
      session.scheduledStartTime.minute,
    );

    final endDateTime = DateTime(
      session.scheduledDate.year,
      session.scheduledDate.month,
      session.scheduledDate.day,
      session.scheduledEndTime.hour,
      session.scheduledEndTime.minute,
    );

    SessionType sessionType = SessionType.lesson;
    switch (session.sessionType) {
      case planner.SessionType.study:
      case planner.SessionType.regular:
        sessionType = SessionType.lesson;
        break;
      case planner.SessionType.revision:
      case planner.SessionType.longRevision:
        sessionType = SessionType.review;
        break;
      case planner.SessionType.practice:
      case planner.SessionType.exam:
        sessionType = SessionType.quiz;
        break;
    }

    SessionStatus sessionStatus = SessionStatus.pending;
    switch (session.status) {
      case planner.SessionStatus.scheduled:
        sessionStatus = SessionStatus.pending;
        break;
      case planner.SessionStatus.inProgress:
        sessionStatus = SessionStatus.inProgress;
        break;
      case planner.SessionStatus.completed:
        sessionStatus = SessionStatus.completed;
        break;
      case planner.SessionStatus.missed:
        sessionStatus = SessionStatus.missed;
        break;
      default:
        sessionStatus = SessionStatus.pending;
    }

    return StudySessionEntity(
      id: subjectId,
      subjectId: subjectId,
      subjectName: session.subjectName,
      subjectColor: colorHex,
      type: sessionType,
      status: sessionStatus,
      startTime: startDateTime,
      endTime: endDateTime,
      topic: session.topicName ?? session.chapterName,
      notes: null,
    );
  }

  @override
  Future<Either<Failure, StatsEntity>> getStats() async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        // Try to get cached data
        final cachedStats = await localDataSource.getCachedStats();
        if (cachedStats != null) {
          return Right(cachedStats.toEntity());
        }
        return const Left(NetworkFailure('No internet connection'));
      }

      // Fetch from remote
      final stats = await remoteDataSource.getStats();

      // Cache the data
      await localDataSource.cacheStats(stats);

      return Right(stats.toEntity());
    } on ServerException catch (e) {
      // Try fallback to cache
      final cachedStats = await localDataSource.getCachedStats();
      if (cachedStats != null) {
        return Right(cachedStats.toEntity());
      }
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      final cachedStats = await localDataSource.getCachedStats();
      if (cachedStats != null) {
        return Right(cachedStats.toEntity());
      }
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudySessionEntity>>> getTodaySessions() async {
    try {
      // PRIORITY 1: Use planner's local sessions if available
      if (plannerLocalDataSource != null) {
        final plannerSessions = await plannerLocalDataSource!.getTodaysSessions();

        if (plannerSessions.isEmpty) {
          // Check if planner has ANY sessions at all
          final allPlannerSessions = await plannerLocalDataSource!.getCachedSessions();
          if (allPlannerSessions.isEmpty) {
            // Planner has no sessions, clear home cache and return empty
            await localDataSource.clearCachedTodaySessions();
            return const Right([]);
          }
          // Planner has sessions but none for today - return empty for today
          return const Right([]);
        }

        // Convert planner sessions to home entities
        final homeEntities = plannerSessions.map((session) {
          // Parse subject ID from session ID or default to 0
          final subjectId = int.tryParse(session.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

          // Convert color to hex string
          final int? colorValue = session.subjectColor?.value;
          final colorHex = colorValue?.toRadixString(16).padLeft(8, '0').substring(2) ?? 'FFB74D';

          // Create DateTime from scheduled date and time
          final startDateTime = DateTime(
            session.scheduledDate.year,
            session.scheduledDate.month,
            session.scheduledDate.day,
            session.scheduledStartTime.hour,
            session.scheduledStartTime.minute,
          );

          final endDateTime = DateTime(
            session.scheduledDate.year,
            session.scheduledDate.month,
            session.scheduledDate.day,
            session.scheduledEndTime.hour,
            session.scheduledEndTime.minute,
          );

          // Parse session type
          SessionType sessionType = SessionType.lesson;
          switch (session.sessionType) {
            case planner.SessionType.study:
            case planner.SessionType.regular:
              sessionType = SessionType.lesson;
              break;
            case planner.SessionType.revision:
            case planner.SessionType.longRevision:
              sessionType = SessionType.review;
              break;
            case planner.SessionType.practice:
            case planner.SessionType.exam:
              sessionType = SessionType.quiz;
              break;
          }

          // Parse session status
          SessionStatus sessionStatus = SessionStatus.pending;
          switch (session.status) {
            case planner.SessionStatus.scheduled:
              sessionStatus = SessionStatus.pending;
              break;
            case planner.SessionStatus.inProgress:
              sessionStatus = SessionStatus.inProgress;
              break;
            case planner.SessionStatus.completed:
              sessionStatus = SessionStatus.completed;
              break;
            case planner.SessionStatus.missed:
              sessionStatus = SessionStatus.missed;
              break;
            default:
              sessionStatus = SessionStatus.pending;
          }

          return StudySessionEntity(
            id: subjectId,
            subjectId: subjectId,
            subjectName: session.subjectName,
            subjectColor: colorHex,
            type: sessionType,
            status: sessionStatus,
            startTime: startDateTime,
            endTime: endDateTime,
            topic: session.topicName ?? session.chapterName,
            notes: null,
          );
        }).toList();

        return Right(homeEntities);
      }

      // PRIORITY 2: Try remote API if no local planner
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        final cachedSessions = await localDataSource.getCachedTodaySessions();
        if (cachedSessions != null) {
          return Right(cachedSessions.map((s) => s.toEntity()).toList());
        }
        return const Left(NetworkFailure('No internet connection'));
      }

      final sessions = await remoteDataSource.getTodaySessions();
      await localDataSource.cacheTodaySessions(sessions);
      return Right(sessions.map((s) => s.toEntity()).toList());
    } on ServerException catch (e) {
      final cachedSessions = await localDataSource.getCachedTodaySessions();
      if (cachedSessions != null) {
        return Right(cachedSessions.map((s) => s.toEntity()).toList());
      }
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      final cachedSessions = await localDataSource.getCachedTodaySessions();
      if (cachedSessions != null) {
        return Right(cachedSessions.map((s) => s.toEntity()).toList());
      }
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubjectProgressEntity>>>
  getSubjectsProgress() async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        final cachedSubjects = await localDataSource
            .getCachedSubjectsProgress();
        if (cachedSubjects != null) {
          return Right(cachedSubjects.map((s) => s.toEntity()).toList());
        }
        return const Left(NetworkFailure('No internet connection'));
      }

      final subjects = await remoteDataSource.getSubjectsProgress();
      await localDataSource.cacheSubjectsProgress(subjects);
      return Right(subjects.map((s) => s.toEntity()).toList());
    } on ServerException catch (e) {
      final cachedSubjects = await localDataSource.getCachedSubjectsProgress();
      if (cachedSubjects != null) {
        return Right(cachedSubjects.map((s) => s.toEntity()).toList());
      }
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      final cachedSubjects = await localDataSource.getCachedSubjectsProgress();
      if (cachedSubjects != null) {
        return Right(cachedSubjects.map((s) => s.toEntity()).toList());
      }
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markSessionCompleted(int sessionId) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      await remoteDataSource.markSessionCompleted(sessionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markSessionMissed(int sessionId) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      await remoteDataSource.markSessionMissed(sessionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStudyTime(int minutes) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      await remoteDataSource.updateStudyTime(minutes);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
