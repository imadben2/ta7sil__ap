import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../models/sync_queue_item.dart';

/// Box name constants
class SyncQueueBoxNames {
  static const String syncQueue = 'planner_sync_queue';
  static const String lastSyncKey = 'last_sync_timestamp';
}

/// Service for managing the offline sync queue
///
/// This service persists offline changes in Hive and provides methods
/// to add, retrieve, and manage queued sync operations
class PlannerSyncQueue {
  late Box<String> _syncQueueBox;

  /// Initialize the sync queue (call during app startup)
  Future<void> init() async {
    _syncQueueBox = await Hive.openBox<String>(SyncQueueBoxNames.syncQueue);
    debugPrint('[SyncQueue] Initialized with ${_syncQueueBox.length} pending items');
  }

  /// Add an item to the sync queue
  Future<void> addToQueue(SyncQueueItem item) async {
    try {
      await _syncQueueBox.put(item.id, _serializeItem(item));
      debugPrint('[SyncQueue] Added: ${item.description} (id: ${item.id})');
    } catch (e, stackTrace) {
      debugPrint('[SyncQueue] ERROR adding item: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  /// Get all queued items
  List<SyncQueueItem> getQueuedItems() {
    try {
      final items = _syncQueueBox.values
          .map((jsonString) => _deserializeItem(jsonString))
          .where((item) => item != null)
          .cast<SyncQueueItem>()
          .toList();

      debugPrint('[SyncQueue] Retrieved ${items.length} items');
      return items;
    } catch (e, stackTrace) {
      debugPrint('[SyncQueue] ERROR retrieving items: $e');
      debugPrint(stackTrace.toString());
      return [];
    }
  }

  /// Get items that should be retried now
  List<SyncQueueItem> getItemsToRetry() {
    final allItems = getQueuedItems();
    final itemsToRetry = allItems.where((item) => item.shouldRetry()).toList();
    debugPrint('[SyncQueue] ${itemsToRetry.length} items ready for retry (out of ${allItems.length})');
    return itemsToRetry;
  }

  /// Remove an item from the queue (after successful sync)
  Future<void> removeFromQueue(String id) async {
    try {
      await _syncQueueBox.delete(id);
      debugPrint('[SyncQueue] Removed item: $id');
    } catch (e, stackTrace) {
      debugPrint('[SyncQueue] ERROR removing item $id: $e');
      debugPrint(stackTrace.toString());
    }
  }

  /// Mark retry attempt (increment retry count, update last attempt time)
  Future<void> markRetry(String id, {String? errorMessage}) async {
    try {
      final jsonString = _syncQueueBox.get(id);
      if (jsonString == null) {
        debugPrint('[SyncQueue] Item $id not found for retry marking');
        return;
      }

      final item = _deserializeItem(jsonString);
      if (item == null) {
        debugPrint('[SyncQueue] Failed to deserialize item $id');
        return;
      }

      final updatedItem = item.copyWith(
        retryCount: item.retryCount + 1,
        lastAttempt: DateTime.now(),
        errorMessage: errorMessage,
      );

      await _syncQueueBox.put(id, _serializeItem(updatedItem));
      debugPrint('[SyncQueue] Marked retry for $id (attempt ${updatedItem.retryCount})');
    } catch (e, stackTrace) {
      debugPrint('[SyncQueue] ERROR marking retry for $id: $e');
      debugPrint(stackTrace.toString());
    }
  }

  /// Clear all items from the queue
  Future<void> clearQueue() async {
    try {
      final count = _syncQueueBox.length;
      await _syncQueueBox.clear();
      debugPrint('[SyncQueue] Cleared $count items from queue');
    } catch (e, stackTrace) {
      debugPrint('[SyncQueue] ERROR clearing queue: $e');
      debugPrint(stackTrace.toString());
    }
  }

  /// Get count of pending items
  int get pendingCount => _syncQueueBox.length;

  /// Get count of failed items (retry count >= 3)
  int get failedCount {
    final allItems = getQueuedItems();
    return allItems.where((item) => item.retryCount >= 3).length;
  }

  /// Get oldest pending item (for debugging)
  SyncQueueItem? get oldestItem {
    final items = getQueuedItems();
    if (items.isEmpty) return null;

    items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return items.first;
  }

  /// Get items by entity type
  List<SyncQueueItem> getItemsByEntityType(SyncEntityType entityType) {
    return getQueuedItems()
        .where((item) => item.entityType == entityType)
        .toList();
  }

  /// Get items by operation type
  List<SyncQueueItem> getItemsByOperation(SyncOperation operation) {
    return getQueuedItems()
        .where((item) => item.operation == operation)
        .toList();
  }

  /// Get last successful sync timestamp
  DateTime? get lastSyncTimestamp {
    final timestampStr = _syncQueueBox.get(SyncQueueBoxNames.lastSyncKey) as String?;
    if (timestampStr == null) return null;

    try {
      return DateTime.parse(timestampStr);
    } catch (e) {
      debugPrint('[SyncQueue] ERROR parsing last sync timestamp: $e');
      return null;
    }
  }

  /// Update last sync timestamp (call after successful sync)
  Future<void> updateLastSyncTimestamp() async {
    try {
      await _syncQueueBox.put(
        SyncQueueBoxNames.lastSyncKey,
        DateTime.now().toIso8601String(),
      );
      debugPrint('[SyncQueue] Updated last sync timestamp');
    } catch (e, stackTrace) {
      debugPrint('[SyncQueue] ERROR updating last sync timestamp: $e');
      debugPrint(stackTrace.toString());
    }
  }

  /// Serialize item to JSON string for Hive storage
  String _serializeItem(SyncQueueItem item) {
    // Hive stores as String to avoid needing custom TypeAdapter
    // We use JSON encoding for simplicity
    final json = item.toJson();
    return jsonEncode(json);
  }

  /// Deserialize item from JSON string
  SyncQueueItem? _deserializeItem(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return SyncQueueItem.fromJson(json);
    } catch (e) {
      debugPrint('[SyncQueue] ERROR deserializing item: $e');
      return null;
    }
  }
}
