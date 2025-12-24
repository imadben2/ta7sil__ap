import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_all_exams.dart';
import '../../domain/usecases/get_upcoming_exams.dart';
import '../../domain/usecases/add_exam.dart';
import '../../domain/usecases/update_exam.dart';
import '../../domain/usecases/delete_exam.dart';
import '../../domain/usecases/record_exam_result.dart';
import 'exams_event.dart';
import 'exams_state.dart';

/// BLoC for managing exam state
class ExamsBloc extends Bloc<ExamsEvent, ExamsState> {
  final GetAllExams getAllExamsUseCase;
  final GetUpcomingExams getUpcomingExamsUseCase;
  final AddExam addExamUseCase;
  final UpdateExam updateExamUseCase;
  final DeleteExam deleteExamUseCase;
  final RecordExamResult recordExamResultUseCase;

  ExamsBloc({
    required this.getAllExamsUseCase,
    required this.getUpcomingExamsUseCase,
    required this.addExamUseCase,
    required this.updateExamUseCase,
    required this.deleteExamUseCase,
    required this.recordExamResultUseCase,
  }) : super(const ExamsInitial()) {
    on<LoadExamsEvent>(_onLoadExams);
    on<LoadUpcomingExamsEvent>(_onLoadUpcomingExams);
    on<LoadExamsBySubjectEvent>(_onLoadExamsBySubject);
    on<AddExamEvent>(_onAddExam);
    on<UpdateExamEvent>(_onUpdateExam);
    on<DeleteExamEvent>(_onDeleteExam);
    on<RecordExamResultEvent>(_onRecordExamResult);
  }

  Future<void> _onLoadExams(
    LoadExamsEvent event,
    Emitter<ExamsState> emit,
  ) async {
    emit(const ExamsLoading());

    final result = await getAllExamsUseCase(NoParams());

    result.fold(
      (failure) => emit(ExamsError(failure.message)),
      (exams) => emit(ExamsLoaded(exams)),
    );
  }

  Future<void> _onLoadUpcomingExams(
    LoadUpcomingExamsEvent event,
    Emitter<ExamsState> emit,
  ) async {
    emit(const ExamsLoading());

    final result = await getUpcomingExamsUseCase(NoParams());

    result.fold(
      (failure) => emit(ExamsError(failure.message)),
      (exams) => emit(ExamsLoaded(exams)),
    );
  }

  Future<void> _onLoadExamsBySubject(
    LoadExamsBySubjectEvent event,
    Emitter<ExamsState> emit,
  ) async {
    emit(const ExamsLoading());

    // Get all exams first, then filter by subject
    final result = await getAllExamsUseCase(NoParams());

    result.fold((failure) => emit(ExamsError(failure.message)), (exams) {
      final filteredExams = exams
          .where((exam) => exam.subjectId == event.subjectId)
          .toList();
      emit(ExamsLoaded(filteredExams));
    });
  }

  Future<void> _onAddExam(AddExamEvent event, Emitter<ExamsState> emit) async {
    final result = await addExamUseCase(event.exam);

    result.fold((failure) => emit(ExamsError(failure.message)), (exam) {
      emit(const ExamOperationSuccess('تمت إضافة الامتحان بنجاح'));
      // Reload exams after successful add
      add(const LoadExamsEvent());
    });
  }

  Future<void> _onUpdateExam(
    UpdateExamEvent event,
    Emitter<ExamsState> emit,
  ) async {
    final result = await updateExamUseCase(event.exam);

    result.fold((failure) => emit(ExamsError(failure.message)), (exam) {
      emit(const ExamOperationSuccess('تم تحديث الامتحان بنجاح'));
      // Reload exams after successful update
      add(const LoadExamsEvent());
    });
  }

  Future<void> _onDeleteExam(
    DeleteExamEvent event,
    Emitter<ExamsState> emit,
  ) async {
    final result = await deleteExamUseCase(event.examId);

    result.fold((failure) => emit(ExamsError(failure.message)), (_) {
      emit(const ExamOperationSuccess('تم حذف الامتحان بنجاح'));
      // Reload exams after successful delete
      add(const LoadExamsEvent());
    });
  }

  Future<void> _onRecordExamResult(
    RecordExamResultEvent event,
    Emitter<ExamsState> emit,
  ) async {
    emit(const ExamsLoading());

    final params = ExamResultParams(
      examId: event.examId,
      score: event.score,
      maxScore: event.maxScore,
      notes: event.notes,
    );

    final result = await recordExamResultUseCase(params);

    result.fold(
      (failure) => emit(ExamsError(failure.message)),
      (response) {
        emit(ExamResultRecorded(
          exam: response.exam,
          adaptationTriggered: response.adaptationTriggered,
        ));
        // Reload exams after successful result recording
        add(const LoadExamsEvent());
      },
    );
  }
}
