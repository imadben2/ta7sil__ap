import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_all_subjects.dart';
import '../../domain/usecases/add_subject.dart';
import '../../domain/usecases/update_subject.dart';
import '../../domain/usecases/delete_subject.dart';
import '../../domain/usecases/get_centralized_subjects.dart';
import 'subjects_event.dart';
import 'subjects_state.dart';

class SubjectsBloc extends Bloc<SubjectsEvent, SubjectsState> {
  final GetAllSubjects getAllSubjectsUseCase;
  final AddSubject addSubjectUseCase;
  final UpdateSubject updateSubjectUseCase;
  final DeleteSubject deleteSubjectUseCase;
  final GetCentralizedSubjects getCentralizedSubjectsUseCase;

  SubjectsBloc({
    required this.getAllSubjectsUseCase,
    required this.addSubjectUseCase,
    required this.updateSubjectUseCase,
    required this.deleteSubjectUseCase,
    required this.getCentralizedSubjectsUseCase,
  }) : super(const SubjectsInitial()) {
    on<LoadSubjectsEvent>(_onLoadSubjects);
    on<AddSubjectEvent>(_onAddSubject);
    on<UpdateSubjectEvent>(_onUpdateSubject);
    on<DeleteSubjectEvent>(_onDeleteSubject);
    on<LoadCentralizedSubjectsEvent>(_onLoadCentralizedSubjects);
  }

  Future<void> _onLoadSubjects(
    LoadSubjectsEvent event,
    Emitter<SubjectsState> emit,
  ) async {
    debugPrint('[SubjectsBloc] _onLoadSubjects called');
    emit(const SubjectsLoading());

    final result = await getAllSubjectsUseCase(NoParams());

    result.fold(
      (failure) {
        debugPrint('[SubjectsBloc] Error loading subjects: ${failure.message}');
        emit(SubjectsError(failure.message));
      },
      (subjects) {
        debugPrint('[SubjectsBloc] Loaded ${subjects.length} subjects');
        emit(SubjectsLoaded(subjects));
      },
    );
  }

  Future<void> _onAddSubject(
    AddSubjectEvent event,
    Emitter<SubjectsState> emit,
  ) async {
    final result = await addSubjectUseCase(event.subject);

    result.fold((failure) => emit(SubjectsError(failure.message)), (subject) {
      emit(const SubjectOperationSuccess('تمت إضافة المادة بنجاح'));
      // Reload subjects
      add(const LoadSubjectsEvent());
    });
  }

  Future<void> _onUpdateSubject(
    UpdateSubjectEvent event,
    Emitter<SubjectsState> emit,
  ) async {
    final result = await updateSubjectUseCase(event.subject);

    result.fold((failure) => emit(SubjectsError(failure.message)), (subject) {
      emit(const SubjectOperationSuccess('تم تحديث المادة بنجاح'));
      // Reload subjects
      add(const LoadSubjectsEvent());
    });
  }

  Future<void> _onDeleteSubject(
    DeleteSubjectEvent event,
    Emitter<SubjectsState> emit,
  ) async {
    final result = await deleteSubjectUseCase(event.subjectId);

    result.fold((failure) => emit(SubjectsError(failure.message)), (_) {
      emit(const SubjectOperationSuccess('تم حذف المادة بنجاح'));
      // Reload subjects
      add(const LoadSubjectsEvent());
    });
  }

  Future<void> _onLoadCentralizedSubjects(
    LoadCentralizedSubjectsEvent event,
    Emitter<SubjectsState> emit,
  ) async {
    emit(const CentralizedSubjectsLoading());

    final result = await getCentralizedSubjectsUseCase(event.params);

    result.fold(
      (failure) => emit(CentralizedSubjectsError(failure.message)),
      (centralizedSubjects) =>
          emit(CentralizedSubjectsLoaded(centralizedSubjects)),
    );
  }
}
