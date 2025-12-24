import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../entities/study_session.dart';
import '../entities/planner_settings.dart';
import '../../data/services/session_lifecycle_service.dart';
import '../../data/datasources/planner_local_datasource.dart';
import '../repositories/planner_repository.dart';

/// Parameters for RescheduleMissedSession use case
class RescheduleMissedSessionParams {
  final StudySession missedSession;
  final PlannerSettings? settings;

  const RescheduleMissedSessionParams({
    required this.missedSession,
    this.settings,
  });
}

/// Use case for rescheduling a missed session to the next available slot
///
/// This use case finds the next available time slot and creates a new
/// scheduled session for the missed content.
class RescheduleMissedSession
    implements UseCase<StudySession?, RescheduleMissedSessionParams> {
  final SessionLifecycleService sessionLifecycleService;
  final PlannerLocalDataSource localDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final PlannerRepository plannerRepository;

  RescheduleMissedSession({
    required this.sessionLifecycleService,
    required this.localDataSource,
    required this.authLocalDataSource,
    required this.plannerRepository,
  });

  @override
  Future<Either<Failure, StudySession?>> call(
    RescheduleMissedSessionParams params,
  ) async {
    try {
      // Validate that the session is actually missed
      if (params.missedSession.status != SessionStatus.missed) {
        return Left(
          CacheFailure('Session is not missed and cannot be rescheduled'),
        );
      }

      // Get settings if not provided
      PlannerSettings settings;
      if (params.settings != null) {
        settings = params.settings!;
      } else {
        // Use repository to get settings (fetches from API if not cached)
        final settingsResult = await plannerRepository.getSettings();
        final settingsOrError = settingsResult.fold(
          (failure) => failure,
          (s) => s,
        );
        if (settingsOrError is Failure) {
          return Left(settingsOrError);
        }
        settings = settingsOrError as PlannerSettings;
      }

      // Reschedule the session
      final newSession = await sessionLifecycleService.rescheduleMissedSession(
        missedSession: params.missedSession,
        settings: settings,
      );

      return Right(newSession);
    } catch (e) {
      return Left(CacheFailure('Failed to reschedule session: $e'));
    }
  }
}

/// Use case for getting all missed sessions
class GetMissedSessions implements UseCase<List<StudySession>, NoParams> {
  final SessionLifecycleService sessionLifecycleService;

  GetMissedSessions({required this.sessionLifecycleService});

  @override
  Future<Either<Failure, List<StudySession>>> call(NoParams params) async {
    try {
      final missedSessions =
          await sessionLifecycleService.getMissedSessions();
      return Right(missedSessions);
    } catch (e) {
      return Left(CacheFailure('Failed to get missed sessions: $e'));
    }
  }
}

/// Use case for getting overdue sessions (past start time but not yet missed)
class GetOverdueSessions implements UseCase<List<StudySession>, NoParams> {
  final SessionLifecycleService sessionLifecycleService;
  final PlannerRepository plannerRepository;

  GetOverdueSessions({
    required this.sessionLifecycleService,
    required this.plannerRepository,
  });

  @override
  Future<Either<Failure, List<StudySession>>> call(NoParams params) async {
    try {
      // Get grace period from settings (fetches from API if not cached)
      int gracePeriod = 15; // Default value
      final settingsResult = await plannerRepository.getSettings();
      settingsResult.fold(
        (failure) {
          // Use default if settings not available
        },
        (settings) {
          gracePeriod = settings.gracePeriodMinutes;
        },
      );

      final overdueSessions = await sessionLifecycleService.getOverdueSessions(
        gracePeriodMinutes: gracePeriod,
      );
      return Right(overdueSessions);
    } catch (e) {
      return Left(CacheFailure('Failed to get overdue sessions: $e'));
    }
  }
}
