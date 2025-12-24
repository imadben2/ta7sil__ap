import 'package:hive/hive.dart';

import '../../domain/entities/notification_entity.dart';

part 'notification_model.g.dart';

/// نموذج الإشعار للتخزين المحلي والتسلسل
@HiveType(typeId: 50)
class NotificationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String body;

  @HiveField(4)
  final String? actionType;

  @HiveField(5)
  final Map<String, dynamic>? actionData;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime? readAt;

  @HiveField(8)
  final String priority;

  @HiveField(9)
  final String? deepLink;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.actionType,
    this.actionData,
    required this.createdAt,
    this.readAt,
    required this.priority,
    this.deepLink,
  });

  /// من JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'system',
      title: json['title_ar'] ?? json['title'] ?? '',
      body: json['body_ar'] ?? json['body'] ?? '',
      actionType: json['action_type'],
      actionData: json['action_data'] is Map
          ? Map<String, dynamic>.from(json['action_data'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      priority: json['priority'] ?? 'normal',
      deepLink: json['data']?['deep_link'],
    );
  }

  /// إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title_ar': title,
      'body_ar': body,
      'action_type': actionType,
      'action_data': actionData,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'priority': priority,
    };
  }

  /// تحويل إلى Entity
  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      type: NotificationEntity.typeFromString(type),
      title: title,
      body: body,
      actionType: actionType,
      actionData: actionData,
      createdAt: createdAt,
      readAt: readAt,
      priority: NotificationEntity.priorityFromString(priority),
      deepLink: deepLink,
    );
  }

  /// تحويل من Entity
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      type: NotificationEntity.typeToString(entity.type),
      title: entity.title,
      body: entity.body,
      actionType: entity.actionType,
      actionData: entity.actionData,
      createdAt: entity.createdAt,
      readAt: entity.readAt,
      priority: entity.priority.name,
      deepLink: entity.deepLink,
    );
  }

  /// نسخ مع تغييرات
  NotificationModel copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    String? actionType,
    Map<String, dynamic>? actionData,
    DateTime? createdAt,
    DateTime? readAt,
    String? priority,
    String? deepLink,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      actionType: actionType ?? this.actionType,
      actionData: actionData ?? this.actionData,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      priority: priority ?? this.priority,
      deepLink: deepLink ?? this.deepLink,
    );
  }
}

/// استجابة قائمة الإشعارات
class NotificationsResponse {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final int total;
  final int currentPage;
  final int lastPage;

  NotificationsResponse({
    required this.notifications,
    required this.unreadCount,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final notificationsData = json['notifications'] ?? json['data'] ?? [];
    final meta = json['meta'];

    return NotificationsResponse(
      notifications: (notificationsData as List)
          .map((n) => NotificationModel.fromJson(n))
          .toList(),
      unreadCount: json['unread_count'] ?? 0,
      total: meta?['total'] ?? json['total'] ?? notificationsData.length,
      currentPage: meta?['current_page'] ?? json['current_page'] ?? 1,
      lastPage: meta?['last_page'] ?? json['last_page'] ?? 1,
    );
  }

  NotificationsListEntity toEntity() {
    return NotificationsListEntity(
      notifications: notifications.map((n) => n.toEntity()).toList(),
      unreadCount: unreadCount,
      total: total,
      currentPage: currentPage,
      lastPage: lastPage,
    );
  }
}
