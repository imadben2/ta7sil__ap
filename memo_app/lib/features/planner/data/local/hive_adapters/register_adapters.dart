import 'package:hive_flutter/hive_flutter.dart';
import 'study_session_adapter.dart';
import 'planner_settings_adapter.dart';
import 'prayer_times_adapter.dart';
import 'subject_adapter.dart';
import 'exam_adapter.dart';
import 'schedule_adapter.dart';
import 'centralized_subject_adapter.dart';
import '../../../models/notification_mapping.dart';

/// Register all Hive type adapters for planner feature
///
/// Call this function in main() before opening any Hive boxes:
/// ```dart
/// await Hive.initFlutter();
/// registerPlannerAdapters();
/// ```
void registerPlannerAdapters() {
  // Register planner entity adapters
  // Type IDs: 10-15

  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(StudySessionAdapter());
  }

  if (!Hive.isAdapterRegistered(11)) {
    Hive.registerAdapter(PlannerSettingsAdapter());
  }

  if (!Hive.isAdapterRegistered(12)) {
    Hive.registerAdapter(PrayerTimesAdapter());
  }

  if (!Hive.isAdapterRegistered(13)) {
    Hive.registerAdapter(SubjectAdapter());
  }

  if (!Hive.isAdapterRegistered(14)) {
    Hive.registerAdapter(ExamAdapter());
  }

  if (!Hive.isAdapterRegistered(15)) {
    Hive.registerAdapter(ScheduleAdapter());
  }

  if (!Hive.isAdapterRegistered(16)) {
    Hive.registerAdapter(CentralizedSubjectAdapter());
  }

  if (!Hive.isAdapterRegistered(17)) {
    Hive.registerAdapter(NotificationMappingAdapter());
  }
}

/// Hive box names for planner feature
class PlannerBoxNames {
  static const String studySessions = 'study_sessions';
  static const String plannerSettings = 'planner_settings';
  static const String prayerTimes = 'prayer_times';
  static const String subjects = 'subjects';
  static const String exams = 'exams';
  static const String schedules = 'schedules';
  static const String syncQueue = 'sync_queue';
  static const String centralizedSubjects = 'centralized_subjects';
  static const String notificationMappings = 'notification_mappings';
}

/// Open all Hive boxes for planner feature
///
/// Call this after registering adapters:
/// ```dart
/// registerPlannerAdapters();
/// await openPlannerBoxes();
/// ```
Future<void> openPlannerBoxes() async {
  await Future.wait([
    Hive.openBox(PlannerBoxNames.studySessions),
    Hive.openBox(PlannerBoxNames.plannerSettings),
    Hive.openBox(PlannerBoxNames.prayerTimes),
    Hive.openBox(PlannerBoxNames.subjects),
    Hive.openBox(PlannerBoxNames.exams),
    Hive.openBox(PlannerBoxNames.schedules),
    Hive.openBox(PlannerBoxNames.syncQueue),
    Hive.openBox(PlannerBoxNames.centralizedSubjects),
  ]);
}

/// Close all Hive boxes for planner feature
Future<void> closePlannerBoxes() async {
  await Future.wait([
    Hive.box(PlannerBoxNames.studySessions).close(),
    Hive.box(PlannerBoxNames.plannerSettings).close(),
    Hive.box(PlannerBoxNames.prayerTimes).close(),
    Hive.box(PlannerBoxNames.subjects).close(),
    Hive.box(PlannerBoxNames.exams).close(),
    Hive.box(PlannerBoxNames.schedules).close(),
    Hive.box(PlannerBoxNames.syncQueue).close(),
    Hive.box(PlannerBoxNames.centralizedSubjects).close(),
  ]);
}
