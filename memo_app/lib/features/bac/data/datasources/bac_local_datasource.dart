import 'package:hive/hive.dart';
import '../models/bac_year_model.dart';
import '../models/bac_session_model.dart';
import '../models/bac_subject_model.dart';
import '../models/bac_chapter_info_model.dart';
import '../models/bac_simulation_model.dart';

/// Local data source for BAC feature using Hive for caching
class BacLocalDataSource {
  static const String _bacYearsBox = 'bac_years';
  static const String _bacSessionsBox = 'bac_sessions';
  static const String _bacSubjectsBox = 'bac_subjects';
  static const String _bacChaptersBox = 'bac_chapters';
  static const String _bacSimulationsBox = 'bac_simulations';
  static const String _lastFetchKey = 'last_fetch_';

  // Cache duration - 24 hours
  static const Duration cacheDuration = Duration(hours: 24);

  /// Check if cached data is still valid
  bool _isCacheValid(String key) {
    final box = Hive.box(_bacYearsBox);
    final lastFetch = box.get('$_lastFetchKey$key');
    if (lastFetch == null) return false;

    final lastFetchTime = DateTime.parse(lastFetch as String);
    return DateTime.now().difference(lastFetchTime) < cacheDuration;
  }

  /// Update last fetch time
  Future<void> _updateLastFetch(String boxName, String key) async {
    final box = Hive.box(boxName);
    await box.put('$_lastFetchKey$key', DateTime.now().toIso8601String());
  }

  // ============ BAC Years ============

  /// Get cached BAC years
  Future<List<BacYearModel>?> getCachedBacYears() async {
    if (!_isCacheValid('bac_years')) return null;

    final box = Hive.box(_bacYearsBox);
    final data = box.get('bac_years');
    if (data == null) return null;

    final jsonList = (data as List).cast<Map<dynamic, dynamic>>();
    return jsonList
        .map((json) => BacYearModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  /// Cache BAC years
  Future<void> cacheBacYears(List<BacYearModel> years) async {
    final box = Hive.box(_bacYearsBox);
    final jsonList = years.map((year) => year.toJson()).toList();
    await box.put('bac_years', jsonList);
    await _updateLastFetch(_bacYearsBox, 'bac_years');
  }

  // ============ BAC Sessions ============

  /// Get cached sessions for a year
  Future<List<BacSessionModel>?> getCachedBacSessions(String yearSlug) async {
    if (!_isCacheValid('sessions_$yearSlug')) return null;

    final box = Hive.box(_bacSessionsBox);
    final data = box.get('sessions_$yearSlug');
    if (data == null) return null;

    final jsonList = (data as List).cast<Map<dynamic, dynamic>>();
    return jsonList
        .map(
          (json) => BacSessionModel.fromJson(Map<String, dynamic>.from(json)),
        )
        .toList();
  }

  /// Cache sessions for a year
  Future<void> cacheBacSessions(
    String yearSlug,
    List<BacSessionModel> sessions,
  ) async {
    final box = Hive.box(_bacSessionsBox);
    final jsonList = sessions.map((session) => session.toJson()).toList();
    await box.put('sessions_$yearSlug', jsonList);
    await _updateLastFetch(_bacSessionsBox, 'sessions_$yearSlug');
  }

  // ============ BAC Subjects ============

  /// Get cached subjects for a session
  Future<List<BacSubjectModel>?> getCachedBacSubjects(
    String sessionSlug,
  ) async {
    if (!_isCacheValid('subjects_$sessionSlug')) return null;

    final box = Hive.box(_bacSubjectsBox);
    final data = box.get('subjects_$sessionSlug');
    if (data == null) return null;

    final jsonList = (data as List).cast<Map<dynamic, dynamic>>();
    return jsonList
        .map(
          (json) => BacSubjectModel.fromJson(Map<String, dynamic>.from(json)),
        )
        .toList();
  }

  /// Cache subjects for a session
  Future<void> cacheBacSubjects(
    String sessionSlug,
    List<BacSubjectModel> subjects,
  ) async {
    final box = Hive.box(_bacSubjectsBox);
    final jsonList = subjects.map((subject) => subject.toJson()).toList();
    await box.put('subjects_$sessionSlug', jsonList);
    await _updateLastFetch(_bacSubjectsBox, 'subjects_$sessionSlug');
  }

  // ============ BAC Chapters ============

  /// Get cached chapters for a subject
  Future<List<BacChapterInfoModel>?> getCachedBacChapters(
    String subjectSlug,
  ) async {
    if (!_isCacheValid('chapters_$subjectSlug')) return null;

    final box = Hive.box(_bacChaptersBox);
    final data = box.get('chapters_$subjectSlug');
    if (data == null) return null;

    final jsonList = (data as List).cast<Map<dynamic, dynamic>>();
    return jsonList
        .map(
          (json) =>
              BacChapterInfoModel.fromJson(Map<String, dynamic>.from(json)),
        )
        .toList();
  }

  /// Cache chapters for a subject
  Future<void> cacheBacChapters(
    String subjectSlug,
    List<BacChapterInfoModel> chapters,
  ) async {
    final box = Hive.box(_bacChaptersBox);
    final jsonList = chapters.map((chapter) => chapter.toJson()).toList();
    await box.put('chapters_$subjectSlug', jsonList);
    await _updateLastFetch(_bacChaptersBox, 'chapters_$subjectSlug');
  }

  // ============ BAC Simulations (Local Storage) ============

  /// Get saved simulation (for resume)
  Future<BacSimulationModel?> getSavedSimulation(int simulationId) async {
    final box = Hive.box(_bacSimulationsBox);
    final data = box.get('simulation_$simulationId');
    if (data == null) return null;

    return BacSimulationModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  /// Save simulation state (for resume after app restart)
  Future<void> saveSimulation(BacSimulationModel simulation) async {
    final box = Hive.box(_bacSimulationsBox);
    await box.put('simulation_${simulation.id}', simulation.toJson());
  }

  /// Delete saved simulation
  Future<void> deleteSavedSimulation(int simulationId) async {
    final box = Hive.box(_bacSimulationsBox);
    await box.delete('simulation_$simulationId');
  }

  /// Get all saved simulations
  Future<List<BacSimulationModel>> getAllSavedSimulations() async {
    final box = Hive.box(_bacSimulationsBox);
    final simulations = <BacSimulationModel>[];

    for (var key in box.keys) {
      if (key.toString().startsWith('simulation_')) {
        final data = box.get(key);
        if (data != null) {
          simulations.add(
            BacSimulationModel.fromJson(Map<String, dynamic>.from(data as Map)),
          );
        }
      }
    }

    return simulations;
  }

  // ============ Cache Management ============

  /// Clear all BAC cache
  Future<void> clearAllCache() async {
    await Hive.box(_bacYearsBox).clear();
    await Hive.box(_bacSessionsBox).clear();
    await Hive.box(_bacSubjectsBox).clear();
    await Hive.box(_bacChaptersBox).clear();
  }

  /// Clear specific cache
  Future<void> clearCache(String key) async {
    final boxes = [
      _bacYearsBox,
      _bacSessionsBox,
      _bacSubjectsBox,
      _bacChaptersBox,
    ];

    for (var boxName in boxes) {
      final box = Hive.box(boxName);
      await box.delete(key);
      await box.delete('$_lastFetchKey$key');
    }
  }

  /// Initialize Hive boxes
  static Future<void> initializeBoxes() async {
    await Hive.openBox(_bacYearsBox);
    await Hive.openBox(_bacSessionsBox);
    await Hive.openBox(_bacSubjectsBox);
    await Hive.openBox(_bacChaptersBox);
    await Hive.openBox(_bacSimulationsBox);
  }

  /// Close all boxes
  static Future<void> closeBoxes() async {
    await Hive.box(_bacYearsBox).close();
    await Hive.box(_bacSessionsBox).close();
    await Hive.box(_bacSubjectsBox).close();
    await Hive.box(_bacChaptersBox).close();
    await Hive.box(_bacSimulationsBox).close();
  }
}
