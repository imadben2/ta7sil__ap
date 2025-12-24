import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/content_library_repository.dart';
import 'content_viewer_event.dart';
import 'content_viewer_state.dart';

/// BLoC for managing content viewer page
class ContentViewerBloc extends Bloc<ContentViewerEvent, ContentViewerState> {
  final ContentLibraryRepository repository;

  ContentViewerBloc({required this.repository})
    : super(const ContentViewerInitial()) {
    on<LoadContentDetail>(_onLoadContentDetail);
    on<UpdateContentProgress>(_onUpdateContentProgress);
    on<MarkContentCompleted>(_onMarkContentCompleted);
    on<TrackVideoProgress>(_onTrackVideoProgress);
    on<RecordContentView>(_onRecordContentView);
    on<RecordContentDownload>(_onRecordContentDownload);
    on<AutoSaveProgress>(_onAutoSaveProgress);
  }

  Future<void> _onLoadContentDetail(
    LoadContentDetail event,
    Emitter<ContentViewerState> emit,
  ) async {
    print('🔵 BLOC: LoadContentDetail received for content ${event.contentId}');
    emit(const ContentViewerLoading());

    // Load content details
    final contentResult = await repository.getContentById(event.contentId);

    await contentResult.fold(
      (failure) async {
        print('❌ BLOC: Failed to load content: ${failure.message}');
        emit(ContentViewerError(failure.message));
      },
      (content) async {
        print('✅ BLOC: Content loaded successfully: ${content.titleAr}');
        // Try to load progress (may not be implemented yet)
        final progressResult = await repository.getContentProgress(
          event.contentId,
        );

        progressResult.fold(
          (failure) {
            print('⚠️ BLOC: Failed to load progress, continuing without it');
            // If progress loading fails, just show content without progress
            emit(ContentViewerLoaded(content: content));
            print('✅ BLOC: State changed to ContentViewerLoaded');
          },
          (progress) {
            print('✅ BLOC: Progress loaded: ${progress.progressPercentage}%');
            emit(ContentViewerLoaded(content: content, progress: progress));
            print('✅ BLOC: State changed to ContentViewerLoaded with progress');
          },
        );
      },
    );
  }

  Future<void> _onUpdateContentProgress(
    UpdateContentProgress event,
    Emitter<ContentViewerState> emit,
  ) async {
    if (state is! ContentViewerLoaded) return;

    final currentState = state as ContentViewerLoaded;

    // Emit updating state
    emit(
      ContentViewerUpdatingProgress(
        content: currentState.content,
        progress: currentState.progress,
        localProgressPercentage: event.progressPercentage,
        localTimeSpentSeconds: event.timeSpentMinutes * 60,
      ),
    );

    // Update progress via API
    final result = await repository.updateContentProgress(
      contentId: event.contentId,
      progressPercentage: event.progressPercentage,
      timeSpentMinutes: event.timeSpentMinutes,
    );

    result.fold(
      (failure) {
        // If update fails, return to loaded state
        emit(currentState);
      },
      (progress) {
        emit(
          ContentViewerProgressUpdated(
            content: currentState.content,
            progress: progress,
          ),
        );

        // Return to loaded state with updated progress
        emit(
          ContentViewerLoaded(
            content: currentState.content,
            progress: progress,
            localProgressPercentage: event.progressPercentage,
            localTimeSpentSeconds: event.timeSpentMinutes * 60,
          ),
        );
      },
    );
  }

  Future<void> _onMarkContentCompleted(
    MarkContentCompleted event,
    Emitter<ContentViewerState> emit,
  ) async {
    print('🔵 BLOC: _onMarkContentCompleted received for content ${event.contentId}');
    print('   Current state: ${state.runtimeType}');

    // Get current content if available from state
    final currentState = state;
    final hasLoadedContent = currentState is ContentViewerLoaded;

    print('   Has loaded content: $hasLoadedContent');

    // Mark as completed via API - this works regardless of BLoC state
    print('🔵 CONTENT_VIEWER_BLOC: Calling markContentAsCompleted for content ${event.contentId}');
    final result = await repository.markContentAsCompleted(event.contentId);

    // Store loaded state reference before fold (to avoid cast inside closures)
    final loadedState = hasLoadedContent ? (currentState as ContentViewerLoaded) : null;

    result.fold(
      (failure) {
        // If update fails, emit error state
        print('❌ CONTENT_VIEWER_BLOC: markContentAsCompleted failed: ${failure.message}');
        if (loadedState != null) {
          emit(ContentViewerError(failure.message, content: loadedState.content));
          emit(loadedState);
        } else {
          emit(ContentViewerError(failure.message));
        }
      },
      (progress) {
        print('✅ CONTENT_VIEWER_BLOC: markContentAsCompleted succeeded');
        print('   Progress data: is_completed=${progress.isCompleted}, progress=${progress.progressPercentage}');

        if (loadedState != null) {
          emit(
            ContentViewerProgressUpdated(
              content: loadedState.content,
              progress: progress,
            ),
          );

          // Return to loaded state with completed progress
          emit(
            ContentViewerLoaded(
              content: loadedState.content,
              progress: progress,
              localProgressPercentage: 100.0,
              localTimeSpentSeconds: loadedState.localTimeSpentSeconds,
            ),
          );
        } else {
          // Even without loaded content, we can emit a success indicator
          print('✅ BLOC: Progress saved to API successfully (state not loaded yet)');
        }
      },
    );
  }

  void _onTrackVideoProgress(
    TrackVideoProgress event,
    Emitter<ContentViewerState> emit,
  ) {
    if (state is! ContentViewerLoaded) return;

    final currentState = state as ContentViewerLoaded;

    // Update local progress without API call
    emit(
      currentState.copyWith(
        localProgressPercentage: event.progressPercentage,
        localTimeSpentSeconds: event.timeSpentSeconds,
      ),
    );
  }

  /// Record content view (silent, no state change)
  Future<void> _onRecordContentView(
    RecordContentView event,
    Emitter<ContentViewerState> emit,
  ) async {
    // Fire and forget - don't wait for result
    repository.recordContentView(event.contentId);
  }

  /// Record content download (silent, no state change)
  Future<void> _onRecordContentDownload(
    RecordContentDownload event,
    Emitter<ContentViewerState> emit,
  ) async {
    // Fire and forget - don't wait for result
    repository.recordContentDownload(event.contentId);
  }

  /// Auto-save progress periodically (silent, no UI feedback)
  Future<void> _onAutoSaveProgress(
    AutoSaveProgress event,
    Emitter<ContentViewerState> emit,
  ) async {
    if (state is! ContentViewerLoaded) return;

    // Silent save - no state changes, just persist to API
    await repository.updateContentProgress(
      contentId: event.contentId,
      progressPercentage: event.progressPercentage,
      timeSpentMinutes: (event.timeSpentSeconds / 60).round(),
    );
  }
}
