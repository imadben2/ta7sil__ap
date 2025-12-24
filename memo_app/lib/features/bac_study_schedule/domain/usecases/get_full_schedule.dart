import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/bac_study_day.dart';
import '../repositories/bac_study_repository.dart';

/// Use case to get the full 98-day schedule
class GetFullSchedule implements UseCase<List<BacStudyDay>, GetFullScheduleParams> {
  final BacStudyRepository repository;

  GetFullSchedule(this.repository);

  @override
  Future<Either<Failure, List<BacStudyDay>>> call(GetFullScheduleParams params) {
    return repository.getFullSchedule(params.streamId);
  }
}

class GetFullScheduleParams {
  final int streamId;

  const GetFullScheduleParams({required this.streamId});
}
