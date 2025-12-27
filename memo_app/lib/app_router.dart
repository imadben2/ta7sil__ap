import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';

// Import pages
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/academic_selection_page.dart';
import 'features/auth/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/pages/update_required_page.dart';
import 'features/home/presentation/pages/main_screen.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/home/presentation/bloc/home_event.dart';
import 'features/courses/presentation/bloc/courses/courses_event.dart';
import 'features/bac/presentation/pages/bac_archives_page.dart';
import 'features/bac/presentation/pages/bac_archives_by_year_page.dart';
import 'features/bac/presentation/pages/bac_years_by_subject_page.dart';
import 'features/bac/presentation/pages/bac_exams_by_subject_page.dart';
import 'features/bac/presentation/pages/bac_subject_detail_page.dart';
import 'features/bac/presentation/pages/bac_simulation_page.dart';
import 'features/bac/presentation/pages/bac_results_page.dart';
import 'features/bac/presentation/pages/bac_performance_page.dart';
import 'features/bac/presentation/bloc/bac_bloc.dart';
import 'features/bac/domain/entities/bac_subject_entity.dart';

// BAC Study Schedule imports
import 'features/bac_study_schedule/presentation/pages/bac_study_main_page.dart';
import 'features/bac_study_schedule/presentation/pages/bac_day_detail_page.dart';
import 'features/bac_study_schedule/presentation/pages/bac_rewards_page.dart';
import 'features/content_library/presentation/pages/subjects_list_page.dart';
import 'features/content_library/presentation/pages/subject_detail_page.dart';
import 'features/content_library/presentation/bloc/subjects/subjects_bloc.dart';
import 'features/content_library/presentation/bloc/subject_detail/subject_detail_bloc.dart';
import 'features/content_library/presentation/bloc/subject_detail/subject_detail_event.dart';
import 'features/content_library/presentation/bloc/subject_detail/subject_detail_state.dart';
import 'features/content_library/domain/entities/subject_entity.dart';
import 'features/content_library/data/datasources/content_library_remote_datasource.dart';
import 'features/content_library/data/repositories/content_library_repository_impl.dart';
import 'features/quiz/presentation/pages/quiz_list_page.dart';
import 'features/quiz/presentation/pages/quiz_detail_page.dart';
import 'features/quiz/presentation/pages/quiz_taking_page.dart';
import 'features/quiz/presentation/pages/quiz_results_page.dart';
import 'features/quiz/presentation/pages/quiz_review_page.dart';
import 'features/quiz/presentation/pages/subject_quizzes_page.dart';
import 'features/quiz/domain/entities/quiz_entity.dart';
import 'features/quiz/presentation/bloc/quiz_list/quiz_list_bloc.dart';
import 'features/quiz/presentation/bloc/quiz_list/quiz_list_event.dart';
import 'features/quiz/presentation/bloc/quiz_list/quiz_list_state.dart';
import 'features/quiz/presentation/bloc/quiz_detail/quiz_detail_bloc.dart';
import 'features/quiz/presentation/bloc/quiz_attempt/quiz_attempt_bloc.dart';
import 'features/quiz/presentation/bloc/quiz_timer/quiz_timer_cubit.dart';
import 'features/quiz/presentation/bloc/quiz_results/quiz_results_bloc.dart';
import 'features/leaderboard/presentation/pages/leaderboard_page.dart';
import 'features/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import 'features/courses/presentation/bloc/courses/courses_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart';

// Planner imports
import 'features/planner/presentation/shell/planner_shell.dart';
import 'features/planner/presentation/screens/planner_main_screen.dart';
import 'features/planner/presentation/screens/today_view_screen.dart';
import 'features/planner/presentation/screens/week_view_screen.dart';
import 'features/planner/presentation/screens/active_session_screen.dart';
import 'features/planner/presentation/screens/session_detail_screen.dart';
import 'features/planner/presentation/screens/session_history_screen.dart';
import 'features/planner/presentation/screens/analytics_dashboard_screen.dart';
import 'features/planner/presentation/screens/schedule_wizard_screen.dart';
import 'features/planner/presentation/screens/schedule_statistics_screen.dart';
import 'features/planner/presentation/pages/planner_settings_page.dart';
import 'features/planner/presentation/pages/subjects_page.dart';
import 'features/planner/presentation/pages/exams_page.dart';
import 'features/planner/presentation/bloc/planner_bloc.dart';
import 'features/planner/presentation/bloc/planner_event.dart';
import 'features/planner/presentation/bloc/planner_state.dart';
import 'features/planner/presentation/bloc/subjects_bloc.dart' as planner_subjects;
import 'features/planner/presentation/bloc/exams_bloc.dart';
import 'features/planner/presentation/bloc/analytics/planner_analytics_bloc.dart';
import 'features/planner/presentation/cubit/session_history_cubit.dart';
import 'features/planner/presentation/bloc/session_timer_cubit.dart';
import 'features/planner/presentation/bloc/settings_cubit.dart' as planner_settings;
import 'features/planner/domain/entities/study_session.dart';

// Profile imports
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/profile/presentation/pages/edit_profile_page.dart';
import 'features/profile/presentation/pages/settings_page.dart';
import 'features/profile/presentation/pages/change_password_page.dart';
import 'features/profile/presentation/pages/tab_order_settings_page.dart';
import 'features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'features/profile/presentation/bloc/profile/profile_event.dart';
import 'features/profile/presentation/bloc/settings/settings_cubit.dart' as profile_settings;

// Notifications imports
import 'features/notifications/presentation/pages/notifications_page.dart';
import 'features/notifications/presentation/bloc/notifications_bloc.dart';
import 'features/notifications/presentation/bloc/notifications_event.dart';

// Help imports
import 'features/help/presentation/pages/user_manual_page.dart';

// Flashcards imports
import 'features/flashcards/presentation/pages/decks_list_page.dart';
import 'features/flashcards/presentation/pages/deck_detail_page.dart';
import 'features/flashcards/presentation/pages/review_page.dart';
import 'features/flashcards/presentation/pages/review_summary_page.dart';
import 'features/flashcards/presentation/pages/flashcard_stats_page.dart';
import 'features/flashcards/presentation/bloc/decks/decks_bloc.dart';
import 'features/flashcards/presentation/bloc/review/review_bloc.dart';
import 'features/flashcards/presentation/bloc/review/review_state.dart';
import 'features/flashcards/presentation/bloc/stats/flashcard_stats_bloc.dart';

// Courses imports
import 'features/courses/presentation/pages/courses_page.dart';
import 'features/courses/presentation/pages/course_detail_page.dart';
import 'features/courses/presentation/pages/course_learning_page.dart';
import 'features/courses/presentation/pages/video_player_page.dart';
import 'features/courses/presentation/pages/lesson_detail_page.dart';
import 'features/courses/presentation/pages/pdf_viewer_page.dart';
import 'features/courses/presentation/pages/subscriptions_page.dart';
import 'features/courses/presentation/pages/payment_receipt_page.dart';
import 'features/courses/presentation/pages/my_receipts_page.dart';
import 'features/courses/presentation/bloc/subscription/subscription_bloc.dart';
import 'features/courses/domain/entities/course_lesson_entity.dart';
import 'features/courses/domain/entities/lesson_attachment_entity.dart';
import 'features/courses/domain/entities/subscription_package_entity.dart';

/// Application router configuration
class AppRouter {
  final AuthBloc authBloc;
  final String? initialRoute;

  AppRouter({required this.authBloc, this.initialRoute});

  late final GoRouter router = GoRouter(
    initialLocation: initialRoute ?? '/splash',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    errorBuilder: (context, state) {
      // Handle unknown routes by redirecting to home
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          GoRouter.of(context).go('/home');
        }
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    },
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplash = state.matchedLocation == '/splash';
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isUpdateRequired = state.matchedLocation == '/update-required';
      final isAcademicSelection =
          state.matchedLocation == '/auth/academic-selection';

      // Allow splash screen and update-required page always (no auth needed)
      if (isSplash || isUpdateRequired) return null;

      // If authenticated
      if (authState is Authenticated) {
        final user = authState.user;

        // Check if user has completed academic profile
        final hasAcademicProfile =
            user.academicProfile != null &&
            user.academicProfile!.phaseId != null &&
            user.academicProfile!.yearId != null &&
            user.academicProfile!.streamId != null;

        // If no academic profile, redirect to selection (first time after login/register)
        if (!hasAcademicProfile && !isAcademicSelection) {
          return '/auth/academic-selection';
        }

        // If has academic profile and on auth/onboarding pages, go to home
        if (hasAcademicProfile &&
            (isAuthRoute || isOnboarding) &&
            !isAcademicSelection) {
          return '/home';
        }
      }

      // If not authenticated, redirect to login from protected pages
      if (authState is Unauthenticated &&
          !isAuthRoute &&
          !isSplash &&
          !isOnboarding) {
        return '/auth/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/update-required',
        name: 'update-required',
        builder: (context, state) {
          final storeUrl = state.extra as String?;
          return UpdateRequiredPage(storeUrl: storeUrl);
        },
      ),
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/auth/academic-selection',
        name: 'academic-selection',
        builder: (context, state) {
          // Check if coming from profile page (edit mode)
          final isEditMode = state.extra as bool? ?? false;
          return AcademicSelectionPage(isEditMode: isEditMode);
        },
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    sl<HomeBloc>()..add(const DashboardLoadRequested()),
              ),
              BlocProvider(
                create: (context) =>
                    sl<QuizListBloc>()
                      ..add(const LoadRecommendations(limit: 3)),
              ),
              BlocProvider(
                create: (context) =>
                    sl<CoursesBloc>()..add(const LoadAllCoursesDataEvent()),
              ),
            ],
            child: const MainScreen(),
          );
        },
      ),
      // Redirect /dashboard to /home (legacy route handling)
      GoRoute(
        path: '/dashboard',
        redirect: (context, state) => '/home',
      ),
      // Content Library Routes
      GoRoute(
        path: '/subjects-list',
        name: 'subjects-list',
        builder: (context, state) {
          // Create repository and bloc for SubjectsListPage
          final dio = sl<Dio>();
          final dataSource = ContentLibraryRemoteDataSource(dio: dio);
          final repository = ContentLibraryRepositoryImpl(
            remoteDataSource: dataSource,
          );

          return BlocProvider(
            create: (context) => SubjectsBloc(repository: repository),
            child: const SubjectsListPage(),
          );
        },
      ),
      GoRoute(
        path: '/subject/:id',
        name: 'subject-detail',
        builder: (context, state) {
          final subjectId = int.parse(state.pathParameters['id']!);
          final subjectFromExtra = state.extra as SubjectEntity?;

          // Create repository and bloc for SubjectDetailPage
          final dio = sl<Dio>();
          final dataSource = ContentLibraryRemoteDataSource(dio: dio);
          final repository = ContentLibraryRepositoryImpl(
            remoteDataSource: dataSource,
          );

          // If subject is passed, only load contents (1 API call)
          // Otherwise fallback to loading subject first (2+ API calls)
          if (subjectFromExtra != null) {
            return BlocProvider(
              create: (context) =>
                  SubjectDetailBloc(repository: repository)
                    ..add(LoadSubjectContents(subjectFromExtra)),
              child: _SubjectDetailWrapperOptimized(subject: subjectFromExtra),
            );
          }

          return BlocProvider(
            create: (context) =>
                SubjectDetailBloc(repository: repository)
                  ..add(LoadSubjectDetail(subjectId)),
            child: _SubjectDetailWrapper(subjectId: subjectId),
          );
        },
      ),
      // BAC Routes
      GoRoute(
        path: '/bac-archives',
        name: 'bac-archives',
        builder: (context, state) => const BacArchivesPage(),
      ),
      GoRoute(
        path: '/bac-archives-by-year',
        name: 'bac-archives-by-year',
        builder: (context, state) => const BacArchivesByYearPage(),
      ),
      GoRoute(
        path: '/bac-years-by-subject',
        name: 'bac-years-by-subject',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BacYearsBySubjectPage(
            subjectId: extra['subjectId'] as int,
            subjectSlug: extra['subjectSlug'] as String,
            subjectName: extra['subjectName'] as String,
            subjectColor: extra['color'] as Color?,
          );
        },
      ),
      GoRoute(
        path: '/bac-subject-exams',
        name: 'bac-subject-exams',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BacExamsBySubjectPage(
            subjectId: extra['subjectId'] as int,
            subjectSlug: extra['subjectSlug'] as String,
            subjectName: extra['subjectName'] as String,
            yearSlug: extra['yearSlug'] as String,
            yearName: extra['yearName'] as String,
            subjectColor: extra['color'] as Color?,
          );
        },
      ),
      GoRoute(
        path: '/bac-subject-detail',
        name: 'bac-subject-detail',
        builder: (context, state) {
          final subject = state.extra as BacSubjectEntity;
          return BacSubjectDetailPage(subject: subject);
        },
      ),
      GoRoute(
        path: '/bac-simulation',
        name: 'bac-simulation',
        builder: (context, state) => const BacSimulationPage(),
      ),
      GoRoute(
        path: '/bac-results',
        name: 'bac-results',
        builder: (context, state) => const BacResultsPage(),
      ),
      GoRoute(
        path: '/bac-performance',
        name: 'bac-performance',
        builder: (context, state) {
          final subject = state.extra as BacSubjectEntity?;
          return BlocProvider.value(
            value: sl<BacBloc>(),
            child: BacPerformancePage(subject: subject),
          );
        },
      ),

      // BAC Study Schedule Routes (98-day planner)
      GoRoute(
        path: '/bac-study-schedule',
        name: 'bac-study-schedule',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final streamId = extra?['streamId'] as int? ?? 0;
          return BacStudyMainPage(streamId: streamId);
        },
      ),
      GoRoute(
        path: '/bac-study-schedule/day/:dayNumber',
        name: 'bac-study-day',
        builder: (context, state) {
          final dayNumber = int.parse(state.pathParameters['dayNumber']!);
          final extra = state.extra as Map<String, dynamic>?;
          final streamId = extra?['streamId'] as int? ?? 0;
          return BacDayDetailPage(
            streamId: streamId,
            dayNumber: dayNumber,
          );
        },
      ),
      GoRoute(
        path: '/bac-study-schedule/rewards',
        name: 'bac-study-rewards',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final streamId = extra?['streamId'] as int? ?? 0;
          return BacRewardsPage(streamId: streamId);
        },
      ),

      // Quiz Routes
      GoRoute(
        path: '/quiz',
        name: 'quiz-list',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => sl<QuizListBloc>(),
            child: const QuizListPage(),
          );
        },
      ),
      GoRoute(
        path: '/quiz/subject/:id',
        name: 'subject-quizzes',
        builder: (context, state) {
          final subjectId = int.parse(state.pathParameters['id']!);
          final extra = state.extra as Map<String, dynamic>?;

          // If full data is provided, use it
          if (extra != null && extra['subject'] != null && extra['quizzes'] != null) {
            final subject = extra['subject'] as SubjectInfo;
            final quizzes = extra['quizzes'] as List<QuizEntity>;
            return SubjectQuizzesPage(
              subject: subject,
              quizzes: quizzes,
            );
          }

          // Otherwise, use BLoC to fetch quizzes by subject ID
          final subjectName = extra?['subjectName'] as String? ?? 'الاختبارات';
          return BlocProvider(
            create: (context) => sl<QuizListBloc>()..add(LoadSubjectQuizzes(
              subjectId: subjectId,
              subjectName: subjectName,
            )),
            child: _SubjectQuizzesWrapper(
              subjectId: subjectId,
              subjectName: subjectName,
            ),
          );
        },
      ),
      GoRoute(
        path: '/quiz/:id',
        name: 'quiz-detail',
        builder: (context, state) {
          final quizId = int.parse(state.pathParameters['id']!);
          return BlocProvider(
            create: (context) => sl<QuizDetailBloc>(),
            child: QuizDetailPage(quizId: quizId),
          );
        },
      ),
      GoRoute(
        path: '/quiz/attempt/:id',
        name: 'quiz-taking',
        builder: (context, state) {
          final attemptId = int.parse(state.pathParameters['id']!);
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => sl<QuizAttemptBloc>()),
              BlocProvider(create: (context) => sl<QuizTimerCubit>()),
            ],
            child: QuizTakingPage(attemptId: attemptId),
          );
        },
      ),
      GoRoute(
        path: '/quiz/results/:id',
        name: 'quiz-results',
        builder: (context, state) {
          final attemptId = int.parse(state.pathParameters['id']!);
          return BlocProvider(
            create: (context) => sl<QuizResultsBloc>(),
            child: QuizResultsPage(attemptId: attemptId),
          );
        },
      ),
      GoRoute(
        path: '/quiz/review/:id',
        name: 'quiz-review',
        builder: (context, state) {
          final attemptId = int.parse(state.pathParameters['id']!);
          return BlocProvider(
            create: (context) => sl<QuizResultsBloc>(),
            child: QuizReviewPage(attemptId: attemptId),
          );
        },
      ),

      // Flashcards Routes
      GoRoute(
        path: '/flashcards',
        name: 'flashcards',
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => sl<DecksBloc>()),
              BlocProvider(create: (context) => sl<FlashcardStatsBloc>()),
            ],
            child: const DecksListPage(),
          );
        },
      ),
      GoRoute(
        path: '/flashcards/stats',
        name: 'flashcard-stats',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => sl<FlashcardStatsBloc>(),
            child: const FlashcardStatsPage(),
          );
        },
      ),
      GoRoute(
        path: '/flashcards/:id',
        name: 'flashcard-deck-detail',
        builder: (context, state) {
          final deckId = int.parse(state.pathParameters['id']!);
          return BlocProvider(
            create: (context) => sl<DecksBloc>(),
            child: DeckDetailPage(deckId: deckId),
          );
        },
      ),
      GoRoute(
        path: '/flashcards/:id/review',
        name: 'flashcard-review',
        builder: (context, state) {
          final deckId = int.parse(state.pathParameters['id']!);
          final cardLimit = state.uri.queryParameters['limit'] != null
              ? int.tryParse(state.uri.queryParameters['limit']!)
              : null;
          final shuffle = state.uri.queryParameters['shuffle'] == 'true';
          final browseMode = state.uri.queryParameters['mode'] == 'browse';

          return BlocProvider(
            create: (context) => sl<ReviewBloc>(),
            child: ReviewPage(
              deckId: deckId,
              cardLimit: cardLimit,
              shuffle: shuffle,
              browseMode: browseMode,
            ),
          );
        },
      ),
      GoRoute(
        path: '/flashcards/:id/summary',
        name: 'flashcard-review-summary',
        builder: (context, state) {
          final deckId = int.parse(state.pathParameters['id']!);
          final result = state.extra as ReviewCompleted?;

          if (result == null) {
            // If no result provided, redirect to deck detail
            return BlocProvider(
              create: (context) => sl<DecksBloc>(),
              child: DeckDetailPage(deckId: deckId),
            );
          }

          return ReviewSummaryPage(
            result: result,
            deckId: deckId,
          );
        },
      ),

      // Leaderboard Route
      GoRoute(
        path: '/leaderboard/:subjectId',
        name: 'leaderboard',
        builder: (context, state) {
          final subjectId = int.parse(state.pathParameters['subjectId']!);
          final extra = state.extra as Map<String, dynamic>?;
          final subjectName = extra?['subjectName'] as String? ?? 'المادة';
          final subjectColor = extra?['subjectColor'] as String?;

          return BlocProvider(
            create: (context) => sl<LeaderboardBloc>(),
            child: LeaderboardPage(
              subjectId: subjectId,
              subjectName: subjectName,
              subjectColor: subjectColor,
            ),
          );
        },
      ),

      // Planner Shell Route with Bottom Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return PlannerShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Schedule Tab (الجدول)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/planner',
                name: 'planner',
                builder: (context, state) {
                  // Always load today's schedule when navigating to planner
                  sl<PlannerBloc>().add(const LoadTodaysScheduleEvent());
                  return BlocProvider.value(
                    value: sl<PlannerBloc>(),
                    child: const PlannerMainScreen(),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'today',
                    name: 'planner-today',
                    builder: (context, state) {
                      return BlocProvider.value(
                        value: sl<PlannerBloc>(),
                        child: const TodayViewScreen(),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'week',
                    name: 'planner-week',
                    builder: (context, state) {
                      return BlocProvider.value(
                        value: sl<PlannerBloc>(),
                        child: const WeekViewScreen(),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'history',
                    name: 'planner-history',
                    builder: (context, state) {
                      return BlocProvider(
                        create: (context) => sl<SessionHistoryCubit>(),
                        child: const SessionHistoryScreen(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 1: Subjects Tab (المواد)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/planner/subjects',
                name: 'planner-subjects',
                builder: (context, state) {
                  return BlocProvider(
                    create: (context) => sl<planner_subjects.SubjectsBloc>(),
                    child: const SubjectsPage(),
                  );
                },
              ),
            ],
          ),

          // Branch 2: Exams Tab (الاختبارات)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/planner/exams',
                name: 'planner-exams',
                builder: (context, state) {
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider<ExamsBloc>(
                        create: (context) => sl<ExamsBloc>(),
                      ),
                      BlocProvider<planner_subjects.SubjectsBloc>(
                        create: (context) => sl<planner_subjects.SubjectsBloc>(),
                      ),
                    ],
                    child: const ExamsPage(),
                  );
                },
              ),
            ],
          ),

          // Branch 3: Analytics Tab (التحليلات)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/planner/analytics',
                name: 'planner-analytics',
                builder: (context, state) {
                  return BlocProvider(
                    create: (context) => sl<PlannerAnalyticsBloc>(),
                    child: const AnalyticsDashboardScreen(),
                  );
                },
              ),
            ],
          ),
        ],
      ),

      // Separate Planner Routes (Outside Shell)
      GoRoute(
        path: '/planner/settings',
        name: 'planner-settings',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<planner_settings.SettingsCubit>()..loadSettings(),
          child: const PlannerSettingsPage(),
        ),
      ),
      GoRoute(
        path: '/planner/statistics',
        name: 'planner-statistics',
        builder: (context, state) => BlocProvider.value(
          value: sl<PlannerBloc>(),
          child: const ScheduleStatisticsScreen(),
        ),
      ),
      GoRoute(
        path: '/planner/wizard',
        name: 'planner-wizard',
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<PlannerBloc>()),
              BlocProvider(create: (context) => sl<planner_subjects.SubjectsBloc>()),
              BlocProvider(create: (context) => sl<planner_settings.SettingsCubit>()),
            ],
            child: const ScheduleWizardScreen(),
          );
        },
      ),
      // Session Detail Route
      GoRoute(
        path: '/planner/session/:id',
        name: 'planner-session-detail',
        builder: (context, state) {
          final sessionId = state.pathParameters['id'];
          final extra = state.extra;
          StudySession? session;

          // Handle both StudySession passed via extra and notification deep link
          if (extra is StudySession) {
            session = extra;
          } else if (sessionId != null) {
            // Load session from BLoC state for notification deep linking
            final plannerBloc = sl<PlannerBloc>();
            final currentState = plannerBloc.state;

            if (currentState is ScheduleLoaded) {
              try {
                session = currentState.sessions.firstWhere(
                  (s) => s.id == sessionId,
                );
              } catch (e) {
                // Session not found, navigate to planner
                Future.microtask(() => context.go('/planner'));
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            } else {
              // State not loaded, load it first
              plannerBloc.add(const LoadTodaysScheduleEvent());
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          } else if (extra != null) {
            // If it's a StudySessionEntity or other type, navigate to planner
            Future.microtask(() => context.go('/planner'));
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (session == null) {
            // Navigate back to planner if session is null
            Future.microtask(() => context.go('/planner'));
            return const Scaffold(
              body: Center(
                child: Text('جلسة غير صالحة', style: TextStyle(fontFamily: 'Cairo')),
              ),
            );
          }

          // Session loaded successfully
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<PlannerBloc>()),
              BlocProvider.value(value: sl<SessionTimerCubit>()),
            ],
            child: SessionDetailScreen(session: session!),
          );
        },
      ),
      GoRoute(
        path: '/planner/session/:id/active',
        name: 'planner-session-active',
        builder: (context, state) {
          final session = state.extra as StudySession?;
          if (session == null) {
            // Navigate back to planner if session is null
            Future.microtask(() => context.go('/planner'));
            return const Scaffold(
              body: Center(
                child: Text('جلسة غير صالحة', style: TextStyle(fontFamily: 'Cairo')),
              ),
            );
          }
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<PlannerBloc>()),
              BlocProvider.value(value: sl<SessionTimerCubit>()),
            ],
            child: ActiveSessionScreen(session: session),
          );
        },
      ),

      // Profile Routes
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => BlocProvider(
          create: (context) => sl<ProfileBloc>()..add(LoadProfile()),
          child: const ProfilePage(),
        ),
        routes: [
          GoRoute(
            path: 'edit',
            name: 'profile-edit',
            builder: (context, state) {
              return BlocProvider(
                create: (context) => sl<ProfileBloc>()..add(const RefreshProfile()),
                child: const EditProfilePage(),
              );
            },
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => BlocProvider(
              create: (context) => sl<profile_settings.SettingsCubit>()..loadSettings(),
              child: const SettingsPage(),
            ),
            routes: [
              GoRoute(
                path: 'tab-order',
                name: 'tab-order-settings',
                builder: (context, state) => const TabOrderSettingsPage(),
              ),
            ],
          ),
          GoRoute(
            path: 'change-password',
            name: 'change-password',
            builder: (context, state) => BlocProvider.value(
              value: context.read<ProfileBloc>(),
              child: const ChangePasswordPage(),
            ),
          ),
        ],
      ),

      // Notifications Route
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => BlocProvider.value(
          value: sl<NotificationsBloc>()..add(const LoadNotifications()),
          child: const NotificationsPage(),
        ),
      ),

      // User Manual Route
      GoRoute(
        path: '/user-manual',
        name: 'user-manual',
        builder: (context, state) => const UserManualPage(),
      ),

      // Courses Routes
      GoRoute(
        path: '/courses',
        name: 'courses',
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [BlocProvider(create: (context) => sl<CoursesBloc>())],
            child: const CoursesPage(),
          );
        },
      ),
      GoRoute(
        path: '/courses/:id',
        name: 'course-detail',
        builder: (context, state) {
          final courseId = int.parse(state.pathParameters['id']!);
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => sl<CoursesBloc>()),
              BlocProvider(create: (context) => sl<SubscriptionBloc>()),
            ],
            child: CourseDetailPage(courseId: courseId),
          );
        },
      ),
      GoRoute(
        path: '/courses/:id/learn',
        name: 'course-learning',
        builder: (context, state) {
          final courseId = int.parse(state.pathParameters['id']!);
          return BlocProvider(
            create: (context) => sl<CoursesBloc>()
              ..add(LoadCourseDetailsEvent(courseId: courseId))
              ..add(LoadCourseModulesEvent(courseId: courseId)),
            child: CourseLearningPage(courseId: courseId),
          );
        },
      ),
      // Lesson detail page with video, attachments, and quiz
      GoRoute(
        path: '/courses/:courseId/lessons/:lessonId',
        name: 'lesson-detail',
        builder: (context, state) {
          final courseId = int.parse(state.pathParameters['courseId']!);
          final lessonId = int.parse(state.pathParameters['lessonId']!);
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => sl<CoursesBloc>()),
            ],
            child: LessonDetailPage(courseId: courseId, lessonId: lessonId),
          );
        },
      ),
      // PDF viewer page
      GoRoute(
        path: '/pdf-viewer',
        name: 'pdf-viewer',
        builder: (context, state) {
          final attachment = state.extra as LessonAttachmentEntity;
          return PdfViewerPage(attachment: attachment);
        },
      ),
      GoRoute(
        path: '/courses/video/:lessonId',
        name: 'video-player',
        builder: (context, state) {
          final lesson = state.extra as CourseLessonEntity;
          final playlistLessons =
              state.uri.queryParameters['hasPlaylist'] == 'true'
              ? (state.uri.queryParameters['playlist']
                    as List<CourseLessonEntity>?)
              : null;

          // VideoPlayerPage now uses the unified videoplayer feature
          // which handles its own bloc internally
          return VideoPlayerPage(
            lesson: lesson,
            playlistLessons: playlistLessons,
          );
        },
      ),
      GoRoute(
        path: '/subscriptions',
        name: 'subscriptions',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => sl<SubscriptionBloc>(),
            child: const SubscriptionsPage(),
          );
        },
      ),
      GoRoute(
        path: '/payment-receipt',
        name: 'payment-receipt',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final package = args['package'] as SubscriptionPackageEntity?;
          final courseId = args['courseId'] as int?;
          final paymentMethod = args['paymentMethod'] as String;

          return BlocProvider(
            create: (context) => sl<SubscriptionBloc>(),
            child: PaymentReceiptPage(
              package: package,
              courseId: courseId,
              paymentMethod: paymentMethod,
            ),
          );
        },
      ),
      GoRoute(
        path: '/my-receipts',
        name: 'my-receipts',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => sl<SubscriptionBloc>(),
            child: const MyReceiptsPage(),
          );
        },
      ),
    ],
  );
}

/// Helper class to refresh router based on auth stream
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _subscription;

  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Optimized wrapper - subject already available, only waits for contents
class _SubjectDetailWrapperOptimized extends StatelessWidget {
  final SubjectEntity subject;

  const _SubjectDetailWrapperOptimized({required this.subject});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubjectDetailBloc, SubjectDetailState>(
      builder: (context, state) {
        if (state is SubjectDetailLoading || state is SubjectDetailInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is SubjectDetailError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'خطأ: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SubjectDetailBloc>().add(
                        LoadSubjectContents(subject),
                      );
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is SubjectContentsLoaded) {
          return SubjectDetailPage(subject: state.subject);
        }

        return const Scaffold(body: Center(child: Text('حالة غير معروفة')));
      },
    );
  }
}

/// Wrapper widget to load subject details and pass to SubjectDetailPage (fallback)
class _SubjectDetailWrapper extends StatefulWidget {
  final int subjectId;

  const _SubjectDetailWrapper({required this.subjectId});

  @override
  State<_SubjectDetailWrapper> createState() => _SubjectDetailWrapperState();
}

class _SubjectDetailWrapperState extends State<_SubjectDetailWrapper> {
  SubjectEntity? _cachedSubject;
  bool _contentsRequested = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubjectDetailBloc, SubjectDetailState>(
      listener: (context, state) {
        // When subject is loaded, immediately request contents
        if (state is SubjectDetailLoaded && !_contentsRequested) {
          _cachedSubject = state.subject;
          _contentsRequested = true;
          context.read<SubjectDetailBloc>().add(LoadSubjectContents(state.subject));
        }
      },
      builder: (context, state) {
        if (state is SubjectDetailLoading || state is SubjectDetailInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is SubjectDetailError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'خطأ: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _contentsRequested = false;
                      context.read<SubjectDetailBloc>().add(
                        LoadSubjectDetail(widget.subjectId),
                      );
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        // Show page when contents are loaded
        if (state is SubjectContentsLoaded) {
          return SubjectDetailPage(subject: state.subject);
        }

        // Still loading contents after subject loaded
        if (_cachedSubject != null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return const Scaffold(body: Center(child: Text('حالة غير معروفة')));
      },
    );
  }
}

/// Wrapper widget to load quizzes by subject ID and display them
class _SubjectQuizzesWrapper extends StatelessWidget {
  final int subjectId;
  final String subjectName;

  const _SubjectQuizzesWrapper({
    required this.subjectId,
    required this.subjectName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizListBloc, QuizListState>(
      builder: (context, state) {
        if (state is QuizListLoading || state is QuizListInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is QuizListError) {
          return Scaffold(
            appBar: AppBar(title: Text(subjectName)),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'خطأ: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<QuizListBloc>().add(LoadSubjectQuizzes(
                        subjectId: subjectId,
                        subjectName: subjectName,
                      ));
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        // Handle the new SubjectQuizzesLoaded state
        if (state is SubjectQuizzesLoaded) {
          return SubjectQuizzesPage(
            subject: state.subject,
            quizzes: state.quizzes,
          );
        }

        // Fallback for QuizListGroupedLoaded (backward compatibility)
        if (state is QuizListGroupedLoaded) {
          SubjectInfo? foundSubject;
          List<QuizEntity> quizzes = [];

          for (final entry in state.groupedQuizzes.entries) {
            if (entry.key.id == subjectId) {
              foundSubject = entry.key;
              quizzes = entry.value;
              break;
            }
          }

          if (foundSubject == null && state.groupedQuizzes.isNotEmpty) {
            for (final entry in state.groupedQuizzes.entries) {
              if (entry.value.isNotEmpty) {
                foundSubject = entry.key;
                quizzes = entry.value;
                break;
              }
            }
          }

          final subject = foundSubject ?? SubjectInfo(
            id: subjectId,
            nameAr: subjectName,
          );

          return SubjectQuizzesPage(
            subject: subject,
            quizzes: quizzes,
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(subjectName)),
          body: const Center(child: Text('لا توجد اختبارات متاحة')),
        );
      },
    );
  }
}
