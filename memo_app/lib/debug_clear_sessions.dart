import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Debug utility to clear old planner sessions from Hive
///
/// Run this from terminal:
/// flutter run lib/debug_clear_sessions.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  print('🗑️  Debug: Clearing planner sessions...');

  try {
    // Open the sessions box
    final sessionsBox = await Hive.openBox('study_sessions');
    final schedulesBox = await Hive.openBox('schedules');
    final homeSessionsBox = await Hive.openBox('today_sessions');

    print('📊 Sessions before clear: ${sessionsBox.length}');
    print('📊 Schedules before clear: ${schedulesBox.length}');
    print('📊 Home sessions before clear: ${homeSessionsBox.length}');

    // Clear all boxes
    await sessionsBox.clear();
    await schedulesBox.clear();
    await homeSessionsBox.delete('sessions');

    // Flush to disk
    await sessionsBox.flush();
    await schedulesBox.flush();
    await homeSessionsBox.flush();

    print('✅ Sessions after clear: ${sessionsBox.length}');
    print('✅ Schedules after clear: ${schedulesBox.length}');
    print('✅ Home sessions after clear: ${homeSessionsBox.length}');

    print('\n✨ Successfully cleared all planner sessions!');
    print('📱 Now open your app and generate a new schedule.');

    // Close boxes
    await sessionsBox.close();
    await schedulesBox.close();
    await homeSessionsBox.close();

  } catch (e) {
    print('❌ Error clearing sessions: $e');
  }
}
