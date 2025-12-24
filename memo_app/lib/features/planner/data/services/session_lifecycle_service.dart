import 'package:flutter/material.dart';
import '../../domain/entities/study_session.dart';
import '../../domain/entities/planner_settings.dart';
import '../datasources/planner_local_datasource.dart';

/// Service responsible for managing the lifecycle of study sessions
///
/// Key responsibilities:
/// - Mark past sessions as "missed" (فائتة) after grace period
/// - Handle session status transitions based on time
/// - Provide rescheduling capabilities for missed sessions
class SessionLifecycleService {
  final PlannerLocalDataSource localDataSource;

  /// Default grace period in minutes before marking a session as missed
  static const int defaultGracePeriodMinutes = 15;

  SessionLifecycleService({required this.localDataSource});

  /// Mark all past scheduled sessions as "missed" (فائتة)
  ///
  /// Sessions are marked as missed if:
  /// 1. Status is "scheduled"
  /// 2. Scheduled START time has passed (including breaks and prayer times)
  ///
  /// [gracePeriodMinutes] - Time after session START before marking as missed
  /// Returns list of sessions that were marked as missed
  Future<List<StudySession>> markPastSessionsAsMissed({
    int gracePeriodMinutes = defaultGracePeriodMinutes,
  }) async {
    final now = DateTime.now();

    // Get sessions from the last 30 days to catch any that might have been missed
    final sessions = await localDataSource.getSessionsInRange(
      now.subtract(const Duration(days: 30)),
      now,
    );

    final updatedSessions = <StudySession>[];

    for (final session in sessions) {
      // Only process scheduled sessions (including breaks and prayer times)
      if (session.status != SessionStatus.scheduled) continue;

      // Calculate session START time with grace period
      final sessionStartDateTime = DateTime(
        session.scheduledDate.year,
        session.scheduledDate.month,
        session.scheduledDate.day,
        session.scheduledStartTime.hour,
        session.scheduledStartTime.minute,
      ).add(Duration(minutes: gracePeriodMinutes));

      // Mark as missed if grace period after START time has passed
      if (sessionStartDateTime.isBefore(now)) {
        final updatedSession = session.copyWith(
          status: SessionStatus.missed,
        );
        await localDataSource.updateSession(updatedSession);
        updatedSessions.add(updatedSession);
      }
    }

    return updatedSessions;
  }

  /// Mark sessions as missed using settings from PlannerSettings
  Future<List<StudySession>> markPastSessionsAsMissedWithSettings(
    PlannerSettings settings,
  ) async {
    final gracePeriod = settings.gracePeriodMinutes;
    return markPastSessionsAsMissed(gracePeriodMinutes: gracePeriod);
  }

  /// Check if a specific session should be marked as missed
  /// Now includes breaks and prayer times, checks START time instead of end time
  bool shouldMarkAsMissed(
    StudySession session, {
    int gracePeriodMinutes = defaultGracePeriodMinutes,
  }) {
    if (session.status != SessionStatus.scheduled) return false;
    // No longer excluding breaks or prayer times

    final now = DateTime.now();
    final sessionStartDateTime = DateTime(
      session.scheduledDate.year,
      session.scheduledDate.month,
      session.scheduledDate.day,
      session.scheduledStartTime.hour,
      session.scheduledStartTime.minute,
    ).add(Duration(minutes: gracePeriodMinutes));

    return sessionStartDateTime.isBefore(now);
  }

  /// Get all missed sessions that can be rescheduled
  Future<List<StudySession>> getMissedSessions() async {
    final now = DateTime.now();
    final sessions = await localDataSource.getSessionsInRange(
      now.subtract(const Duration(days: 30)),
      now,
    );

    return sessions
        .where((session) =>
            session.status == SessionStatus.missed &&
            !session.isBreak &&
            !session.isPrayerTime)
        .toList();
  }

  /// Find the next available slot for rescheduling a missed session
  ///
  /// [missedSession] - The session that needs to be rescheduled
  /// [settings] - Planner settings for study window constraints
  /// [existingSessions] - Current scheduled sessions to avoid conflicts
  ///
  /// Returns a new session with updated schedule, or null if no slot found
  Future<StudySession?> findNextAvailableSlot({
    required StudySession missedSession,
    required PlannerSettings settings,
    required List<StudySession> existingSessions,
  }) async {
    final now = DateTime.now();
    final sessionDuration = missedSession.duration;

    // Search for next 7 days
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final targetDate = now.add(Duration(days: dayOffset));

      // Skip if it's today and we're past study end time
      if (dayOffset == 0) {
        final currentTime = TimeOfDay.fromDateTime(now);
        if (_isTimePast(currentTime, settings.studyEndTime)) continue;
      }

      // Get sessions for this day
      final daySessions = existingSessions.where((s) {
        return s.scheduledDate.year == targetDate.year &&
            s.scheduledDate.month == targetDate.month &&
            s.scheduledDate.day == targetDate.day;
      }).toList();

      // Sort by start time
      daySessions.sort((a, b) {
        final aMinutes =
            a.scheduledStartTime.hour * 60 + a.scheduledStartTime.minute;
        final bMinutes =
            b.scheduledStartTime.hour * 60 + b.scheduledStartTime.minute;
        return aMinutes.compareTo(bMinutes);
      });

      // Find available slot
      final slot = _findSlotInDay(
        targetDate: targetDate,
        daySessions: daySessions,
        requiredDuration: sessionDuration,
        studyStartTime: settings.studyStartTime,
        studyEndTime: settings.studyEndTime,
        minBreak: settings.minBreakBetweenSessions,
        isToday: dayOffset == 0,
        currentTime: now,
      );

      if (slot != null) {
        // Create new session with updated schedule
        final newId =
            'reschedule_${missedSession.id}_${DateTime.now().millisecondsSinceEpoch}';
        return StudySession(
          id: newId,
          userId: missedSession.userId,
          subjectId: missedSession.subjectId,
          subjectName: missedSession.subjectName,
          chapterId: missedSession.chapterId,
          chapterName: missedSession.chapterName,
          scheduledDate: targetDate,
          scheduledStartTime: slot.startTime,
          scheduledEndTime: slot.endTime,
          duration: sessionDuration,
          suggestedContentId: missedSession.suggestedContentId,
          suggestedContentType: missedSession.suggestedContentType,
          contentTitle: missedSession.contentTitle,
          contentSuggestion: missedSession.contentSuggestion,
          topicName: missedSession.topicName,
          sessionType: missedSession.sessionType,
          requiredEnergyLevel: missedSession.requiredEnergyLevel,
          estimatedEnergyLevel: missedSession.estimatedEnergyLevel,
          priorityScore: missedSession.priorityScore,
          isPinned: false,
          isBreak: false,
          isPrayerTime: false,
          subjectColor: missedSession.subjectColor,
          usePomodoroTechnique: missedSession.usePomodoroTechnique,
          pomodoroDurationMinutes: missedSession.pomodoroDurationMinutes,
          status: SessionStatus.scheduled,
          userNotes: 'إعادة جدولة من جلسة فائتة: ${missedSession.id}',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    }

    return null; // No available slot found
  }

  /// Reschedule a missed session to the next available slot
  ///
  /// Returns the updated session with new schedule if successful, null otherwise
  /// The original session is updated in place (same ID) for easier API sync
  Future<StudySession?> rescheduleMissedSession({
    required StudySession missedSession,
    required PlannerSettings settings,
  }) async {
    if (missedSession.status != SessionStatus.missed) {
      return null;
    }

    // Get all existing scheduled sessions
    final now = DateTime.now();
    final existingSessions = await localDataSource.getSessionsInRange(
      now,
      now.add(const Duration(days: 7)),
    );

    // Filter to only scheduled sessions (excluding the current missed session)
    final scheduledSessions = existingSessions
        .where((s) => s.status == SessionStatus.scheduled && s.id != missedSession.id)
        .toList();

    // Find next available slot
    final slotSession = await findNextAvailableSlot(
      missedSession: missedSession,
      settings: settings,
      existingSessions: scheduledSessions,
    );

    if (slotSession != null) {
      // Update the original session in place (keep same ID for API sync)
      final updatedSession = missedSession.copyWith(
        scheduledDate: slotSession.scheduledDate,
        scheduledStartTime: slotSession.scheduledStartTime,
        scheduledEndTime: slotSession.scheduledEndTime,
        status: SessionStatus.scheduled,
        userNotes: 'إعادة جدولة من جلسة فائتة',
        updatedAt: DateTime.now(),
      );

      // Save the updated session locally
      await localDataSource.updateSession(updatedSession);

      return updatedSession;
    }

    return null;
  }

  /// Get sessions that are currently overdue (past start time but not started)
  /// Now includes breaks and prayer times
  Future<List<StudySession>> getOverdueSessions({
    int gracePeriodMinutes = defaultGracePeriodMinutes,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todaySessions = await localDataSource.getTodaysSessions();

    return todaySessions.where((session) {
      if (session.status != SessionStatus.scheduled) return false;
      // No longer excluding breaks or prayer times

      final sessionStartDateTime = DateTime(
        today.year,
        today.month,
        today.day,
        session.scheduledStartTime.hour,
        session.scheduledStartTime.minute,
      );

      final sessionStartWithGrace = sessionStartDateTime.add(
        Duration(minutes: gracePeriodMinutes),
      );

      // Session is overdue if start time has passed but grace period hasn't ended
      return sessionStartDateTime.isBefore(now) &&
          sessionStartWithGrace.isAfter(now);
    }).toList();
  }

  // Helper: Check if time1 is past time2
  bool _isTimePast(TimeOfDay time1, TimeOfDay time2) {
    final minutes1 = time1.hour * 60 + time1.minute;
    final minutes2 = time2.hour * 60 + time2.minute;
    return minutes1 >= minutes2;
  }

  // Helper: Find available slot in a day
  _TimeSlot? _findSlotInDay({
    required DateTime targetDate,
    required List<StudySession> daySessions,
    required Duration requiredDuration,
    required TimeOfDay studyStartTime,
    required TimeOfDay studyEndTime,
    required int minBreak,
    required bool isToday,
    required DateTime currentTime,
  }) {
    final requiredMinutes = requiredDuration.inMinutes;

    // Start time: either study start or current time (whichever is later)
    int searchStartMinutes = studyStartTime.hour * 60 + studyStartTime.minute;

    if (isToday) {
      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      // Add 5 minutes buffer from current time
      searchStartMinutes =
          currentMinutes > searchStartMinutes ? currentMinutes + 5 : searchStartMinutes;
    }

    final studyEndMinutes = studyEndTime.hour * 60 + studyEndTime.minute;

    // Check gaps between sessions
    int previousEnd = searchStartMinutes;

    for (final session in daySessions) {
      final sessionStart =
          session.scheduledStartTime.hour * 60 + session.scheduledStartTime.minute;
      final sessionEnd =
          session.scheduledEndTime.hour * 60 + session.scheduledEndTime.minute;

      // Check if there's a gap before this session
      final availableMinutes = sessionStart - previousEnd - minBreak;

      if (availableMinutes >= requiredMinutes) {
        return _TimeSlot(
          startTime: TimeOfDay(
            hour: previousEnd ~/ 60,
            minute: previousEnd % 60,
          ),
          endTime: TimeOfDay(
            hour: (previousEnd + requiredMinutes) ~/ 60,
            minute: (previousEnd + requiredMinutes) % 60,
          ),
        );
      }

      previousEnd = sessionEnd + minBreak;
    }

    // Check gap after last session
    final availableMinutes = studyEndMinutes - previousEnd;
    if (availableMinutes >= requiredMinutes) {
      return _TimeSlot(
        startTime: TimeOfDay(
          hour: previousEnd ~/ 60,
          minute: previousEnd % 60,
        ),
        endTime: TimeOfDay(
          hour: (previousEnd + requiredMinutes) ~/ 60,
          minute: (previousEnd + requiredMinutes) % 60,
        ),
      );
    }

    return null;
  }
}

/// Helper class representing a time slot
class _TimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  _TimeSlot({required this.startTime, required this.endTime});
}

