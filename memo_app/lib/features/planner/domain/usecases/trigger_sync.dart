import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/services/background_sync_service.dart';

/// Use case for manually triggering background sync
///
/// This allows users to force a sync from the UI (e.g., from settings or pull-to-refresh)
class TriggerSync implements UseCase<SyncResult, NoParams> {
  final BackgroundSyncService syncService;

  TriggerSync(this.syncService);

  @override
  Future<Either<Failure, SyncResult>> call(NoParams params) async {
    try {
      final result = await syncService.processQueue();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('فشل المزامنة: ${e.toString()}'));
    }
  }
}
