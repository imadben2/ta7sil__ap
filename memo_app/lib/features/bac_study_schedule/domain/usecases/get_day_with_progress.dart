import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/bac_study_day.dart';
import '../repositories/bac_study_repository.dart';

/// Use case to get a day's schedule with user's progress
class GetDayWithProgress implements UseCase<BacStudyDay, GetDayWithProgressParams> {
  final BacStudyRepository repository;

  GetDayWithProgress(this.repository);

  @override
  Future<Either<Failure, BacStudyDay>> call(GetDayWithProgressParams params) {
    return repository.getDayWithProgress(params.streamId, params.dayNumber);
  }
}

class GetDayWithProgressParams {
  final int streamId;
  final int dayNumber;

  const GetDayWithProgressParams({
    required this.streamId,
    required this.dayNumber,
  });
}
