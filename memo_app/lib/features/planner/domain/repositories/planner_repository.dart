import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/schedule.dart';
import '../entities/study_session.dart';
import '../entities/planner_settings.dart';
import '../entities/prayer_times.dart';
import '../entities/subject.dart';
import '../entities/exam.dart';
import '../entities/centralized_subject.dart';
import '../entities/planner_analytics.dart';
import '../entities/session_history.dart';
import '../entities/achievement.dart';
import '../entities/points_history.dart';
import '../entities/session_content.dart';
import '../usecases/trigger_adaptation.dart';
import '../usecases/record_exam_result.dart';

/// Abstract repository interface for planner operations
abstract class PlannerRepository {
  /// Generate a new study schedule
  ///
  /// [scheduleType] - Type of schedule (daily, weekly, full 30-day)
  /// [selectedSubjectIds] - Optional filter for specific subjects
  Future<Either<Failure, Schedule>> generateSchedule({
    required PlannerSettings settings,
    required List<Subject> subjects,
    required List<Exam> exams,
    required DateTime startDate,
    required DateTime endDate,
    bool startFromNow = true,
    ScheduleType scheduleType = ScheduleType.weekly,
    List<String>? selectedSubjectIds,
  });

  /// Get today's sessions
  Future<Either<Failure, List<StudySession>>> getTodaysSessions();

  /// Get sessions for a specific week
  Future<Either<Failure, List<StudySession>>> getWeekSessions(
    DateTime startDate,
  );

  /// Get all sessions for next 30 days
  Future<Either<Failure, List<StudySession>>> getAllUpcomingSessions();

  /// Start a session
  Future<Either<Failure, Unit>> startSession(String sessionId);

  /// Pause a session
  Future<Either<Failure, Unit>> pauseSession(String sessionId);

  /// Resume a paused session
  Future<Either<Failure, Unit>> resumeSession(String sessionId);

  /// Complete a session
  Future<Either<Failure, Unit>> completeSession(
    String sessionId, {
    required int completionPercentage,
    String? userNotes,
    String? mood,
  });

  /// Skip a session with reason
  Future<Either<Failure, Unit>> skipSession(String sessionId, String reason);

  /// Reschedule a session
  Future<Either<Failure, Unit>> rescheduleSession(
    String sessionId,
    DateTime newDateTime,
  );

  /// Pin/unpin a session
  Future<Either<Failure, Unit>> pinSession(String sessionId, bool isPinned);

  /// Delete all sessions (entire schedule)
  Future<Either<Failure, Unit>> deleteAllSessions();

  /// Force refresh sessions from server (clears local cache and fetches fresh data)
  /// Returns the refreshed sessions for today
  Future<Either<Failure, List<StudySession>>> forceRefreshFromServer();

  /// Get planner settings
  Future<Either<Failure, PlannerSettings>> getSettings();

  /// Update planner settings
  Future<Either<Failure, Unit>> updateSettings(PlannerSettings settings);

  /// Get prayer times for a specific date
  Future<Either<Failure, PrayerTimes>> getPrayerTimes(
    DateTime date,
    String city,
  );

  // Subject Management
  /// Get all subjects
  Future<Either<Failure, List<Subject>>> getAllSubjects();

  /// Get a specific subject by ID
  Future<Either<Failure, Subject>> getSubject(String id);

  /// Add a new subject
  Future<Either<Failure, Subject>> addSubject(Subject subject);

  /// Update an existing subject
  Future<Either<Failure, Subject>> updateSubject(Subject subject);

  /// Delete a subject
  Future<Either<Failure, Unit>> deleteSubject(String id);

  // Exam Management
  /// Get all exams
  Future<Either<Failure, List<Exam>>> getAllExams();

  /// Get exams for a specific subject
  Future<Either<Failure, List<Exam>>> getExamsBySubject(String subjectId);

  /// Get upcoming exams
  Future<Either<Failure, List<Exam>>> getUpcomingExams();

  /// Add a new exam
  Future<Either<Failure, Exam>> addExam(Exam exam);

  /// Update an existing exam
  Future<Either<Failure, Exam>> updateExam(Exam exam);

  /// Delete an exam
  Future<Either<Failure, Unit>> deleteExam(String id);

  // Centralized Subjects Management
  /// Get all centralized subjects from shared API
  /// These subjects are managed centrally and shared across features
  Future<Either<Failure, List<CentralizedSubject>>> getCentralizedSubjects({
    int? streamId,
    int? yearId,
    bool activeOnly = true,
  });

  // Analytics & History
  /// Get comprehensive planner analytics for a specified period
  Future<Either<Failure, PlannerAnalytics>> getPlannerAnalytics(String period);

  /// Get session history with filters and aggregations
  Future<Either<Failure, SessionHistory>> getSessionHistory({
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? filters,
  });

  // Gamification & Achievements
  /// Get all achievements with progress and stats
  Future<Either<Failure, AchievementsResponse>> getAchievements();

  /// Get points history for a specified period
  Future<Either<Failure, PointsHistory>> getPointsHistory(int periodDays);

  // Exam Result Recording
  /// Record an exam result and optionally trigger adaptation
  Future<Either<Failure, ExamResultResponse>> recordExamResult({
    required String examId,
    required double score,
    required double maxScore,
    String? notes,
  });

  // Schedule Adaptation
  /// Trigger manual schedule adaptation based on performance
  Future<Either<Failure, AdaptationResult>> triggerAdaptation();

  // Session Content (Curriculum Integration)
  /// Get next content items to study for a session
  ///
  /// [subjectId] - Subject ID to get content for
  /// [sessionType] - Type of session (study, revision, practice, exam)
  /// [durationMinutes] - Session duration to estimate content amount
  /// [limit] - Max items to return (default 5)
  /// [contentId] - Optional specific content ID to filter (e.g., unit ID from session)
  Future<Either<Failure, (List<SessionContent>, SessionContentMeta)>> getNextSessionContent({
    required String subjectId,
    required String sessionType,
    int durationMinutes = 30,
    int limit = 5,
    String? contentId,
  });

  /// Mark a content item's phase as complete
  ///
  /// [contentId] - Subject planner content ID
  /// [phase] - Phase to mark (understanding, review, theory_practice, exercise_practice)
  /// [durationMinutes] - Time spent on this content
  Future<Either<Failure, Unit>> markContentPhaseComplete({
    required String contentId,
    required String phase,
    int durationMinutes = 0,
  });

  /// Mark multiple content items' phases as complete (batch operation)
  ///
  /// Used when completing a session to mark all assigned content
  Future<Either<Failure, Unit>> markMultipleContentPhasesComplete({
    required List<String> contentIds,
    required String phase,
    int durationMinutes = 0,
  });
}
