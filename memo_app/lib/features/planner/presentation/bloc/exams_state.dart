import 'package:equatable/equatable.dart';
import '../../domain/entities/exam.dart';

/// Base class for all exam states
abstract class ExamsState extends Equatable {
  const ExamsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class ExamsInitial extends ExamsState {
  const ExamsInitial();
}

/// Loading state while fetching exams
class ExamsLoading extends ExamsState {
  const ExamsLoading();
}

/// Exams loaded successfully
class ExamsLoaded extends ExamsState {
  final List<Exam> exams;

  const ExamsLoaded(this.exams);

  @override
  List<Object?> get props => [exams];
}

/// Error occurred while loading/modifying exams
class ExamsError extends ExamsState {
  final String message;

  const ExamsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Exam operation success (add/update/delete)
class ExamOperationSuccess extends ExamsState {
  final String message;

  const ExamOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Exam result recorded successfully
class ExamResultRecorded extends ExamsState {
  final Exam exam;
  final bool adaptationTriggered;
  final String message;

  const ExamResultRecorded({
    required this.exam,
    this.adaptationTriggered = false,
    this.message = 'تم تسجيل النتيجة بنجاح',
  });

  @override
  List<Object?> get props => [exam, adaptationTriggered, message];
}
