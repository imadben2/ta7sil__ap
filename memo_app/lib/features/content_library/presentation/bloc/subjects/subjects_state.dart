import 'package:equatable/equatable.dart';
import '../../../domain/entities/subject_entity.dart';

/// States for SubjectsBloc
abstract class SubjectsState extends Equatable {
  const SubjectsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SubjectsInitial extends SubjectsState {
  const SubjectsInitial();
}

/// Loading state
class SubjectsLoading extends SubjectsState {
  const SubjectsLoading();
}

/// Loaded state with subjects
class SubjectsLoaded extends SubjectsState {
  final List<SubjectEntity> subjects;
  final List<SubjectEntity> filteredSubjects;
  final String searchQuery;

  const SubjectsLoaded({
    required this.subjects,
    required this.filteredSubjects,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [subjects, filteredSubjects, searchQuery];

  SubjectsLoaded copyWith({
    List<SubjectEntity>? subjects,
    List<SubjectEntity>? filteredSubjects,
    String? searchQuery,
  }) {
    return SubjectsLoaded(
      subjects: subjects ?? this.subjects,
      filteredSubjects: filteredSubjects ?? this.filteredSubjects,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Error state
class SubjectsError extends SubjectsState {
  final String message;

  const SubjectsError(this.message);

  @override
  List<Object?> get props => [message];
}
