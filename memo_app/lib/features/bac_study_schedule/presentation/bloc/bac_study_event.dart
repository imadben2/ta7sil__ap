import 'package:equatable/equatable.dart';

/// Events for BacStudyBloc
abstract class BacStudyEvent extends Equatable {
  const BacStudyEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load user stats
class LoadBacStudyStats extends BacStudyEvent {
  final int streamId;

  const LoadBacStudyStats({required this.streamId});

  @override
  List<Object?> get props => [streamId];
}

/// Event to load a specific week's schedule
class LoadBacStudyWeek extends BacStudyEvent {
  final int streamId;
  final int weekNumber;

  const LoadBacStudyWeek({
    required this.streamId,
    required this.weekNumber,
  });

  @override
  List<Object?> get props => [streamId, weekNumber];
}

/// Event to load a specific day with progress
class LoadBacStudyDay extends BacStudyEvent {
  final int streamId;
  final int dayNumber;

  const LoadBacStudyDay({
    required this.streamId,
    required this.dayNumber,
  });

  @override
  List<Object?> get props => [streamId, dayNumber];
}

/// Event to load all weekly rewards
class LoadBacStudyRewards extends BacStudyEvent {
  final int streamId;

  const LoadBacStudyRewards({required this.streamId});

  @override
  List<Object?> get props => [streamId];
}

/// Event to mark a topic as complete/incomplete
class ToggleBacStudyTopicComplete extends BacStudyEvent {
  final int topicId;
  final bool isCompleted;
  final int streamId;
  final int dayNumber;

  const ToggleBacStudyTopicComplete({
    required this.topicId,
    required this.isCompleted,
    required this.streamId,
    required this.dayNumber,
  });

  @override
  List<Object?> get props => [topicId, isCompleted, streamId, dayNumber];
}

/// Event to change selected week
class SelectBacStudyWeek extends BacStudyEvent {
  final int weekNumber;

  const SelectBacStudyWeek({required this.weekNumber});

  @override
  List<Object?> get props => [weekNumber];
}

/// Event to refresh all data
class RefreshBacStudyData extends BacStudyEvent {
  final int streamId;

  const RefreshBacStudyData({required this.streamId});

  @override
  List<Object?> get props => [streamId];
}
