import 'package:equatable/equatable.dart';
import '../../domain/entities/bac_study_day.dart';
import '../../domain/entities/bac_weekly_reward.dart';
import '../../domain/entities/bac_user_stats.dart';
import '../../domain/repositories/bac_study_repository.dart';

/// States for BacStudyBloc
abstract class BacStudyState extends Equatable {
  const BacStudyState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BacStudyInitial extends BacStudyState {
  const BacStudyInitial();
}

/// Loading state
class BacStudyLoading extends BacStudyState {
  const BacStudyLoading();
}

/// Main loaded state with all data
class BacStudyLoaded extends BacStudyState {
  final BacUserStats stats;
  final int selectedWeek;
  final BacWeekScheduleData? currentWeekData;
  final List<BacWeeklyReward> rewards;
  final bool isLoadingWeek;
  final String? weekLoadError;

  const BacStudyLoaded({
    required this.stats,
    this.selectedWeek = 1,
    this.currentWeekData,
    this.rewards = const [],
    this.isLoadingWeek = false,
    this.weekLoadError,
  });

  @override
  List<Object?> get props => [
        stats,
        selectedWeek,
        currentWeekData,
        rewards,
        isLoadingWeek,
        weekLoadError,
      ];

  BacStudyLoaded copyWith({
    BacUserStats? stats,
    int? selectedWeek,
    BacWeekScheduleData? currentWeekData,
    List<BacWeeklyReward>? rewards,
    bool? isLoadingWeek,
    String? weekLoadError,
  }) {
    return BacStudyLoaded(
      stats: stats ?? this.stats,
      selectedWeek: selectedWeek ?? this.selectedWeek,
      currentWeekData: currentWeekData ?? this.currentWeekData,
      rewards: rewards ?? this.rewards,
      isLoadingWeek: isLoadingWeek ?? this.isLoadingWeek,
      weekLoadError: weekLoadError,
    );
  }
}

/// Day detail state
class BacStudyDayLoaded extends BacStudyState {
  final BacStudyDay day;
  final BacUserStats? stats;
  final bool isUpdating;

  const BacStudyDayLoaded({
    required this.day,
    this.stats,
    this.isUpdating = false,
  });

  @override
  List<Object?> get props => [day, stats, isUpdating];

  BacStudyDayLoaded copyWith({
    BacStudyDay? day,
    BacUserStats? stats,
    bool? isUpdating,
  }) {
    return BacStudyDayLoaded(
      day: day ?? this.day,
      stats: stats ?? this.stats,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

/// Rewards list state
class BacStudyRewardsLoaded extends BacStudyState {
  final List<BacWeeklyReward> rewards;
  final BacUserStats? stats;

  const BacStudyRewardsLoaded({
    required this.rewards,
    this.stats,
  });

  @override
  List<Object?> get props => [rewards, stats];
}

/// Error state
class BacStudyError extends BacStudyState {
  final String message;

  const BacStudyError(this.message);

  @override
  List<Object?> get props => [message];
}
