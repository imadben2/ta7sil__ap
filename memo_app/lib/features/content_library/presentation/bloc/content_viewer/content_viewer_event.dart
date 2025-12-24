import 'package:equatable/equatable.dart';

/// Events for ContentViewerBloc
abstract class ContentViewerEvent extends Equatable {
  const ContentViewerEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load content details
class LoadContentDetail extends ContentViewerEvent {
  final int contentId;

  const LoadContentDetail(this.contentId);

  @override
  List<Object?> get props => [contentId];
}

/// Event to update content progress
class UpdateContentProgress extends ContentViewerEvent {
  final int contentId;
  final double progressPercentage;
  final int timeSpentMinutes;

  const UpdateContentProgress({
    required this.contentId,
    required this.progressPercentage,
    required this.timeSpentMinutes,
  });

  @override
  List<Object?> get props => [contentId, progressPercentage, timeSpentMinutes];
}

/// Event to mark content as completed
class MarkContentCompleted extends ContentViewerEvent {
  final int contentId;

  const MarkContentCompleted(this.contentId);

  @override
  List<Object?> get props => [contentId];
}

/// Event to track video progress (local only, no API call)
class TrackVideoProgress extends ContentViewerEvent {
  final double progressPercentage;
  final int timeSpentSeconds;

  const TrackVideoProgress({
    required this.progressPercentage,
    required this.timeSpentSeconds,
  });

  @override
  List<Object?> get props => [progressPercentage, timeSpentSeconds];
}

/// Event to record content view
class RecordContentView extends ContentViewerEvent {
  final int contentId;

  const RecordContentView(this.contentId);

  @override
  List<Object?> get props => [contentId];
}

/// Event to record content download
class RecordContentDownload extends ContentViewerEvent {
  final int contentId;

  const RecordContentDownload(this.contentId);

  @override
  List<Object?> get props => [contentId];
}

/// Event to auto-save progress periodically (silent, no UI feedback)
class AutoSaveProgress extends ContentViewerEvent {
  final int contentId;
  final double progressPercentage;
  final int timeSpentSeconds;

  const AutoSaveProgress({
    required this.contentId,
    required this.progressPercentage,
    required this.timeSpentSeconds,
  });

  @override
  List<Object?> get props => [contentId, progressPercentage, timeSpentSeconds];
}
