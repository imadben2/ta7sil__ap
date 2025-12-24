import 'package:hive_flutter/hive_flutter.dart';
import '../constants/api_constants.dart';

/// Hive local storage service for caching data
class HiveService {
  // Initialize Hive
  Future<void> init() async {
    await Hive.initFlutter();

    // Open boxes
    await Hive.openBox(ApiConstants.hiveBoxAuth);
    await Hive.openBox(ApiConstants.hiveBoxSubjects);
    await Hive.openBox(ApiConstants.hiveBoxContents);
    await Hive.openBox(ApiConstants.hiveBoxPlanner);
    await Hive.openBox(ApiConstants.hiveBoxCache);

    // Open BAC boxes
    await Hive.openBox('bac_years');
    await Hive.openBox('bac_sessions');
    await Hive.openBox('bac_subjects');
    await Hive.openBox('bac_chapters');
    await Hive.openBox('bac_simulations');

    // Open BAC Study Schedule box (98-day planner)
    await Hive.openBox(ApiConstants.hiveBoxBacStudy);
  }

  // Get box
  Box _getBox(String boxName) {
    return Hive.box(boxName);
  }

  // Generic save
  Future<void> save(String boxName, String key, dynamic value) async {
    final box = _getBox(boxName);
    await box.put(key, value);
  }

  // Generic get
  dynamic get(String boxName, String key, {dynamic defaultValue}) {
    final box = _getBox(boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  // Generic delete
  Future<void> delete(String boxName, String key) async {
    final box = _getBox(boxName);
    await box.delete(key);
  }

  // Clear box
  Future<void> clearBox(String boxName) async {
    final box = _getBox(boxName);
    await box.clear();
  }

  // Clear all boxes
  Future<void> clearAll() async {
    await clearBox(ApiConstants.hiveBoxAuth);
    await clearBox(ApiConstants.hiveBoxSubjects);
    await clearBox(ApiConstants.hiveBoxContents);
    await clearBox(ApiConstants.hiveBoxPlanner);
    await clearBox(ApiConstants.hiveBoxCache);
  }

  // Check if key exists
  bool has(String boxName, String key) {
    final box = _getBox(boxName);
    return box.containsKey(key);
  }

  // Get all keys in box
  Iterable<dynamic> getAllKeys(String boxName) {
    final box = _getBox(boxName);
    return box.keys;
  }

  // Get all values in box
  Iterable<dynamic> getAllValues(String boxName) {
    final box = _getBox(boxName);
    return box.values;
  }
}
