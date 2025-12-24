import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/content_library_repository.dart';
import '../../../domain/entities/content_entity.dart';
import 'subject_detail_event.dart';
import 'subject_detail_state.dart';

/// BLoC for managing subject detail page
class SubjectDetailBloc extends Bloc<SubjectDetailEvent, SubjectDetailState> {
  final ContentLibraryRepository repository;

  SubjectDetailBloc({required this.repository})
    : super(const SubjectDetailInitial()) {
    on<LoadSubjectDetail>(_onLoadSubjectDetail);
    on<LoadChapterContent>(_onLoadChapterContent);
    on<RefreshSubjectDetail>(_onRefreshSubjectDetail);
    on<RefreshChapterContent>(_onRefreshChapterContent);
    on<LoadSubjectContents>(_onLoadSubjectContents);
  }

  Future<void> _onLoadSubjectDetail(
    LoadSubjectDetail event,
    Emitter<SubjectDetailState> emit,
  ) async {
    emit(const SubjectDetailLoading());

    // Load subject details
    final subjectResult = await repository.getSubjectById(event.subjectId);

    await subjectResult.fold(
      (failure) async => emit(SubjectDetailError(failure.message)),
      (subject) async {
        // Load chapters for the subject
        final chaptersResult = await repository.getChaptersBySubject(
          event.subjectId,
        );

        chaptersResult.fold(
          (failure) => emit(SubjectDetailError(failure.message)),
          (chapters) =>
              emit(SubjectDetailLoaded(subject: subject, chapters: chapters)),
        );
      },
    );
  }

  Future<void> _onLoadChapterContent(
    LoadChapterContent event,
    Emitter<SubjectDetailState> emit,
  ) async {
    if (state is! SubjectDetailLoaded) return;

    final currentState = state as SubjectDetailLoaded;

    // Check if content is already loaded
    if (currentState.isContentLoaded(event.chapterId, event.contentType)) {
      return;
    }

    // Emit loading state
    emit(
      SubjectDetailLoadingContent(
        subject: currentState.subject,
        chapters: currentState.chapters,
        chapterContents: currentState.chapterContents,
        loadingChapterId: event.chapterId,
        loadingContentType: event.contentType,
      ),
    );

    // Load content
    final result = await repository.getContentByChapter(
      chapterId: event.chapterId,
      contentType: event.contentType,
    );

    result.fold(
      (failure) {
        // If loading fails, return to the previous state
        emit(currentState);
      },
      (contents) {
        // Update the chapter contents map
        final updatedContents = Map<int, Map<String, List<ContentEntity>>>.from(
          currentState.chapterContents,
        );

        if (!updatedContents.containsKey(event.chapterId)) {
          updatedContents[event.chapterId] = {};
        }

        updatedContents[event.chapterId]![event.contentType] = contents;

        emit(currentState.copyWith(chapterContents: updatedContents));
      },
    );
  }

  Future<void> _onRefreshSubjectDetail(
    RefreshSubjectDetail event,
    Emitter<SubjectDetailState> emit,
  ) async {
    // Keep the current state visible while refreshing
    final currentState = state;

    // Load subject details
    final subjectResult = await repository.getSubjectById(event.subjectId);

    await subjectResult.fold(
      (failure) async {
        // If refresh fails, keep the current state
        if (currentState is SubjectDetailLoaded) {
          emit(currentState);
        } else {
          emit(SubjectDetailError(failure.message));
        }
      },
      (subject) async {
        // Load chapters for the subject
        final chaptersResult = await repository.getChaptersBySubject(
          event.subjectId,
        );

        chaptersResult.fold(
          (failure) {
            if (currentState is SubjectDetailLoaded) {
              emit(currentState);
            } else {
              emit(SubjectDetailError(failure.message));
            }
          },
          (chapters) {
            // Clear cached content on refresh
            emit(SubjectDetailLoaded(subject: subject, chapters: chapters));
          },
        );
      },
    );
  }

  /// Refresh chapter content - forces reload from API, ignoring cache
  Future<void> _onRefreshChapterContent(
    RefreshChapterContent event,
    Emitter<SubjectDetailState> emit,
  ) async {
    if (state is! SubjectDetailLoaded) return;

    final currentState = state as SubjectDetailLoaded;

    // Load content from API (no cache check)
    final result = await repository.getContentByChapter(
      chapterId: event.chapterId,
      contentType: event.contentType,
    );

    result.fold(
      (failure) {
        // If loading fails, keep the current state
        emit(currentState);
      },
      (contents) {
        // Update the chapter contents map with fresh data
        final updatedContents = Map<int, Map<String, List<ContentEntity>>>.from(
          currentState.chapterContents,
        );

        if (!updatedContents.containsKey(event.chapterId)) {
          updatedContents[event.chapterId] = {};
        }

        updatedContents[event.chapterId]![event.contentType] = contents;

        emit(currentState.copyWith(chapterContents: updatedContents));
      },
    );
  }

  /// Load all contents directly by subject ID (for subjects without chapters)
  Future<void> _onLoadSubjectContents(
    LoadSubjectContents event,
    Emitter<SubjectDetailState> emit,
  ) async {
    emit(const SubjectDetailLoading());

    final result = await repository.getContents(subjectId: event.subject.id);

    result.fold(
      (failure) {
        print('❌ SubjectDetailBloc: Error loading contents: ${failure.message}');
        emit(SubjectDetailError(failure.message));
      },
      (contents) {
        print('✅ SubjectDetailBloc: Loaded ${contents.length} contents');
        for (final c in contents) {
          print('   - ${c.titleAr} (type: ${c.type}, progress: ${c.progressPercentage}, status: ${c.progressStatus}, isCompleted: ${c.isCompleted})');
        }
        emit(SubjectContentsLoaded(
          subject: event.subject,
          allContents: contents,
        ));
      },
    );
  }
}
