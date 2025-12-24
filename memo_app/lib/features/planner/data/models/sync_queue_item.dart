import 'package:equatable/equatable.dart';

/// Enum for sync operation types
enum SyncOperation {
  create,
  update,
  delete,
  action, // For special actions like start, pause, complete, etc.
}

/// Enum for entity types that can be synced
enum SyncEntityType {
  session,
  settings,
  subject,
  exam,
  schedule,
}

/// Model representing a queued sync operation
///
/// This model is used to persist offline changes in a queue
/// until they can be synchronized with the remote API
class SyncQueueItem extends Equatable {
  final String id;
  final SyncOperation operation;
  final SyncEntityType entityType;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;
  final DateTime? lastAttempt;
  final String? errorMessage;
  final String? actionType; // For action operations: 'start', 'pause', 'complete', etc.

  const SyncQueueItem({
    required this.id,
    required this.operation,
    required this.entityType,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
    this.lastAttempt,
    this.errorMessage,
    this.actionType,
  });

  /// Create a new sync queue item
  factory SyncQueueItem.create({
    required SyncOperation operation,
    required SyncEntityType entityType,
    required Map<String, dynamic> data,
    String? actionType,
  }) {
    return SyncQueueItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      operation: operation,
      entityType: entityType,
      data: data,
      createdAt: DateTime.now(),
      actionType: actionType,
    );
  }

  /// Copy with method for updating fields
  SyncQueueItem copyWith({
    String? id,
    SyncOperation? operation,
    SyncEntityType? entityType,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    int? retryCount,
    DateTime? lastAttempt,
    String? errorMessage,
    String? actionType,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      entityType: entityType ?? this.entityType,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      errorMessage: errorMessage ?? this.errorMessage,
      actionType: actionType ?? this.actionType,
    );
  }

  /// Convert to JSON for Hive storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operation': operation.index,
      'entityType': entityType.index,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'lastAttempt': lastAttempt?.toIso8601String(),
      'errorMessage': errorMessage,
      'actionType': actionType,
    };
  }

  /// Create from JSON (Hive storage)
  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as String,
      operation: SyncOperation.values[json['operation'] as int],
      entityType: SyncEntityType.values[json['entityType'] as int],
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      lastAttempt: json['lastAttempt'] != null
          ? DateTime.parse(json['lastAttempt'] as String)
          : null,
      errorMessage: json['errorMessage'] as String?,
      actionType: json['actionType'] as String?,
    );
  }

  /// Check if this item should be retried
  ///
  /// Uses exponential backoff: 1min, 5min, 15min, 1hr, 6hr
  bool shouldRetry() {
    if (retryCount >= 5) return false; // Max 5 retries
    if (lastAttempt == null) return true;

    final delays = [
      Duration(minutes: 1),
      Duration(minutes: 5),
      Duration(minutes: 15),
      Duration(hours: 1),
      Duration(hours: 6),
    ];

    final delay = retryCount < delays.length
        ? delays[retryCount]
        : delays.last;

    return DateTime.now().difference(lastAttempt!) >= delay;
  }

  /// Human-readable description of this sync item
  String get description {
    final operationName = operation == SyncOperation.action
        ? actionType ?? 'action'
        : operation.name;
    return '$operationName ${entityType.name}';
  }

  @override
  List<Object?> get props => [
        id,
        operation,
        entityType,
        data,
        createdAt,
        retryCount,
        lastAttempt,
        errorMessage,
        actionType,
      ];
}
