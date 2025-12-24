import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/content_library_remote_datasource.dart';
import '../../data/repositories/content_library_repository_impl.dart';
import '../../domain/repositories/content_library_repository.dart';
import 'subjects/subjects_bloc.dart';
import 'subject_detail/subject_detail_bloc.dart';
import 'content_viewer/content_viewer_bloc.dart';

/// Provides all BLoC providers for content library feature
class ContentLibraryProviders {
  /// Create repository instance
  static ContentLibraryRepository _createRepository(Dio dio) {
    final dataSource = ContentLibraryRemoteDataSource(dio: dio);
    return ContentLibraryRepositoryImpl(remoteDataSource: dataSource);
  }

  /// Get list of all BLoC providers
  static List<BlocProvider> getProviders(Dio dio) {
    final repository = _createRepository(dio);

    return [
      BlocProvider<SubjectsBloc>(
        create: (context) => SubjectsBloc(repository: repository),
      ),
      BlocProvider<SubjectDetailBloc>(
        create: (context) => SubjectDetailBloc(repository: repository),
      ),
      BlocProvider<ContentViewerBloc>(
        create: (context) => ContentViewerBloc(repository: repository),
      ),
    ];
  }
}
