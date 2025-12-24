import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_achievements.dart';
import '../../../../../core/usecase/usecase.dart';
import 'achievements_event.dart';
import 'achievements_state.dart';

/// BLoC for managing achievements
class AchievementsBloc extends Bloc<AchievementsEvent, AchievementsState> {
  final GetAchievements getAchievements;

  AchievementsBloc({required this.getAchievements})
      : super(const AchievementsInitial()) {
    on<LoadAchievementsEvent>(_onLoadAchievements);
    on<RefreshAchievementsEvent>(_onRefreshAchievements);
  }

  Future<void> _onLoadAchievements(
    LoadAchievementsEvent event,
    Emitter<AchievementsState> emit,
  ) async {
    emit(const AchievementsLoading(message: 'جاري تحميل الإنجازات...'));

    final result = await getAchievements(NoParams());

    result.fold(
      (failure) {
        emit(AchievementsError('فشل في تحميل الإنجازات: ${failure.message}'));
      },
      (response) {
        emit(AchievementsLoaded(response));
      },
    );
  }

  Future<void> _onRefreshAchievements(
    RefreshAchievementsEvent event,
    Emitter<AchievementsState> emit,
  ) async {
    // Keep current data visible during refresh
    final currentState = state;

    if (currentState is! AchievementsLoaded) {
      emit(const AchievementsLoading(message: 'جاري تحديث الإنجازات...'));
    }

    final result = await getAchievements(NoParams());

    result.fold(
      (failure) {
        // If refresh fails, keep showing current data with error
        if (currentState is AchievementsLoaded) {
          emit(currentState); // Keep showing data
        } else {
          emit(AchievementsError('فشل في تحديث الإنجازات: ${failure.message}'));
        }
      },
      (response) {
        emit(AchievementsLoaded(response));
      },
    );
  }
}
