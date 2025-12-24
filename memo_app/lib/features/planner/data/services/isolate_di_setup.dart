import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/hive_service.dart';
import '../datasources/planner_sync_queue.dart';
import '../datasources/planner_remote_datasource.dart';
import '../datasources/planner_local_datasource.dart';
import 'background_sync_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../local/hive_adapters/register_adapters.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';

/// Initialize dependency injection for WorkManager isolate
///
/// This is a lightweight DI setup containing only sync-related dependencies.
/// Must be called in the WorkManager isolate callback before processing sync queue.
Future<void> initIsolateDI() async {
  try {
    debugPrint('[IsolateDI] Starting initialization...');

    final sl = GetIt.instance;

    // Initialize Hive in isolate
    await Hive.initFlutter();
    debugPrint('[IsolateDI] Hive initialized');

    // Register Planner Hive adapters (needed for deserializing models)
    registerPlannerAdapters();
    debugPrint('[IsolateDI] Adapters registered');

    // Open necessary Hive boxes
    await Hive.openBox<String>(SyncQueueBoxNames.syncQueue);
    await Hive.openBox(ApiConstants.hiveBoxAuth); // For auth data
    debugPrint('[IsolateDI] Hive boxes opened');

    // Core - Storage Services
    sl.registerLazySingleton<SecureStorageService>(
      () => SecureStorageService(const FlutterSecureStorage()),
    );
    debugPrint('[IsolateDI] SecureStorageService registered');

    sl.registerLazySingleton<HiveService>(
      () => HiveService(),
    );
    debugPrint('[IsolateDI] HiveService registered');

    // Core - Network
    sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(Connectivity()),
    );
    debugPrint('[IsolateDI] NetworkInfo registered');

    // Auth - Local Data Source
    sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(
        secureStorage: sl(),
        hiveService: sl(),
      ),
    );
    debugPrint('[IsolateDI] AuthLocalDataSource registered');

    // Planner - Data Sources
    sl.registerLazySingleton<PlannerSyncQueue>(
      () => PlannerSyncQueue(),
    );
    debugPrint('[IsolateDI] PlannerSyncQueue registered');

    sl.registerLazySingleton<PlannerRemoteDataSource>(
      () => PlannerRemoteDataSourceImpl(
        dio: Dio(BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        )),
        baseUrl: ApiConstants.baseUrl,
        authLocalDataSource: sl(),
      ),
    );
    debugPrint('[IsolateDI] PlannerRemoteDataSource registered');

    sl.registerLazySingleton<PlannerLocalDataSource>(
      () => PlannerLocalDataSourceImpl(),
    );
    debugPrint('[IsolateDI] PlannerLocalDataSource registered');

    // Planner - Services
    sl.registerLazySingleton<BackgroundSyncService>(
      () => BackgroundSyncService(
        syncQueue: sl(),
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
      ),
    );
    debugPrint('[IsolateDI] BackgroundSyncService registered');

    // Initialize sync queue
    await sl<PlannerSyncQueue>().init();
    debugPrint('[IsolateDI] PlannerSyncQueue initialized');

    debugPrint('[IsolateDI] Initialization complete successfully!');
  } catch (e, stackTrace) {
    debugPrint('[IsolateDI] ERROR during initialization: $e');
    debugPrint('[IsolateDI] Stack trace: $stackTrace');
    rethrow;
  }
}

/// Cleanup DI container in isolate
///
/// Call this after WorkManager task completes to free resources
Future<void> cleanupIsolateDI() async {
  try {
    debugPrint('[IsolateDI] Starting cleanup...');

    // Close Hive boxes
    await Hive.close();
    debugPrint('[IsolateDI] Hive closed');

    // Reset GetIt instance
    await GetIt.instance.reset();
    debugPrint('[IsolateDI] GetIt reset');

    debugPrint('[IsolateDI] Cleanup complete');
  } catch (e, stackTrace) {
    debugPrint('[IsolateDI] ERROR during cleanup: $e');
    debugPrint('[IsolateDI] Stack trace: $stackTrace');
  }
}
