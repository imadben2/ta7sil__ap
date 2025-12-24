import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/academic_entities.dart';
import '../../domain/usecases/get_academic_phases_usecase.dart';
import '../../domain/usecases/get_academic_years_usecase.dart';
import '../../domain/usecases/get_academic_streams_usecase.dart';
import '../../domain/usecases/update_academic_profile_usecase.dart';
import 'academic_setup_event.dart';
import 'academic_setup_state.dart';

/// BLoC for managing academic setup wizard
class AcademicSetupBloc extends Bloc<AcademicSetupEvent, AcademicSetupState> {
  final GetAcademicPhasesUseCase getAcademicPhasesUseCase;
  final GetAcademicYearsUseCase getAcademicYearsUseCase;
  final GetAcademicStreamsUseCase getAcademicStreamsUseCase;
  final UpdateAcademicProfileUseCase updateAcademicProfileUseCase;

  AcademicSetupBloc({
    required this.getAcademicPhasesUseCase,
    required this.getAcademicYearsUseCase,
    required this.getAcademicStreamsUseCase,
    required this.updateAcademicProfileUseCase,
  }) : super(const AcademicSetupInitial()) {
    on<LoadAcademicPhases>(_onLoadAcademicPhases);
    on<LoadAcademicYears>(_onLoadAcademicYears);
    on<LoadAcademicStreams>(_onLoadAcademicStreams);
    on<SubmitAcademicProfile>(_onSubmitAcademicProfile);
    on<ResetAcademicSetup>(_onResetAcademicSetup);
  }

  Future<void> _onLoadAcademicPhases(
    LoadAcademicPhases event,
    Emitter<AcademicSetupState> emit,
  ) async {
    print('🔵 ACADEMIC_BLOC: LoadAcademicPhases event received');
    emit(const AcademicSetupLoading());

    try {
      print('🔵 ACADEMIC_BLOC: Calling getAcademicPhasesUseCase...');
      final result = await getAcademicPhasesUseCase();

      result.fold(
        (failure) {
          print('❌ ACADEMIC_BLOC: Failed to load phases');
          print('❌ ACADEMIC_BLOC: Failure type: ${failure.runtimeType}');
          print('❌ ACADEMIC_BLOC: Failure message: ${failure.message}');
          emit(AcademicSetupError(failure.message));
        },
        (response) {
          print('✅ ACADEMIC_BLOC: Phases loaded successfully');
          print('✅ ACADEMIC_BLOC: Number of phases: ${response.phases.length}');
          for (var phase in response.phases) {
            print(
              '   Phase: id=${phase.id}, name=${phase.nameAr}, slug=${phase.slug}, order=${phase.order}',
            );
          }
          emit(AcademicPhasesLoaded(response.phases));
        },
      );
    } catch (e, stackTrace) {
      print('💥 ACADEMIC_BLOC: Exception caught in _onLoadAcademicPhases');
      print('💥 ACADEMIC_BLOC: Exception: $e');
      print('💥 ACADEMIC_BLOC: StackTrace: $stackTrace');
      emit(AcademicSetupError('حدث خطأ غير متوقع: $e'));
    }
  }

  Future<void> _onLoadAcademicYears(
    LoadAcademicYears event,
    Emitter<AcademicSetupState> emit,
  ) async {
    print(
      '🔵 ACADEMIC_BLOC: LoadAcademicYears event received for phaseId=${event.phaseId}',
    );
    emit(const AcademicSetupLoading());

    try {
      print('🔵 ACADEMIC_BLOC: Calling getAcademicYearsUseCase...');
      final result = await getAcademicYearsUseCase(event.phaseId);

      result.fold(
        (failure) {
          print('❌ ACADEMIC_BLOC: Failed to load years');
          print('❌ ACADEMIC_BLOC: Failure type: ${failure.runtimeType}');
          print('❌ ACADEMIC_BLOC: Failure message: ${failure.message}');
          emit(AcademicSetupError(failure.message));
        },
        (response) {
          print('✅ ACADEMIC_BLOC: Years loaded successfully');
          print(
            '✅ ACADEMIC_BLOC: Phase: id=${response.phase.id}, name=${response.phase.nameAr}',
          );
          print('✅ ACADEMIC_BLOC: Number of years: ${response.years.length}');
          for (var year in response.years) {
            print(
              '   Year: id=${year.id}, name=${year.nameAr}, level=${year.levelNumber}',
            );
          }
          emit(
            AcademicYearsLoaded(
              selectedPhase: response.phase,
              years: response.years,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      print('💥 ACADEMIC_BLOC: Exception caught in _onLoadAcademicYears');
      print('💥 ACADEMIC_BLOC: Exception: $e');
      print('💥 ACADEMIC_BLOC: StackTrace: $stackTrace');
      emit(AcademicSetupError('حدث خطأ غير متوقع: $e'));
    }
  }

  Future<void> _onLoadAcademicStreams(
    LoadAcademicStreams event,
    Emitter<AcademicSetupState> emit,
  ) async {
    print(
      '🔵 ACADEMIC_BLOC: LoadAcademicStreams event received for yearId=${event.yearId}',
    );

    // Preserve the selected phase from the previous state
    AcademicPhase? selectedPhase;
    if (state is AcademicYearsLoaded) {
      selectedPhase = (state as AcademicYearsLoaded).selectedPhase;
      print(
        '🔵 ACADEMIC_BLOC: Preserving selectedPhase from previous state: id=${selectedPhase.id}, name=${selectedPhase.nameAr}',
      );
    }

    emit(const AcademicSetupLoading());

    try {
      print('🔵 ACADEMIC_BLOC: Calling getAcademicStreamsUseCase...');
      final result = await getAcademicStreamsUseCase(event.yearId);

      result.fold(
        (failure) {
          print('❌ ACADEMIC_BLOC: Failed to load streams');
          print('❌ ACADEMIC_BLOC: Failure type: ${failure.runtimeType}');
          print('❌ ACADEMIC_BLOC: Failure message: ${failure.message}');
          emit(AcademicSetupError(failure.message));
        },
        (response) {
          print('✅ ACADEMIC_BLOC: Streams loaded successfully');
          print(
            '✅ ACADEMIC_BLOC: Year: id=${response.year.id}, name=${response.year.nameAr}',
          );
          print(
            '✅ ACADEMIC_BLOC: Number of streams: ${response.streams.length}',
          );
          for (var stream in response.streams) {
            print(
              '   Stream: id=${stream.id}, name=${stream.nameAr}, slug=${stream.slug}',
            );
          }

          // Use the phase from previous state, or create a fallback if not available
          final phase =
              selectedPhase ??
              AcademicPhase(
                id: response.year.academicPhaseId ?? 0,
                nameAr: '',
                slug: '',
                order: 0,
              );

          emit(
            AcademicStreamsLoaded(
              selectedPhase: phase,
              selectedYear: response.year,
              streams: response.streams,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      print('💥 ACADEMIC_BLOC: Exception caught in _onLoadAcademicStreams');
      print('💥 ACADEMIC_BLOC: Exception: $e');
      print('💥 ACADEMIC_BLOC: StackTrace: $stackTrace');
      emit(AcademicSetupError('حدث خطأ غير متوقع: $e'));
    }
  }

  Future<void> _onSubmitAcademicProfile(
    SubmitAcademicProfile event,
    Emitter<AcademicSetupState> emit,
  ) async {
    print('🔵 ACADEMIC_BLOC: SubmitAcademicProfile event received');
    print(
      '🔵 ACADEMIC_BLOC: phaseId=${event.phaseId}, yearId=${event.yearId}, streamId=${event.streamId}',
    );
    emit(const AcademicSetupLoading());

    try {
      print('🔵 ACADEMIC_BLOC: Calling updateAcademicProfileUseCase...');
      final result = await updateAcademicProfileUseCase(
        phaseId: event.phaseId,
        yearId: event.yearId,
        streamId: event.streamId,
      );

      result.fold(
        (failure) {
          print('❌ ACADEMIC_BLOC: Failed to update profile');
          print('❌ ACADEMIC_BLOC: Failure type: ${failure.runtimeType}');
          print('❌ ACADEMIC_BLOC: Failure message: ${failure.message}');
          emit(AcademicSetupError(failure.message));
        },
        (updatedUser) {
          print('✅ ACADEMIC_BLOC: Profile updated successfully');
          print('✅ ACADEMIC_BLOC: User now has academic profile:');
          print('   phaseId: ${updatedUser.academicProfile?.phaseId}');
          print('   yearId: ${updatedUser.academicProfile?.yearId}');
          print('   streamId: ${updatedUser.academicProfile?.streamId}');
          emit(const AcademicProfileUpdated());
        },
      );
    } catch (e, stackTrace) {
      print('💥 ACADEMIC_BLOC: Exception caught in _onSubmitAcademicProfile');
      print('💥 ACADEMIC_BLOC: Exception: $e');
      print('💥 ACADEMIC_BLOC: StackTrace: $stackTrace');
      emit(AcademicSetupError('حدث خطأ غير متوقع: $e'));
    }
  }

  Future<void> _onResetAcademicSetup(
    ResetAcademicSetup event,
    Emitter<AcademicSetupState> emit,
  ) async {
    print('🔵 ACADEMIC_BLOC: ResetAcademicSetup event received');
    emit(const AcademicSetupInitial());
  }
}
