import 'package:equatable/equatable.dart';

/// أنواع الإشعارات
enum NotificationType {
  studyReminder,
  examAlert,
  dailySummary,
  weeklySummary,
  courseUpdate,
  achievement,
  system,
  announcement,
}

/// أولوية الإشعار
enum NotificationPriority {
  low,
  normal,
  high,
}

/// كيان الإشعار
class NotificationEntity extends Equatable {
  /// معرف الإشعار
  final String id;

  /// نوع الإشعار
  final NotificationType type;

  /// العنوان
  final String title;

  /// النص
  final String body;

  /// نوع الإجراء (للتنقل)
  final String? actionType;

  /// بيانات الإجراء
  final Map<String, dynamic>? actionData;

  /// تاريخ الإنشاء
  final DateTime createdAt;

  /// تاريخ القراءة
  final DateTime? readAt;

  /// حالة القراءة
  bool get isRead => readAt != null;

  /// الأولوية
  final NotificationPriority priority;

  /// رابط التنقل العميق
  final String? deepLink;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.actionType,
    this.actionData,
    required this.createdAt,
    this.readAt,
    this.priority = NotificationPriority.normal,
    this.deepLink,
  });

  /// تحويل النوع من نص
  static NotificationType typeFromString(String type) {
    switch (type) {
      case 'study_reminder':
        return NotificationType.studyReminder;
      case 'exam_alert':
        return NotificationType.examAlert;
      case 'daily_summary':
        return NotificationType.dailySummary;
      case 'weekly_summary':
        return NotificationType.weeklySummary;
      case 'course_update':
        return NotificationType.courseUpdate;
      case 'achievement':
        return NotificationType.achievement;
      case 'system':
        return NotificationType.system;
      case 'announcement':
        return NotificationType.announcement;
      default:
        return NotificationType.system;
    }
  }

  /// تحويل النوع إلى نص
  static String typeToString(NotificationType type) {
    switch (type) {
      case NotificationType.studyReminder:
        return 'study_reminder';
      case NotificationType.examAlert:
        return 'exam_alert';
      case NotificationType.dailySummary:
        return 'daily_summary';
      case NotificationType.weeklySummary:
        return 'weekly_summary';
      case NotificationType.courseUpdate:
        return 'course_update';
      case NotificationType.achievement:
        return 'achievement';
      case NotificationType.system:
        return 'system';
      case NotificationType.announcement:
        return 'announcement';
    }
  }

  /// تحويل الأولوية من نص
  static NotificationPriority priorityFromString(String priority) {
    switch (priority) {
      case 'low':
        return NotificationPriority.low;
      case 'high':
        return NotificationPriority.high;
      default:
        return NotificationPriority.normal;
    }
  }

  /// أيقونة النوع
  String get typeIcon {
    switch (type) {
      case NotificationType.studyReminder:
        return '📚';
      case NotificationType.examAlert:
        return '🎯';
      case NotificationType.dailySummary:
        return '📊';
      case NotificationType.weeklySummary:
        return '📈';
      case NotificationType.courseUpdate:
        return '📖';
      case NotificationType.achievement:
        return '🏆';
      case NotificationType.system:
        return '⚙️';
      case NotificationType.announcement:
        return '📢';
    }
  }

  /// اسم النوع بالعربية
  String get typeNameAr {
    switch (type) {
      case NotificationType.studyReminder:
        return 'تذكير دراسي';
      case NotificationType.examAlert:
        return 'تنبيه امتحان';
      case NotificationType.dailySummary:
        return 'ملخص يومي';
      case NotificationType.weeklySummary:
        return 'ملخص أسبوعي';
      case NotificationType.courseUpdate:
        return 'تحديث دورة';
      case NotificationType.achievement:
        return 'إنجاز';
      case NotificationType.system:
        return 'نظام';
      case NotificationType.announcement:
        return 'إعلان';
    }
  }

  /// نسخ مع تغييرات
  NotificationEntity copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    String? actionType,
    Map<String, dynamic>? actionData,
    DateTime? createdAt,
    DateTime? readAt,
    NotificationPriority? priority,
    String? deepLink,
  }) {
    return NotificationEntity(
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

  /// وضع علامة كمقروء
  NotificationEntity markAsRead() {
    return copyWith(readAt: DateTime.now());
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        body,
        actionType,
        actionData,
        createdAt,
        readAt,
        priority,
        deepLink,
      ];
}

/// كيان قائمة الإشعارات مع الإحصائيات
class NotificationsListEntity extends Equatable {
  /// قائمة الإشعارات
  final List<NotificationEntity> notifications;

  /// عدد الإشعارات غير المقروءة
  final int unreadCount;

  /// إجمالي الإشعارات
  final int total;

  /// الصفحة الحالية
  final int currentPage;

  /// عدد الصفحات
  final int lastPage;

  /// هل هناك المزيد
  bool get hasMore => currentPage < lastPage;

  const NotificationsListEntity({
    required this.notifications,
    required this.unreadCount,
    required this.total,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  /// قائمة فارغة
  factory NotificationsListEntity.empty() {
    return const NotificationsListEntity(
      notifications: [],
      unreadCount: 0,
      total: 0,
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        unreadCount,
        total,
        currentPage,
        lastPage,
      ];
}
