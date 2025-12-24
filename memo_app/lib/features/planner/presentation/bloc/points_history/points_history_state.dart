import 'package:equatable/equatable.dart';
import '../../../domain/entities/points_history.dart';

abstract class PointsHistoryState extends Equatable {
  const PointsHistoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class PointsHistoryInitial extends PointsHistoryState {
  const PointsHistoryInitial();
}

/// Loading state while fetching points history
class PointsHistoryLoading extends PointsHistoryState {
  final String? message;

  const PointsHistoryLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Successfully loaded points history
class PointsHistoryLoaded extends PointsHistoryState {
  final PointsHistory history;

  const PointsHistoryLoaded(this.history);

  /// Get daily points list
  List<DailyPoints> get dailyPoints => history.dailyPoints;

  /// Get total points
  int get totalPoints => history.totalPoints;

  /// Get current level
  int get currentLevel => history.currentLevel;

  /// Get level progress percentage
  double get levelProgress => history.levelProgress;

  /// Get points to next level
  int get pointsToNextLevel => history.pointsToNextLevel;

  /// Get period points
  int get periodPoints => history.periodPoints;

  /// Get average points per day
  double get averagePointsPerDay => history.averagePointsPerDay;

  @override
  List<Object?> get props => [history];
}

/// Error state when loading fails
class PointsHistoryError extends PointsHistoryState {
  final String message;

  const PointsHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
