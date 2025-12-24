import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/session_history.dart';
import '../repositories/planner_repository.dart';

/// Use case for getting session history with filters
class GetSessionHistory
    implements UseCase<SessionHistory, SessionHistoryParams> {
  final PlannerRepository repository;

  GetSessionHistory(this.repository);

  @override
  Future<Either<Failure, SessionHistory>> call(
    SessionHistoryParams params,
  ) async {
    return await repository.getSessionHistory(
      startDate: params.startDate,
      endDate: params.endDate,
      filters: params.filters,
    );
  }
}

class SessionHistoryParams {
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic>? filters;

  SessionHistoryParams({
    required this.startDate,
    required this.endDate,
    this.filters,
  });

  /// Helper factory for common date ranges
  factory SessionHistoryParams.lastDays(
    int days, {
    Map<String, dynamic>? filters,
  }) {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    return SessionHistoryParams(
      startDate: start,
      endDate: end,
      filters: filters,
    );
  }

  /// Helper factory for last 3 months
  factory SessionHistoryParams.lastThreeMonths({
    Map<String, dynamic>? filters,
  }) {
    final end = DateTime.now();
    final start = DateTime(end.year, end.month - 3, end.day);
    return SessionHistoryParams(
      startDate: start,
      endDate: end,
      filters: filters,
    );
  }
}
