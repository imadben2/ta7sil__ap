import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quiz_entity.dart';
import '../repositories/quiz_repository.dart';

/// Use case for getting list of quizzes
///
/// Supports filtering by:
/// - Academic context (automatic)
/// - Academic stream (explicit filter)
/// - Subject/Chapter
/// - Quiz type and difficulty
/// - User's selected subjects
class GetQuizzesUseCase {
  final QuizRepository repository;

  GetQuizzesUseCase(this.repository);

  Future<Either<Failure, List<QuizEntity>>> call(GetQuizzesParams params) {
    return repository.getQuizzes(
      academicFilter: params.academicFilter,
      mySubjectsOnly: params.mySubjectsOnly,
      streamId: params.streamId,
      subjectId: params.subjectId,
      chapterId: params.chapterId,
      quizType: params.quizType,
      difficulty: params.difficulty,
      page: params.page,
      perPage: params.perPage,
    );
  }
}

/// Parameters for GetQuizzesUseCase
class GetQuizzesParams {
  final bool academicFilter;
  final bool mySubjectsOnly;
  final int? streamId;
  final int? subjectId;
  final int? chapterId;
  final String? quizType;
  final String? difficulty;
  final int page;
  final int perPage;

  const GetQuizzesParams({
    this.academicFilter = true,
    this.mySubjectsOnly = false,
    this.streamId,
    this.subjectId,
    this.chapterId,
    this.quizType,
    this.difficulty,
    this.page = 1,
    this.perPage = 15,
  });
}
