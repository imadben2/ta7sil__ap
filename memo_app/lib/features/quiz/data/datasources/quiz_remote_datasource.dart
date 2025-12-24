import 'package:dio/dio.dart';
import '../models/quiz_model.dart';
import '../models/attempt_model.dart';
import '../models/result_model.dart';
import '../models/performance_model.dart';

/// Remote data source for quiz feature
///
/// Handles all API calls to Laravel backend
abstract class QuizRemoteDataSource {
  /// Get list of quizzes with filters
  Future<List<QuizModel>> getQuizzes({
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

  /// Get quiz details by ID
  Future<QuizModel> getQuizDetails(int quizId);

  /// Start new quiz attempt
  Future<QuizAttemptModel> startQuiz({required int quizId, int? seed});

  /// Get current in-progress attempt
  Future<QuizAttemptModel?> getCurrentAttempt();

  /// Save answer during attempt
  Future<void> saveAnswer({
    required int attemptId,
    required int questionId,
    required dynamic answer,
  });

  /// Submit quiz for grading
  Future<QuizResultModel> submitQuiz({
    required int attemptId,
    Map<int, dynamic>? finalAnswers,
  });

  /// Get quiz results
  Future<QuizResultModel> getQuizResults(int attemptId);

  /// Get quiz review with answers
  Future<QuizResultModel> getQuizReview(int attemptId);

  /// Abandon quiz attempt
  Future<void> abandonQuiz(int attemptId);

  /// Get recommended quizzes
  Future<List<QuizModel>> getRecommendations({int limit = 10});

  /// Get performance statistics
  Future<QuizPerformanceModel> getPerformance({
    int? subjectId,
    String period = 'all',
  });

  /// Get attempts history
  Future<List<QuizAttemptModel>> getAttemptsHistory({
    int? subjectId,
    String? status,
    int page = 1,
  });
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final Dio dio;

  QuizRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<QuizModel>> getQuizzes({
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
      final response = await dio.get(
        '/v1/quizzes',
        queryParameters: {
          'academic_filter': academicFilter,
          'my_subjects_only': mySubjectsOnly,
          if (streamId != null) 'stream_id': streamId,
          if (subjectId != null) 'subject_id': subjectId,
          if (chapterId != null) 'chapter_id': chapterId,
          if (quizType != null) 'quiz_type': quizType,
          if (difficulty != null) 'difficulty': difficulty,
          'page': page,
          'per_page': perPage,
        },
      );

      final List<dynamic> quizzesJson = response.data['data']['quizzes'];
      return quizzesJson.map((json) => QuizModel.fromJson(json)).toList();
    } on DioException catch (e) {
      // Check if error is due to incomplete academic profile
      if (e.response?.statusCode == 400 &&
          e.response?.data['message']?.toString().contains(
                'academic profile',
              ) ==
              true &&
          academicFilter == true) {
        // Retry without academic filter
        return getQuizzes(
          academicFilter: false,
          mySubjectsOnly: mySubjectsOnly,
          streamId: streamId,
          subjectId: subjectId,
          chapterId: chapterId,
          quizType: quizType,
          difficulty: difficulty,
          page: page,
          perPage: perPage,
        );
      }
      throw _handleError(e);
    }
  }

  @override
  Future<QuizModel> getQuizDetails(int quizId) async {
    try {
      final response = await dio.get('/v1/quizzes/$quizId');
      final data = response.data['data'];

      // Merge user_stats into quiz data for the model
      final quizData = Map<String, dynamic>.from(data['quiz']);
      if (data['user_stats'] != null) {
        quizData['user_stats'] = data['user_stats'];
      }

      return QuizModel.fromJson(quizData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<QuizAttemptModel> startQuiz({required int quizId, int? seed}) async {
    try {
      final response = await dio.post(
        '/v1/quizzes/$quizId/start',
        data: {if (seed != null) 'seed': seed},
      );

      return QuizAttemptModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<QuizAttemptModel?> getCurrentAttempt() async {
    try {
      final response = await dio.get('/v1/quiz-attempts/current');

      if (response.data['data']['attempt'] == null) {
        return null;
      }

      return QuizAttemptModel.fromJson(response.data['data']['attempt']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleError(e);
    }
  }

  @override
  Future<void> saveAnswer({
    required int attemptId,
    required int questionId,
    required dynamic answer,
  }) async {
    try {
      await dio.post(
        '/v1/quiz-attempts/$attemptId/answer',
        data: {'question_id': questionId, 'answer': answer},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<QuizResultModel> submitQuiz({
    required int attemptId,
    Map<int, dynamic>? finalAnswers,
  }) async {
    try {
      final response = await dio.post(
        '/v1/quiz-attempts/$attemptId/submit',
        data: {
          if (finalAnswers != null)
            'final_answers': finalAnswers.map(
              (key, value) => MapEntry(key.toString(), value),
            ),
        },
      );

      return QuizResultModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<QuizResultModel> getQuizResults(int attemptId) async {
    try {
      final response = await dio.get('/v1/quiz-attempts/$attemptId/results');
      return QuizResultModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<QuizResultModel> getQuizReview(int attemptId) async {
    try {
      final response = await dio.get('/v1/quiz-attempts/$attemptId/review');
      return QuizResultModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> abandonQuiz(int attemptId) async {
    try {
      await dio.delete('/v1/quiz-attempts/$attemptId/abandon');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<QuizModel>> getRecommendations({int limit = 10}) async {
    try {
      final response = await dio.get(
        '/v1/quizzes/recommended',
        queryParameters: {'limit': limit},
      );

      // API can return either:
      // 1. {data: {recommended_quizzes: [{quiz: {...}}, ...]}}
      // 2. {data: {quizzes: [...]}}
      final responseData = response.data['data'];
      List<dynamic> quizzesJson;

      if (responseData.containsKey('recommended_quizzes')) {
        // Format 1: Extract quiz objects from recommended_quizzes array
        quizzesJson = (responseData['recommended_quizzes'] as List)
            .map((item) => item['quiz'])
            .toList();
      } else if (responseData.containsKey('quizzes')) {
        // Format 2: Direct quizzes array
        quizzesJson = responseData['quizzes'] as List;
      } else {
        return [];
      }

      return quizzesJson.map((quizData) {
        // Transform simplified API response to match full model structure
        final quiz = quizData as Map<String, dynamic>;

        return QuizModel.fromJson({
          'id': quiz['id'],
          'title_ar': quiz['title_ar'],
          'description_ar': quiz['description_ar'],
          'quiz_type': quiz['quiz_type'] ?? 'practice',
          'time_limit_minutes': quiz['time_limit_minutes'] ?? quiz['duration'],
          'passing_score': (quiz['passing_score'] as num?)?.toDouble() ?? 70.0,
          'difficulty_level':
              quiz['difficulty_level'] ?? quiz['difficulty'] ?? 'medium',
          'estimated_duration_minutes':
              quiz['estimated_duration_minutes'] ?? quiz['duration'] ?? 0,
          'total_questions': quiz['total_questions'] ?? 0,
          'average_score': quiz['average_score'] != null
              ? (quiz['average_score'] as num).toDouble()
              : null,
          'total_attempts':
              quiz['total_attempts'] ?? quiz['user_attempts'] ?? 0,
          'is_premium': quiz['is_premium'] == true || quiz['is_premium'] == 1,
          'tags': quiz['tags'],
          'subject': quiz['subject'] is String
              ? {
                  'id': 0,
                  'name_ar': quiz['subject'],
                  'name_en': null,
                  'name_fr': null,
                }
              : quiz['subject'],
          'chapter': quiz['chapter'] == null || quiz['chapter'] is String
              ? null
              : quiz['chapter'],
          'user_stats': quiz['user_stats'],
        });
      }).toList();
    } on DioException catch (e) {
      // If academic profile is incomplete, return empty list for recommendations
      if (e.response?.statusCode == 400 &&
          e.response?.data['message']?.toString().contains(
                'academic profile',
              ) ==
              true) {
        return [];
      }
      throw _handleError(e);
    }
  }

  @override
  Future<QuizPerformanceModel> getPerformance({
    int? subjectId,
    String period = 'all',
  }) async {
    try {
      final response = await dio.get(
        '/v1/quizzes/performance',
        queryParameters: {
          if (subjectId != null) 'subject_id': subjectId,
          'period': period,
        },
      );

      return QuizPerformanceModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<QuizAttemptModel>> getAttemptsHistory({
    int? subjectId,
    String? status,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        '/v1/quizzes/my-attempts',
        queryParameters: {
          if (subjectId != null) 'subject_id': subjectId,
          if (status != null) 'status': status,
          'page': page,
        },
      );

      final List<dynamic> attemptsJson = response.data['data']['attempts'];
      return attemptsJson
          .map((json) => QuizAttemptModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to app-specific exceptions
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = error.response!.data['message'] ?? 'حدث خطأ غير متوقع';

      switch (statusCode) {
        case 400:
          return Exception('طلب غير صالح: $message');
        case 401:
          return Exception('غير مصرح: $message');
        case 403:
          return Exception('ممنوع: $message');
        case 404:
          return Exception('غير موجود: $message');
        case 409:
          return Exception('تعارض: $message');
        case 422:
          return Exception('خطأ في التحقق: $message');
        case 500:
          return Exception('خطأ في الخادم: $message');
        default:
          return Exception('خطأ: $message');
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception('انتهت مهلة الاتصال');
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception('لا يوجد اتصال بالإنترنت');
    }

    return Exception('حدث خطأ غير متوقع');
  }
}
