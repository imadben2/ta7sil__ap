import 'package:hive/hive.dart';

part 'notification_mapping.g.dart';

@HiveType(typeId: 17)
class NotificationMapping extends HiveObject {
  @HiveField(0)
  final String sessionId;

  @HiveField(1)
  final int notificationId;

  @HiveField(2)
  final DateTime scheduledFor;

  @HiveField(3)
  final DateTime createdAt;

  NotificationMapping({
    required this.sessionId,
    required this.notificationId,
    required this.scheduledFor,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationMapping &&
        other.sessionId == sessionId &&
        other.notificationId == notificationId &&
        other.scheduledFor == scheduledFor &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return sessionId.hashCode ^
        notificationId.hashCode ^
        scheduledFor.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'NotificationMapping(sessionId: $sessionId, notificationId: $notificationId, scheduledFor: $scheduledFor, createdAt: $createdAt)';
  }
}
