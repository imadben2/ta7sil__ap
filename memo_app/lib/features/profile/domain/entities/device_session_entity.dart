import 'package:equatable/equatable.dart';

/// كيان جلسة الجهاز
///
/// يمثل جهازًا متصلاً بالحساب
class DeviceSessionEntity extends Equatable {
  /// معرف الجلسة
  final int id;

  /// معرف المستخدم
  final int userId;

  /// معرف الجهاز الفريد
  final String deviceId;

  /// اسم الجهاز
  final String deviceName;

  /// نوع الجهاز (mobile, tablet, web)
  final String deviceType;

  /// نظام التشغيل
  final String? os;

  /// إصدار نظام التشغيل
  final String? osVersion;

  /// المتصفح (إن كان web)
  final String? browser;

  /// عنوان IP
  final String? ipAddress;

  /// هل هذا هو الجهاز الحالي؟
  final bool isCurrent;

  /// آخر نشاط
  final DateTime lastActivityAt;

  /// تاريخ الإنشاء
  final DateTime createdAt;

  /// نص آخر نشاط من API (مثل "Active now")
  final String? lastActivityHuman;

  /// أيقونة الجهاز من API
  final String? _deviceIconFromApi;

  const DeviceSessionEntity({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    this.os,
    this.osVersion,
    this.browser,
    this.ipAddress,
    required this.isCurrent,
    required this.lastActivityAt,
    required this.createdAt,
    this.lastActivityHuman,
    String? deviceIcon,
  }) : _deviceIconFromApi = deviceIcon;

  /// وصف الجهاز الكامل
  String get fullDeviceDescription {
    final parts = <String>[];
    parts.add(deviceName);
    if (os != null) {
      parts.add(os!);
      if (osVersion != null) parts.add(osVersion!);
    }
    if (browser != null) parts.add(browser!);
    return parts.join(' • ');
  }

  /// مدة منذ آخر نشاط
  Duration get timeSinceLastActivity {
    return DateTime.now().difference(lastActivityAt);
  }

  /// نص "منذ" بالعربية (منذ 5 دقائق، منذ ساعة، ...)
  String get lastActivityAgo {
    // Always calculate from lastActivityAt for consistent Arabic formatting
    final duration = timeSinceLastActivity;

    if (duration.inMinutes < 1) {
      return 'الآن';
    } else if (duration.inMinutes < 60) {
      final mins = duration.inMinutes;
      if (mins == 1) return 'منذ دقيقة';
      if (mins == 2) return 'منذ دقيقتين';
      if (mins <= 10) return 'منذ $mins دقائق';
      return 'منذ $mins دقيقة';
    } else if (duration.inHours < 24) {
      final hours = duration.inHours;
      if (hours == 1) return 'منذ ساعة';
      if (hours == 2) return 'منذ ساعتين';
      if (hours <= 10) return 'منذ $hours ساعات';
      return 'منذ $hours ساعة';
    } else if (duration.inDays < 7) {
      final days = duration.inDays;
      if (days == 1) return 'منذ يوم';
      if (days == 2) return 'منذ يومين';
      return 'منذ $days أيام';
    } else if (duration.inDays < 30) {
      final weeks = (duration.inDays / 7).floor();
      if (weeks == 1) return 'منذ أسبوع';
      if (weeks == 2) return 'منذ أسبوعين';
      return 'منذ $weeks أسابيع';
    } else {
      final months = (duration.inDays / 30).floor();
      if (months == 1) return 'منذ شهر';
      if (months == 2) return 'منذ شهرين';
      return 'منذ $months أشهر';
    }
  }

  /// أيقونة نوع الجهاز
  String get deviceIcon {
    // Use API-provided icon if available
    if (_deviceIconFromApi != null && _deviceIconFromApi.isNotEmpty) {
      return _deviceIconFromApi;
    }

    switch (deviceType.toLowerCase()) {
      case 'mobile':
        return '📱';
      case 'tablet':
        return '📲';
      case 'web':
      case 'desktop':
        return '💻';
      default:
        return '📱';
    }
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    deviceId,
    deviceName,
    deviceType,
    os,
    osVersion,
    browser,
    ipAddress,
    isCurrent,
    lastActivityAt,
    createdAt,
    lastActivityHuman,
    _deviceIconFromApi,
  ];
}
