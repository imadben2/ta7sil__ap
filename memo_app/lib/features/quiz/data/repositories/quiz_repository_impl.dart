import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/entities/quiz_attempt_entity.dart';
import '../../domain/entities/quiz_result_entity.dart';
import '../../domain/entities/quiz_performance_entity.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../datasources/quiz_remote_datasource.dart';
import '../datasources/quiz_local_datasource.dart';
import '../models/attempt_model.dart';

/// Implementation of QuizRepository
///
/// Implements offline-first strategy:
/// 1. Try remote call
/// 2. If fails and cache exists, return cache
/// 3. If no cache, return failure
/// 4. On success, update cache
class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource remoteDataSource;
  final QuizLocalDataSource localDataSource;

  QuizRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<QuizEntity>>> getQuizzes({
    bool academicFilter = true,
    bool mySubjectsOnly = false,
    int? streamId,
    int? subjectId,
    int? chapterId,
    String? quizType,
    String? difficulty,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      // Try remote call
      final quizzes = await remoteDataSource.getQuizzes(
        academicFilter: academicFilter,
        mySubjectsOnly: mySubjectsOnly,
        streamId: streamId,
        subjectId: subjectId,
        chapterId: chapterId,
        quizType: quizType,
        difficulty: difficulty,
        page: page,
        perPage: perPage,
      );

      // Cache the result with a key based on filters
      final cacheKey = _buildCacheKey(
        academicFilter: academicFilter,
        mySubjectsOnly: mySubjectsOnly,
        streamId: streamId,
        subjectId: subjectId,
        chapterId: chapterId,
        quizType: quizType,
        difficulty: difficulty,
        page: page,
      );

      await localDataSource.cacheQuizzes(quizzes, cacheKey);

      return Right(quizzes.map((model) => model as QuizEntity).toList());
    } on ServerException catch (e) {
      // Try to return cached data
      final cached = await _getCachedQuizzes(
        academicFilter: academicFilter,
        mySubjectsOnly: mySubjectsOnly,
        streamId: streamId,
        subjectId: subjectId,
        chapterId: chapterId,
        quizType: quizType,
        difficulty: difficulty,
        page: page,
      );
      if (cached != null) {
        return Right(cached);
      }
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      // Try to return cached data
      final cached = await _getCachedQuizzes(
        academicFilter: academicFilter,
        mySubjectsOnly: mySubjectsOnly,
        streamId: streamId,
        subjectId: subjectId,
        chapterId: chapterId,
        quizType: quizType,
        difficulty: difficulty,
        page: page,
      );
      if (cached != null) {
        return Right(cached);
      }
      return Left(NetworkFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on DeviceMismatchException catch (e) {
      return Left(DeviceMismatchFailure(e.message));
    } catch (e) {
      return Left(GenericFailure('فشل تحميل الاختبارات: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, QuizEntity>> getQuizDetails(int quizId) async {
    try {
      // Try remote call
      final quiz = await remoteDataSource.getQuizDetails(quizId);

      // Cache the result
      await localDataSource.cacheQuizDetails(quiz);

      return Right(quiz);
    } on ServerException catch (e) {
      // Try to return cached data
      final cached = await localDataSource.getCachedQuizDetails(quizId);
      if (cached != null) {
        return Right(cached);
      }
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      // Try to return cached data
      final cached = await localDataSource.getCachedQuizDetails(quizId);
      if (cached != null) {
        return Right(cached);
      }
      return Left(NetworkFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } catch (e) {
      return Left(GenericFailure('فشل تحميل تفاصيل الاختبار: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, QuizAttemptEntity>> startQuiz({
    required int quizId,
    int? seed,
  }) async {
    try {
      final attempt = await remoteDataSource.startQuiz(
        quizId: quizId,
        seed: seed,
      );

      // Cache current attempt
      await localDataSource.cacheCurrentAttempt(attempt);

      return Right(attempt.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } on ClientException catch (e) {
      return Left(ClientFailure(e.message));
    } catch (e) {
      return Left(GenericFailure('فشل بدء الاختبار: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, QuizAttemptEntity?>> getCurrentAttempt() async {
    try {
      // Try remote call first
      final attempt = await remoteDataSource.getCurrentAttempt();

      if (attempt != null) {
        // Cache the result
        await localDataSource.cacheCurrentAttempt(attempt);
        return Right(attempt.toEntity());
      }

      return const Right(null);
    } on NetworkException catch (_) {
      // If network fails, try cache
      final cached = await localDataSource.getCachedCurrentAttempt();
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      // Try cache on any error
      final cached = await localDataSource.getCachedCurrentAttempt();
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return Left(
        GenericFailure('فشل تحميل المحاولة الحالية: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveAnswer({
    required int attemptId,
    required int questionId,
    required dynamic answer,
  }) async {
    try {
      // Try remote call
      await remoteDataSource.saveAnswer(
        attemptId: attemptId,
        questionId: questionId,
        answer: answer,
      );

      // Update cached attempt with the answer
      final cachedAttempt = await localDataSource.getCachedCurrentAttempt();
      if (cachedAttempt != null) {
        // Update answers map
        final updatedAnswers = Map<String, dynamic>.from(
          cachedAttempt.modelAnswers,
        );
        updatedAnswers[questionId.toString()] = answer;

        final updatedAttempt = QuizAttemptModel(
          modelId: cachedAttempt.modelId,
          modelQuizId: cachedAttempt.modelQuizId,
          modelUserId: cachedAttempt.modelUserId,
          modelStartedAt: cachedAttempt.modelStartedAt,
          modelCompletedAt: cachedAttempt.modelCompletedAt,
          modelStatus: cachedAttempt.modelStatus,
          modelTimeLimitSeconds: cachedAttempt.modelTimeLimitSeconds,
          modelExpiresAt: cachedAttempt.modelExpiresAt,
          modelTimeSpentSeconds: cachedAttempt.modelTimeSpentSeconds,
          modelQuestions: cachedAttempt.modelQuestions,
          modelAnswers: updatedAnswers,
          modelScore: cachedAttempt.modelScore,
        );

        await localDataSource.cacheCurrentAttempt(updatedAttempt);
      }

      return const Right(null);
    } on NetworkException catch (e) {
      // Queue the answer for later sync
      await localDataSource.queueAnswer(
        attemptId: attemptId,
        questionId: questionId,
        answer: answer,
        timestamp: DateTime.now(),
      );

      // Update local cache anyway
      final cachedAttempt = await localDataSource.getCachedCurrentAttempt();
      if (cachedAttempt != null) {
        final updatedAnswers = Map<String, dynamic>.from(
          cachedAttempt.modelAnswers,
        );
        updatedAnswers[questionId.toString()] = answer;

        final updatedAttempt = QuizAttemptModel(
          modelId: cachedAttempt.modelId,
          modelQuizId: cachedAttempt.modelQuizId,
          modelUserId: cachedAttempt.modelUserId,
          modelStartedAt: cachedAttempt.modelStartedAt,
          modelCompletedAt: cachedAttempt.modelCompletedAt,
          modelStatus: cachedAttempt.modelStatus,
          modelTimeLimitSeconds: cachedAttempt.modelTimeLimitSeconds,
          modelExpiresAt: cachedAttempt.modelExpiresAt,
          modelTimeSpentSeconds: cachedAttempt.modelTimeSpentSeconds,
          modelQuestions: cachedAttempt.modelQuestions,
          modelAnswers: updatedAnswers,
          modelScore: cachedAttempt.modelScore,
        );

        await localDataSource.cacheCurrentAttempt(updatedAttempt);
      }

      return const Right(null); // Success locally, will sync later
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(GenericFailure('فشل حفظ الإجابة: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, QuizResultEntity>> submitQuiz({
    required int attemptId,
    Map<int, dynamic>? finalAnswers,
  }) async {
    try {
      // Sync any queued answers first
      await _syncQueuedAnswers();

      // Submit quiz
      final result = await remoteDataSource.submitQuiz(
        attemptId: attemptId,
        finalAnswers: finalAnswers,
      );

      // Clear cached attempt
      await localDataSource.clearCurrentAttempt();

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(GenericFailure('فشل إرسال الاختبار: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, QuizResultEntity>> getQuizResults(
    int attemptId,
  ) async {
    try {
      final result = await remoteDataSource.getQuizResults(attemptId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } catch (e) {
      return Left(GenericFailure('فشل تحميل النتائج: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, QuizResultEntity>> getQuizReview(int attemptId) async {
    try {
      final result = await remoteDataSource.getQuizReview(attemptId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } catch (e) {
      return Left(GenericFailure('فشل تحميل مراجعة الاختبار: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> abandonQuiz(int attemptId) async {
    try {
      await remoteDataSource.abandonQuiz(attemptId);

      // Clear cached attempt
      await localDataSource.clearCurrentAttempt();

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(GenericFailure('فشل إلغاء الاختبار: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<QuizEntity>>> getRecommendations({
    int limit = 10,
  }) async {
    try {
      final quizzes = await remoteDataSource.getRecommendations(limit: limit);
      return Right(quizzes.map((model) => model as QuizEntity).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(
        GenericFailure('فشل تحميل الاختبارات المقترحة: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, QuizPerformanceEntity>> getPerformance({
    int? subjectId,
    String period = 'all',
  }) async {
    try {
      final performance = await remoteDataSource.getPerformance(
        subjectId: subjectId,
        period: period,
      );
      return Right(performance);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(GenericFailure('فشل تحميل إحصائيات الأداء: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<QuizAttemptEntity>>> getAttemptsHistory({
    int? subjectId,
    String? status,
    int page = 1,
  }) async {
    try {
      final attempts = await remoteDataSource.getAttemptsHistory(
        subjectId: subjectId,
        status: status,
        page: page,
      );
      return Right(attempts.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(GenericFailure('فشل تحميل سجل المحاولات: ${e.toString()}'));
    }
  }

  // ========== HELPER METHODS ==========

  /// Build cache key from filters
  String _buildCacheKey({
    required bool academicFilter,
    required bool mySubjectsOnly,
    int? streamId,
    int? subjectId,
    int? chapterId,
    String? quizType,
    String? difficulty,
    required int page,
  }) {
    return 'quizzes_${academicFilter}_${mySubjectsOnly}_${streamId}_${subjectId}_${chapterId}_${quizType}_${difficulty}_$page';
  }

  /// Get cached quizzes
  Future<List<QuizEntity>?> _getCachedQuizzes({
    required bool academicFilter,
    required bool mySubjectsOnly,
    int? streamId,
    int? subjectId,
    int? chapterId,
    String? quizType,
    String? difficulty,
    required int page,
  }) async {
    final cacheKey = _buildCacheKey(
      academicFilter: academicFilter,
      mySubjectsOnly: mySubjectsOnly,
      streamId: streamId,
      subjectId: subjectId,
      chapterId: chapterId,
      quizType: quizType,
      difficulty: difficulty,
      page: page,
    );

    final cached = await localDataSource.getCachedQuizzes(cacheKey);
    return cached?.map((model) => model as QuizEntity).toList();
  }

  /// Sync queued answers when connection is available
  Future<void> _syncQueuedAnswers() async {
    try {
      final queuedAnswers = await localDataSource.getQueuedAnswers();

      for (final answerData in queuedAnswers) {
        try {
          await remoteDataSource.saveAnswer(
            attemptId: answerData['attempt_id'] as int,
            questionId: answerData['question_id'] as int,
            answer: answerData['answer'],
          );

          // Clear successfully synced answer
          await localDataSource.clearQueuedAnswer(answerData['id'] as String);
        } catch (e) {
          // Skip failed items, will try again next time
          continue;
        }
      }
    } catch (e) {
      // Silent fail - sync will be retried on next submission
    }
  }
}
