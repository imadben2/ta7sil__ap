import 'package:equatable/equatable.dart';
import '../../../domain/entities/content_entity.dart';
import '../../../domain/entities/content_progress_entity.dart';

/// States for ContentViewerBloc
abstract class ContentViewerState extends Equatable {
  const ContentViewerState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ContentViewerInitial extends ContentViewerState {
  const ContentViewerInitial();
}

/// Loading state
class ContentViewerLoading extends ContentViewerState {
  const ContentViewerLoading();
}

/// Loaded state with content details
class ContentViewerLoaded extends ContentViewerState {
  final ContentEntity content;
  final ContentProgressEntity? progress;
  final double localProgressPercentage;
  final int localTimeSpentSeconds;

  const ContentViewerLoaded({
    required this.content,
    this.progress,
    this.localProgressPercentage = 0.0,
    this.localTimeSpentSeconds = 0,
  });

  @override
  List<Object?> get props => [
    content,
    progress,
    localProgressPercentage,
    localTimeSpentSeconds,
  ];

  ContentViewerLoaded copyWith({
    ContentEntity? content,
    ContentProgressEntity? progress,
    double? localProgressPercentage,
    int? localTimeSpentSeconds,
  }) {
    return ContentViewerLoaded(
      content: content ?? this.content,
      progress: progress ?? this.progress,
      localProgressPercentage:
          localProgressPercentage ?? this.localProgressPercentage,
      localTimeSpentSeconds:
          localTimeSpentSeconds ?? this.localTimeSpentSeconds,
    );
  }
}

/// Updating progress state
class ContentViewerUpdatingProgress extends ContentViewerState {
  final ContentEntity content;
  final ContentProgressEntity? progress;
  final double localProgressPercentage;
  final int localTimeSpentSeconds;

  const ContentViewerUpdatingProgress({
    required this.content,
    this.progress,
    required this.localProgressPercentage,
    required this.localTimeSpentSeconds,
  });

  @override
  List<Object?> get props => [
    content,
    progress,
    localProgressPercentage,
    localTimeSpentSeconds,
  ];
}

/// Progress updated successfully
class ContentViewerProgressUpdated extends ContentViewerState {
  final ContentEntity content;
  final ContentProgressEntity progress;

  const ContentViewerProgressUpdated({
    required this.content,
    required this.progress,
  });

  @override
  List<Object?> get props => [content, progress];
}

/// Error state
class ContentViewerError extends ContentViewerState {
  final String message;
  final ContentEntity? content;

  const ContentViewerError(this.message, {this.content});

  @override
  List<Object?> get props => [message, content];
}
