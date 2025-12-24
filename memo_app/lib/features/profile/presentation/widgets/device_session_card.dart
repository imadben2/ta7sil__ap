import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

/// Device session card widget
///
/// Displays information about a logged-in device session:
/// - Device type and name (mobile, tablet, desktop, web)
/// - Browser/OS information
/// - Last active time
/// - Location and IP address
/// - Current device badge
/// - Logout button
///
/// Usage:
/// ```dart
/// DeviceSessionCard(
///   session: DeviceSessionEntity(...),
///   isCurrentDevice: true,
///   onLogout: () => print('Logout device'),
/// )
/// ```
class DeviceSessionCard extends StatelessWidget {
  /// Device session data
  final DeviceSessionModel session;

  /// Whether this is the current device
  final bool isCurrentDevice;

  /// Callback when logout button is pressed
  final VoidCallback? onLogout;

  const DeviceSessionCard({
    Key? key,
    required this.session,
    this.isCurrentDevice = false,
    this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentDevice
              ? AppColors.primary.withOpacity(0.5)
              : Colors.grey[300]!,
          width: isCurrentDevice ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row (device icon, name, current badge)
          Row(
            children: [
              _buildDeviceIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            session.deviceName ?? _getDeviceTypeLabel(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentDevice) _buildCurrentBadge(),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getBrowserOSInfo(),
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Cairo',
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Device details
          _buildDetailRow(
            icon: Icons.access_time,
            label: 'آخر نشاط',
            value: _formatLastActive(session.lastActiveAt),
          ),

          if (session.location != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.location_on_outlined,
              label: 'الموقع',
              value: session.location!,
            ),
          ],

          if (session.ipAddress != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.public,
              label: 'عنوان IP',
              value: session.ipAddress!,
            ),
          ],

          // Logout button (only for non-current devices)
          if (!isCurrentDevice && onLogout != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[700],
                  side: BorderSide(color: Colors.red[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build device type icon
  Widget _buildDeviceIcon() {
    IconData icon;
    Color color;

    switch (session.deviceType?.toLowerCase()) {
      case 'mobile':
        icon = Icons.phone_android;
        color = AppColors.primary;
        break;
      case 'tablet':
        icon = Icons.tablet_android;
        color = AppColors.primary;
        break;
      case 'desktop':
        icon = Icons.computer;
        color = Colors.blue[700]!;
        break;
      case 'web':
        icon = Icons.language;
        color = Colors.green[700]!;
        break;
      default:
        icon = Icons.devices;
        color = Colors.grey[700]!;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  /// Build "current device" badge
  Widget _buildCurrentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'الجهاز الحالي',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
          color: Colors.white,
        ),
      ),
    );
  }

  /// Build detail row (icon + label + value)
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Cairo',
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Cairo',
              color: Colors.grey[800],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Get device type label in Arabic
  String _getDeviceTypeLabel() {
    switch (session.deviceType?.toLowerCase()) {
      case 'mobile':
        return 'هاتف محمول';
      case 'tablet':
        return 'جهاز لوحي';
      case 'desktop':
        return 'حاسوب';
      case 'web':
        return 'متصفح ويب';
      default:
        return 'جهاز غير معروف';
    }
  }

  /// Get browser and OS information
  String _getBrowserOSInfo() {
    final parts = <String>[];

    if (session.browser != null && session.browser!.isNotEmpty) {
      parts.add(session.browser!);
    }

    if (session.platform != null && session.platform!.isNotEmpty) {
      parts.add(session.platform!);
    }

    return parts.isNotEmpty ? parts.join(' • ') : 'معلومات غير متوفرة';
  }

  /// Format last active time
  String _formatLastActive(DateTime? lastActive) {
    if (lastActive == null) return 'غير معروف';

    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      // Show full date for older sessions
      return DateFormat('yyyy/MM/dd HH:mm').format(lastActive);
    }
  }
}

/// Simplified device session model (for widget usage)
///
/// In production, this should be imported from domain/entities
class DeviceSessionModel {
  final String id;
  final String? deviceType; // mobile, tablet, desktop, web
  final String? deviceName; // e.g., "iPhone 13", "Samsung Galaxy", "Windows PC"
  final String? browser; // e.g., "Chrome 120", "Safari 17"
  final String? platform; // e.g., "iOS 17", "Android 14", "Windows 11"
  final String? location; // e.g., "Algiers, Algeria"
  final String? ipAddress;
  final DateTime? lastActiveAt;
  final DateTime? createdAt;

  const DeviceSessionModel({
    required this.id,
    this.deviceType,
    this.deviceName,
    this.browser,
    this.platform,
    this.location,
    this.ipAddress,
    this.lastActiveAt,
    this.createdAt,
  });
}

/// Empty state for device sessions list
class DeviceSessionsEmptyState extends StatelessWidget {
  const DeviceSessionsEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.devices_other,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد أجهزة متصلة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'أنت متصل من هذا الجهاز فقط',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Cairo',
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Header for devices page with "logout all" button
class DeviceSessionsHeader extends StatelessWidget {
  final int totalDevices;
  final VoidCallback? onLogoutAll;

  const DeviceSessionsHeader({
    Key? key,
    required this.totalDevices,
    this.onLogoutAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.devices, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الأجهزة المتصلة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'لديك $totalDevices جهاز متصل',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Cairo',
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (totalDevices > 1 && onLogoutAll != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onLogoutAll,
                icon: const Icon(Icons.logout, size: 20),
                label: const Text(
                  'تسجيل الخروج من جميع الأجهزة الأخرى',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
