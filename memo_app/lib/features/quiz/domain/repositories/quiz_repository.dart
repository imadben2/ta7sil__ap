import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quiz_entity.dart';
import '../entities/quiz_attempt_entity.dart';
import '../entities/quiz_result_entity.dart';
import '../entities/quiz_performance_entity.dart';

/// Quiz repository interface
///
/// Defines all operations for quiz feature.
/// Implementation handles API calls, caching, and offline support.
abstract class QuizRepository {
  /// Get list of quizzes with optional filters
  ///
  /// Filters:
  /// - [academicFilter]: Auto-filter by user's academic profile (default: true)
  /// - [mySubjectsOnly]: Show only user's selected subjects
  /// - [streamId]: Filter by academic stream ID (explicit filter)
  /// - [subjectId]: Filter by specific subject
  /// - [chapterId]: Filter by specific chapter
  /// - [quizType]: Filter by type (practice/timed/exam)
  /// - [difficulty]: Filter by difficulty (easy/medium/hard)
  /// - [page]: Page number for pagination
  /// - [perPage]: Items per page
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
  });

  /// Get detailed quiz information by ID
  ///
  /// Returns full quiz metadata including:
  /// - Basic info
  /// - Configuration
  /// - Statistics
  /// - User-specific data (attempts, best score)
  Future<Either<Failure, QuizEntity>> getQuizDetails(int quizId);

  /// Start a new quiz attempt
  ///
  /// Returns:
  /// - New attempt record
  /// - Questions (shuffled if applicable)
  /// - Time limit information
  ///
  /// If user has an in-progress attempt, returns that instead
  Future<Either<Failure, QuizAttemptEntity>> startQuiz({
    required int quizId,
    int? seed, // For reproducible shuffling
  });

  /// Get current in-progress attempt
  ///
  /// Returns null if no in-progress attempt exists
  Future<Either<Failure, QuizAttemptEntity?>> getCurrentAttempt();

  /// Save answer for a question during attempt
  ///
  /// Auto-saves progress to prevent data loss.
  /// Does NOT trigger correction - just stores the answer.
  Future<Either<Failure, void>> saveAnswer({
    required int attemptId,
    required int questionId,
    required dynamic answer,
  });

  /// Submit quiz for grading
  ///
  /// Triggers auto-correction and returns results.
  /// Cannot be undone once submitted.
  Future<Either<Failure, QuizResultEntity>> submitQuiz({
    required int attemptId,
    Map<int, dynamic>? finalAnswers, // Optional: if different from saved
  });

  /// Get quiz results by attempt ID
  ///
  /// Returns detailed results including:
  /// - Overall score
  /// - Question-by-question breakdown
  /// - Weak areas
  Future<Either<Failure, QuizResultEntity>> getQuizResults(int attemptId);

  /// Get quiz review (answer breakdown)
  ///
  /// Shows correct/incorrect answers with explanations.
  /// Only available if quiz allows review.
  Future<Either<Failure, QuizResultEntity>> getQuizReview(int attemptId);

  /// Abandon current quiz attempt
  ///
  /// Marks attempt as abandoned.
  /// Cannot be resumed after abandoning.
  Future<Either<Failure, void>> abandonQuiz(int attemptId);

  /// Get recommended quizzes for user
  ///
  /// AI-powered recommendations based on:
  /// - Weak areas
  /// - Priority subjects
  /// - Recent performance
  /// - Adaptive difficulty
  ///
  /// [limit]: Maximum number of recommendations
  Future<Either<Failure, List<QuizEntity>>> getRecommendations({
    int limit = 10,
  });

  /// Get user's quiz performance statistics
  ///
  /// Returns comprehensive performance data:
  /// - Overall stats
  /// - Subject-specific performance
  /// - Question type accuracy
  /// - Weak areas
  ///
  /// [subjectId]: Optional filter for specific subject
  /// [period]: Time period (week/month/year/all)
  Future<Either<Failure, QuizPerformanceEntity>> getPerformance({
    int? subjectId,
    String period = 'all',
  });

  /// Get user's quiz attempts history
  ///
  /// [subjectId]: Filter by subject
  /// [status]: Filter by status (completed/in_progress/abandoned)
  /// [page]: Page number
  Future<Either<Failure, List<QuizAttemptEntity>>> getAttemptsHistory({
    int? subjectId,
    String? status,
    int page = 1,
  });
}
