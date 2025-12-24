import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../../core/network/network_info.dart';

// Data Sources
import '../data/datasources/courses_remote_datasource.dart';
import '../data/datasources/courses_local_datasource.dart';

// Repositories
import '../data/repositories/courses_repository_impl.dart';
import '../data/repositories/subscription_repository_impl.dart';
import '../domain/repositories/courses_repository.dart';
import '../domain/repositories/subscription_repository.dart';

// Use Cases - Courses
import '../domain/usecases/get_courses_usecase.dart';
import '../domain/usecases/get_featured_courses_usecase.dart';
import '../domain/usecases/get_course_details_usecase.dart';
import '../domain/usecases/get_course_modules_usecase.dart';
import '../domain/usecases/check_course_access_usecase.dart';
import '../domain/usecases/update_lesson_progress_usecase.dart';
import '../domain/usecases/get_lesson_progress_usecase.dart';
import '../domain/usecases/mark_lesson_completed_usecase.dart';
import '../domain/usecases/get_signed_video_url_usecase.dart';
import '../domain/usecases/get_my_courses_usecase.dart';
import '../domain/usecases/submit_review_usecase.dart';
import '../domain/usecases/get_course_reviews_usecase.dart';
import '../domain/usecases/generate_certificate_usecase.dart';

// Use Cases - Subscriptions
import '../domain/usecases/get_subscription_packages_usecase.dart';
import '../domain/usecases/get_my_subscriptions_usecase.dart';
import '../domain/usecases/validate_subscription_code_usecase.dart';
import '../domain/usecases/redeem_subscription_code_usecase.dart';
import '../domain/usecases/submit_receipt_usecase.dart';
import '../domain/usecases/get_my_receipts_usecase.dart';

// BLoCs
import '../presentation/bloc/courses/courses_bloc.dart';
import '../presentation/bloc/subscription/subscription_bloc.dart';

// Use the same GetIt instance from the main injection_container
final getIt = GetIt.instance;

Future<void> initCoursesInjection() async {
  // ========== Data Sources ==========

  // Remote Data Source
  getIt.registerLazySingleton<CoursesRemoteDataSource>(
    () => CoursesRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Local Data Source
  getIt.registerLazySingleton<CoursesLocalDataSource>(
    () => CoursesLocalDataSourceImpl(),
  );

  // ========== Repositories ==========

  getIt.registerLazySingleton<CoursesRepository>(
    () => CoursesRepositoryImpl(
      remoteDataSource: getIt<CoursesRemoteDataSource>(),
      localDataSource: getIt<CoursesLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      remoteDataSource: getIt<CoursesRemoteDataSource>(),
      localDataSource: getIt<CoursesLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // ========== Use Cases - Courses ==========

  getIt.registerLazySingleton(
    () => GetCoursesUseCase(getIt<CoursesRepository>()),
  );

  getIt.registerLazySingleton(
    () => GetFeaturedCoursesUseCase(getIt<CoursesRepository>()),
  );

  getIt.registerLazySingleton(
    () => GetCourseDetailsUseCase(getIt<CoursesRepository>()),
  );

  getIt.registerLazySingleton(
    () => GetCourseModulesUseCase(getIt<CoursesRepository>()),
  );

  getIt.registerLazySingleton(
    () => CheckCourseAccessUseCase(getIt<CoursesRepository>()),
  );

  getIt.registerLazySingleton(
    () => UpdateLessonProgressUseCase(getIt<CoursesRepository>()),
  );

  getIt.registerLazySingleton(
    () => GetLessonProgressUseCase(getIt<CoursesRepository>()),
  );

  getIt.registerLazySingleton(
    () => MarkLessonCompletedUseCase(getIt<CoursesRepository>()),
  );

  getIt.registerLazySingleton(
    () => GetSignedVideoUrlUseCase(getIt<CoursesRepository>()),
  );

  getIt.registerLazySingleton(
    () => GetMyCoursesUseCase(getIt<CoursesRepository>()),
  );

  getIt.registerLazySingleton(
    () => SubmitReviewUseCase(getIt<CoursesRepository>()),
  );

  getIt.registerLazySingleton(
    () => GetCourseReviewsUseCase(getIt<CoursesRepository>()),
  );

  getIt.registerLazySingleton(
    () => GenerateCertificateUseCase(getIt<CoursesRepository>()),
  );

  // ========== Use Cases - Subscriptions ==========

  getIt.registerLazySingleton(
    () => GetSubscriptionPackagesUseCase(getIt<SubscriptionRepository>()),
  );

  getIt.registerLazySingleton(
    () => GetMySubscriptionsUseCase(getIt<SubscriptionRepository>()),
  );

  getIt.registerLazySingleton(
    () => ValidateSubscriptionCodeUseCase(getIt<SubscriptionRepository>()),
  );

  getIt.registerLazySingleton(
    () => RedeemSubscriptionCodeUseCase(getIt<SubscriptionRepository>()),
  );

  getIt.registerLazySingleton(
    () => SubmitReceiptUseCase(getIt<SubscriptionRepository>()),
  );

  getIt.registerLazySingleton(
    () => GetMyReceiptsUseCase(getIt<SubscriptionRepository>()),
  );

  // ========== BLoCs ==========

  // Courses BLoC (Factory - new instance per request)
  getIt.registerFactory(
    () => CoursesBloc(
      getCoursesUseCase: getIt<GetCoursesUseCase>(),
      getFeaturedCoursesUseCase: getIt<GetFeaturedCoursesUseCase>(),
      getCourseDetailsUseCase: getIt<GetCourseDetailsUseCase>(),
      getCourseModulesUseCase: getIt<GetCourseModulesUseCase>(),
      checkCourseAccessUseCase: getIt<CheckCourseAccessUseCase>(),
    ),
  );

  // Note: VideoPlayerBloc removed - video_player_page.dart now uses the
  // unified videoplayer feature which handles its own bloc internally

  // Subscription BLoC (Factory)
  getIt.registerFactory(
    () => SubscriptionBloc(
      getSubscriptionPackagesUseCase: getIt<GetSubscriptionPackagesUseCase>(),
      getMySubscriptionsUseCase: getIt<GetMySubscriptionsUseCase>(),
      validateSubscriptionCodeUseCase: getIt<ValidateSubscriptionCodeUseCase>(),
      redeemSubscriptionCodeUseCase: getIt<RedeemSubscriptionCodeUseCase>(),
      submitReceiptUseCase: getIt<SubmitReceiptUseCase>(),
      getMyReceiptsUseCase: getIt<GetMyReceiptsUseCase>(),
    ),
  );
}
