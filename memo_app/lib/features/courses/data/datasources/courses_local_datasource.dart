import 'package:hive/hive.dart';
import '../models/course_model.dart';
import '../models/course_module_model.dart';
import '../models/subscription_package_model.dart';

/// Local Data Source للدورات
/// يستخدم Hive للتخزين المؤقت مع TTL 12 ساعة
abstract class CoursesLocalDataSource {
  // ========== Courses Cache ==========
  Future<List<CourseModel>?> getCachedCourses();
  Future<void> cacheCourses(List<CourseModel> courses);
  Future<CourseModel?> getCachedCourse(int courseId);
  Future<void> cacheCourse(CourseModel course);

  // ========== Featured Courses Cache ==========
  Future<List<CourseModel>?> getCachedFeaturedCourses();
  Future<void> cacheFeaturedCourses(List<CourseModel> courses);

  // ========== Modules Cache ==========
  Future<List<CourseModuleModel>?> getCachedModules(int courseId);
  Future<void> cacheModules(int courseId, List<CourseModuleModel> modules);

  // ========== Packages Cache ==========
  Future<List<SubscriptionPackageModel>?> getCachedPackages();
  Future<void> cachePackages(List<SubscriptionPackageModel> packages);

  // ========== Cache Management ==========
  Future<void> clearCache();
  Future<void> clearExpiredCache();
}

class CoursesLocalDataSourceImpl implements CoursesLocalDataSource {
  static const String coursesBoxName = 'courses';
  static const String featuredCoursesBoxName = 'featured_courses';
  static const String courseDetailsBoxName = 'course_details';
  static const String modulesBoxName = 'course_modules';
  static const String packagesBoxName = 'subscription_packages';

  static const String coursesKey = 'all_courses';
  static const String featuredCoursesKey = 'featured_courses';
  static const String packagesKey = 'all_packages';

  static const Duration cacheTTL = Duration(hours: 12);

  // ========== Courses Cache ==========

  @override
  Future<List<CourseModel>?> getCachedCourses() async {
    try {
      final box = await Hive.openBox(coursesBoxName);
      final data = box.get(coursesKey);

      if (data == null) return null;

      // Check if cache is expired
      final cacheTime = box.get('${coursesKey}_timestamp') as int?;
      if (cacheTime == null || _isCacheExpired(cacheTime)) {
        await box.delete(coursesKey);
        await box.delete('${coursesKey}_timestamp');
        return null;
      }

      final coursesList = (data as List).cast<Map<dynamic, dynamic>>();
      return coursesList
          .map((json) => CourseModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheCourses(List<CourseModel> courses) async {
    try {
      final box = await Hive.openBox(coursesBoxName);
      final coursesList = courses.map((c) => c.toJson()).toList();

      await box.put(coursesKey, coursesList);
      await box.put(
        '${coursesKey}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Silent fail - caching is not critical
    }
  }

  @override
  Future<CourseModel?> getCachedCourse(int courseId) async {
    try {
      final box = await Hive.openBox(courseDetailsBoxName);
      final key = 'course_$courseId';
      final data = box.get(key);

      if (data == null) return null;

      // Check if cache is expired
      final cacheTime = box.get('${key}_timestamp') as int?;
      if (cacheTime == null || _isCacheExpired(cacheTime)) {
        await box.delete(key);
        await box.delete('${key}_timestamp');
        return null;
      }

      return CourseModel.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheCourse(CourseModel course) async {
    try {
      final box = await Hive.openBox(courseDetailsBoxName);
      final key = 'course_${course.id}';

      await box.put(key, course.toJson());
      await box.put('${key}_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Silent fail
    }
  }

  // ========== Featured Courses Cache ==========

  @override
  Future<List<CourseModel>?> getCachedFeaturedCourses() async {
    try {
      final box = await Hive.openBox(featuredCoursesBoxName);
      final data = box.get(featuredCoursesKey);

      if (data == null) return null;

      // Check if cache is expired
      final cacheTime = box.get('${featuredCoursesKey}_timestamp') as int?;
      if (cacheTime == null || _isCacheExpired(cacheTime)) {
        await box.delete(featuredCoursesKey);
        await box.delete('${featuredCoursesKey}_timestamp');
        return null;
      }

      final coursesList = (data as List).cast<Map<dynamic, dynamic>>();
      return coursesList
          .map((json) => CourseModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheFeaturedCourses(List<CourseModel> courses) async {
    try {
      final box = await Hive.openBox(featuredCoursesBoxName);
      final coursesList = courses.map((c) => c.toJson()).toList();

      await box.put(featuredCoursesKey, coursesList);
      await box.put(
        '${featuredCoursesKey}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Silent fail
    }
  }

  // ========== Modules Cache ==========

  @override
  Future<List<CourseModuleModel>?> getCachedModules(int courseId) async {
    try {
      final box = await Hive.openBox(modulesBoxName);
      final key = 'modules_$courseId';
      final data = box.get(key);

      if (data == null) return null;

      // Check if cache is expired
      final cacheTime = box.get('${key}_timestamp') as int?;
      if (cacheTime == null || _isCacheExpired(cacheTime)) {
        await box.delete(key);
        await box.delete('${key}_timestamp');
        return null;
      }

      final modulesList = (data as List).cast<Map<dynamic, dynamic>>();
      return modulesList
          .map(
            (json) =>
                CourseModuleModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheModules(
    int courseId,
    List<CourseModuleModel> modules,
  ) async {
    try {
      final box = await Hive.openBox(modulesBoxName);
      final key = 'modules_$courseId';
      final modulesList = modules.map((m) => m.toJson()).toList();

      await box.put(key, modulesList);
      await box.put('${key}_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Silent fail
    }
  }

  // ========== Packages Cache ==========

  @override
  Future<List<SubscriptionPackageModel>?> getCachedPackages() async {
    try {
      final box = await Hive.openBox(packagesBoxName);
      final data = box.get(packagesKey);

      if (data == null) return null;

      // Check if cache is expired
      final cacheTime = box.get('${packagesKey}_timestamp') as int?;
      if (cacheTime == null || _isCacheExpired(cacheTime)) {
        await box.delete(packagesKey);
        await box.delete('${packagesKey}_timestamp');
        return null;
      }

      final packagesList = (data as List).cast<Map<dynamic, dynamic>>();
      return packagesList
          .map(
            (json) => SubscriptionPackageModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cachePackages(List<SubscriptionPackageModel> packages) async {
    try {
      final box = await Hive.openBox(packagesBoxName);
      final packagesList = packages.map((p) => p.toJson()).toList();

      await box.put(packagesKey, packagesList);
      await box.put(
        '${packagesKey}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Silent fail
    }
  }

  // ========== Cache Management ==========

  @override
  Future<void> clearCache() async {
    try {
      await Hive.deleteBoxFromDisk(coursesBoxName);
      await Hive.deleteBoxFromDisk(featuredCoursesBoxName);
      await Hive.deleteBoxFromDisk(courseDetailsBoxName);
      await Hive.deleteBoxFromDisk(modulesBoxName);
      await Hive.deleteBoxFromDisk(packagesBoxName);
    } catch (e) {
      // Silent fail
    }
  }

  @override
  Future<void> clearExpiredCache() async {
    try {
      final boxes = [
        coursesBoxName,
        featuredCoursesBoxName,
        courseDetailsBoxName,
        modulesBoxName,
        packagesBoxName,
      ];

      for (final boxName in boxes) {
        try {
          final box = await Hive.openBox(boxName);
          final keys = box.keys.toList();

          for (final key in keys) {
            if (key.toString().endsWith('_timestamp')) {
              final timestamp = box.get(key) as int?;
              if (timestamp != null && _isCacheExpired(timestamp)) {
                final dataKey = key.toString().replaceAll('_timestamp', '');
                await box.delete(dataKey);
                await box.delete(key);
              }
            }
          }
        } catch (e) {
          // Continue with next box
        }
      }
    } catch (e) {
      // Silent fail
    }
  }

  // ========== Helper Methods ==========

  bool _isCacheExpired(int timestamp) {
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    return now.difference(cacheTime) > cacheTTL;
  }
}
