import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/stats_entity.dart';
import '../entities/study_session_entity.dart';
import '../entities/subject_progress_entity.dart';

/// Complete dashboard data from unified endpoint
class CompleteDashboardEntity {
  final StatsEntity stats;
  final List<StudySessionEntity> todaySessions;
  final List<SubjectProgressEntity> subjectsProgress;
  final List<Map<String, dynamic>> featuredCourses;
  final List<Map<String, dynamic>> sponsors;
  final List<Map<String, dynamic>> promos;

  const CompleteDashboardEntity({
    required this.stats,
    required this.todaySessions,
    required this.subjectsProgress,
    required this.featuredCourses,
    required this.sponsors,
    required this.promos,
  });
}

/// Repository interface for Home dashboard data
abstract class HomeRepository {
  /// OPTIMIZED: Get all dashboard data in a single API call
  Future<Either<Failure, CompleteDashboardEntity>> getCompleteDashboard();

  /// Get user statistics for dashboard
  Future<Either<Failure, StatsEntity>> getStats();

  /// Get today's study sessions
  Future<Either<Failure, List<StudySessionEntity>>> getTodaySessions();

  /// Get subject progress for all enrolled subjects
  Future<Either<Failure, List<SubjectProgressEntity>>> getSubjectsProgress();

  /// Mark a session as completed
  Future<Either<Failure, void>> markSessionCompleted(int sessionId);

  /// Mark a session as missed
  Future<Either<Failure, void>> markSessionMissed(int sessionId);

  /// Update study time (track session)
  Future<Either<Failure, void>> updateStudyTime(int minutes);
}
