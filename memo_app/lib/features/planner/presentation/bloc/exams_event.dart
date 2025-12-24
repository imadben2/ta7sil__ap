import 'package:equatable/equatable.dart';
import '../../domain/entities/exam.dart';

/// Base class for all exam events
abstract class ExamsEvent extends Equatable {
  const ExamsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all exams
class LoadExamsEvent extends ExamsEvent {
  const LoadExamsEvent();
}

/// Event to load upcoming exams only
class LoadUpcomingExamsEvent extends ExamsEvent {
  const LoadUpcomingExamsEvent();
}

/// Event to load exams for a specific subject
class LoadExamsBySubjectEvent extends ExamsEvent {
  final String subjectId;

  const LoadExamsBySubjectEvent(this.subjectId);

  @override
  List<Object?> get props => [subjectId];
}

/// Event to add a new exam
class AddExamEvent extends ExamsEvent {
  final Exam exam;

  const AddExamEvent(this.exam);

  @override
  List<Object?> get props => [exam];
}

/// Event to update an existing exam
class UpdateExamEvent extends ExamsEvent {
  final Exam exam;

  const UpdateExamEvent(this.exam);

  @override
  List<Object?> get props => [exam];
}

/// Event to delete an exam
class DeleteExamEvent extends ExamsEvent {
  final String examId;

  const DeleteExamEvent(this.examId);

  @override
  List<Object?> get props => [examId];
}

/// Event to record exam result
class RecordExamResultEvent extends ExamsEvent {
  final String examId;
  final double score;
  final double maxScore;
  final String? notes;

  const RecordExamResultEvent({
    required this.examId,
    required this.score,
    required this.maxScore,
    this.notes,
  });

  @override
  List<Object?> get props => [examId, score, maxScore, notes];
}
