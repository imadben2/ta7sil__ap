/// BAC Feature Setup - Dependency Injection and Routing
/// This file provides all necessary setup for the BAC Archives feature
///
/// Usage:
/// 1. Add BAC dependencies to main.dart dependency injection
/// 2. Add BAC routes to app routing configuration
/// 3. Initialize Hive boxes on app startup

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'domain/usecases/get_bac_years.dart';
import 'domain/usecases/get_bac_sessions.dart';
import 'domain/usecases/get_bac_subjects.dart';
import 'domain/usecases/get_bac_chapters.dart';
import 'domain/usecases/create_simulation.dart';
import 'domain/usecases/manage_simulation.dart';
import 'domain/usecases/submit_simulation.dart';
import 'domain/usecases/get_simulation_history.dart';
import 'domain/usecases/get_simulation_results.dart';
import 'domain/usecases/get_subject_performance.dart';
import 'domain/usecases/download_exam_pdf.dart';
import 'data/datasources/bac_remote_datasource.dart';
import 'data/datasources/bac_local_datasource.dart';
import 'data/repositories/bac_repository_impl.dart';
import 'presentation/bloc/bac_bloc.dart';
import 'presentation/cubit/simulation_timer_cubit.dart';
import 'presentation/pages/bac_archives_page.dart';
import 'presentation/pages/bac_archives_by_year_page.dart';
import 'presentation/pages/bac_subject_detail_page.dart';
import 'presentation/pages/bac_simulation_page.dart';
import 'presentation/pages/bac_results_page.dart';
import 'presentation/pages/bac_performance_page.dart';
import 'domain/entities/bac_subject_entity.dart';

/// Setup BAC dependencies for dependency injection
/// Call this in main.dart
class BacDependencies {
  static late BacRemoteDataSource remoteDataSource;
  static late BacLocalDataSource localDataSource;
  static late BacRepositoryImpl repository;
  static late GetBacYears getBacYears;
  static late GetBacSessions getBacSessions;
  static late GetBacSubjects getBacSubjects;
  static late GetBacChapters getBacChapters;
  static late CreateSimulation createSimulation;
  static late StartSimulation startSimulation;
  static late PauseSimulation pauseSimulation;
  static late ResumeSimulation resumeSimulation;
  static late SubmitSimulation submitSimulation;
  static late GetSimulationHistory getSimulationHistory;
  static late GetSimulationResults getSimulationResults;
  static late GetSubjectPerformance getSubjectPerformance;
  static late DownloadExamPdf downloadExamPdf;

  static Future<void> initialize(Dio dio) async {
    // Initialize Hive boxes
    await BacLocalDataSource.initializeBoxes();

    // Data sources
    remoteDataSource = BacRemoteDataSource(dio: dio);
    localDataSource = BacLocalDataSource();

    // Repository
    repository = BacRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    // Use cases
    getBacYears = GetBacYears(repository);
    getBacSessions = GetBacSessions(repository);
    getBacSubjects = GetBacSubjects(repository);
    getBacChapters = GetBacChapters(repository);
    createSimulation = CreateSimulation(repository);
    startSimulation = StartSimulation(repository);
    pauseSimulation = PauseSimulation(repository);
    resumeSimulation = ResumeSimulation(repository);
    submitSimulation = SubmitSimulation(repository);
    getSimulationHistory = GetSimulationHistory(repository);
    getSimulationResults = GetSimulationResults(repository);
    getSubjectPerformance = GetSubjectPerformance(repository);
    downloadExamPdf = DownloadExamPdf(repository);
  }

  static Future<void> dispose() async {
    await BacLocalDataSource.closeBoxes();
  }
}

/// BLoC Providers for BAC feature
/// Wrap app with these providers
class BacProviders extends StatelessWidget {
  final Widget child;

  const BacProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BacBloc>(
          create: (_) => BacBloc(
            getBacYears: BacDependencies.getBacYears,
            getBacSessions: BacDependencies.getBacSessions,
            getBacSubjects: BacDependencies.getBacSubjects,
            getBacChapters: BacDependencies.getBacChapters,
            createSimulation: BacDependencies.createSimulation,
            startSimulation: BacDependencies.startSimulation,
            pauseSimulation: BacDependencies.pauseSimulation,
            resumeSimulation: BacDependencies.resumeSimulation,
            submitSimulation: BacDependencies.submitSimulation,
            getSimulationHistory: BacDependencies.getSimulationHistory,
            getSimulationResults: BacDependencies.getSimulationResults,
            getSubjectPerformance: BacDependencies.getSubjectPerformance,
            downloadExamPdf: BacDependencies.downloadExamPdf,
            repository: BacDependencies.repository,
          ),
        ),
        BlocProvider<SimulationTimerCubit>(
          create: (_) => SimulationTimerCubit(),
        ),
      ],
      child: child,
    );
  }
}

/// BAC Routes configuration
/// Add these routes to your MaterialApp
class BacRoutes {
  static Map<String, WidgetBuilder> get routes => {
    '/bac-archives': (context) => const BacArchivesByYearPage(),
    '/bac-archives-by-year': (context) => const BacArchivesByYearPage(),
    '/bac-subject-detail': (context) {
      final subject =
          ModalRoute.of(context)!.settings.arguments as BacSubjectEntity;
      return BacSubjectDetailPage(subject: subject);
    },
    '/bac-simulation': (context) => const BacSimulationPage(),
    '/bac-results': (context) => const BacResultsPage(),
    '/bac-performance': (context) => const BacPerformancePage(),
  };
}

/// Example usage in main.dart:
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Hive.initFlutter();
///
///   final dio = Dio();
///   await BacDependencies.initialize(dio);
///
///   runApp(
///     BacProviders(
///       child: MaterialApp(
///         routes: {
///           ...BacRoutes.routes,
///           // ... other routes
///         },
///       ),
///     ),
///   );
/// }
/// ```
