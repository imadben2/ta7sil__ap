import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz_location;
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings_ar.dart';
import 'core/storage/hive_service.dart';
import 'injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/academic_setup_bloc.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/home/presentation/bloc/sponsors/sponsors_bloc.dart';
import 'features/home/presentation/bloc/promo/promo_bloc.dart';
import 'features/bac/presentation/bloc/bac_bloc.dart';
import 'features/bac/presentation/cubit/simulation_timer_cubit.dart';
import 'features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'features/profile/presentation/bloc/settings/settings_cubit.dart';
import 'features/profile/presentation/bloc/settings/settings_state.dart';
import 'features/courses/presentation/bloc/subscription/subscription_bloc.dart';
import 'features/notifications/presentation/bloc/notifications_bloc.dart';
import 'features/notifications/presentation/bloc/notifications_event.dart';
import 'features/planner/data/local/hive_adapters/register_adapters.dart';
import 'features/planner/data/datasources/planner_sync_queue.dart';
import 'features/planner/data/services/background_sync_service.dart';
import 'features/planner/services/notification_id_manager.dart';
import 'core/services/notification_service.dart';
import 'core/services/fcm_token_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/tab_order_service.dart';
import 'core/services/app_lifecycle_observer.dart';
import 'core/video_player/domain/video_player_settings_service.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone for local scheduled notifications
  tz.initializeTimeZones();
  tz_location.setLocalLocation(tz_location.getLocation('Africa/Algiers'));
  debugPrint('[main] Timezone initialized: Africa/Algiers');

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[main] Firebase initialized successfully');
  } catch (e) {
    debugPrint('[main] Firebase initialization error: $e');
    // Continue app initialization even if Firebase fails
  }

  // Initialize dependency injection
  await di.init();

  // Initialize Hive
  await di.sl<HiveService>().init();

  // Register planner Hive adapters
  registerPlannerAdapters();

  // Open planner Hive boxes
  await openPlannerBoxes();

  // Initialize sync queue
  await di.sl<PlannerSyncQueue>().init();

  // Initialize connectivity service
  await di.sl<ConnectivityService>().init();

  // Initialize background sync service
  await di.sl<BackgroundSyncService>().init();

  // Initialize notification ID manager
  await di.sl<NotificationIdManager>().initialize();

  // Initialize notification service (includes Firebase Messaging)
  try {
    await di.sl<NotificationService>().init();
    debugPrint('[main] NotificationService initialized successfully');
  } catch (e) {
    debugPrint('[main] NotificationService initialization error: $e');
    // Continue app initialization even if NotificationService fails
  }

  // Initialize FCM token service (device info and token refresh listener)
  try {
    await di.sl<FcmTokenService>().init();
    debugPrint('[main] FcmTokenService initialized successfully');
  } catch (e) {
    debugPrint('[main] FcmTokenService initialization error: $e');
    // Continue app initialization even if FcmTokenService fails
  }

  // Open Profile-related Hive boxes
  await Hive.openBox('profile_cache');
  await Hive.openBox('statistics_cache');
  await Hive.openBox('settings_cache');

  // Initialize tab order service (loads saved preferences from Hive)
  await di.sl<TabOrderService>().init();

  // Initialize video player settings service (loads cached settings from Hive)
  await VideoPlayerSettingsService().initialize();
  debugPrint('[main] VideoPlayerSettingsService initialized');

  // Initialize app lifecycle observer (handles notification sync on app resume/midnight)
  di.sl<AppLifecycleObserver>().init();

  // Check if app was launched from notification tap
  String? initialRoute;
  try {
    final notificationDetails =
        await di.sl<NotificationService>().getNotificationAppLaunchDetails();

    if (notificationDetails?.didNotificationLaunchApp ?? false) {
      final payload = notificationDetails!.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        if (data['type'] == 'session_reminder' && data['route'] != null) {
          initialRoute = data['route'] as String;
          debugPrint('[main] App launched from notification, navigating to: $initialRoute');
        }
      }
    }
  } catch (e) {
    debugPrint('[main] Error checking notification launch details: $e');
  }

  runApp(MemoApp(initialRoute: initialRoute));
}

class MemoApp extends StatelessWidget {
  final String? initialRoute;

  const MemoApp({super.key, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    // Get AuthBloc from DI
    final authBloc = di.sl<AuthBloc>();

    // Trigger initial auth check
    authBloc.add(const AuthCheckRequested());

    // Create router with initial route from notification
    final appRouter = AppRouter(
      authBloc: authBloc,
      initialRoute: initialRoute,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider(create: (_) => di.sl<AcademicSetupBloc>()),
        BlocProvider(create: (_) => di.sl<HomeBloc>()),
        BlocProvider(create: (_) => di.sl<SponsorsBloc>()),
        BlocProvider(create: (_) => di.sl<PromoBloc>()),
        BlocProvider(create: (_) => di.sl<BacBloc>()),
        BlocProvider(create: (_) => di.sl<SimulationTimerCubit>()),
        BlocProvider(create: (_) => di.sl<ProfileBloc>()),
        BlocProvider(create: (_) => di.sl<SettingsCubit>()..loadSettings()),
        BlocProvider(create: (_) => di.sl<SubscriptionBloc>()),
        BlocProvider(create: (_) => di.sl<NotificationsBloc>()..add(const LoadNotifications())),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          // Convert theme mode string to ThemeMode enum
          final themeMode = settingsState is SettingsLoaded
              ? _convertThemeMode(settingsState.settings.themeMode)
              : ThemeMode.system;

          return MaterialApp.router(
            title: AppStringsAr.appName,
            debugShowCheckedModeBanner: false,

            // Localization
            locale: const Locale('ar', 'DZ'),
            supportedLocales: const [
              Locale('ar', 'DZ'), // Arabic (Algeria)
              Locale('ar', ''), // Arabic (generic)
              Locale('fr', 'FR'), // French
              Locale('en', 'US'), // English
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // RTL Configuration
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },

            // Theme - NOW DYNAMIC!
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,

            // Router
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}

/// Convert theme mode string to ThemeMode enum 033359
ThemeMode _convertThemeMode(String themeModeString) {
  switch (themeModeString) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}
