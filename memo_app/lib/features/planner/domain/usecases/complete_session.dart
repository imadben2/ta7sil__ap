import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/planner_repository.dart';

/// Use case for completing a study session
class CompleteSession implements UseCase<Unit, CompleteSessionParams> {
  final PlannerRepository repository;

  CompleteSession(this.repository);

  @override
  Future<Either<Failure, Unit>> call(CompleteSessionParams params) async {
    return await repository.completeSession(
      params.sessionId,
      completionPercentage: params.completionPercentage,
      userNotes: params.userNotes,
      mood: params.mood,
    );
  }
}

class CompleteSessionParams {
  final String sessionId;
  final int completionPercentage;
  final String? userNotes;
  final String? mood;

  CompleteSessionParams({
    required this.sessionId,
    this.completionPercentage = 100,
    this.userNotes,
    this.mood,
  });
}
