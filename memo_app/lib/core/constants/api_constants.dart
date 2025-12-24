/// API endpoints and configuration constants
class ApiConstants {
  ApiConstants._();

  // App Version - Update this with each release
  static const String appVersion = '1.0';

  // Base URL - Update this for production
  // 10.0.2.2 is the Android emulator's alias for localhost
  //static const String baseUrl = 'https://tahssil.site/api';
  static const String baseUrl = 'http://10.0.2.2:8084/api';

  // Version Check Endpoint
  static const String versionCheck = '/app/version-check';

  // Timeout durati
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String loginWithGoogle = '/v1/auth/google';
  static const String logout = '/auth/logout';
  static const String logoutAll = '/auth/logout-all';
  static const String me = '/auth/me';
  static const String refreshToken = '/auth/refresh';
  static const String deviceTransferRequest = '/auth/device-transfer/request';
  static const String myDeviceTransferRequests =
      '/auth/device-transfer/my-requests';

  // Profile Endpoints
  static const String profile = '/profile';
  static const String updateProfile = '/profile';
  static const String updateAcademicProfile = '/profile/academic';
  static const String profilePhoto = '/profile/photo';
  static const String profileChangePassword = '/profile/change-password';
  static const String profileExport = '/profile/export';
  static const String profileDelete = '/profile/delete-account';
  static const String profileStats = '/profile/stats';
  static const String updateAvatar = '/profile/avatar';
  static const String updatePreferences = '/profile/preferences';

  // Device Sessions Endpoints
  static const String deviceSessions = '/sessions/devices';
  static const String deviceSessionUpdate = '/sessions/device';
  static const String deviceSessionStatistics = '/sessions/statistics';

  // Academic Endpoints (use non-v1 routes which exist in API)
  static const String academicPhases = '/academic/phases';
  static const String academicYears = '/academic/years';
  static const String academicStreams = '/academic/streams';
  static const String subjects = '/academic/subjects';

  // Content Endpoints (V1)
  static const String contents = '/v1/contents';
  static const String contentChapters = '/v1/contents/chapters';
  static const String contentByChapter = '/v1/contents/chapter';
  static const String contentSearch = '/v1/contents/search';
  static const String contentTypes = '/v1/contents/types';
  static const String contentDetail = '/v1/contents';
  static const String contentDownload = '/v1/contents';

  // Progress Endpoints (V1)
  static const String progressAll = '/v1/progress/all';
  static const String progressContent = '/v1/progress/content';
  static const String progressSubject = '/v1/progress/subject';

  // Bookmark Endpoints (V1)
  static const String bookmarks = '/v1/bookmarks';
  static const String bookmarkContent = '/v1/bookmarks/content';
  static const String bookmarkCount = '/v1/bookmarks/count';

  // Rating Endpoints (V1)
  static const String rateContent = '/v1/ratings/content';

  // Planner Endpoints
  static const String plannerSessions = '/planner/sessions';
  static const String plannerSessionsToday = '/planner/sessions/today';
  static const String plannerSessionStart = '/planner/sessions/start';
  static const String plannerSessionPause = '/planner/sessions/pause';
  static const String plannerSessionResume = '/planner/sessions/resume';
  static const String plannerSessionComplete = '/planner/sessions/complete';
  static const String plannerSessionSkip = '/planner/sessions/skip';
  static const String plannerSettings = '/planner/settings';
  static const String plannerSchedule = '/planner/schedule';
  static const String plannerGenerate = '/planner/generate';
  static const String plannerSubjects = '/planner/subjects';
  static const String plannerExams = '/planner/exams';
  static const String plannerCentralizedSubjects = '/subjects/academic';
  static const String plannerPrayerTimes = '/planner/prayer-times';

  // Quiz Endpoints
  static const String quizzes = '/quiz';
  static const String quizDetail = '/quiz';
  static const String quizAttempt = '/quiz/attempt';
  static const String quizSubmit = '/quiz/submit';
  static const String quizResults = '/quiz/results';

  // BAC Study Schedule Endpoints (98-day planner)
  static const String bacStudySchedule = '/bac-study/schedule';
  static const String bacStudyDay = '/bac-study/day';
  static const String bacStudyWeek = '/bac-study/week';
  static const String bacStudyRewards = '/bac-study/rewards';
  static const String bacStudyProgress = '/bac-study/progress/user';
  static const String bacStudyStats = '/bac-study/progress/stats';
  static const String bacStudyComplete = '/bac-study/progress/complete';
  static const String bacStudyDayWithProgress = '/bac-study/day-with-progress';

  // Flashcards Endpoints
  static const String flashcardDecks = '/v1/flashcard-decks';
  static String flashcardDeckDetail(int id) => '/v1/flashcard-decks/$id';
  static const String flashcardsDue = '/v1/flashcards/due';
  static const String flashcardReviewStart = '/v1/flashcard-reviews/start';
  static String flashcardReviewAnswer(int sessionId) =>
      '/v1/flashcard-reviews/$sessionId/answer';
  static String flashcardReviewComplete(int sessionId) =>
      '/v1/flashcard-reviews/$sessionId/complete';
  static const String flashcardStats = '/v1/flashcard-stats';
  static const String flashcardStatsForecast = '/v1/flashcard-stats/forecast';
  static const String flashcardStatsTodaySummary = '/v1/flashcard-stats/today';
  static const String hiveBoxFlashcards = 'flashcards_box';

  // BAC Endpoints
  static const String bacYears = '/v1/bac/years';
  static const String bacSessions = '/v1/bac/sessions';
  static const String bacSubjects = '/v1/bac/subjects';
  static const String bacChapters = '/v1/bac/chapters';
  static const String bacSimulations = '/v1/bac/simulations';
  static const String bacExamsBySubject = '/v1/bac/exams-by-subject';
  static const String bacSimulationStart = '/v1/bac/simulations/start';
  static const String bacSimulationPause = '/v1/bac/simulations/pause';
  static const String bacSimulationResume = '/v1/bac/simulations/resume';
  static const String bacSimulationSubmit = '/v1/bac/simulations/submit';
  static const String bacSimulationResults = '/v1/bac/simulations/results';
  static const String bacSubjectPerformance = '/v1/bac/subjects/performance';
  static const String bacExamDownload = '/v1/bac/exams/download';

  // Course Endpoints (Paid)
  static const String courses = '/courses';
  static const String courseDetail = '/courses';
  static const String courseLessons = '/courses/lessons';
  static const String coursePurchase = '/courses/purchase';

  // Statistics Endpoints
  static const String statistics = '/v1/statistics';
  static const String userStats = '/v1/statistics/user';
  static const String weeklyStats = '/v1/statistics/weekly';
  static const String monthlyStats = '/v1/statistics/monthly';

  // Dashboard Endpoints
  static const String dashboard = '/v1/dashboard';
  static const String dashboardStats = '/v1/dashboard/stats';
  static const String dashboardTodaySchedule = '/v1/dashboard/today';
  static const String todaySessions = '/v1/dashboard/today-sessions';
  static const String subjectsProgress = '/v1/dashboard/subjects-progress';
  static const String updateStudyTime = '/v1/statistics/study-time';

  // Sponsors Endpoints
  static const String sponsors = '/v1/sponsors';
  static String sponsorClick(int id) => '/v1/sponsors/$id/click';

  // Promo Endpoints
  static const String promos = '/v1/promos';
  static String promoClick(int id) => '/v1/promos/$id/click';

  // Notification Endpoints (V1)
  static const String notifications = '/v1/notifications';
  static const String notificationsRead = '/v1/notifications/read';
  static const String notificationsReadAll = '/v1/notifications/read-all';
  static const String notificationsFcmToken = '/v1/notifications/register-device';

  // HTTP Headers
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerAuthorization = 'Authorization';
  static const String headerDeviceId = 'X-Device-ID';

  // Content Types
  static const String contentTypeJson = 'application/json';
  static const String contentTypeFormData = 'multipart/form-data';

  // Storage Keys
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyRefreshToken = 'refresh_token';
  static const String storageKeyDeviceId = 'device_id';
  static const String storageKeyUser = 'user_data';
  static const String storageKeyAcademicProfile = 'academic_profile';
  static const String storageKeyRememberMe = 'remember_me';

  // Hive Box Names
  static const String hiveBoxAuth = 'auth_box';
  static const String hiveBoxSubjects = 'subjects_box';
  static const String hiveBoxContents = 'contents_box';
  static const String hiveBoxPlanner = 'planner_box';
  static const String hiveBoxBacStudy = 'bac_study_box';
  static const String hiveBoxCache = 'cache_box';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Rate Limiting
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
