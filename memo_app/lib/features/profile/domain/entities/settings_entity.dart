import 'package:equatable/equatable.dart';

/// كيان الإعدادات
///
/// جميع الإعدادات تُخزن محليًا في Hive (لا يتم مزامنتها مع API)
/// يشمل:
/// - إعدادات الإشعارات
/// - إعدادات أوقات الصلاة
/// - اللغة والثيم
/// - إدارة البيانات
class SettingsEntity extends Equatable {
  /// إعدادات الإشعارات
  final NotificationSettings notifications;

  /// إعدادات أوقات الصلاة
  final PrayerTimesSettings prayerTimes;

  /// اللغة ('ar', 'fr', 'en')
  final String locale;

  /// وضع الثيم ('system', 'light', 'dark')
  final String themeMode;

  /// الوضع غير متصل
  final bool offlineMode;

  /// حجم الذاكرة المؤقتة (MB)
  final int cacheSize;

  /// مشغل الفيديو المفضل ('chewie', 'better_player', 'media_kit')
  final String preferredVideoPlayer;

  const SettingsEntity({
    required this.notifications,
    required this.prayerTimes,
    required this.locale,
    required this.themeMode,
    required this.offlineMode,
    required this.cacheSize,
    required this.preferredVideoPlayer,
  });

  /// الإعدادات الافتراضية
  factory SettingsEntity.defaults() {
    return const SettingsEntity(
      notifications: NotificationSettings(
        enabled: true,
        sessions: true,
        quizzes: true,
        achievements: true,
        prayerReminders: true,
      ),
      prayerTimes: PrayerTimesSettings(
        enabled: true,
        city: 'Algiers',
        reminderMinutesBefore: 10,
      ),
      locale: 'ar',
      themeMode: 'system',
      offlineMode: false,
      cacheSize: 0,
      preferredVideoPlayer: 'chewie',
    );
  }

  /// نسخ مع تغييرات
  SettingsEntity copyWith({
    NotificationSettings? notifications,
    PrayerTimesSettings? prayerTimes,
    String? locale,
    String? themeMode,
    bool? offlineMode,
    int? cacheSize,
    String? preferredVideoPlayer,
  }) {
    return SettingsEntity(
      notifications: notifications ?? this.notifications,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      offlineMode: offlineMode ?? this.offlineMode,
      cacheSize: cacheSize ?? this.cacheSize,
      preferredVideoPlayer: preferredVideoPlayer ?? this.preferredVideoPlayer,
    );
  }

  @override
  List<Object?> get props => [
    notifications,
    prayerTimes,
    locale,
    themeMode,
    offlineMode,
    cacheSize,
    preferredVideoPlayer,
  ];
}

/// إعدادات الإشعارات
class NotificationSettings extends Equatable {
  /// تفعيل الإشعارات العامة
  final bool enabled;

  /// إشعارات الجلسات الدراسية
  final bool sessions;

  /// إشعارات الاختبارات
  final bool quizzes;

  /// إشعارات الإنجازات
  final bool achievements;

  /// تذكير أوقات الصلاة
  final bool prayerReminders;

  const NotificationSettings({
    required this.enabled,
    required this.sessions,
    required this.quizzes,
    required this.achievements,
    required this.prayerReminders,
  });

  /// نسخ مع تغييرات
  NotificationSettings copyWith({
    bool? enabled,
    bool? sessions,
    bool? quizzes,
    bool? achievements,
    bool? prayerReminders,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      sessions: sessions ?? this.sessions,
      quizzes: quizzes ?? this.quizzes,
      achievements: achievements ?? this.achievements,
      prayerReminders: prayerReminders ?? this.prayerReminders,
    );
  }

  @override
  List<Object?> get props => [
    enabled,
    sessions,
    quizzes,
    achievements,
    prayerReminders,
  ];
}

/// إعدادات أوقات الصلاة
class PrayerTimesSettings extends Equatable {
  /// تفعيل أوقات الصلاة
  final bool enabled;

  /// المدينة (Algiers, Oran, Constantine, ...)
  final String city;

  /// التذكير قبل الصلاة بـ X دقيقة
  final int reminderMinutesBefore;

  const PrayerTimesSettings({
    required this.enabled,
    required this.city,
    required this.reminderMinutesBefore,
  });

  /// نسخ مع تغييرات
  PrayerTimesSettings copyWith({
    bool? enabled,
    String? city,
    int? reminderMinutesBefore,
  }) {
    return PrayerTimesSettings(
      enabled: enabled ?? this.enabled,
      city: city ?? this.city,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
    );
  }

  @override
  List<Object?> get props => [enabled, city, reminderMinutesBefore];
}

/// قائمة المدن الجزائرية
class AlgerianCities {
  static const List<String> cities = [
    'Algiers', // الجزائر
    'Oran', // وهران
    'Constantine', // قسنطينة
    'Annaba', // عنابة
    'Blida', // البليدة
    'Batna', // باتنة
    'Djelfa', // الجلفة
    'Sétif', // سطيف
    'Sidi Bel Abbès', // سيدي بلعباس
    'Biskra', // بسكرة
    'Tébessa', // تبسة
    'Tiaret', // تيارت
    'Béjaïa', // بجاية
    'Tlemcen', // تلمسان
    'Ouargla', // ورقلة
    'Mostaganem', // مستغانم
    'Bordj Bou Arreridj', // برج بوعريريج
    'Chlef', // الشلف
    'Skikda', // سكيكدة
    'Jijel', // جيجل
    'Relizane', // غليزان
    'M\'Sila', // المسيلة
    'Oueled Djellal', // أولاد جلال
    'Saïda', // سعيدة
    'Khenchela', // خنشلة
    'Souk Ahras', // سوق أهراس
    'Médéa', // المدية
    'El Oued', // الوادي
    'Tamanrasset', // تمنراست
    'Tindouf', // تندوف
    'Béchar', // بشار
    'Adrar', // أدرار
  ];

  /// أسماء المدن بالعربية
  static const Map<String, String> citiesAr = {
    'Algiers': 'الجزائر',
    'Oran': 'وهران',
    'Constantine': 'قسنطينة',
    'Annaba': 'عنابة',
    'Blida': 'البليدة',
    'Batna': 'باتنة',
    'Djelfa': 'الجلفة',
    'Sétif': 'سطيف',
    'Sidi Bel Abbès': 'سيدي بلعباس',
    'Biskra': 'بسكرة',
    'Tébessa': 'تبسة',
    'Tiaret': 'تيارت',
    'Béjaïa': 'بجاية',
    'Tlemcen': 'تلمسان',
    'Ouargla': 'ورقلة',
    'Mostaganem': 'مستغانم',
    'Bordj Bou Arreridj': 'برج بوعريريج',
    'Chlef': 'الشلف',
    'Skikda': 'سكيكدة',
    'Jijel': 'جيجل',
    'Relizane': 'غليزان',
    'M\'Sila': 'المسيلة',
    'Oueled Djellal': 'أولاد جلال',
    'Saïda': 'سعيدة',
    'Khenchela': 'خنشلة',
    'Souk Ahras': 'سوق أهراس',
    'Médéa': 'المدية',
    'El Oued': 'الوادي',
    'Tamanrasset': 'تمنراست',
    'Tindouf': 'تندوف',
    'Béchar': 'بشار',
    'Adrar': 'أدرار',
  };

  /// الحصول على الاسم بالعربية
  static String getArabicName(String cityName) {
    return citiesAr[cityName] ?? cityName;
  }
}
