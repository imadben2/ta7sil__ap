import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/bac_study_repository.dart';

/// Use case to get a specific week's schedule with reward
class GetWeekSchedule implements UseCase<BacWeekScheduleData, GetWeekScheduleParams> {
  final BacStudyRepository repository;

  GetWeekSchedule(this.repository);

  @override
  Future<Either<Failure, BacWeekScheduleData>> call(GetWeekScheduleParams params) {
    return repository.getWeekSchedule(params.streamId, params.weekNumber);
  }
}

class GetWeekScheduleParams {
  final int streamId;
  final int weekNumber;

  const GetWeekScheduleParams({
    required this.streamId,
    required this.weekNumber,
  });
}
