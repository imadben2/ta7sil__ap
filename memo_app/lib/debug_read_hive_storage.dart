import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Debug utility to read and display all Hive storage contents
///
/// Run this to see what's stored in local cache
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  print('📦 HIVE STORAGE INSPECTOR 📦');
  print('=' * 80);

  try {
    // 1. STUDY SESSIONS BOX
    print('\n🎓 STUDY SESSIONS (study_sessions):');
    print('-' * 80);
    final sessionsBox = await Hive.openBox('study_sessions');
    print('Total sessions: ${sessionsBox.length}');

    if (sessionsBox.isNotEmpty) {
      print('\nSessions stored:');
      int index = 0;
      for (var key in sessionsBox.keys) {
        final session = sessionsBox.get(key);
        print('  [$index] Key: $key');
        if (session != null) {
          // Try to extract subject info
          try {
            print('      Type: ${session.runtimeType}');
            print('      Data: ${session.toString().substring(0, 200)}...');
          } catch (e) {
            print('      Data: $session');
          }
        }
        index++;
        if (index >= 10) {
          print('  ... and ${sessionsBox.length - 10} more sessions');
          break;
        }
      }
    } else {
      print('  ✅ Empty (no sessions cached)');
    }

    // 2. SCHEDULES BOX
    print('\n📅 SCHEDULES (schedules):');
    print('-' * 80);
    final schedulesBox = await Hive.openBox('schedules');
    print('Total schedules: ${schedulesBox.length}');

    if (schedulesBox.isNotEmpty) {
      for (var key in schedulesBox.keys) {
        final schedule = schedulesBox.get(key);
        print('  Key: $key');
        print('  Data: ${schedule.toString().substring(0, 150)}...');
      }
    } else {
      print('  ✅ Empty (no schedules cached)');
    }

    // 3. PLANNER SETTINGS BOX
    print('\n⚙️  PLANNER SETTINGS (planner_settings):');
    print('-' * 80);
    final settingsBox = await Hive.openBox('planner_settings');
    print('Total settings: ${settingsBox.length}');

    if (settingsBox.isNotEmpty) {
      for (var key in settingsBox.keys) {
        final settings = settingsBox.get(key);
        print('  User ID: $key');
        try {
          print('  Settings type: ${settings.runtimeType}');
        } catch (e) {
          print('  Data: $settings');
        }
      }
    } else {
      print('  ⚠️  Empty (no settings found)');
    }

    // 4. SUBJECTS BOX
    print('\n📚 SUBJECTS (subjects):');
    print('-' * 80);
    final subjectsBox = await Hive.openBox('subjects');
    print('Total subjects: ${subjectsBox.length}');

    if (subjectsBox.isNotEmpty) {
      print('\nSubjects stored:');
      for (var key in subjectsBox.keys) {
        final subject = subjectsBox.get(key);
        print('  Subject ID: $key');
        try {
          print('  Type: ${subject.runtimeType}');
        } catch (e) {
          print('  Data: $subject');
        }
      }
    } else {
      print('  ⚠️  Empty (no subjects cached)');
    }

    // 5. EXAMS BOX
    print('\n📝 EXAMS (exams):');
    print('-' * 80);
    final examsBox = await Hive.openBox('exams');
    print('Total exams: ${examsBox.length}');

    if (examsBox.isNotEmpty) {
      for (var key in examsBox.keys) {
        final exam = examsBox.get(key);
        print('  Exam ID: $key');
        print('  Data: ${exam.toString().substring(0, 100)}...');
      }
    } else {
      print('  ✅ Empty (no exams cached)');
    }

    // 6. TODAY SESSIONS (home cache)
    print('\n🏠 TODAY SESSIONS (today_sessions):');
    print('-' * 80);
    try {
      final homeSessionsBox = await Hive.openBox('today_sessions');
      print('Total entries: ${homeSessionsBox.length}');

      if (homeSessionsBox.isNotEmpty) {
        for (var key in homeSessionsBox.keys) {
          final data = homeSessionsBox.get(key);
          print('  Key: $key');
          print('  Has data: ${data != null}');
        }
      } else {
        print('  ✅ Empty');
      }
      await homeSessionsBox.close();
    } catch (e) {
      print('  Box not found or error: $e');
    }

    // 7. SYNC QUEUE
    print('\n🔄 SYNC QUEUE (sync_queue):');
    print('-' * 80);
    try {
      final syncBox = await Hive.openBox('sync_queue');
      print('Pending sync items: ${syncBox.length}');
      await syncBox.close();
    } catch (e) {
      print('  Box not found or error: $e');
    }

    // SUMMARY
    print('\n' + '=' * 80);
    print('📊 SUMMARY:');
    print('  Sessions:  ${sessionsBox.length} items');
    print('  Schedules: ${schedulesBox.length} items');
    print('  Settings:  ${settingsBox.length} items');
    print('  Subjects:  ${subjectsBox.length} items');
    print('  Exams:     ${examsBox.length} items');
    print('=' * 80);

    // Close boxes
    await sessionsBox.close();
    await schedulesBox.close();
    await settingsBox.close();
    await subjectsBox.close();
    await examsBox.close();

    print('\n✅ Inspection complete!');

  } catch (e, stackTrace) {
    print('❌ Error reading Hive storage: $e');
    print('Stack trace: $stackTrace');
  }
}
