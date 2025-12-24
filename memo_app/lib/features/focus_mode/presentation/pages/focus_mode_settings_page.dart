import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_app/features/focus_mode/domain/entities/focus_mode_settings.dart';
import 'package:memo_app/features/focus_mode/domain/entities/focus_session_entity.dart';
import 'package:memo_app/features/focus_mode/presentation/bloc/focus_mode_bloc.dart';
import 'package:memo_app/features/focus_mode/presentation/bloc/focus_mode_event.dart';
import 'package:memo_app/features/focus_mode/presentation/bloc/focus_mode_state.dart';

/// Focus Mode Settings Page
///
/// Allows users to configure focus mode behavior:
/// - System DND automation
/// - Notification suppression
/// - Quiet hours scheduling
/// - Study session integration
/// - Priority filtering
class FocusModeSettingsPage extends StatefulWidget {
  const FocusModeSettingsPage({super.key});

  @override
  State<FocusModeSettingsPage> createState() => _FocusModeSettingsPageState();
}

class _FocusModeSettingsPageState extends State<FocusModeSettingsPage> {
  late FocusModeSettings _settings;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    // Load current settings from BLoC
    final state = context.read<FocusModeBloc>().state;
    if (state is FocusModeInactive) {
      _settings = state.settings;
      _hasPermission = state.hasDndPermission;
    } else if (state is FocusModeActive) {
      _settings = state.settings;
    } else {
      _settings = FocusModeSettings.defaults();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('إعدادات وضع التركيز'),
        backgroundColor: const Color(0xFF6B4CE6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<FocusModeBloc, FocusModeState>(
        listener: (context, state) {
          if (state is FocusModeSettingsUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حفظ الإعدادات'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is DndPermissionChecked) {
            setState(() {
              _hasPermission = state.hasPermission;
            });
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionCard(
              title: 'السلوك الأساسي',
              icon: Icons.settings,
              children: [
                _buildSwitchTile(
                  title: 'تفعيل عدم الإزعاج التلقائي',
                  subtitle: 'تشغيل وضع عدم الإزعاج للنظام (Android)',
                  value: _settings.autoEnableSystemDnd,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(
                        autoEnableSystemDnd: value,
                      );
                    });
                    _saveSettings();
                  },
                  trailing: !_hasPermission
                      ? TextButton(
                          onPressed: () {
                            context
                                .read<FocusModeBloc>()
                                .add(const RequestDndPermission());
                          },
                          child: const Text('منح الإذن'),
                        )
                      : null,
                ),
                _buildSwitchTile(
                  title: 'كتم إشعارات التطبيق',
                  subtitle: 'إيقاف إشعارات MEMO أثناء التركيز',
                  value: _settings.suppressOwnNotifications,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(
                        suppressOwnNotifications: value,
                      );
                    });
                    _saveSettings();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'الاستثناءات',
              icon: Icons.priority_high,
              children: [
                _buildSwitchTile(
                  title: 'السماح بالتنبيهات الحرجة',
                  subtitle: 'إشعارات الامتحانات المهمة',
                  value: _settings.allowCriticalAlerts,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(
                        allowCriticalAlerts: value,
                      );
                    });
                    _saveSettings();
                  },
                ),
                _buildSwitchTile(
                  title: 'السماح بتذكيرات الصلاة',
                  subtitle: 'إظهار تنبيهات أوقات الصلاة',
                  value: _settings.allowPrayerReminders,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(
                        allowPrayerReminders: value,
                      );
                    });
                    _saveSettings();
                  },
                ),
                _buildSwitchTile(
                  title: 'السماح بإشعارات الإنجازات',
                  subtitle: 'إظهار الإنجازات الجديدة',
                  value: _settings.allowAchievementNotifications,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(
                        allowAchievementNotifications: value,
                      );
                    });
                    _saveSettings();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'التكامل مع المخطط',
              icon: Icons.calendar_today,
              children: [
                _buildSwitchTile(
                  title: 'تفعيل تلقائي أثناء الجلسات',
                  subtitle: 'تشغيل وضع التركيز عند بدء جلسة دراسة',
                  value: _settings.autoEnableDuringStudySessions,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(
                        autoEnableDuringStudySessions: value,
                      );
                    });
                    _saveSettings();
                  },
                ),
                _buildSwitchTile(
                  title: 'إظهار مؤشر التركيز',
                  subtitle: 'عرض شارة عائمة عند التفعيل',
                  value: _settings.showFloatingIndicator,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(
                        showFloatingIndicator: value,
                      );
                    });
                    _saveSettings();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildTestButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF6B4CE6), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: trailing ??
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6B4CE6),
          ),
    );
  }

  Widget _buildTestButton() {
    return ElevatedButton.icon(
      onPressed: () {
        context.read<FocusModeBloc>().add(
              StartFocusMode(
                type: FocusModeType.manual,
                duration: const Duration(minutes: 5),
              ),
            );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تفعيل وضع التركيز لمدة 5 دقائق'),
            backgroundColor: Color(0xFF6B4CE6),
          ),
        );
      },
      icon: const Icon(Icons.play_arrow),
      label: const Text('تجربة وضع التركيز (5 دقائق)'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6B4CE6),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _saveSettings() {
    context.read<FocusModeBloc>().add(UpdateFocusModeSettings(_settings));
  }
}
