import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/study_session.dart';
import '../../domain/entities/planner_settings.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/exam.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/centralized_subject.dart';
import '../local/hive_adapters/register_adapters.dart';

/// Local data source for planner feature using Hive
///
/// Provides offline-first storage for all planner entities
abstract class PlannerLocalDataSource {
  // Study Sessions
  Future<void> cacheSession(StudySession session);
  Future<List<StudySession>> getCachedSessions();
  Future<StudySession?> getSession(String sessionId);
  Future<List<StudySession>> getTodaysSessions();
  Future<List<StudySession>> getSessionsInRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<void> updateSession(StudySession session);
  Future<void> deleteSession(String sessionId);
  Future<void> clearAllSessions();
  Future<void> clearPendingSessions(); // Clear only pending/scheduled sessions, preserving completed/in-progress
  Future<void> flushSessions(); // Force flush sessions to disk

  // Planner Settings
  Future<void> cacheSettings(PlannerSettings settings);
  Future<PlannerSettings?> getCachedSettings(String userId);
  Future<void> updateSettings(PlannerSettings settings);

  // Prayer Times
  Future<void> cachePrayerTimes(PrayerTimes prayerTimes);
  Future<PrayerTimes?> getCachedPrayerTimes(DateTime date);
  Future<void> clearOldPrayerTimes();

  // Subjects
  Future<void> cacheSubject(Subject subject);
  Future<List<Subject>> getCachedSubjects();
  Future<Subject?> getSubject(String subjectId);
  Future<void> updateSubject(Subject subject);
  Future<void> deleteSubject(String subjectId);

  // Exams
  Future<void> cacheExam(Exam exam);
  Future<List<Exam>> getCachedExams();
  Future<Exam?> getExam(String examId);
  Future<void> updateExam(Exam exam);
  Future<void> deleteExam(String examId);

  // Schedules
  Future<void> cacheSchedule(Schedule schedule);
  Future<Schedule?> getLatestSchedule();
  Future<void> clearOldSchedules();

  // Centralized Subjects
  Future<void> cacheCentralizedSubjects(List<CentralizedSubject> subjects);
  Future<List<CentralizedSubject>?> getCachedCentralizedSubjects();
  Future<DateTime?> getCentralizedSubjectsLastUpdate();
  Future<bool> isCentralizedSubjectsCacheValid();

  // Cache Management
  Future<void> clearAllCache();
}

class PlannerLocalDataSourceImpl implements PlannerLocalDataSource {
  static const String _centralizedSubjectsKey = 'centralized_subjects';
  static const String _centralizedSubjectsTimestampKey =
      'centralized_subjects_timestamp';
  static const int _cacheDurationHours = 24;

  // Hive boxes
  Box get _sessionsBox => Hive.box(PlannerBoxNames.studySessions);
  Box get _settingsBox => Hive.box(PlannerBoxNames.plannerSettings);
  Box get _prayerTimesBox => Hive.box(PlannerBoxNames.prayerTimes);
  Box get _subjectsBox => Hive.box(PlannerBoxNames.subjects);
  Box get _examsBox => Hive.box(PlannerBoxNames.exams);
  Box get _schedulesBox => Hive.box(PlannerBoxNames.schedules);
  Box get _centralizedSubjectsBox =>
      Hive.box(PlannerBoxNames.centralizedSubjects);

  // Study Sessions
  @override
  Future<void> cacheSession(StudySession session) async {
    debugPrint('[LocalDataSource] Caching session: ${session.id}, date: ${session.scheduledDate}, isBreak: ${session.isBreak}');
    await _sessionsBox.put(session.id, session);
    debugPrint('[LocalDataSource] Session cached. Box now has ${_sessionsBox.length} sessions');
  }

  @override
  Future<List<StudySession>> getCachedSessions() async {
    try {
      final sessions = _sessionsBox.values.cast<StudySession>().toList();
      debugPrint('[LocalDataSource] ========== GET CACHED SESSIONS ==========');
      debugPrint('[LocalDataSource] Total sessions in box: ${sessions.length}');

      // Debug: Print sample sessions to see what subjects are cached
      if (sessions.isNotEmpty) {
        final sampleSize = sessions.length > 3 ? 3 : sessions.length;
        debugPrint('[LocalDataSource] Sample sessions:');
        for (int i = 0; i < sampleSize; i++) {
          debugPrint('  ${i + 1}. ${sessions[i].subjectName} - ${sessions[i].scheduledDate}');
        }
      }

      return sessions;
    } catch (e, stackTrace) {
      debugPrint('[LocalDataSource] ERROR reading sessions: $e');
      debugPrint('[LocalDataSource] Stack: $stackTrace');
      return [];
    }
  }

  @override
  Future<StudySession?> getSession(String sessionId) async {
    return _sessionsBox.get(sessionId) as StudySession?;
  }

  @override
  Future<List<StudySession>> getTodaysSessions() async {
    final today = DateTime.now();
    final allSessions = await getCachedSessions();

    return allSessions.where((session) {
      final sessionDate = session.scheduledDate;
      // Filter by date AND exclude skipped sessions from display
      return sessionDate.year == today.year &&
          sessionDate.month == today.month &&
          sessionDate.day == today.day &&
          session.status != SessionStatus.skipped;
    }).toList();
  }

  @override
  Future<List<StudySession>> getSessionsInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allSessions = await getCachedSessions();

    return allSessions.where((session) {
      final sessionDate = session.scheduledDate;
      // Filter by date range AND exclude skipped sessions from display
      return (sessionDate.isAfter(startDate) ||
              sessionDate.isAtSameMomentAs(startDate)) &&
          (sessionDate.isBefore(endDate) ||
              sessionDate.isAtSameMomentAs(endDate)) &&
          session.status != SessionStatus.skipped;
    }).toList();
  }

  @override
  Future<void> updateSession(StudySession session) async {
    await _sessionsBox.put(session.id, session);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _sessionsBox.delete(sessionId);
  }

  @override
  Future<void> clearAllSessions() async {
    // Clear both sessions and schedules boxes
    debugPrint('[LocalDataSource] ========== CLEARING ALL SESSIONS ==========');
    debugPrint('[LocalDataSource] Sessions before clear: ${_sessionsBox.length}');
    debugPrint('[LocalDataSource] Schedules before clear: ${_schedulesBox.length}');

    await _sessionsBox.clear();
    await _schedulesBox.clear();

    // Force flush to disk to ensure changes persist immediately
    await _sessionsBox.flush();
    await _schedulesBox.flush();

    debugPrint('[LocalDataSource] ✓ Main boxes cleared and flushed');

    // Also clear ALL related caches to ensure complete cleanup
    try {
      final homeSessionsBox = await Hive.openBox('today_sessions');
      await homeSessionsBox.clear(); // Clear entire box
      await homeSessionsBox.flush();
      debugPrint('[LocalDataSource] ✓ Home sessions cache cleared');
    } catch (e) {
      debugPrint('[LocalDataSource] ⚠ Failed to clear home sessions cache: $e');
    }

    debugPrint('[LocalDataSource] Sessions after clear: ${_sessionsBox.length}');
    debugPrint('[LocalDataSource] Schedules after clear: ${_schedulesBox.length}');
    debugPrint('[LocalDataSource] ========== CLEAR COMPLETE ==========');
  }

  @override
  Future<void> clearPendingSessions() async {
    debugPrint('[LocalDataSource] clearPendingSessions called');
    final allSessions = await getCachedSessions();
    debugPrint('[LocalDataSource] Total sessions before: ${allSessions.length}');

    // Only delete scheduled sessions, preserve completed/in-progress/missed/skipped/paused
    final sessionsToDelete = allSessions.where((session) {
      return session.status == SessionStatus.scheduled;
    }).toList();

    debugPrint('[LocalDataSource] Sessions to delete: ${sessionsToDelete.length}');

    for (final session in sessionsToDelete) {
      await _sessionsBox.delete(session.id);
    }

    // Clear schedules box as we're regenerating
    await _schedulesBox.clear();

    final preserved = allSessions.length - sessionsToDelete.length;
    debugPrint('[LocalDataSource] Cleared ${sessionsToDelete.length} pending sessions, '
        'preserved $preserved completed/in-progress sessions');
  }

  @override
  Future<void> flushSessions() async {
    await _sessionsBox.flush();
    await _schedulesBox.flush();
    debugPrint('[LocalDataSource] Sessions and schedules flushed to disk');
  }

  // Planner Settings
  @override
  Future<void> cacheSettings(PlannerSettings settings) async {
    debugPrint('[LocalDataSource] cacheSettings: userId=${settings.userId}');
    await _settingsBox.put(settings.userId, settings);
    await _settingsBox.flush(); // Ensure persistence
    debugPrint('[LocalDataSource] cacheSettings: flushed to disk');
  }

  @override
  Future<PlannerSettings?> getCachedSettings(String userId) async {
    final settings = _settingsBox.get(userId) as PlannerSettings?;
    debugPrint('[LocalDataSource] getCachedSettings: userId=$userId, found=${settings != null}');
    return settings;
  }

  @override
  Future<void> updateSettings(PlannerSettings settings) async {
    debugPrint('[LocalDataSource] updateSettings: userId=${settings.userId}');
    await _settingsBox.put(settings.userId, settings);
    await _settingsBox.flush(); // Ensure persistence
    debugPrint('[LocalDataSource] updateSettings: flushed to disk');
  }

  // Prayer Times
  @override
  Future<void> cachePrayerTimes(PrayerTimes prayerTimes) async {
    final key = _formatDateKey(prayerTimes.date);
    await _prayerTimesBox.put(key, prayerTimes);
  }

  @override
  Future<PrayerTimes?> getCachedPrayerTimes(DateTime date) async {
    final key = _formatDateKey(date);
    return _prayerTimesBox.get(key) as PrayerTimes?;
  }

  @override
  Future<void> clearOldPrayerTimes() async {
    final today = DateTime.now();
    final keysToDelete = <String>[];

    for (final key in _prayerTimesBox.keys) {
      final parts = (key as String).split('-');
      if (parts.length == 3) {
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );

        // Delete prayer times older than 7 days
        if (today.difference(date).inDays > 7) {
          keysToDelete.add(key);
        }
      }
    }

    for (final key in keysToDelete) {
      await _prayerTimesBox.delete(key);
    }
  }

  // Subjects
  @override
  Future<void> cacheSubject(Subject subject) async {
    await _subjectsBox.put(subject.id, subject);
  }

  @override
  Future<List<Subject>> getCachedSubjects() async {
    return _subjectsBox.values.cast<Subject>().toList();
  }

  @override
  Future<Subject?> getSubject(String subjectId) async {
    return _subjectsBox.get(subjectId) as Subject?;
  }

  @override
  Future<void> updateSubject(Subject subject) async {
    await _subjectsBox.put(subject.id, subject);
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    await _subjectsBox.delete(subjectId);
  }

  // Exams
  @override
  Future<void> cacheExam(Exam exam) async {
    await _examsBox.put(exam.id, exam);
  }

  @override
  Future<List<Exam>> getCachedExams() async {
    return _examsBox.values.cast<Exam>().toList();
  }

  @override
  Future<Exam?> getExam(String examId) async {
    return _examsBox.get(examId) as Exam?;
  }

  @override
  Future<void> updateExam(Exam exam) async {
    await _examsBox.put(exam.id, exam);
  }

  @override
  Future<void> deleteExam(String examId) async {
    await _examsBox.delete(examId);
  }

  // Schedules
  @override
  Future<void> cacheSchedule(Schedule schedule) async {
    await _schedulesBox.put(schedule.id, schedule);
  }

  @override
  Future<Schedule?> getLatestSchedule() async {
    if (_schedulesBox.isEmpty) return null;

    // Get all schedules and sort by createdAt
    final schedules = _schedulesBox.values.cast<Schedule>().toList();
    schedules.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return schedules.first;
  }

  @override
  Future<void> clearOldSchedules() async {
    final schedules = _schedulesBox.values.cast<Schedule>().toList();

    // Keep only the latest 5 schedules
    if (schedules.length > 5) {
      schedules.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final schedulesToDelete = schedules.skip(5);
      for (final schedule in schedulesToDelete) {
        await _schedulesBox.delete(schedule.id);
      }
    }
  }

  // Centralized Subjects
  @override
  Future<void> cacheCentralizedSubjects(
    List<CentralizedSubject> subjects,
  ) async {
    await _centralizedSubjectsBox.put(_centralizedSubjectsKey, subjects);
    await _centralizedSubjectsBox.put(
      _centralizedSubjectsTimestampKey,
      DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<List<CentralizedSubject>?> getCachedCentralizedSubjects() async {
    final subjects = _centralizedSubjectsBox.get(_centralizedSubjectsKey);
    if (subjects == null) return null;
    return (subjects as List).cast<CentralizedSubject>();
  }

  @override
  Future<DateTime?> getCentralizedSubjectsLastUpdate() async {
    final timestamp = _centralizedSubjectsBox.get(
      _centralizedSubjectsTimestampKey,
    );
    if (timestamp == null) return null;
    return DateTime.parse(timestamp as String);
  }

  @override
  Future<bool> isCentralizedSubjectsCacheValid() async {
    final lastUpdate = await getCentralizedSubjectsLastUpdate();
    if (lastUpdate == null) return false;

    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    return difference.inHours < _cacheDurationHours;
  }

  // Cache Management
  @override
  Future<void> clearAllCache() async {
    debugPrint('[LocalDataSource] clearAllCache called');
    debugPrint('[LocalDataSource] Sessions before clear: ${_sessionsBox.length}');
    debugPrint('[LocalDataSource] Settings before clear: ${_settingsBox.length}');
    debugPrint('[LocalDataSource] Prayer times before clear: ${_prayerTimesBox.length}');
    debugPrint('[LocalDataSource] Subjects before clear: ${_subjectsBox.length}');
    debugPrint('[LocalDataSource] Exams before clear: ${_examsBox.length}');
    debugPrint('[LocalDataSource] Schedules before clear: ${_schedulesBox.length}');
    debugPrint('[LocalDataSource] Centralized subjects before clear: ${_centralizedSubjectsBox.length}');

    // Clear all planner-related boxes
    await _sessionsBox.clear();
    await _prayerTimesBox.clear();
    await _examsBox.clear();
    await _schedulesBox.clear();
    await _centralizedSubjectsBox.clear();
    // Note: We don't clear settings and subjects as they may be needed for new schedule generation

    // Also clear the home page's cached sessions to keep UI consistent
    try {
      final homeSessionsBox = await Hive.openBox('today_sessions');
      await homeSessionsBox.clear();
      debugPrint('[LocalDataSource] Home sessions cache cleared');
    } catch (e) {
      debugPrint('[LocalDataSource] Failed to clear home sessions cache: $e');
    }

    debugPrint('[LocalDataSource] Cache cleared successfully');
    debugPrint('[LocalDataSource] Sessions after clear: ${_sessionsBox.length}');
    debugPrint('[LocalDataSource] Schedules after clear: ${_schedulesBox.length}');
  }

  // Helper methods
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
