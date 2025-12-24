import 'package:equatable/equatable.dart';

/// Events for SubjectsBloc
abstract class SubjectsEvent extends Equatable {
  const SubjectsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all subjects
class LoadSubjects extends SubjectsEvent {
  final int? yearId;
  final int? streamId;
  final bool withContentOnly;

  const LoadSubjects({
    this.yearId,
    this.streamId,
    this.withContentOnly = true,
  });

  @override
  List<Object?> get props => [yearId, streamId, withContentOnly];
}

/// Event to search subjects by query
class SearchSubjects extends SubjectsEvent {
  final String query;

  const SearchSubjects(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to refresh subjects
class RefreshSubjects extends SubjectsEvent {
  final int? yearId;
  final int? streamId;

  const RefreshSubjects({this.yearId, this.streamId});

  @override
  List<Object?> get props => [yearId, streamId];
}
