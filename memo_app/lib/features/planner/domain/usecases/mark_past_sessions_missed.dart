import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../entities/study_session.dart';
import '../entities/planner_settings.dart';
import '../../data/services/session_lifecycle_service.dart';
import '../../data/datasources/planner_local_datasource.dart';

/// Parameters for MarkPastSessionsMissed use case
class MarkPastSessionsMissedParams {
  final PlannerSettings? settings;

  const MarkPastSessionsMissedParams({this.settings});
}

/// Use case for marking past scheduled sessions as missed (فائتة)
///
/// This use case should be called:
/// 1. At app launch
/// 2. When app returns to foreground
/// 3. At midnight (day transition)
/// 4. Before loading schedule views
class MarkPastSessionsMissed
    implements UseCase<List<StudySession>, MarkPastSessionsMissedParams> {
  final SessionLifecycleService sessionLifecycleService;
  final PlannerLocalDataSource localDataSource;
  final AuthLocalDataSource authLocalDataSource;

  MarkPastSessionsMissed({
    required this.sessionLifecycleService,
    required this.localDataSource,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, List<StudySession>>> call(
    MarkPastSessionsMissedParams params,
  ) async {
    try {
      List<StudySession> markedSessions;

      if (params.settings != null) {
        // Use settings-based grace period
        markedSessions =
            await sessionLifecycleService.markPastSessionsAsMissedWithSettings(
          params.settings!,
        );
      } else {
        // Get actual user ID from auth
        String userId;
        try {
          final user = await authLocalDataSource.getCachedUser();
          userId = user.id.toString();
        } catch (e) {
          userId = 'default_user';
        }

        // Get settings from local storage
        final settings = await localDataSource.getCachedSettings(userId);
        if (settings != null) {
          markedSessions =
              await sessionLifecycleService.markPastSessionsAsMissedWithSettings(
            settings,
          );
        } else {
          // Use default grace period
          markedSessions =
              await sessionLifecycleService.markPastSessionsAsMissed();
        }
      }

      return Right(markedSessions);
    } catch (e) {
      return Left(CacheFailure('Failed to mark sessions as missed: $e'));
    }
  }
}
