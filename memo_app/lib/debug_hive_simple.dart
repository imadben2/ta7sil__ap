import 'dart:io';
import 'package:hive/hive.dart';

/// Simple Hive inspector without Flutter dependencies
Future<void> main() async {
  print('📦 HIVE STORAGE INSPECTOR 📦');
  print('=' * 80);

  // Initialize Hive with app directory
  final appDir = Directory.current.path;
  print('App directory: $appDir');

  // Common Hive paths
  final possiblePaths = [
    '$appDir\\build\\windows\\x64\\runner\\Debug',
    '$appDir\\build\\windows\\x64\\runner\\Release',
    Platform.environment['APPDATA'] ?? '',
  ];

  print('\nSearching for Hive databases...\n');

  for (final path in possiblePaths) {
    if (path.isEmpty) continue;
    final dir = Directory(path);
    if (await dir.exists()) {
      print('Checking: $path');
      final files = await dir.list(recursive: true).where((entity) {
        return entity is File && entity.path.endsWith('.hive');
      }).toList();

      if (files.isNotEmpty) {
        print('  Found Hive databases:');
        for (final file in files) {
          final stat = await file.stat();
          print('    - ${file.path.split('\\').last} (${stat.size} bytes)');
        }
      }
    }
  }

  print('\n' + '=' * 80);
  print('\n📝 To view actual data:');
  print('1. Open the app on your device/emulator');
  print('2. Go to Planner screen');
  print('3. Click the menu (☰) button');
  print('4. Select "حذف الجدول" (Delete Schedule)');
  print('\nThis will clear all cached sessions from Hive storage.');
  print('=' * 80);
}
