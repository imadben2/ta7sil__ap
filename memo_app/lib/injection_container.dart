import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Core
import 'core/constants/api_constants.dart';
import 'core/network/dio_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/storage/hive_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/tab_order_service.dart';
import 'core/services/app_lifecycle_observer.dart';

// Features - Auth
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/login_with_google_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/validate_token_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/get_academic_phases_usecase.dart';
import 'features/auth/domain/usecases/get_academic_years_usecase.dart';
import 'features/auth/domain/usecases/get_academic_streams_usecase.dart';
import 'features/auth/domain/usecases/update_academic_profile_usecase.dart';
import 'features/auth/presentation/bloc/academic_setup_bloc.dart';

// Home
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/home/domain/usecases/get_dashboard_data_usecase.dart';
import 'features/home/domain/usecases/mark_session_completed_usecase.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/data/datasources/home_remote_datasource.dart';
import 'features/home/data/datasources/home_local_datasource.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Sponsors
import 'features/home/presentation/bloc/sponsors/sponsors_bloc.dart';
import 'features/home/domain/usecases/get_sponsors_usecase.dart';
import 'features/home/domain/usecases/record_sponsor_click_usecase.dart';
import 'features/home/domain/repositories/sponsors_repository.dart';
import 'features/home/data/repositories/sponsors_repository_impl.dart';
import 'features/home/data/datasources/sponsors_remote_datasource.dart';

// Promos
import 'features/home/presentation/bloc/promo/promo_bloc.dart';
import 'features/home/domain/usecases/get_promos_usecase.dart';
import 'features/home/domain/usecases/record_promo_click_usecase.dart';
import 'features/home/domain/repositories/promo_repository.dart';
import 'features/home/data/repositories/promo_repository_impl.dart';
import 'features/home/data/datasources/promo_remote_datasource.dart';

// BAC
import 'features/bac/presentation/bloc/bac_bloc.dart';
import 'features/bac/presentation/cubit/simulation_timer_cubit.dart';
import 'features/bac/presentation/bloc/bac_bookmark/bac_bookmark_bloc.dart';
import 'features/bac/domain/repositories/bac_repository.dart';
import 'features/bac/domain/usecases/get_bac_years.dart';
import 'features/bac/domain/usecases/get_bac_sessions.dart';
import 'features/bac/domain/usecases/get_bac_subjects.dart';
import 'features/bac/domain/usecases/get_bac_chapters.dart';
import 'features/bac/domain/usecases/create_simulation.dart';
import 'features/bac/domain/usecases/manage_simulation.dart';
import 'features/bac/domain/usecases/submit_simulation.dart';
import 'features/bac/domain/usecases/get_simulation_history.dart';
import 'features/bac/domain/usecases/get_simulation_results.dart';
import 'features/bac/domain/usecases/get_subject_performance.dart';
import 'features/bac/domain/usecases/download_exam_pdf.dart';
import 'features/bac/data/repositories/bac_repository_impl.dart';
import 'features/bac/data/datasources/bac_remote_datasource.dart';
import 'features/bac/data/datasources/bac_local_datasource.dart';

// BAC Study Schedule (98-day planner)
import 'features/bac_study_schedule/presentation/bloc/bac_study_bloc.dart';
import 'features/bac_study_schedule/domain/repositories/bac_study_repository.dart';
import 'features/bac_study_schedule/domain/usecases/get_full_schedule.dart';
import 'features/bac_study_schedule/domain/usecases/get_day_schedule.dart';
import 'features/bac_study_schedule/domain/usecases/get_week_schedule.dart';
import 'features/bac_study_schedule/domain/usecases/get_day_with_progress.dart';
import 'features/bac_study_schedule/domain/usecases/get_user_stats.dart';
import 'features/bac_study_schedule/domain/usecases/get_weekly_rewards.dart';
import 'features/bac_study_schedule/domain/usecases/mark_topic_complete.dart';
import 'features/bac_study_schedule/data/repositories/bac_study_repository_impl.dart';
import 'features/bac_study_schedule/data/datasources/bac_study_remote_datasource.dart';
import 'features/bac_study_schedule/data/datasources/bac_study_local_datasource.dart';

// Quiz
import 'features/quiz/presentation/bloc/quiz_list/quiz_list_bloc.dart';
import 'features/quiz/presentation/bloc/quiz_detail/quiz_detail_bloc.dart';
import 'features/quiz/presentation/bloc/quiz_attempt/quiz_attempt_bloc.dart';
import 'features/quiz/presentation/bloc/quiz_timer/quiz_timer_cubit.dart';
import 'features/quiz/presentation/bloc/quiz_results/quiz_results_bloc.dart';
import 'features/quiz/domain/repositories/quiz_repository.dart';
import 'features/quiz/domain/usecases/get_quizzes_usecase.dart';
import 'features/quiz/domain/usecases/get_quiz_details_usecase.dart';
import 'features/quiz/domain/usecases/start_quiz_usecase.dart';
import 'features/quiz/domain/usecases/get_current_attempt_usecase.dart';
import 'features/quiz/domain/usecases/save_answer_usecase.dart';
import 'features/quiz/domain/usecases/submit_quiz_usecase.dart';
import 'features/quiz/domain/usecases/get_quiz_results_usecase.dart';
import 'features/quiz/domain/usecases/get_quiz_review_usecase.dart';
import 'features/quiz/domain/usecases/abandon_quiz_usecase.dart';
import 'features/quiz/domain/usecases/get_recommendations_usecase.dart';
import 'features/quiz/domain/usecases/get_performance_usecase.dart';
import 'features/quiz/domain/usecases/get_attempts_history_usecase.dart';
import 'features/quiz/data/repositories/quiz_repository_impl.dart';
import 'features/quiz/data/datasources/quiz_remote_datasource.dart';
import 'features/quiz/data/datasources/quiz_local_datasource.dart';

// Leaderboard
import 'features/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import 'features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'features/leaderboard/domain/usecases/get_leaderboard_usecase.dart';
import 'features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'features/leaderboard/data/datasources/leaderboard_remote_datasource.dart';

// Profile
import 'features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'features/profile/presentation/bloc/statistics/statistics_bloc.dart';
import 'features/profile/presentation/bloc/settings/settings_cubit.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/repositories/statistics_repository.dart';
import 'features/profile/domain/repositories/settings_repository.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/domain/usecases/change_password_usecase.dart';
import 'features/profile/domain/usecases/get_statistics_usecase.dart';
import 'features/profile/domain/usecases/get_settings_usecase.dart';
import 'features/profile/domain/usecases/update_settings_usecase.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/data/repositories/statistics_repository_impl.dart';
import 'features/profile/data/repositories/settings_repository_impl.dart';
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/datasources/profile_local_datasource.dart';
import 'features/profile/data/datasources/statistics_remote_datasource.dart';
import 'features/profile/data/datasources/statistics_local_datasource.dart';
import 'features/profile/data/datasources/settings_local_datasource.dart';
import 'features/profile/data/datasources/settings_remote_datasource.dart';

// Content Library (shared repository for subjects)
import 'features/content_library/domain/repositories/content_library_repository.dart';
import 'features/content_library/data/repositories/content_library_repository_impl.dart';
import 'features/content_library/data/datasources/content_library_remote_datasource.dart';
import 'features/content_library/presentation/bloc/bookmark/bookmark_bloc.dart';

// Planner
import 'features/planner/data/datasources/planner_local_datasource.dart';
import 'features/planner/data/datasources/planner_remote_datasource.dart';
import 'features/planner/data/datasources/planner_sync_queue.dart';
import 'features/planner/data/services/background_sync_service.dart';
import 'features/planner/data/repositories/planner_repository_impl.dart';
import 'features/planner/data/services/priority_calculator.dart';
import 'features/planner/data/services/prayer_times_service.dart';
import 'features/planner/domain/repositories/planner_repository.dart';
import 'features/planner/services/notification_id_manager.dart';
import 'features/planner/services/session_notification_service.dart';
import 'features/planner/models/notification_mapping.dart';
import 'features/planner/domain/usecases/generate_schedule.dart';
import 'features/planner/domain/usecases/get_todays_sessions.dart';
import 'features/planner/domain/usecases/get_week_sessions.dart';
import 'features/planner/domain/usecases/start_session.dart';
import 'features/planner/domain/usecases/pause_session.dart';
import 'features/planner/domain/usecases/resume_session.dart';
import 'features/planner/domain/usecases/complete_session.dart';
import 'features/planner/domain/usecases/skip_session.dart';
import 'features/planner/domain/usecases/get_planner_settings.dart';
import 'features/planner/domain/usecases/get_session_history.dart';
import 'features/planner/domain/usecases/get_planner_analytics.dart';
import 'features/planner/domain/usecases/get_all_subjects.dart';
import 'features/planner/domain/usecases/delete_all_sessions.dart';
import 'features/planner/domain/usecases/get_centralized_subjects.dart';
import 'features/planner/domain/usecases/add_subject.dart';
import 'features/planner/domain/usecases/update_subject.dart';
import 'features/planner/domain/usecases/delete_subject.dart';
import 'features/planner/domain/usecases/update_planner_settings.dart';
import 'features/planner/domain/usecases/reschedule_session.dart';
import 'features/planner/domain/usecases/pin_session.dart';
import 'features/planner/domain/usecases/add_exam.dart';
import 'features/planner/domain/usecases/update_exam.dart';
import 'features/planner/domain/usecases/delete_exam.dart';
import 'features/planner/domain/usecases/get_upcoming_exams.dart';
import 'features/planner/domain/usecases/get_all_exams.dart';
import 'features/planner/domain/usecases/trigger_sync.dart';
import 'features/planner/domain/usecases/mark_past_sessions_missed.dart';
import 'features/planner/domain/usecases/reschedule_missed_session.dart';
import 'features/planner/data/services/session_lifecycle_service.dart';
import 'features/planner/data/services/subject_allocation_service.dart';
import 'features/planner/presentation/bloc/planner_bloc.dart';
import 'features/planner/presentation/bloc/subjects_bloc.dart';
import 'features/planner/presentation/bloc/exams_bloc.dart';
import 'features/planner/presentation/bloc/analytics/planner_analytics_bloc.dart';
import 'features/planner/presentation/cubit/session_history_cubit.dart';
import 'features/planner/presentation/bloc/session_timer_cubit.dart';
import 'features/planner/presentation/bloc/settings_cubit.dart' as planner_settings;
import 'features/planner/presentation/bloc/achievements/achievements_bloc.dart';
import 'features/planner/presentation/bloc/points_history/points_history_bloc.dart';
import 'features/planner/domain/usecases/record_exam_result.dart';
import 'features/planner/domain/usecases/get_achievements.dart';
import 'features/planner/domain/usecases/get_points_history.dart';
import 'features/planner/domain/usecases/trigger_adaptation.dart';

// Courses
import 'features/courses/di/courses_injection.dart' as courses_di;
import 'core/network/network_info.dart';

// Flashcards
import 'features/flashcards/domain/repositories/flashcards_repository.dart';
import 'features/flashcards/domain/usecases/get_decks_usecase.dart';
import 'features/flashcards/domain/usecases/get_deck_details_usecase.dart';
import 'features/flashcards/domain/usecases/get_due_cards_usecase.dart';
import 'features/flashcards/domain/usecases/start_review_usecase.dart';
import 'features/flashcards/domain/usecases/submit_answer_usecase.dart';
import 'features/flashcards/domain/usecases/complete_session_usecase.dart';
import 'features/flashcards/domain/usecases/get_stats_usecase.dart';
import 'features/flashcards/data/repositories/flashcards_repository_impl.dart';
import 'features/flashcards/data/datasources/flashcards_remote_datasource.dart';
import 'features/flashcards/presentation/bloc/decks/decks_bloc.dart';
import 'features/flashcards/presentation/bloc/review/review_bloc.dart';
import 'features/flashcards/presentation/bloc/stats/flashcard_stats_bloc.dart';

// Notifications
import 'core/services/notification_service.dart';
import 'core/services/fcm_token_service.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/data/datasources/notification_remote_datasource.dart';
import 'features/notifications/data/datasources/notification_local_datasource.dart';
import 'features/notifications/presentation/bloc/notifications_bloc.dart';

final sl = GetIt.instance;

/// Initialize dependency injection
Future<void> init() async {
  //! External - Must be registered first as they are dependencies for other services
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Storage services - needed by Dio interceptor
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(sl()),
  );
  sl.registerLazySingleton<HiveService>(() => HiveService());

  // Configure Dio with auth interceptor - must be after SecureStorageService
  // Note: Do NOT set baseUrl here - datasources provide full URLs with their own baseUrl parameter
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add auth interceptor to attach Bearer token
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Get token from secure storage
        final secureStorage = sl<SecureStorageService>();
        final token = await secureStorage.getToken();

        debugPrint('========== DIO REQUEST ==========');
        debugPrint('[Dio] Method: ${options.method}');
        debugPrint('[Dio] URL: ${options.uri}');
        debugPrint('[Dio] Token exists: ${token != null}');
        if (token != null) {
          debugPrint('[Dio] Token (first 20 chars): ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
          options.headers['Authorization'] = 'Bearer $token';
        } else {
          debugPrint('[Dio] WARNING: No auth token found!');
        }

        // Add device ID
        final deviceId = await secureStorage.getDeviceId();
        if (deviceId != null) {
          options.headers['X-Device-ID'] = deviceId;
        }

        debugPrint('[Dio] Headers: ${options.headers}');
        debugPrint('==================================');

        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('========== DIO RESPONSE ==========');
        debugPrint('[Dio] Status: ${response.statusCode}');
        debugPrint('[Dio] URL: ${response.requestOptions.uri}');
        debugPrint('[Dio] Data: ${response.data}');
        debugPrint('===================================');
        handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('========== DIO ERROR ==========');
        debugPrint('[Dio] Error: ${error.message}');
        debugPrint('[Dio] URL: ${error.requestOptions.uri}');
        debugPrint('[Dio] Status: ${error.response?.statusCode}');
        debugPrint('[Dio] Response: ${error.response?.data}');
        debugPrint('================================');
        handler.next(error);
      },
    ));

    return dio;
  });

  //! Features - Auth
  // BLoC - Must be singleton so all features share the same auth state
  sl.registerLazySingleton(
    () => AuthBloc(
      loginUseCase: sl(),
      loginWithGoogleUseCase: sl(),
      registerUseCase: sl(),
      validateTokenUseCase: sl(),
      logoutUseCase: sl(),
      secureStorage: sl(),
      fcmTokenService: sl<FcmTokenService>(),
    ),
  );

  sl.registerFactory(
    () => AcademicSetupBloc(
      getAcademicPhasesUseCase: sl(),
      getAcademicYearsUseCase: sl(),
      getAcademicStreamsUseCase: sl(),
      updateAcademicProfileUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => ValidateTokenUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetAcademicPhasesUseCase(sl()));
  sl.registerLazySingleton(() => GetAcademicYearsUseCase(sl()));
  sl.registerLazySingleton(() => GetAcademicStreamsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAcademicProfileUseCase(sl()));

  //! Planner Data Source (registered early for Home feature dependency)
  sl.registerLazySingleton<PlannerLocalDataSource>(
    () => PlannerLocalDataSourceImpl(),
  );

  // Planner Sync Queue
  sl.registerLazySingleton<PlannerSyncQueue>(
    () => PlannerSyncQueue(),
  );

  // Background Sync Service
  sl.registerLazySingleton<BackgroundSyncService>(
    () => BackgroundSyncService(
      syncQueue: sl(),
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  //! Features - Home
  // BLoC
  sl.registerFactory(
    () => HomeBloc(
      getDashboardDataUseCase: sl(),
      markSessionCompletedUseCase: sl(),
      homeRepository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDashboardDataUseCase(sl(), sl<PlannerRepository>()));
  sl.registerLazySingleton(() => MarkSessionCompletedUseCase(sl()));

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      connectivity: sl(),
      plannerLocalDataSource: sl<PlannerLocalDataSource>(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(),
  );

  //! Features - Sponsors
  // BLoC
  sl.registerFactory(
    () => SponsorsBloc(
      getSponsorsUseCase: sl(),
      recordSponsorClickUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSponsorsUseCase(repository: sl()));
  sl.registerLazySingleton(() => RecordSponsorClickUseCase(repository: sl()));

  // Repository
  sl.registerLazySingleton<SponsorsRepository>(
    () => SponsorsRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<SponsorsRemoteDataSource>(
    () => SponsorsRemoteDataSourceImpl(dio: sl()),
  );

  //! Features - Promos
  // BLoC
  sl.registerFactory(
    () => PromoBloc(
      getPromosUseCase: sl(),
      recordPromoClickUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPromosUseCase(repository: sl()));
  sl.registerLazySingleton(() => RecordPromoClickUseCase(repository: sl()));

  // Repository
  sl.registerLazySingleton<PromoRepository>(
    () => PromoRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<PromoRemoteDataSource>(
    () => PromoRemoteDataSourceImpl(dio: sl()),
  );

  //! Features - BAC
  // Data sources
  sl.registerLazySingleton<BacRemoteDataSource>(
    () => BacRemoteDataSource(dio: sl()),
  );
  sl.registerLazySingleton<BacLocalDataSource>(() => BacLocalDataSource());

  // Repository
  sl.registerLazySingleton<BacRepository>(
    () => BacRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetBacYears(sl()));
  sl.registerLazySingleton(() => GetBacSessions(sl()));
  sl.registerLazySingleton(() => GetBacSubjects(sl()));
  sl.registerLazySingleton(() => GetBacChapters(sl()));
  sl.registerLazySingleton(() => CreateSimulation(sl()));
  sl.registerLazySingleton(() => StartSimulation(sl()));
  sl.registerLazySingleton(() => PauseSimulation(sl()));
  sl.registerLazySingleton(() => ResumeSimulation(sl()));
  sl.registerLazySingleton(() => SubmitSimulation(sl()));
  sl.registerLazySingleton(() => GetSimulationHistory(sl()));
  sl.registerLazySingleton(() => GetSimulationResults(sl()));
  sl.registerLazySingleton(() => GetSubjectPerformance(sl()));
  sl.registerLazySingleton(() => DownloadExamPdf(sl()));

  // BLoC
  sl.registerFactory(
    () => BacBloc(
      getBacYears: sl(),
      getBacSessions: sl(),
      getBacSubjects: sl(),
      getBacChapters: sl(),
      createSimulation: sl(),
      startSimulation: sl(),
      pauseSimulation: sl(),
      resumeSimulation: sl(),
      submitSimulation: sl(),
      getSimulationHistory: sl(),
      getSimulationResults: sl(),
      getSubjectPerformance: sl(),
      downloadExamPdf: sl(),
      repository: sl(),
    ),
  );

  sl.registerFactory(() => SimulationTimerCubit());

  // BAC Bookmark BLoC
  sl.registerFactory<BacBookmarkBloc>(
    () => BacBookmarkBloc(dataSource: sl()),
  );

  //! Features - BAC Study Schedule (98-day planner)
  // Data sources
  sl.registerLazySingleton<BacStudyRemoteDataSource>(
    () => BacStudyRemoteDataSource(dio: sl()),
  );
  sl.registerLazySingleton<BacStudyLocalDataSource>(
    () => BacStudyLocalDataSource(),
  );

  // Repository
  sl.registerLazySingleton<BacStudyRepository>(
    () => BacStudyRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetFullSchedule(sl()));
  sl.registerLazySingleton(() => GetDaySchedule(sl()));
  sl.registerLazySingleton(() => GetWeekSchedule(sl()));
  sl.registerLazySingleton(() => GetDayWithProgress(sl()));
  sl.registerLazySingleton(() => GetUserStats(sl()));
  sl.registerLazySingleton(() => GetWeeklyRewards(sl()));
  sl.registerLazySingleton(() => MarkTopicComplete(sl()));

  // BLoC
  sl.registerFactory<BacStudyBloc>(
    () => BacStudyBloc(
      getUserStats: sl(),
      getWeekSchedule: sl(),
      getDayWithProgress: sl(),
      getWeeklyRewards: sl(),
      markTopicComplete: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      secureStorage: sl(),
      connectivity: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl(), hiveService: sl()),
  );

  //! Core
  // Network
  sl.registerLazySingleton<DioClient>(
    () => DioClient(dio: sl(), secureStorage: sl(), hiveService: sl()),
  );

  //! Features - Quiz
  // BLoCs
  sl.registerFactory(
    () => QuizListBloc(
      getQuizzesUseCase: sl(),
      getRecommendationsUseCase: sl(),
      getCentralizedSubjectsUseCase: sl(),
      authRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => QuizDetailBloc(getQuizDetailsUseCase: sl(), startQuizUseCase: sl()),
  );

  sl.registerFactory(
    () => QuizAttemptBloc(
      getCurrentAttemptUseCase: sl(),
      saveAnswerUseCase: sl(),
      submitQuizUseCase: sl(),
      abandonQuizUseCase: sl(),
    ),
  );

  sl.registerFactory(() => QuizTimerCubit());

  sl.registerFactory(
    () => QuizResultsBloc(
      getQuizResultsUseCase: sl(),
      getQuizReviewUseCase: sl(),
      getPerformanceUseCase: sl(),
      getAttemptsHistoryUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetQuizzesUseCase(sl()));
  sl.registerLazySingleton(() => GetQuizDetailsUseCase(sl()));
  sl.registerLazySingleton(() => StartQuizUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentAttemptUseCase(sl()));
  sl.registerLazySingleton(() => SaveAnswerUseCase(sl()));
  sl.registerLazySingleton(() => SubmitQuizUseCase(sl()));
  sl.registerLazySingleton(() => GetQuizResultsUseCase(sl()));
  sl.registerLazySingleton(() => GetQuizReviewUseCase(sl()));
  sl.registerLazySingleton(() => AbandonQuizUseCase(sl()));
  sl.registerLazySingleton(() => GetRecommendationsUseCase(sl()));
  sl.registerLazySingleton(() => GetPerformanceUseCase(sl()));
  sl.registerLazySingleton(() => GetAttemptsHistoryUseCase(sl()));

  // Repository
  sl.registerLazySingleton<QuizRepository>(
    () => QuizRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<QuizRemoteDataSource>(
    () => QuizRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<QuizLocalDataSource>(
    () => QuizLocalDataSourceImpl(),
  );

  //! Features - Leaderboard
  // BLoC
  sl.registerFactory(
    () => LeaderboardBloc(
      getStreamLeaderboard: sl(),
      getSubjectLeaderboard: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetStreamLeaderboardUseCase(sl()));
  sl.registerLazySingleton(() => GetSubjectLeaderboardUseCase(sl()));

  // Repository
  sl.registerLazySingleton<LeaderboardRepository>(
    () => LeaderboardRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<LeaderboardRemoteDataSource>(
    () => LeaderboardRemoteDataSourceImpl(dio: sl()),
  );

  //! Features - Profile
  // BLoCs
  sl.registerFactory(
    () => ProfileBloc(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      changePasswordUseCase: sl(),
      profileRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => SettingsCubit(getSettingsUseCase: sl(), updateSettingsUseCase: sl()),
  );

  sl.registerFactory(
    () => StatisticsBloc(getStatistics: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => GetStatisticsUseCase(sl()));
  sl.registerLazySingleton(() => GetSettingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSettingsUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton<StatisticsRepository>(
    () =>
        StatisticsRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<StatisticsRemoteDataSource>(
    () => StatisticsRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<StatisticsLocalDataSource>(
    () => StatisticsLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(dio: sl()),
  );

  //! Features - Notifications
  // Services
  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(),
  );

  sl.registerLazySingleton<FcmTokenService>(
    () => FcmTokenService(
      dio: sl<Dio>(),
      notificationService: sl<NotificationService>(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<NotificationLocalDataSource>(
    () => NotificationLocalDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // BLoC
  sl.registerLazySingleton<NotificationsBloc>(
    () => NotificationsBloc(
      repository: sl(),
      notificationService: sl(),
    ),
  );

  //! Features - Planner
  // Services
  sl.registerLazySingleton(() => PriorityCalculator());
  sl.registerLazySingleton(() => SubjectAllocationService());
  // ScheduleGenerator removed - using Laravel API only for schedule generation
  sl.registerLazySingleton(() => PrayerTimesService(sl<Dio>()));
  sl.registerLazySingleton(
    () => SessionLifecycleService(localDataSource: sl()),
  );

  // Notification services
  sl.registerLazySingleton<NotificationIdManager>(
    () => NotificationIdManager(),
  );

  sl.registerLazySingleton<SessionNotificationService>(
    () => SessionNotificationService(
      notificationService: sl<NotificationService>(),
      notificationIdManager: sl<NotificationIdManager>(),
    ),
  );

  // Data sources
  // Note: PlannerLocalDataSource is registered earlier for Home feature dependency
  sl.registerLazySingleton<PlannerRemoteDataSource>(
    () => PlannerRemoteDataSourceImpl(
      dio: sl<Dio>(),
      baseUrl: ApiConstants.baseUrl,
      authLocalDataSource: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<PlannerRepository>(
    () => PlannerRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
      priorityCalculator: sl(),
      prayerTimesService: sl(),
      authLocalDataSource: sl(),
      syncQueue: sl(),
    ),
  );

  // Use cases - Sessions
  sl.registerLazySingleton(() => GenerateSchedule(sl()));
  sl.registerLazySingleton(() => GetTodaysSessions(sl()));
  sl.registerLazySingleton(() => GetWeekSessions(sl()));
  sl.registerLazySingleton(() => StartSession(sl()));
  sl.registerLazySingleton(() => PauseSession(sl()));
  sl.registerLazySingleton(() => ResumeSession(sl()));
  sl.registerLazySingleton(() => CompleteSession(sl()));
  sl.registerLazySingleton(() => SkipSession(sl()));
  sl.registerLazySingleton(() => RescheduleSession(sl()));
  sl.registerLazySingleton(() => DeleteAllSessions(sl()));
  sl.registerLazySingleton(() => PinSession(sl()));
  sl.registerLazySingleton(() => TriggerSync(sl()));

  // Use cases - Session Lifecycle
  sl.registerLazySingleton(
    () => MarkPastSessionsMissed(
      sessionLifecycleService: sl(),
      localDataSource: sl(),
      authLocalDataSource: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => RescheduleMissedSession(
      sessionLifecycleService: sl(),
      localDataSource: sl(),
      authLocalDataSource: sl(),
      plannerRepository: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => GetMissedSessions(sessionLifecycleService: sl()),
  );
  sl.registerLazySingleton(
    () => GetOverdueSessions(
      sessionLifecycleService: sl(),
      plannerRepository: sl(),
    ),
  );

  // Use cases - Settings
  sl.registerLazySingleton(() => GetPlannerSettings(sl()));
  sl.registerLazySingleton(() => UpdatePlannerSettings(sl()));

  // Use cases - Analytics
  sl.registerLazySingleton(() => GetSessionHistory(sl()));
  sl.registerLazySingleton(() => GetPlannerAnalytics(sl()));

  // Use cases - Subjects
  sl.registerLazySingleton(() => GetAllSubjects(sl()));
  sl.registerLazySingleton(() => GetCentralizedSubjects(sl()));
  sl.registerLazySingleton(() => AddSubject(sl()));
  sl.registerLazySingleton(() => UpdateSubject(sl()));
  sl.registerLazySingleton(() => DeleteSubject(sl()));

  // Use cases - Exams
  sl.registerLazySingleton(() => AddExam(sl()));
  sl.registerLazySingleton(() => UpdateExam(sl()));
  sl.registerLazySingleton(() => DeleteExam(sl()));
  sl.registerLazySingleton(() => GetUpcomingExams(sl()));
  sl.registerLazySingleton(() => GetAllExams(sl()));
  sl.registerLazySingleton(() => RecordExamResult(sl()));

  // Use cases - Achievements & Points
  sl.registerLazySingleton(() => GetAchievements(sl()));
  sl.registerLazySingleton(() => GetPointsHistory(sl()));

  // Use cases - Adaptation
  sl.registerLazySingleton(() => TriggerAdaptation(sl()));

  // BLoCs - PlannerBloc is singleton to persist state across navigation
  // and prevent "Cannot add new events after calling close" errors
  sl.registerLazySingleton(
    () => PlannerBloc(
      generateScheduleUseCase: sl(),
      getTodaysSessionsUseCase: sl(),
      getWeekSessionsUseCase: sl(),
      startSessionUseCase: sl(),
      pauseSessionUseCase: sl(),
      resumeSessionUseCase: sl(),
      completeSessionUseCase: sl(),
      skipSessionUseCase: sl(),
      getSettingsUseCase: sl(),
      updateSettingsUseCase: sl(),
      getAllSubjectsUseCase: sl(),
      deleteAllSessionsUseCase: sl(),
      markPastSessionsMissedUseCase: sl(),
      rescheduleMissedSessionUseCase: sl(),
      rescheduleSessionUseCase: sl(),
      pinSessionUseCase: sl(),
      triggerSyncUseCase: sl(),
      getMissedSessionsUseCase: sl(),
      getOverdueSessionsUseCase: sl(),
      triggerAdaptationUseCase: sl(),
      localDataSource: sl(),
      sessionNotificationService: sl<SessionNotificationService>(),
      plannerRepository: sl<PlannerRepository>(),
    ),
  );

  sl.registerFactory(
    () => SubjectsBloc(
      getAllSubjectsUseCase: sl(),
      addSubjectUseCase: sl(),
      updateSubjectUseCase: sl(),
      deleteSubjectUseCase: sl(),
      getCentralizedSubjectsUseCase: sl(),
    ),
  );

  sl.registerFactory(() => PlannerAnalyticsBloc(getPlannerAnalytics: sl()));

  sl.registerFactory(() => SessionHistoryCubit(getSessionHistory: sl()));

  // Session Timer Cubit - Singleton to persist timer state across navigation
  sl.registerLazySingleton(() => SessionTimerCubit());

  // Planner Settings Cubit
  sl.registerFactory(
    () => planner_settings.SettingsCubit(
      getSettingsUseCase: sl(),
      updateSettingsUseCase: sl(),
      sessionNotificationService: sl<SessionNotificationService>(),
      plannerBloc: sl<PlannerBloc>(),
    ),
  );

  // Exams BLoC
  sl.registerFactory(
    () => ExamsBloc(
      getAllExamsUseCase: sl(),
      getUpcomingExamsUseCase: sl(),
      addExamUseCase: sl(),
      updateExamUseCase: sl(),
      deleteExamUseCase: sl(),
      recordExamResultUseCase: sl(),
    ),
  );

  // Achievements BLoC
  sl.registerFactory(
    () => AchievementsBloc(getAchievements: sl()),
  );

  // Points History BLoC
  sl.registerFactory(
    () => PointsHistoryBloc(getPointsHistory: sl()),
  );

  //! Content Library Repository (shared with content_library feature)
  sl.registerLazySingleton<ContentLibraryRepository>(
    () => ContentLibraryRepositoryImpl(
      remoteDataSource: ContentLibraryRemoteDataSource(dio: sl<Dio>()),
    ),
  );

  // Bookmark BLoC
  sl.registerFactory<BookmarkBloc>(
    () => BookmarkBloc(repository: sl()),
  );

  //! Features - Courses
  // Initialize Courses DI using courses_di getIt instance
  // Note: courses_di.getIt is the same instance as sl (both are GetIt.instance)
  // So BLoCs registered in initCoursesInjection() are already accessible via sl
  await courses_di.initCoursesInjection();

  //! Features - Flashcards
  // Data Sources
  sl.registerLazySingleton<FlashcardsRemoteDataSource>(
    () => FlashcardsRemoteDataSourceImpl(dio: sl()),
  );

  // Repository
  sl.registerLazySingleton<FlashcardsRepository>(
    () => FlashcardsRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetDecksUseCase(sl()));
  sl.registerLazySingleton(() => GetDeckDetailsUseCase(sl()));
  sl.registerLazySingleton(() => GetDueCardsUseCase(sl()));
  sl.registerLazySingleton(() => StartReviewUseCase(sl()));
  sl.registerLazySingleton(() => SubmitAnswerUseCase(sl()));
  sl.registerLazySingleton(() => CompleteSessionUseCase(sl()));
  sl.registerLazySingleton(() => GetFlashcardStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetForecastUseCase(sl()));
  sl.registerLazySingleton(() => GetTodaySummaryUseCase(sl()));

  // BLoCs
  sl.registerFactory(
    () => DecksBloc(
      getDecksUseCase: sl(),
      getDeckDetailsUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ReviewBloc(
      startReviewUseCase: sl(),
      submitAnswerUseCase: sl(),
      completeSessionUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => FlashcardStatsBloc(
      getStatsUseCase: sl(),
      getForecastUseCase: sl(),
      getTodaySummaryUseCase: sl(),
    ),
  );

  // Tab Order Service (for custom category ordering)
  sl.registerLazySingleton<TabOrderService>(
    () => TabOrderService(hiveService: sl()),
  );

  //! Core - Network
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(sl()),
  );

  //! Core - Lifecycle Observer
  sl.registerLazySingleton<AppLifecycleObserver>(
    () => AppLifecycleObserver(
      plannerBloc: sl<PlannerBloc>(),
      settingsCubit: sl<planner_settings.SettingsCubit>(),
      syncService: sl<BackgroundSyncService>(),
      connectivityService: sl<ConnectivityService>(),
      sessionNotificationService: sl<SessionNotificationService>(),
    ),
  );
}
