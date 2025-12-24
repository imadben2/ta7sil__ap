import 'package:equatable/equatable.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/centralized_subject.dart';

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

/// Subjects loaded successfully
class SubjectsLoaded extends SubjectsState {
  final List<Subject> subjects;

  const SubjectsLoaded(this.subjects);

  @override
  List<Object?> get props => [subjects];
}

/// Error state
class SubjectsError extends SubjectsState {
  final String message;

  const SubjectsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Subject operation success (add/update/delete)
class SubjectOperationSuccess extends SubjectsState {
  final String message;

  const SubjectOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Centralized subjects loading
class CentralizedSubjectsLoading extends SubjectsState {
  const CentralizedSubjectsLoading();
}

/// Centralized subjects loaded successfully
class CentralizedSubjectsLoaded extends SubjectsState {
  final List<CentralizedSubject> centralizedSubjects;

  const CentralizedSubjectsLoaded(this.centralizedSubjects);

  @override
  List<Object?> get props => [centralizedSubjects];
}

/// Centralized subjects error
class CentralizedSubjectsError extends SubjectsState {
  final String message;

  const CentralizedSubjectsError(this.message);

  @override
  List<Object?> get props => [message];
}
