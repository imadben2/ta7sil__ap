import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/content_library_repository.dart';
import 'subjects_event.dart';
import 'subjects_state.dart';

/// BLoC for managing subjects list
class SubjectsBloc extends Bloc<SubjectsEvent, SubjectsState> {
  final ContentLibraryRepository repository;

  SubjectsBloc({required this.repository}) : super(const SubjectsInitial()) {
    on<LoadSubjects>(_onLoadSubjects);
    on<SearchSubjects>(_onSearchSubjects);
    on<RefreshSubjects>(_onRefreshSubjects);
  }

  Future<void> _onLoadSubjects(
    LoadSubjects event,
    Emitter<SubjectsState> emit,
  ) async {
    emit(const SubjectsLoading());

    final result = await repository.getSubjects(
      yearId: event.yearId,
      streamId: event.streamId,
      withContentOnly: event.withContentOnly,
    );

    result.fold(
      (failure) => emit(SubjectsError(failure.message)),
      (subjects) =>
          emit(SubjectsLoaded(subjects: subjects, filteredSubjects: subjects)),
    );
  }

  Future<void> _onSearchSubjects(
    SearchSubjects event,
    Emitter<SubjectsState> emit,
  ) async {
    if (state is SubjectsLoaded) {
      final currentState = state as SubjectsLoaded;
      final query = event.query.toLowerCase().trim();

      if (query.isEmpty) {
        emit(
          currentState.copyWith(
            filteredSubjects: currentState.subjects,
            searchQuery: '',
          ),
        );
        return;
      }

      final filtered = currentState.subjects.where((subject) {
        return subject.nameAr.toLowerCase().contains(query) ||
            (subject.nameEn?.toLowerCase().contains(query) ?? false) ||
            (subject.nameFr?.toLowerCase().contains(query) ?? false);
      }).toList();

      emit(
        currentState.copyWith(filteredSubjects: filtered, searchQuery: query),
      );
    }
  }

  Future<void> _onRefreshSubjects(
    RefreshSubjects event,
    Emitter<SubjectsState> emit,
  ) async {
    // Keep the current state visible while refreshing
    final currentState = state;

    final result = await repository.getSubjects(
      yearId: event.yearId,
      streamId: event.streamId,
    );

    result.fold(
      (failure) {
        // If refresh fails, keep the current state and optionally show a snackbar
        if (currentState is SubjectsLoaded) {
          emit(currentState);
        } else {
          emit(SubjectsError(failure.message));
        }
      },
      (subjects) =>
          emit(SubjectsLoaded(subjects: subjects, filteredSubjects: subjects)),
    );
  }
}
