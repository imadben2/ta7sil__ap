import 'package:equatable/equatable.dart';
import '../../domain/usecases/get_dashboard_data_usecase.dart';

/// Base class for all home states
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state when home is first created
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// State when dashboard data is being loaded
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// State when dashboard data is successfully loaded
class HomeLoaded extends HomeState {
  final DashboardData data;
  final DateTime lastUpdated;

  const HomeLoaded({required this.data, required this.lastUpdated});

  @override
  List<Object?> get props => [data, lastUpdated];

  /// Create a copy with updated data
  HomeLoaded copyWith({DashboardData? data, DateTime? lastUpdated}) {
    return HomeLoaded(
      data: data ?? this.data,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// State when there's an error loading dashboard
class HomeError extends HomeState {
  final String message;
  final DashboardData? cachedData; // Show cached data even with error

  const HomeError({required this.message, this.cachedData});

  @override
  List<Object?> get props => [message, cachedData];

  /// Check if we have cached data to show
  bool get hasCachedData => cachedData != null;
}

/// State when refreshing dashboard (show loading indicator)
class HomeRefreshing extends HomeState {
  final DashboardData currentData; // Keep showing current data while refreshing

  const HomeRefreshing(this.currentData);

  @override
  List<Object?> get props => [currentData];
}

/// State when a session action is being processed
class HomeSessionUpdating extends HomeState {
  final DashboardData currentData;
  final int sessionId;

  const HomeSessionUpdating({
    required this.currentData,
    required this.sessionId,
  });

  @override
  List<Object?> get props => [currentData, sessionId];
}
