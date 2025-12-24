import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_event.dart';
import '../bloc/profile/profile_state.dart';
import '../../domain/entities/device_session_entity.dart';
import '../widgets/profile_page_header.dart';

/// صفحة إدارة الأجهزة المتصلة
///
/// تعرض:
/// - قائمة الأجهزة المتصلة بالحساب
/// - الجهاز الحالي مميز
/// - إمكانية تسجيل الخروج من أجهزة محددة
/// - إمكانية تسجيل الخروج من جميع الأجهزة الأخرى
class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  bool _hasAttemptedRegistration = false;

  @override
  void initState() {
    super.initState();
    // تحميل قائمة الأجهزة
    context.read<ProfileBloc>().add(const LoadDevices());
  }

  /// تسجيل الجهاز الحالي إذا لم تكن هناك جلسات
  Future<void> _registerCurrentDeviceIfNeeded() async {
    if (_hasAttemptedRegistration) return;
    _hasAttemptedRegistration = true;

    try {
      final deviceInfo = await _getDeviceInfo();
      if (mounted) {
        context.read<ProfileBloc>().add(RegisterCurrentDevice(deviceInfo));
      }
    } catch (e) {
      // في حالة الفشل، نعيد تحميل قائمة الأجهزة
      if (mounted) {
        context.read<ProfileBloc>().add(const LoadDevices());
      }
    }
  }

  /// الحصول على معلومات الجهاز الحالي
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, dynamic> deviceData = {};

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      deviceData = {
        'device_name': androidInfo.model,
        'device_type': 'mobile',
        'device_os': 'Android',
        'os_version': androidInfo.version.release,
        'app_version': '1.0.0',
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      deviceData = {
        'device_name': iosInfo.name,
        'device_type': iosInfo.model.toLowerCase().contains('ipad') ? 'tablet' : 'mobile',
        'device_os': 'iOS',
        'os_version': iosInfo.systemVersion,
        'app_version': '1.0.0',
      };
    }

    return deviceData;
  }

  /// عرض نافذة تأكيد تسجيل الخروج
  void _showLogoutDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirm();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('تسجيل خروج'),
          ),
        ],
      ),
    );
  }

  /// تسجيل الخروج من جهاز محدد
  void _logoutDevice(int sessionId) {
    _showLogoutDialog(
      title: 'تسجيل الخروج من الجهاز',
      message: 'هل أنت متأكد من تسجيل الخروج من هذا الجهاز؟',
      onConfirm: () {
        context.read<ProfileBloc>().add(LogoutDevice(sessionId));
      },
    );
  }

  /// تسجيل الخروج من جميع الأجهزة الأخرى
  void _logoutAllOthers() {
    _showLogoutDialog(
      title: 'تسجيل الخروج من الأجهزة الأخرى',
      message:
          'سيتم تسجيل خروجك من جميع الأجهزة الأخرى باستثناء هذا الجهاز. هل تريد المتابعة؟',
      onConfirm: () {
        context.read<ProfileBloc>().add(const LogoutAllOtherDevices());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.slateBackground,
        body: Column(
          children: [
            // الهيدر الموحد
            ProfilePageHeader(
              title: 'الأجهزة المتصلة',
              subtitle: 'إدارة أجهزتك المتصلة',
              icon: Icons.devices_rounded,
              onBack: () => Navigator.pop(context),
              onAction: () {
                context.read<ProfileBloc>().add(const LoadDevices());
              },
              actionIcon: Icons.refresh_rounded,
            ),
            // المحتوى
            Expanded(
              child: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is DeviceLogoutSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تسجيل الخروج بنجاح'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              // إعادة تحميل قائمة الأجهزة
              context.read<ProfileBloc>().add(const LoadDevices());
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is DevicesLoaded) {
                final devices = state.devices;

                if (devices.isEmpty) {
                  // محاولة تسجيل الجهاز الحالي تلقائياً
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _registerCurrentDeviceIfNeeded();
                  });
                  return _buildEmptyState();
                }

                // فصل الجهاز الحالي عن الأجهزة الأخرى
                final currentDevice = devices.firstWhere(
                  (d) => d.isCurrent,
                  orElse: () => devices.first,
                );
                final otherDevices = devices
                    .where((d) => !d.isCurrent)
                    .toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // معلومات أمان
                      _buildSecurityInfoCard(),

                      const SizedBox(height: 24),

                      // الجهاز الحالي
                      _buildSectionTitle('هذا الجهاز'),
                      const SizedBox(height: 12),
                      _buildDeviceCard(currentDevice, isCurrent: true),

                      const SizedBox(height: 24),

                      // الأجهزة الأخرى
                      if (otherDevices.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionTitle('الأجهزة الأخرى'),
                            TextButton.icon(
                              onPressed: _logoutAllOthers,
                              icon: const Icon(Icons.logout, size: 18),
                              label: const Text('تسجيل الخروج من الكل'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...otherDevices.map(
                          (device) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildDeviceCard(device, isCurrent: false),
                          ),
                        ),
                      ] else ...[
                        _buildSectionTitle('الأجهزة الأخرى'),
                        const SizedBox(height: 12),
                        _buildNoOtherDevicesCard(),
                      ],
                    ],
                  ),
                );
              }

              return _buildEmptyState();
            },
          ),
        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildSecurityInfoCard() {
    return Container(
      padding: EdgeInsets.all(AppDesignTokens.spacingLG),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusCard),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.info,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'يمكنك تسجيل الخروج من الأجهزة التي لا تستخدمها لحماية حسابك',
              style: TextStyle(
                color: const Color(0xFF1E293B),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(
    DeviceSessionEntity device, {
    required bool isCurrent,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusCard),
        border: isCurrent
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isCurrent ? 0.08 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // أيقونة الجهاز
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.primary.withOpacity(0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusIcon),
                  ),
                  child: Center(
                    child: Text(
                      device.deviceIcon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // معلومات الجهاز
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              device.deviceName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'الحالي',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        device.os ?? 'نظام غير معروف',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 16),

            // تفاصيل الجهاز
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    device.ipAddress ?? 'غير معروف',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  device.lastActivityAgo,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // زر تسجيل الخروج (للأجهزة الأخرى فقط)
            if (!isCurrent) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _logoutDevice(device.id),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('تسجيل خروج'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoOtherDevicesCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 36,
                color: Colors.green.shade400,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد أجهزة أخرى متصلة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'حسابك آمن',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.devices_other_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد أجهزة متصلة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.read<ProfileBloc>().add(const LoadDevices());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: AppDesignTokens.spacingXXL,
                  vertical: AppDesignTokens.spacingLG,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
