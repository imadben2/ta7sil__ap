import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/study_session.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/session_content.dart';
import '../../domain/usecases/trigger_adaptation.dart';

/// Base class for all PlannerBloc states
abstract class PlannerState extends Equatable {
  const PlannerState();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// Initial & Loading States
// ============================================================================

/// Initial state when BLoC is created
class PlannerInitial extends PlannerState {
  const PlannerInitial();
}

/// Generic loading state
class PlannerLoading extends PlannerState {
  final String? message;

  const PlannerLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Specific loading state for schedule generation
class GeneratingSchedule extends PlannerState {
  final int progress; // 0-100

  const GeneratingSchedule({this.progress = 0});

  @override
  List<Object?> get props => [progress];
}

// ============================================================================
// Success States - Schedule
// ============================================================================

/// Schedule loaded successfully
class ScheduleLoaded extends PlannerState {
  final List<StudySession> sessions;
  final DateTime date;
  final String? message;

  const ScheduleLoaded({
    required this.sessions,
    required this.date,
    this.message,
  });

  @override
  List<Object?> get props => [sessions, date, message];
}

/// Week schedule loaded successfully
class WeekScheduleLoaded extends PlannerState {
  final List<StudySession> sessions;
  final DateTime weekStart;
  final String? message;

  const WeekScheduleLoaded({
    required this.sessions,
    required this.weekStart,
    this.message,
  });

  @override
  List<Object?> get props => [sessions, weekStart, message];
}

/// New schedule generated successfully
class ScheduleGenerated extends PlannerState {
  final Schedule schedule;
  final String message;

  const ScheduleGenerated({required this.schedule, required this.message});

  @override
  List<Object?> get props => [schedule, message];
}

// ============================================================================
// Success States - Session Actions
// ============================================================================

/// Session started successfully
class SessionStarted extends PlannerState {
  final StudySession session;
  final String message;

  const SessionStarted({required this.session, required this.message});

  @override
  List<Object?> get props => [session, message];
}

/// Session paused successfully
class SessionPaused extends PlannerState {
  final StudySession session;

  const SessionPaused({required this.session});

  @override
  List<Object?> get props => [session];
}

/// Session resumed successfully
class SessionResumed extends PlannerState {
  final StudySession session;

  const SessionResumed({required this.session});

  @override
  List<Object?> get props => [session];
}

/// Session completed successfully
class SessionCompleted extends PlannerState {
  final StudySession session;
  final int pointsEarned;
  final String message;

  const SessionCompleted({
    required this.session,
    required this.pointsEarned,
    required this.message,
  });

  @override
  List<Object?> get props => [session, pointsEarned, message];
}

/// Session skipped
class SessionSkipped extends PlannerState {
  final StudySession session;
  final String reason;
  final String message;

  const SessionSkipped({
    required this.session,
    required this.reason,
    required this.message,
  });

  @override
  List<Object?> get props => [session, reason, message];
}

/// Session rescheduled
class SessionRescheduled extends PlannerState {
  final StudySession session;
  final DateTime newDate;
  final String message;

  const SessionRescheduled({
    required this.session,
    required this.newDate,
    required this.message,
  });

  @override
  List<Object?> get props => [session, newDate, message];
}

/// Session pinned/unpinned
class SessionPinned extends PlannerState {
  final StudySession session;
  final bool isPinned;
  final String message;

  const SessionPinned({
    required this.session,
    required this.isPinned,
    required this.message,
  });

  @override
  List<Object?> get props => [session, isPinned, message];
}

// ============================================================================
// Success States - Sync & Cache
// ============================================================================

/// Offline changes synced successfully
class OfflineChangesSynced extends PlannerState {
  final int syncedCount;
  final String message;

  const OfflineChangesSynced({
    required this.syncedCount,
    required this.message,
  });

  @override
  List<Object?> get props => [syncedCount, message];
}

/// Cache cleared successfully
class CacheCleared extends PlannerState {
  final String message;

  const CacheCleared({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Schedule deleted successfully
class ScheduleDeleted extends PlannerState {
  final String message;

  const ScheduleDeleted({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Settings saved successfully
class SettingsSaved extends PlannerState {
  final String message;

  const SettingsSaved({this.message = 'تم حفظ الإعدادات بنجاح'});

  @override
  List<Object?> get props => [message];
}

// ============================================================================
// Error State
// ============================================================================

/// Error occurred
class PlannerError extends PlannerState {
  final String message;
  final Failure? failure;
  final bool canRetry;

  const PlannerError({
    required this.message,
    this.failure,
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, failure, canRetry];
}

// ============================================================================
// Empty State
// ============================================================================

/// No schedule available
class NoScheduleAvailable extends PlannerState {
  final String message;

  const NoScheduleAvailable({
    this.message = 'لا يوجد جدول دراسي. قم بإنشاء جدول جديد.',
  });

  @override
  List<Object?> get props => [message];
}

// ============================================================================
// Session Lifecycle States
// ============================================================================

/// Sessions marked as missed after lifecycle check
class SessionsMarkedMissed extends PlannerState {
  final List<StudySession> missedSessions;
  final int count;
  final String message;

  const SessionsMarkedMissed({
    required this.missedSessions,
    required this.count,
    required this.message,
  });

  @override
  List<Object?> get props => [missedSessions, count, message];
}

/// Missed session rescheduled successfully
class MissedSessionRescheduled extends PlannerState {
  final StudySession originalSession;
  final StudySession newSession;
  final String message;

  const MissedSessionRescheduled({
    required this.originalSession,
    required this.newSession,
    required this.message,
  });

  @override
  List<Object?> get props => [originalSession, newSession, message];
}

/// Failed to reschedule missed session (no available slots)
class MissedSessionRescheduleFailed extends PlannerState {
  final StudySession session;
  final String message;

  const MissedSessionRescheduleFailed({
    required this.session,
    required this.message,
  });

  @override
  List<Object?> get props => [session, message];
}

/// Missed sessions loaded
class MissedSessionsLoaded extends PlannerState {
  final List<StudySession> missedSessions;

  const MissedSessionsLoaded({required this.missedSessions});

  @override
  List<Object?> get props => [missedSessions];
}

/// Overdue sessions loaded (past start time but not yet missed)
class OverdueSessionsLoaded extends PlannerState {
  final List<StudySession> overdueSessions;

  const OverdueSessionsLoaded({required this.overdueSessions});

  @override
  List<Object?> get props => [overdueSessions];
}

/// Full schedule loaded (all sessions)
class FullScheduleLoaded extends PlannerState {
  final List<StudySession> sessions;
  final DateTime startDate;
  final DateTime endDate;
  final String? message;

  const FullScheduleLoaded({
    required this.sessions,
    required this.startDate,
    required this.endDate,
    this.message,
  });

  @override
  List<Object?> get props => [sessions, startDate, endDate, message];
}

// ============================================================================
// Adaptation States
// ============================================================================

/// Adaptation in progress
class AdaptationInProgress extends PlannerState {
  final String message;

  const AdaptationInProgress({this.message = 'جاري تكييف الجدول...'});

  @override
  List<Object?> get props => [message];
}

/// Adaptation completed successfully
class AdaptationCompleted extends PlannerState {
  final AdaptationResult result;
  final String message;

  const AdaptationCompleted({
    required this.result,
    this.message = 'تم تكييف الجدول بنجاح',
  });

  @override
  List<Object?> get props => [result, message];
}

// ============================================================================
// Session Content States (Curriculum Integration)
// ============================================================================

/// Loading session content
class SessionContentLoading extends PlannerState {
  final String message;

  const SessionContentLoading({this.message = 'جاري تحميل المحتوى...'});

  @override
  List<Object?> get props => [message];
}

/// Session content loaded successfully
class SessionContentLoaded extends PlannerState {
  final List<SessionContent> contents;
  final SessionContentMeta meta;

  const SessionContentLoaded({
    required this.contents,
    required this.meta,
  });

  @override
  List<Object?> get props => [contents, meta];
}

/// Session content load error
class SessionContentError extends PlannerState {
  final String message;

  const SessionContentError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Content phase marked complete
class ContentPhaseMarked extends PlannerState {
  final String contentId;
  final String phase;
  final String message;

  const ContentPhaseMarked({
    required this.contentId,
    required this.phase,
    this.message = 'تم تحديث التقدم',
  });

  @override
  List<Object?> get props => [contentId, phase, message];
}

/// Multiple content phases marked complete (session completion)
class SessionContentMarkedComplete extends PlannerState {
  final int contentCount;
  final String phase;
  final String message;

  const SessionContentMarkedComplete({
    required this.contentCount,
    required this.phase,
    this.message = 'تم تحديث تقدم المحتوى',
  });

  @override
  List<Object?> get props => [contentCount, phase, message];
}
