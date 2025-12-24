import 'package:hive/hive.dart';
import '../models/stats_model.dart';
import '../models/study_session_model.dart';
import '../models/subject_progress_model.dart';

abstract class HomeLocalDataSource {
  Future<StatsModel?> getCachedStats();
  Future<void> cacheStats(StatsModel stats);
  Future<List<StudySessionModel>?> getCachedTodaySessions();
  Future<void> cacheTodaySessions(List<StudySessionModel> sessions);
  Future<void> clearCachedTodaySessions();
  Future<List<SubjectProgressModel>?> getCachedSubjectsProgress();
  Future<void> cacheSubjectsProgress(List<SubjectProgressModel> subjects);
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  static const String statsBox = 'home_stats';
  static const String sessionsBox = 'today_sessions';
  static const String subjectsBox = 'subjects_progress';

  @override
  Future<StatsModel?> getCachedStats() async {
    final box = await Hive.openBox(statsBox);
    final data = box.get('stats');
    if (data != null) {
      return StatsModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  @override
  Future<void> cacheStats(StatsModel stats) async {
    final box = await Hive.openBox(statsBox);
    await box.put('stats', stats.toJson());
  }

  @override
  Future<List<StudySessionModel>?> getCachedTodaySessions() async {
    final box = await Hive.openBox(sessionsBox);
    final data = box.get('sessions');
    if (data != null) {
      final List<dynamic> list = data;
      return list
          .map(
            (json) =>
                StudySessionModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    }
    return null;
  }

  @override
  Future<void> cacheTodaySessions(List<StudySessionModel> sessions) async {
    final box = await Hive.openBox(sessionsBox);
    await box.put('sessions', sessions.map((s) => s.toJson()).toList());
  }

  @override
  Future<void> clearCachedTodaySessions() async {
    final box = await Hive.openBox(sessionsBox);
    await box.delete('sessions');
  }

  @override
  Future<List<SubjectProgressModel>?> getCachedSubjectsProgress() async {
    final box = await Hive.openBox(subjectsBox);
    final data = box.get('subjects');
    if (data != null) {
      final List<dynamic> list = data;
      return list
          .map(
            (json) =>
                SubjectProgressModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    }
    return null;
  }

  @override
  Future<void> cacheSubjectsProgress(
    List<SubjectProgressModel> subjects,
  ) async {
    final box = await Hive.openBox(subjectsBox);
    await box.put('subjects', subjects.map((s) => s.toJson()).toList());
  }
}
