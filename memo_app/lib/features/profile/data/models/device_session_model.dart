import '../../domain/entities/device_session_entity.dart';

/// نموذج جلسة الجهاز للتعامل مع API
class DeviceSessionModel {
  final int id;
  final int userId;
  final String deviceName;
  final String deviceType;
  final String? os;
  final String? osVersion;
  final String? appVersion;
  final String? ipAddress;
  final String? location;
  final bool isCurrent;
  final bool isActive;
  final String? lastActivityAt;
  final String? lastActivityHuman;
  final String? expiresAt;
  final String createdAt;
  final String? deviceIcon;

  DeviceSessionModel({
    required this.id,
    required this.userId,
    required this.deviceName,
    required this.deviceType,
    this.os,
    this.osVersion,
    this.appVersion,
    this.ipAddress,
    this.location,
    required this.isCurrent,
    this.isActive = true,
    this.lastActivityAt,
    this.lastActivityHuman,
    this.expiresAt,
    required this.createdAt,
    this.deviceIcon,
  });

  /// Parse from API response with nested structure
  factory DeviceSessionModel.fromJson(Map<String, dynamic> json) {
    // Handle nested structure: { device: {...}, session: {...} }
    if (json.containsKey('device') && json.containsKey('session')) {
      final device = json['device'] as Map<String, dynamic>? ?? {};
      final session = json['session'] as Map<String, dynamic>? ?? {};

      return DeviceSessionModel(
        id: json['id'] as int,
        userId: 0, // Not provided in nested response
        deviceName: device['name'] as String? ?? 'Unknown Device',
        deviceType: device['type'] as String? ?? 'mobile',
        os: device['os'] as String?,
        osVersion: device['os_version'] as String?,
        appVersion: device['app_version'] as String?,
        ipAddress: session['ip_address'] as String?,
        location: session['location'] as String?,
        isCurrent: session['is_current'] as bool? ?? false,
        isActive: session['is_active'] as bool? ?? true,
        lastActivityAt: session['last_active_at'] as String?,
        lastActivityHuman: session['last_active_human'] as String?,
        expiresAt: session['expires_at'] as String?,
        createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
        deviceIcon: device['icon'] as String?,
      );
    }

    // Handle flat structure (for update endpoint response)
    return DeviceSessionModel(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? 0,
      deviceName: json['device_name'] as String? ?? 'Unknown Device',
      deviceType: json['device_type'] as String? ?? 'mobile',
      os: json['device_os'] as String?,
      osVersion: json['os_version'] as String?,
      appVersion: json['app_version'] as String?,
      ipAddress: json['ip_address'] as String?,
      location: json['location'] as String?,
      isCurrent: json['is_current'] as bool? ?? false,
      isActive: true,
      lastActivityAt: json['last_active_at'] as String?,
      lastActivityHuman: null,
      expiresAt: json['expires_at'] as String?,
      createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      deviceIcon: null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'device_name': deviceName,
    'device_type': deviceType,
    'device_os': os,
    'os_version': osVersion,
    'app_version': appVersion,
    'ip_address': ipAddress,
    'location': location,
    'is_current': isCurrent,
    'is_active': isActive,
    'last_active_at': lastActivityAt,
    'expires_at': expiresAt,
    'created_at': createdAt,
  };

  DeviceSessionEntity toEntity() {
    // Parse lastActivityAt safely
    DateTime? lastActivity;
    if (lastActivityAt != null) {
      try {
        lastActivity = DateTime.parse(lastActivityAt!);
      } catch (_) {
        lastActivity = DateTime.now();
      }
    }

    // Parse createdAt safely
    DateTime created;
    try {
      created = DateTime.parse(createdAt);
    } catch (_) {
      created = DateTime.now();
    }

    return DeviceSessionEntity(
      id: id,
      userId: userId,
      deviceId: id.toString(),
      deviceName: deviceName,
      deviceType: deviceType,
      os: os,
      osVersion: osVersion,
      browser: null,
      ipAddress: ipAddress,
      isCurrent: isCurrent,
      lastActivityAt: lastActivity ?? DateTime.now(),
      createdAt: created,
      lastActivityHuman: lastActivityHuman,
      deviceIcon: _getDeviceIcon(),
    );
  }

  /// Get device icon based on type and OS
  String _getDeviceIcon() {
    if (deviceIcon != null) {
      // Map API icon names to emoji
      switch (deviceIcon) {
        case 'phone_android':
          return '📱';
        case 'phone_iphone':
          return '📱';
        case 'tablet':
        case 'tablet_android':
        case 'tablet_mac':
          return '📲';
        case 'computer':
        case 'desktop_windows':
        case 'desktop_mac':
          return '💻';
        case 'web':
          return '🌐';
        default:
          return '📱';
      }
    }

    // Fallback based on device type
    switch (deviceType.toLowerCase()) {
      case 'mobile':
        return '📱';
      case 'tablet':
        return '📲';
      case 'web':
        return '🌐';
      case 'desktop':
        return '💻';
      default:
        return '📱';
    }
  }
}
