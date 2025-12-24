import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/settings_entity.dart';
import '../bloc/settings/settings_cubit.dart';
import '../bloc/settings/settings_state.dart';

/// صفحة الإعدادات - تصميم حديث مطابق لصفحة دوراتي
///
/// الأقسام:
/// - الإشعارات (6 خيارات)
/// - أوقات الصلاة (مدينة + تذكير)
/// - اللغة والثيم
/// - إدارة البيانات (cache, offline mode)
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // ثوابت الألوان - مطابقة لصفحة دوراتي
  static const _primaryPurple = AppColors.primary;
  static const _secondaryPurple = AppColors.primaryDark;
  static const _bgColor = AppColors.slateBackground;

  // Notifications
  bool _notificationsEnabled = false;
  bool _sessionsNotif = false;
  bool _quizzesNotif = false;
  bool _achievementsNotif = false;
  bool _prayerReminders = false;

  // Prayer times
  bool _prayerTimesEnabled = true;
  String _selectedCity = 'Algiers';
  int _reminderMinutes = 10;

  // Language & Theme
  String _selectedLocale = 'ar';
  String _selectedTheme = 'system';

  // Data management
  bool _offlineMode = false;
  int _cacheSize = 12; // MB

  // Video player
  String _selectedPlayer = 'chewie';

  @override
  void initState() {
    super.initState();
    // Load settings from cubit on init
    _loadSettingsFromCubit();
  }

  void _loadSettingsFromCubit() {
    final settingsCubit = context.read<SettingsCubit>();
    final state = settingsCubit.state;

    if (state is SettingsLoaded) {
      _updateLocalStateFromSettings(state.settings);
    } else {
      // If settings not loaded yet, load them now
      settingsCubit.loadSettings();
    }
  }

  void _updateLocalStateFromSettings(SettingsEntity settings) {
    setState(() {
      // Notifications
      _notificationsEnabled = settings.notifications.enabled;
      _sessionsNotif = settings.notifications.sessions;
      _quizzesNotif = settings.notifications.quizzes;
      _achievementsNotif = settings.notifications.achievements;
      _prayerReminders = settings.notifications.prayerReminders;

      // Prayer times
      _prayerTimesEnabled = settings.prayerTimes.enabled;
      _selectedCity = settings.prayerTimes.city;
      _reminderMinutes = settings.prayerTimes.reminderMinutesBefore;

      // Language & Theme
      _selectedLocale = settings.locale;
      _selectedTheme = settings.themeMode;

      // Data management
      _offlineMode = settings.offlineMode;
      _cacheSize = settings.cacheSize;

      // Video player
      _selectedPlayer = settings.preferredVideoPlayer;
      print('🎬 Settings page loaded player: $_selectedPlayer');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          print('🎬 Settings state changed: ${state.runtimeType}');
          if (state is SettingsLoaded) {
            print('🎬 Settings loaded in listener');
            _updateLocalStateFromSettings(state.settings);
          } else if (state is SettingsSaved) {
            print('🎬 Settings saved in listener');
            _updateLocalStateFromSettings(state.settings);
          } else if (state is SettingsError) {
            print('❌ Settings error: ${state.message}');
          }
        },
        child: Scaffold(
          backgroundColor: _bgColor,
          body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // الإشعارات
                    _buildNotificationsSection(),

                    const SizedBox(height: 20),

                    // أوقات الصلاة
                    _buildPrayerTimesSection(),

                    const SizedBox(height: 20),

                    // اللغة والثيم
                    _buildLanguageThemeSection(),

                    const SizedBox(height: 20),

                    // إدارة البيانات
                    _buildDataManagementSection(),

                    const SizedBox(height: 20),

                    // مشغل الفيديو
                    _buildVideoPlayerSection(),

                    const SizedBox(height: 32),

                    // زر إعادة التعيين
                    _buildResetButton(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// الهيدر مع gradient بنفسجي
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryPurple, _secondaryPurple],
        ),
      ),
      child: Column(
        children: [
          // محتوى الهيدر
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // زر الرجوع
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // الأيقونة
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // العنوان
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الإعدادات',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'تخصيص التطبيق',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                // زر الحفظ
                GestureDetector(
                  onTap: _handleSave,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // القاع المنحني
          Container(
            height: 24,
            decoration: const BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// قسم الإشعارات
  Widget _buildNotificationsSection() {
    return _buildSection(
      title: 'الإشعارات',
      icon: Icons.notifications_rounded,
      children: [
        _buildSwitchTile(
          title: 'تفعيل الإشعارات',
          subtitle: 'غير متوفر حالياً',
          value: _notificationsEnabled,
          onChanged: (value) {
            if (value) {
              // Show coming soon dialog when trying to enable
              _showNotificationComingSoonDialog();
            }
          },
        ),
      ],
    );
  }

  /// حوار الإشعارات قريباً
  void _showNotificationComingSoonDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة متحركة
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.info.withOpacity(0.15),
                      AppColors.primary.withOpacity(0.15),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.info,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              // العنوان
              const Text(
                'قريباً',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 12),
              // الرسالة
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.info,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'ميزة الإشعارات ستكون متوفرة في التحديث القادم إن شاء الله',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // زر الإغلاق
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'حسناً',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// قسم أوقات الصلاة
  Widget _buildPrayerTimesSection() {
    return _buildSection(
      title: 'أوقات الصلاة',
      icon: Icons.mosque_rounded,
      children: [
        _buildSwitchTile(
          title: 'تفعيل أوقات الصلاة',
          subtitle: 'عرض أوقات الصلاة في التطبيق',
          value: _prayerTimesEnabled,
          onChanged: (value) => setState(() => _prayerTimesEnabled = value),
        ),
        if (_prayerTimesEnabled) ...[
          Divider(height: 1, color: AppColors.slate500.withOpacity(0.1)),
          _buildCitySelector(),
          Divider(height: 1, color: AppColors.slate500.withOpacity(0.1)),
          _buildReminderSelector(),
        ],
      ],
    );
  }

  /// اختيار المدينة
  Widget _buildCitySelector() {
    final cities = ['Algiers', 'Oran', 'Constantine', 'Annaba', 'Batna'];
    final citiesAr = {
      'Algiers': 'الجزائر',
      'Oran': 'وهران',
      'Constantine': 'قسنطينة',
      'Annaba': 'عنابة',
      'Batna': 'باتنة',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_city_rounded, color: _primaryPurple, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'المدينة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.slate500,
                  ),
                ),
                const SizedBox(height: 4),
                DropdownButton<String>(
                  value: _selectedCity,
                  isExpanded: true,
                  underline: Container(),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate900,
                  ),
                  items: cities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(citiesAr[city] ?? city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// اختيار وقت التذكير
  Widget _buildReminderSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.alarm_rounded, color: _primaryPurple, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'التذكير قبل الصلاة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.slate500,
                  ),
                ),
                const SizedBox(height: 4),
                DropdownButton<int>(
                  value: _reminderMinutes,
                  isExpanded: true,
                  underline: Container(),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate900,
                  ),
                  items: [5, 10, 15, 20, 30].map((minutes) {
                    return DropdownMenuItem(
                      value: minutes,
                      child: Text('$minutes دقيقة'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _reminderMinutes = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// قسم اللغة والثيم
  Widget _buildLanguageThemeSection() {
    return _buildSection(
      title: 'المظهر',
      icon: Icons.palette_rounded,
      children: [
        _buildOptionTile(
          icon: Icons.reorder_rounded,
          title: 'ترتيب التبويبات',
          subtitle: 'تخصيص ترتيب التبويبات الرئيسية',
          onTap: () => context.push('/profile/settings/tab-order'),
        ),
        Divider(height: 1, color: AppColors.slate500.withOpacity(0.1)),
        _buildOptionTile(
          icon: Icons.language_rounded,
          title: 'اللغة',
          subtitle: _getLocaleLabel(_selectedLocale),
          onTap: () => _showLanguageDialog(),
        ),
        Divider(height: 1, color: AppColors.slate500.withOpacity(0.1)),
        _buildOptionTile(
          icon: Icons.brightness_6_rounded,
          title: 'الوضع',
          subtitle: _getThemeLabel(_selectedTheme),
          onTap: () => _showThemeDialog(),
        ),
      ],
    );
  }

  /// قسم إدارة البيانات
  Widget _buildDataManagementSection() {
    return _buildSection(
      title: 'إدارة البيانات',
      icon: Icons.storage_rounded,
      children: [
        _buildSwitchTile(
          title: 'الوضع غير متصل',
          subtitle: 'استخدام التطبيق بدون إنترنت',
          value: _offlineMode,
          onChanged: (value) => setState(() => _offlineMode = value),
        ),
        Divider(height: 1, color: AppColors.slate500.withOpacity(0.1)),
        _buildOptionTile(
          icon: Icons.folder_rounded,
          title: 'الذاكرة المؤقتة',
          subtitle: '$_cacheSize ميجابايت',
          trailing: TextButton(
            onPressed: _clearCache,
            child: const Text(
              'مسح',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// قسم عام بتصميم حديث
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_primaryPurple, _secondaryPurple],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: _primaryPurple, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.slate500.withOpacity(0.1)),
          // المحتوى
          ...children,
        ],
      ),
    );
  }

  /// بلاطة مع Switch
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isSubItem = false,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.only(
        right: isSubItem ? 56 : 20,
        left: 20,
        top: 8,
        bottom: 8,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.slate900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: AppColors.slate500,
        ),
      ),
      activeColor: _primaryPurple,
    );
  }

  /// بلاطة خيار
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _primaryPurple, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.slate900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: AppColors.slate500,
        ),
      ),
      trailing: trailing ?? Icon(
        Icons.arrow_back_ios_rounded,
        color: AppColors.slate500.withOpacity(0.5),
        size: 16,
      ),
      onTap: onTap,
    );
  }

  /// قسم مشغل الفيديو
  Widget _buildVideoPlayerSection() {
    return _buildSection(
      title: 'مشغل الفيديو',
      icon: Icons.play_circle_rounded,
      children: [
        _buildPlayerSelector(),
      ],
    );
  }

  /// اختيار المشغل
  Widget _buildPlayerSelector() {
    final players = ['chewie', 'media_kit', 'simple_youtube', 'omni', 'orax_video_player'];
    final playersAr = {
      'chewie': 'تشيوي (افتراضي)',
      'media_kit': 'ميديا كيت (أداء عالي)',
      'simple_youtube': 'يوتيوب بسيط (فيديوهات يوتيوب)',
      'omni': 'أومني (يوتيوب + شبكة)',
      'orax_video_player': 'أوراكس (يوتيوب + جودات)',
    };
    final playersDesc = {
      'chewie': 'بسيط وموثوق',
      'media_kit': 'أداء عالي للفيديوهات عالية الدقة',
      'simple_youtube': 'مشغل يوتيوب المدمج للفيديوهات على يوتيوب',
      'omni': 'دعم يوتيوب وفيميو مع واجهة مخصصة',
      'orax_video_player': 'دعم يوتيوب، اختيار الجودة، ترجمات، تكبير',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.video_settings_rounded, color: _primaryPurple, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'المشغل المفضل',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.slate500,
                  ),
                ),
                const SizedBox(height: 4),
                DropdownButton<String>(
                  value: _selectedPlayer,
                  isExpanded: true,
                  underline: Container(),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate900,
                  ),
                  items: players.map((player) {
                    return DropdownMenuItem(
                      value: player,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            playersAr[player] ?? player,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            playersDesc[player] ?? '',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: AppColors.slate500.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPlayer = value!;
                    });
                    // Persist to cubit
                    context.read<SettingsCubit>().changeVideoPlayer(value!);

                    // Show info message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'سيتم تطبيق المشغل الجديد على الفيديوهات التي تفتحها بعد هذا التغيير',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// زر إعادة التعيين
  Widget _buildResetButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.3), width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showResetDialog,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh_rounded, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'إعادة تعيين الإعدادات للافتراضية',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// حفظ الإعدادات
  void _handleSave() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم حفظ الإعدادات بنجاح',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppColors.emerald500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }

  /// مسح الذاكرة المؤقتة
  Future<void> _clearCache() async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.amber500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.folder_delete_rounded, color: AppColors.amber500, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'مسح الذاكرة المؤقتة',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Text(
          'هل تريد مسح الذاكرة المؤقتة؟ سيتم إعادة تحميل البيانات عند الحاجة.',
          style: TextStyle(fontFamily: 'Cairo', color: AppColors.slate600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo', color: AppColors.slate500),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amber500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() => _cacheSize = 0);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'تم مسح الذاكرة المؤقتة',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  backgroundColor: AppColors.emerald500,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('مسح', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  /// حوار اللغة
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'اختر اللغة',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('ar', 'العربية'),
            _buildLanguageOption('fr', 'Français'),
            _buildLanguageOption('en', 'English'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String locale, String label) {
    return RadioListTile<String>(
      value: locale,
      groupValue: _selectedLocale,
      title: Text(label, style: const TextStyle(fontFamily: 'Cairo')),
      activeColor: _primaryPurple,
      onChanged: (value) {
        setState(() => _selectedLocale = value!);
        Navigator.pop(context);
      },
    );
  }

  /// حوار الثيم
  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'اختر الوضع',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('system', 'تلقائي (حسب النظام)'),
            _buildThemeOption('light', 'فاتح'),
            _buildThemeOption('dark', 'داكن'),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String theme, String label) {
    return RadioListTile<String>(
      value: theme,
      groupValue: _selectedTheme,
      title: Text(label, style: const TextStyle(fontFamily: 'Cairo')),
      activeColor: _primaryPurple,
      onChanged: (value) {
        setState(() => _selectedTheme = value!);
        // Save theme to cubit immediately
        context.read<SettingsCubit>().changeTheme(value!);
        Navigator.pop(context);

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'تم تغيير الوضع بنجاح',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: _primaryPurple,
          ),
        );
      },
    );
  }

  /// حوار إعادة التعيين
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_rounded, color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'إعادة التعيين',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Text(
          'هل تريد إعادة تعيين جميع الإعدادات للقيم الافتراضية؟',
          style: TextStyle(fontFamily: 'Cairo', color: AppColors.slate600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo', color: AppColors.slate500),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              _resetToDefaults();
            },
            child: const Text(
              'إعادة تعيين',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }

  /// إعادة التعيين للافتراضي
  void _resetToDefaults() {
    setState(() {
      _notificationsEnabled = false;
      _sessionsNotif = false;
      _quizzesNotif = false;
      _achievementsNotif = false;
      _prayerReminders = false;
      _prayerTimesEnabled = true;
      _selectedCity = 'Algiers';
      _reminderMinutes = 10;
      _selectedLocale = 'ar';
      _selectedTheme = 'system';
      _offlineMode = false;
      _selectedPlayer = 'chewie';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم إعادة تعيين الإعدادات',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppColors.emerald500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _getLocaleLabel(String locale) {
    switch (locale) {
      case 'ar':
        return 'العربية';
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      default:
        return 'العربية';
    }
  }

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'system':
        return 'تلقائي';
      case 'light':
        return 'فاتح';
      case 'dark':
        return 'داكن';
      default:
        return 'تلقائي';
    }
  }
}
