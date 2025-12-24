import 'package:hive/hive.dart';
import '../models/notification_mapping.dart';

/// Manages persistent mapping between session IDs and notification IDs
/// using Hive local storage
class NotificationIdManager {
  static const String _boxName = 'notification_mappings';
  Box<NotificationMapping>? _box;

  /// Initialize the Hive box for notification mappings
  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<NotificationMapping>(_boxName);
    } else {
      _box = Hive.box<NotificationMapping>(_boxName);
    }
  }

  /// Save a session-to-notification mapping
  Future<void> saveMapping(
    String sessionId,
    int notificationId,
    DateTime scheduledFor,
  ) async {
    _ensureInitialized();

    final mapping = NotificationMapping(
      sessionId: sessionId,
      notificationId: notificationId,
      scheduledFor: scheduledFor,
      createdAt: DateTime.now(),
    );

    await _box!.put(sessionId, mapping);
  }

  /// Get the notification ID for a session
  Future<int?> getNotificationId(String sessionId) async {
    _ensureInitialized();

    final mapping = _box!.get(sessionId);
    return mapping?.notificationId;
  }

  /// Remove a mapping by session ID
  Future<void> removeMapping(String sessionId) async {
    _ensureInitialized();

    await _box!.delete(sessionId);
  }

  /// Remove multiple mappings by session IDs
  Future<void> removeMappings(List<String> sessionIds) async {
    _ensureInitialized();

    await _box!.deleteAll(sessionIds);
  }

  /// Get all session-to-notification mappings
  /// Returns a map of sessionId -> notificationId
  Future<Map<String, int>> getAllMappings() async {
    _ensureInitialized();

    final Map<String, int> mappings = {};

    for (final key in _box!.keys) {
      final mapping = _box!.get(key);
      if (mapping != null) {
        mappings[mapping.sessionId] = mapping.notificationId;
      }
    }

    return mappings;
  }

  /// Get all notification mapping objects
  Future<List<NotificationMapping>> getAllMappingObjects() async {
    _ensureInitialized();

    return _box!.values.toList();
  }

  /// Clear all mappings
  Future<void> clearAllMappings() async {
    _ensureInitialized();

    await _box!.clear();
  }

  /// Generate a unique notification ID from session ID using hash
  /// Returns a consistent ID in the range of 100000-999999
  int generateUniqueId(String sessionId) {
    // Generate hash code from session ID
    final hash = sessionId.hashCode;

    // Convert to positive number in range 100000-999999
    final id = (hash.abs() % 900000) + 100000;

    return id;
  }

  /// Check if a mapping exists for a session
  Future<bool> hasMapping(String sessionId) async {
    _ensureInitialized();

    return _box!.containsKey(sessionId);
  }

  /// Get mapping object for a session
  Future<NotificationMapping?> getMapping(String sessionId) async {
    _ensureInitialized();

    return _box!.get(sessionId);
  }

  /// Remove mappings older than the specified duration
  Future<void> cleanupOldMappings(Duration maxAge) async {
    _ensureInitialized();

    final cutoffDate = DateTime.now().subtract(maxAge);
    final keysToDelete = <String>[];

    for (final key in _box!.keys) {
      final mapping = _box!.get(key);
      if (mapping != null && mapping.createdAt.isBefore(cutoffDate)) {
        keysToDelete.add(key as String);
      }
    }

    if (keysToDelete.isNotEmpty) {
      await _box!.deleteAll(keysToDelete);
    }
  }

  /// Ensure the box is initialized before operations
  void _ensureInitialized() {
    if (_box == null || !_box!.isOpen) {
      throw StateError(
        'NotificationIdManager not initialized. Call initialize() first.',
      );
    }
  }

  /// Close the Hive box (call on app dispose if needed)
  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
    }
  }
}
