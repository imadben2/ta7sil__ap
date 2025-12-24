import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../entities/stats_entity.dart';
import '../entities/study_session_entity.dart';
import '../entities/subject_progress_entity.dart';
import '../repositories/home_repository.dart';
import '../../../planner/domain/repositories/planner_repository.dart';
import '../../../planner/domain/entities/study_session.dart' as planner;

/// Combined dashboard data
class DashboardData {
  final StatsEntity stats;
  final List<StudySessionEntity> todaySessions;
  final List<SubjectProgressEntity> subjectsProgress;

  const DashboardData({
    required this.stats,
    required this.todaySessions,
    required this.subjectsProgress,
  });
}

/// Use case to get all dashboard data in one call
class GetDashboardDataUseCase {
  final HomeRepository repository;
  final PlannerRepository plannerRepository;

  GetDashboardDataUseCase(this.repository, this.plannerRepository);

  Future<Either<Failure, DashboardData>> call() async {
    try {
      debugPrint('[GetDashboardDataUseCase] ========== FETCHING DASHBOARD DATA ==========');

      // Fetch all data in parallel
      final results = await Future.wait([
        repository.getStats().then((result) => result.fold((l) => l, (r) => r)),
        // USE PLANNER REPOSITORY instead of Home repository for today's sessions
        plannerRepository.getTodaysSessions().then(
          (result) => result.fold((l) => l, (r) => r),
        ),
        repository.getSubjectsProgress().then(
          (result) => result.fold((l) => l, (r) => r),
        ),
      ]);

      // Check if any result is a Failure
      for (final result in results) {
        if (result is Failure) {
          debugPrint('[GetDashboardDataUseCase] ✗ One of the requests failed');
          return Left(result);
        }
      }

      // Convert Planner sessions to Home entities
      final plannerSessions = results[1] as List<planner.StudySession>;
      debugPrint('[GetDashboardDataUseCase] Converting ${plannerSessions.length} planner sessions to home entities');

      // FILTER OUT BREAKS - Home screen should only show study sessions, not breaks
      debugPrint('[GetDashboardDataUseCase] ========== FILTERING BREAKS ==========');
      for (final s in plannerSessions) {
        debugPrint('[GetDashboardDataUseCase] Session: ${s.subjectName} - isBreak: ${s.isBreak}');
      }
      final studySessions = plannerSessions.where((session) => !session.isBreak).toList();
      debugPrint('[GetDashboardDataUseCase] Filtered to ${studySessions.length} study sessions (excluded ${plannerSessions.length - studySessions.length} breaks)');
      debugPrint('[GetDashboardDataUseCase] ========================================');

      final homeEntities = studySessions.map((session) {
        // Parse subject ID from session ID or default to 0
        final subjectId = int.tryParse(session.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

        // Convert color to hex string
        final int? colorValue = session.subjectColor?.value;
        final colorHex = colorValue?.toRadixString(16).padLeft(8, '0').substring(2) ?? 'FFB74D';

        // Create DateTime from scheduled date and time
        final startDateTime = DateTime(
          session.scheduledDate.year,
          session.scheduledDate.month,
          session.scheduledDate.day,
          session.scheduledStartTime.hour,
          session.scheduledStartTime.minute,
        );

        final endDateTime = DateTime(
          session.scheduledDate.year,
          session.scheduledDate.month,
          session.scheduledDate.day,
          session.scheduledEndTime.hour,
          session.scheduledEndTime.minute,
        );

        // Parse session type
        SessionType sessionType = SessionType.lesson;
        switch (session.sessionType) {
          case planner.SessionType.study:
          case planner.SessionType.regular:
            sessionType = SessionType.lesson;
            break;
          case planner.SessionType.revision:
          case planner.SessionType.longRevision:
            sessionType = SessionType.review;
            break;
          case planner.SessionType.practice:
          case planner.SessionType.exam:
            sessionType = SessionType.quiz;
            break;
        }

        // Parse session status
        SessionStatus sessionStatus = SessionStatus.pending;
        switch (session.status) {
          case planner.SessionStatus.scheduled:
            sessionStatus = SessionStatus.pending;
            break;
          case planner.SessionStatus.inProgress:
            sessionStatus = SessionStatus.inProgress;
            break;
          case planner.SessionStatus.completed:
            sessionStatus = SessionStatus.completed;
            break;
          case planner.SessionStatus.missed:
            sessionStatus = SessionStatus.missed;
            break;
          default:
            sessionStatus = SessionStatus.pending;
        }

        return StudySessionEntity(
          id: subjectId,
          subjectId: subjectId,
          subjectName: session.subjectName,
          subjectColor: colorHex,
          type: sessionType,
          status: sessionStatus,
          startTime: startDateTime,
          endTime: endDateTime,
          topic: session.topicName ?? session.chapterName,
          notes: null,
        );
      }).toList();

      debugPrint('[GetDashboardDataUseCase] ✓ Dashboard data fetched successfully');
      if (homeEntities.isNotEmpty) {
        debugPrint('[GetDashboardDataUseCase] First session subject: ${homeEntities.first.subjectName}');
      }

      // All successful, combine data
      return Right(
        DashboardData(
          stats: results[0] as StatsEntity,
          todaySessions: homeEntities,
          subjectsProgress: results[2] as List<SubjectProgressEntity>,
        ),
      );
    } catch (e) {
      debugPrint('[GetDashboardDataUseCase] ✗ Error: $e');
      return const Left(ServerFailure('Failed to load dashboard data'));
    }
  }
}
