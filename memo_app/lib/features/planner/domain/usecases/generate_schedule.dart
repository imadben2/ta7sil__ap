import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/schedule.dart';
import '../entities/planner_settings.dart';
import '../entities/subject.dart';
import '../entities/exam.dart';
import '../repositories/planner_repository.dart';

/// Use case for generating a study schedule
class GenerateSchedule implements UseCase<Schedule, GenerateScheduleParams> {
  final PlannerRepository repository;

  GenerateSchedule(this.repository);

  @override
  Future<Either<Failure, Schedule>> call(GenerateScheduleParams params) async {
    return await repository.generateSchedule(
      settings: params.settings,
      subjects: params.subjects,
      exams: params.exams,
      startDate: params.startDate,
      endDate: params.endDate,
      startFromNow: params.startFromNow,
      scheduleType: params.scheduleType,
      selectedSubjectIds: params.selectedSubjectIds,
    );
  }
}

class GenerateScheduleParams {
  final PlannerSettings settings;
  final List<Subject> subjects;
  final List<Exam> exams;
  final DateTime startDate;
  final DateTime endDate;
  final bool startFromNow;
  /// Type of schedule to generate (daily, weekly, full)
  final ScheduleType scheduleType;
  /// Optional list of subject IDs to filter (if null, include all subjects)
  final List<String>? selectedSubjectIds;

  GenerateScheduleParams({
    required this.settings,
    required this.subjects,
    required this.exams,
    required this.startDate,
    required this.endDate,
    this.startFromNow = true,
    this.scheduleType = ScheduleType.weekly,
    this.selectedSubjectIds,
  });
}
