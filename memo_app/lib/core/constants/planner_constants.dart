/// Constants specific to the Planner feature
class PlannerConstants {
  PlannerConstants._();

  // Prayer Times API
  static const String prayerTimesApiBaseUrl = 'https://api.aladhan.com/v1';
  static const String prayerTimesByCityEndpoint = 'https://api.aladhan.com/v1/timingsByCity';
  static const int prayerTimesApiTimeout = 10; // seconds
  static const String defaultCountry = 'Algeria';
  static const int prayerCalculationMethod = 2; // Islamic Society of North America

  // Cache durations
  static const int prayerTimesCacheDuration = 24; // hours
  static const int prayerTimesCacheDays = 1; // days (same as hours/24)
  static const int scheduleCacheDuration = 7; // days
  static const int sessionsCacheDuration = 30; // days

  // Defaults for schedule generation
  static const int defaultSessionDuration = 45; // minutes
  static const int defaultBreakDuration = 10; // minutes
  static const int defaultStudyHoursPerDay = 6; // hours

  // Session timing
  static const int minSessionDuration = 15; // minutes
  static const int maxSessionDuration = 120; // minutes
  static const int pomodoroWorkDuration = 25; // minutes
  static const int pomodoroBreakDuration = 5; // minutes
  static const int pomodoroLongBreakDuration = 15; // minutes

  // Points system
  static const int pointsPerCompletedSession = 10;
  static const int pointsPerSkippedSession = -5;
  static const int bonusPointsForStreak = 5;
  static const int streakDaysForBonus = 3;

  // UI Constants
  static const double sessionCardHeight = 120.0;
  static const double subjectCardHeight = 80.0;
  static const int maxRecentSessions = 10;

  // Sync
  static const int syncQueueMaxSize = 100;
  static const int syncRetryAttempts = 3;
  static const int syncRetryDelay = 5; // seconds

  // Notifications
  static const int sessionReminderMinutes = 15;
  static const int examReminderDays = 3;

  // Colors (Material color values)
  static const int primaryColorValue = 0xFF2196F3;
  static const int accentColorValue = 0xFF03DAC6;
  static const int errorColorValue = 0xFFB00020;
  static const int warningColorValue = 0xFFFFA726;
  static const int successColorValue = 0xFF4CAF50;
}
