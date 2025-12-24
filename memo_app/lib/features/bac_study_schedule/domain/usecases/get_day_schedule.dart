import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/bac_study_day.dart';
import '../repositories/bac_study_repository.dart';

/// Use case to get a specific day's schedule
class GetDaySchedule implements UseCase<BacStudyDay, GetDayScheduleParams> {
  final BacStudyRepository repository;

  GetDaySchedule(this.repository);

  @override
  Future<Either<Failure, BacStudyDay>> call(GetDayScheduleParams params) {
    return repository.getDaySchedule(params.streamId, params.dayNumber);
  }
}

class GetDayScheduleParams {
  final int streamId;
  final int dayNumber;

  const GetDayScheduleParams({
    required this.streamId,
    required this.dayNumber,
  });
}
