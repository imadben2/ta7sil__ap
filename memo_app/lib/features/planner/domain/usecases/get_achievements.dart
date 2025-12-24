import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/achievement.dart';
import '../repositories/planner_repository.dart';

/// Use case for getting user achievements
class GetAchievements implements UseCase<AchievementsResponse, NoParams> {
  final PlannerRepository repository;

  GetAchievements(this.repository);

  @override
  Future<Either<Failure, AchievementsResponse>> call(NoParams params) async {
    return await repository.getAchievements();
  }
}
