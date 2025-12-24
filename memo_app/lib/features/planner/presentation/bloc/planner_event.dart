import 'package:equatable/equatable.dart';
import '../../domain/entities/schedule.dart';

/// Base class for all PlannerBloc events
abstract class PlannerEvent extends Equatable {
  const PlannerEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// Schedule Management Events
// ============================================================================

/// Generate a new study schedule
///
/// [scheduleType] - Type of schedule: daily (1 day), weekly (7 days), or full (30 days)
/// [selectedSubjectIds] - Optional filter for specific subjects (if null, uses settings)
class GenerateScheduleEvent extends PlannerEvent {
  final DateTime startDate;
  final DateTime endDate;
  final bool startFromNow;
  /// Type of schedule to generate
  final ScheduleType scheduleType;
  /// Specific subjects to include (null = all subjects from settings)
  final List<String>? selectedSubjectIds;

  const GenerateScheduleEvent({
    required this.startDate,
    required this.endDate,
    this.startFromNow = true,
    this.scheduleType = ScheduleType.weekly,
    this.selectedSubjectIds,
  });

  @override
  List<Object?> get props => [startDate, endDate, startFromNow, scheduleType, selectedSubjectIds];
}

/// Load today's sessions
class LoadTodaysScheduleEvent extends PlannerEvent {
  const LoadTodaysScheduleEvent();
}

/// Load sessions for a specific week
class LoadWeekScheduleEvent extends PlannerEvent {
  final DateTime startDate;

  const LoadWeekScheduleEvent(this.startDate);

  @override
  List<Object?> get props => [startDate];
}

/// Refresh current schedule (re-fetch from source)
class RefreshScheduleEvent extends PlannerEvent {
  const RefreshScheduleEvent();
}

/// Force refresh schedule from server (clears local cache and fetches fresh data)
/// Use this when local cache is stale and needs to be replaced with server data
class ForceRefreshFromServerEvent extends PlannerEvent {
  const ForceRefreshFromServerEvent();
}

// ============================================================================
// Session Action Events
// ============================================================================

/// Start a scheduled session
class StartSessionEvent extends PlannerEvent {
  final String sessionId;

  const StartSessionEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Pause an in-progress session
class PauseSessionEvent extends PlannerEvent {
  final String sessionId;

  const PauseSessionEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Resume a paused session
class ResumeSessionEvent extends PlannerEvent {
  final String sessionId;

  const ResumeSessionEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Complete a session
class CompleteSessionEvent extends PlannerEvent {
  final String sessionId;
  final String? userNotes;
  final double? completionRate;
  final String? mood; // happy, neutral, sad

  const CompleteSessionEvent({
    required this.sessionId,
    this.userNotes,
    this.completionRate,
    this.mood,
  });

  @override
  List<Object?> get props => [sessionId, userNotes, completionRate, mood];
}

/// Skip a session with reason
class SkipSessionEvent extends PlannerEvent {
  final String sessionId;
  final String reason;

  const SkipSessionEvent({required this.sessionId, required this.reason});

  @override
  List<Object?> get props => [sessionId, reason];
}

/// Reschedule a session to a new time
class RescheduleSessionEvent extends PlannerEvent {
  final String sessionId;
  final DateTime newDate;

  const RescheduleSessionEvent({
    required this.sessionId,
    required this.newDate,
  });

  @override
  List<Object?> get props => [sessionId, newDate];
}

/// Pin/unpin a session (prevent auto-rescheduling)
class PinSessionEvent extends PlannerEvent {
  final String sessionId;
  final bool isPinned;

  const PinSessionEvent({required this.sessionId, required this.isPinned});

  @override
  List<Object?> get props => [sessionId, isPinned];
}

// ============================================================================
// Settings Events
// ============================================================================

/// Load planner settings
class LoadSettingsEvent extends PlannerEvent {
  const LoadSettingsEvent();
}

/// Update planner settings
class UpdateSettingsEvent extends PlannerEvent {
  const UpdateSettingsEvent();
}

/// Save planner settings
class SaveSettingsEvent extends PlannerEvent {
  final double dailyGoalHours;
  final String studyStartTime;
  final String studyEndTime;
  final String morningEnergy;
  final String afternoonEnergy;
  final String eveningEnergy;
  final bool usePomodoro;
  final int? pomodoroWorkMinutes;
  final int? pomodoroBreakMinutes;
  final bool autoRescheduleMissed;

  const SaveSettingsEvent({
    required this.dailyGoalHours,
    required this.studyStartTime,
    required this.studyEndTime,
    required this.morningEnergy,
    required this.afternoonEnergy,
    required this.eveningEnergy,
    required this.usePomodoro,
    this.pomodoroWorkMinutes,
    this.pomodoroBreakMinutes,
    required this.autoRescheduleMissed,
  });

  @override
  List<Object?> get props => [
    dailyGoalHours,
    studyStartTime,
    studyEndTime,
    morningEnergy,
    afternoonEnergy,
    eveningEnergy,
    usePomodoro,
    pomodoroWorkMinutes,
    pomodoroBreakMinutes,
    autoRescheduleMissed,
  ];
}

// ============================================================================
// Sync Events
// ============================================================================

/// Sync offline changes to server
class SyncOfflineChangesEvent extends PlannerEvent {
  const SyncOfflineChangesEvent();
}

/// Clear local cache
class ClearCacheEvent extends PlannerEvent {
  const ClearCacheEvent();
}

/// Delete entire schedule
class DeleteScheduleEvent extends PlannerEvent {
  const DeleteScheduleEvent();
}

// ============================================================================
// Session Lifecycle Events
// ============================================================================

/// Check and update session lifecycle (mark past sessions as missed)
/// Should be called at app launch, when returning to foreground, and at midnight
class CheckSessionLifecycleEvent extends PlannerEvent {
  const CheckSessionLifecycleEvent();
}

/// Reschedule a missed session to the next available slot
class RescheduleMissedSessionEvent extends PlannerEvent {
  final String sessionId;

  const RescheduleMissedSessionEvent({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

/// Get all missed sessions for display
class LoadMissedSessionsEvent extends PlannerEvent {
  const LoadMissedSessionsEvent();
}

/// Get overdue sessions (past start time but not yet missed)
class LoadOverdueSessionsEvent extends PlannerEvent {
  const LoadOverdueSessionsEvent();
}

/// Load all scheduled sessions (for full schedule view)
class LoadFullScheduleEvent extends PlannerEvent {
  const LoadFullScheduleEvent();
}

/// Load sessions for a specific date
class LoadSessionsForDateEvent extends PlannerEvent {
  final DateTime date;

  const LoadSessionsForDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

// ============================================================================
// Adaptation Events
// ============================================================================

/// Trigger schedule adaptation based on performance
class TriggerAdaptationEvent extends PlannerEvent {
  const TriggerAdaptationEvent();
}

// ============================================================================
// Session Content Events (Curriculum Integration)
// ============================================================================

/// Load content items for a study session
class LoadSessionContentEvent extends PlannerEvent {
  final String subjectId;
  final String sessionType; // study, revision, practice, exam
  final int durationMinutes;
  final int limit;
  /// Optional: specific content ID from the session (subject_planner_content_id)
  /// When provided, only shows the content for this specific unit/topic
  final String? contentId;

  const LoadSessionContentEvent({
    required this.subjectId,
    required this.sessionType,
    this.durationMinutes = 30,
    this.limit = 5,
    this.contentId,
  });

  @override
  List<Object?> get props => [subjectId, sessionType, durationMinutes, limit, contentId];
}

/// Mark content phase as complete for a specific content item
class MarkContentPhaseCompleteEvent extends PlannerEvent {
  final String contentId;
  final String phase; // understanding, review, theory_practice, exercise_practice
  final int durationMinutes;

  const MarkContentPhaseCompleteEvent({
    required this.contentId,
    required this.phase,
    this.durationMinutes = 0,
  });

  @override
  List<Object?> get props => [contentId, phase, durationMinutes];
}

/// Mark multiple content items' phases as complete (used when completing a session)
class MarkSessionContentCompleteEvent extends PlannerEvent {
  final List<String> contentIds;
  final String sessionType; // determines which phase to mark
  final int totalDurationMinutes;

  const MarkSessionContentCompleteEvent({
    required this.contentIds,
    required this.sessionType,
    this.totalDurationMinutes = 0,
  });

  /// Get the phase to mark based on session type
  String get phaseToMark {
    return switch (sessionType) {
      'study' => 'understanding',
      'revision' => 'review',
      'practice' => 'theory_practice',
      'exam' => 'exercise_practice',
      _ => 'understanding',
    };
  }

  @override
  List<Object?> get props => [contentIds, sessionType, totalDurationMinutes];
}
