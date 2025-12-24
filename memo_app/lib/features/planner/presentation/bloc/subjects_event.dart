import 'package:equatable/equatable.dart';
import '../../domain/entities/subject.dart';
import '../../domain/usecases/get_centralized_subjects.dart';

abstract class SubjectsEvent extends Equatable {
  const SubjectsEvent();

  @override
  List<Object?> get props => [];
}

/// Load all subjects
class LoadSubjectsEvent extends SubjectsEvent {
  const LoadSubjectsEvent();
}

/// Add a new subject
class AddSubjectEvent extends SubjectsEvent {
  final Subject subject;

  const AddSubjectEvent(this.subject);

  @override
  List<Object?> get props => [subject];
}

/// Update an existing subject
class UpdateSubjectEvent extends SubjectsEvent {
  final Subject subject;

  const UpdateSubjectEvent(this.subject);

  @override
  List<Object?> get props => [subject];
}

/// Delete a subject
class DeleteSubjectEvent extends SubjectsEvent {
  final String subjectId;

  const DeleteSubjectEvent(this.subjectId);

  @override
  List<Object?> get props => [subjectId];
}

/// Load centralized subjects from shared API
class LoadCentralizedSubjectsEvent extends SubjectsEvent {
  final GetCentralizedSubjectsParams params;

  const LoadCentralizedSubjectsEvent([
    this.params = const GetCentralizedSubjectsParams(),
  ]);

  @override
  List<Object?> get props => [params];
}
