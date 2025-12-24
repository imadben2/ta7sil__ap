import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/prayer_times.dart';
import '../repositories/planner_repository.dart';

/// Use case for getting prayer times
class GetPrayerTimes implements UseCase<PrayerTimes, GetPrayerTimesParams> {
  final PlannerRepository repository;

  GetPrayerTimes(this.repository);

  @override
  Future<Either<Failure, PrayerTimes>> call(GetPrayerTimesParams params) async {
    return await repository.getPrayerTimes(params.date, params.city);
  }
}

class GetPrayerTimesParams {
  final String city;
  final DateTime date;

  GetPrayerTimesParams({required this.city, required this.date});
}
