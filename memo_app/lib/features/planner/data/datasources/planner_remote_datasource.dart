import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/study_session.dart';
import '../../domain/entities/planner_settings.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/exam.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/centralized_subject.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/points_history.dart';
import '../../domain/entities/session_content.dart';
import '../../domain/usecases/trigger_adaptation.dart';
import '../../domain/usecases/record_exam_result.dart';
import '../models/study_session_model.dart';
import '../models/planner_settings_model.dart';
import '../models/subject_model.dart';
import '../models/exam_model.dart';
import '../models/schedule_model.dart';
import '../models/centralized_subject_model.dart';
import '../models/achievement_model.dart';
import '../models/points_history_model.dart';
import '../models/session_content_model.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';

/// Remote data source for planner feature using Laravel API
///
/// Handles all HTTP requests to the backend
abstract class PlannerRemoteDataSource {
  // Study Sessions
  Future<List<StudySession>> fetchTodaysSessions(String userId);
  Future<List<StudySession>> fetchSessionsInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<StudySession> createSession(StudySession session);
  Future<void> updateSession(StudySession session);
  Future<void> deleteSession(String sessionId);
  Future<void> startSession(String sessionId);
  Future<void> pauseSession(String sessionId);
  Future<void> resumeSession(String sessionId);
  Future<void> completeSession(
    String sessionId,
    int completionPercentage,
    String? userNotes,
    String? mood,
  );
  Future<void> skipSession(String sessionId, String reason);
  Future<void> rescheduleSession(
    String sessionId,
    DateTime newDate,
    TimeOfDay newStartTime,
    TimeOfDay newEndTime,
  );
  Future<void> pinSession(String sessionId, bool isPinned);
  Future<void> deleteAllSessions();

  // Planner Settings
  Future<PlannerSettings> fetchSettings(String userId);
  Future<void> updateSettings(PlannerSettings settings);

  // Schedule Generation
  Future<Schedule> generateSchedule({
    required String userId,
    required List<String> subjectIds,
    required DateTime startDate,
    required DateTime endDate,
  });

  // Subjects
  Future<List<Subject>> fetchSubjects(String userId);
  Future<Subject> createSubject(Subject subject);
  Future<void> addSubject(String userId, Subject subject);
  Future<void> updateSubject(String userId, Subject subject);
  Future<void> deleteSubject(String userId, String subjectId);

  // Exams
  Future<List<Exam>> fetchExams(String userId);
  Future<Exam> createExam(Exam exam);
  Future<void> addExam(String userId, Exam exam);
  Future<void> updateExam(String userId, Exam exam);
  Future<void> deleteExam(String userId, String examId);

  // Centralized Subjects
  Future<List<CentralizedSubject>> fetchCentralizedSubjects({
    int? streamId,
    int? yearId,
    bool activeOnly = true,
  });

  // Achievements & Gamification
  Future<AchievementsResponse> fetchAchievements();
  Future<PointsHistory> fetchPointsHistory(int periodDays);

  // Exam Result Recording
  Future<ExamResultResponse> recordExamResult({
    required String examId,
    required double score,
    required double maxScore,
    String? notes,
  });

  // Schedule Adaptation
  Future<AdaptationResult> triggerAdaptation();

  // Session Content (Curriculum Integration)
  Future<SessionContentResponse> fetchNextSessionContent({
    required String subjectId,
    required String sessionType,
    int durationMinutes = 30,
    int limit = 5,
    String? contentId, // Optional: filter to specific unit/topic
  });

  Future<void> markContentPhaseComplete({
    required String contentId,
    required String phase,
    int durationMinutes = 0,
  });
}

class PlannerRemoteDataSourceImpl implements PlannerRemoteDataSource {
  final Dio dio;
  final String baseUrl;
  final AuthLocalDataSource authLocalDataSource;

  PlannerRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrl,
    required this.authLocalDataSource,
  });

  // Study Sessions
  @override
  Future<List<StudySession>> fetchTodaysSessions(String userId) async {
    try {
      debugPrint('[PlannerRemoteDataSource] Fetching today\'s sessions for user: $userId');
      final response = await dio.get(
        '$baseUrl/v1/planner/sessions/today',
        queryParameters: {'user_id': userId},
      );

      debugPrint('[PlannerRemoteDataSource] Response status: ${response.statusCode}');
      debugPrint('[PlannerRemoteDataSource] Response data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        debugPrint('[PlannerRemoteDataSource] Parsed ${data.length} sessions');
        return data
            .map((json) => StudySessionModel.fromJson(json).toEntity())
            .toList();
      } else {
        throw ServerException(message: 'Failed to fetch today\'s sessions');
      }
    } on DioException catch (e) {
      debugPrint('[PlannerRemoteDataSource] DioException: ${e.message}');
      debugPrint('[PlannerRemoteDataSource] Response: ${e.response?.data}');
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<List<StudySession>> fetchSessionsInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await dio.get(
        '$baseUrl/v1/planner/sessions/range',
        queryParameters: {
          'user_id': userId,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data
            .map((json) => StudySessionModel.fromJson(json).toEntity())
            .toList();
      } else {
        throw ServerException(message: 'Failed to fetch sessions in range');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<StudySession> createSession(StudySession session) async {
    try {
      final model = StudySessionModel.fromEntity(session);
      final response = await dio.post(
        '$baseUrl/v1/planner/sessions',
        data: model.toJson(),
      );

      if (response.statusCode == 201) {
        return StudySessionModel.fromJson(response.data['data']).toEntity();
      } else {
        throw ServerException(message: 'Failed to create session');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<void> updateSession(StudySession session) async {
    try {
      final model = StudySessionModel.fromEntity(session);
      final response = await dio.put(
        '$baseUrl/v1/planner/sessions/${session.id}',
        data: model.toJson(),
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to update session');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      final response = await dio.delete('$baseUrl/v1/planner/sessions/$sessionId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(message: 'Failed to delete session');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<void> startSession(String sessionId) async {
    try {
      final response = await dio.post(
        '$baseUrl/v1/planner/sessions/$sessionId/start',
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to start session');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<void> pauseSession(String sessionId) async {
    try {
      final response = await dio.post(
        '$baseUrl/v1/planner/sessions/$sessionId/pause',
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to pause session');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<void> resumeSession(String sessionId) async {
    try {
      final response = await dio.post(
        '$baseUrl/v1/planner/sessions/$sessionId/resume',
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to resume session');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<void> completeSession(
    String sessionId,
    int completionPercentage,
    String? userNotes,
    String? mood,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl/v1/planner/sessions/$sessionId/complete',
        data: {
          'completion_percentage': completionPercentage,
          if (userNotes != null) 'user_notes': userNotes,
          if (mood != null) 'mood': mood,
        },
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to complete session');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<void> skipSession(String sessionId, String reason) async {
    try {
      final response = await dio.post(
        '$baseUrl/v1/planner/sessions/$sessionId/skip',
        data: {'reason': reason},
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to skip session');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<void> rescheduleSession(
    String sessionId,
    DateTime newDate,
    TimeOfDay newStartTime,
    TimeOfDay newEndTime,
  ) async {
    try {
      // Create full datetime strings as expected by the API
      final newStart = DateTime(
        newDate.year,
        newDate.month,
        newDate.day,
        newStartTime.hour,
        newStartTime.minute,
      );
      final newEnd = DateTime(
        newDate.year,
        newDate.month,
        newDate.day,
        newEndTime.hour,
        newEndTime.minute,
      );

      final response = await dio.put(
        '$baseUrl/v1/planner/sessions/$sessionId/reschedule',
        data: {
          'new_start': newStart.toIso8601String(),
          'new_end': newEnd.toIso8601String(),
        },
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to reschedule session');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<void> pinSession(String sessionId, bool isPinned) async {
    try {
      final response = await dio.post(
        '$baseUrl/v1/planner/sessions/$sessionId/pin',
        data: {'is_pinned': isPinned},
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to pin/unpin session');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<void> deleteAllSessions() async {
    try {
      debugPrint('[PlannerRemoteDataSource] Deleting ALL sessions from remote...');
      final response = await dio.delete('$baseUrl/planner/sessions');

      debugPrint('[PlannerRemoteDataSource] Delete response: ${response.statusCode}');
      if (response.statusCode == 200) {
        debugPrint('[PlannerRemoteDataSource] Successfully deleted all remote sessions');
        debugPrint('[PlannerRemoteDataSource] Response data: ${response.data}');
      } else {
        throw ServerException(message: 'Failed to delete all sessions');
      }
    } on DioException catch (e) {
      debugPrint('[PlannerRemoteDataSource] DioException while deleting sessions: ${e.message}');
      debugPrint('[PlannerRemoteDataSource] Response: ${e.response?.data}');
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  // Planner Settings
  @override
  Future<PlannerSettings> fetchSettings(String userId) async {
    try {
      final response = await dio.get(
        '$baseUrl/v1/planner/settings',
        queryParameters: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        return PlannerSettingsModel.fromJson(response.data['data']).toEntity();
      } else {
        throw ServerException(message: 'Failed to fetch settings');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<void> updateSettings(PlannerSettings settings) async {
    try {
      final model = PlannerSettingsModel.fromEntity(settings);
      final response = await dio.put(
        '$baseUrl/v1/planner/settings/${settings.userId}',
        data: model.toJson(),
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to update settings');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  // Schedule Generation
  @override
  Future<Schedule> generateSchedule({
    required String userId,
    required List<String> subjectIds,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get user's academic info from Hive
      final user = await authLocalDataSource.getCachedUser();

      // Build request data
      final requestData = <String, dynamic>{
        'user_id': userId,
        'subject_ids': subjectIds,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
      };

      // Add academic info if available
      if (user != null) {
        if (user.academicYearId != null) {
          requestData['academic_year_id'] = user.academicYearId;
        }
        if (user.streamId != null) {
          requestData['academic_stream_id'] = user.streamId;
        }
      }

      final response = await dio.post(
        '$baseUrl/v1/planner/schedules/generate',
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ScheduleModel.fromJson(response.data['data']).toEntity();
      } else {
        throw ServerException(message: 'Failed to generate schedule');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  // Subjects
  @override
  Future<List<Subject>> fetchSubjects(String userId) async {
    try {
      // Use planner subjects endpoint which includes user-specific data
      // like last_year_average and difficulty_level from user_subject_progress
      debugPrint('[PlannerRemoteDataSource] fetchSubjects called');
      debugPrint('[PlannerRemoteDataSource] URL: $baseUrl/v1/planner/subjects');
      debugPrint('[PlannerRemoteDataSource] Headers: ${dio.options.headers}');

      final response = await dio.get('$baseUrl/v1/planner/subjects');

      debugPrint('[PlannerRemoteDataSource] Response status: ${response.statusCode}');
      debugPrint('[PlannerRemoteDataSource] Response data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        debugPrint('[PlannerRemoteDataSource] Subjects count: ${data.length}');
        return data
            .map((json) => SubjectModel.fromJson(json).toEntity())
            .toList();
      } else {
        throw ServerException(message: 'Failed to fetch subjects');
      }
    } on DioException catch (e) {
      debugPrint('[PlannerRemoteDataSource] DioException: ${e.message}');
      debugPrint('[PlannerRemoteDataSource] Response: ${e.response?.data}');
      debugPrint('[PlannerRemoteDataSource] Status: ${e.response?.statusCode}');
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    } catch (e) {
      debugPrint('[PlannerRemoteDataSource] Exception: $e');
      rethrow;
    }
  }

  @override
  Future<Subject> createSubject(Subject subject) async {
    try {
      final model = SubjectModel.fromEntity(subject);
      final response = await dio.post(
        '$baseUrl/subjects',
        data: model.toJson(),
      );

      if (response.statusCode == 201) {
        return SubjectModel.fromJson(response.data['data']).toEntity();
      } else {
        throw ServerException(message: 'Failed to create subject');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<void> addSubject(String userId, Subject subject) async {
    try {
      final model = SubjectModel.fromEntity(subject);
      final response = await dio.post(
        '$baseUrl/v1/planner/subjects',
        data: model.toJson(),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw ServerException(message: 'Failed to add subject');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<void> updateSubject(String userId, Subject subject) async {
    try {
      final model = SubjectModel.fromEntity(subject);
      final response = await dio.put(
        '$baseUrl/v1/planner/subjects/${subject.id}',
        data: model.toJson(),
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to update subject');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<void> deleteSubject(String userId, String subjectId) async {
    try {
      final response = await dio.delete('$baseUrl/v1/planner/subjects/$subjectId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(message: 'Failed to delete subject');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  // Exams
  @override
  Future<List<Exam>> fetchExams(String userId) async {
    try {
      final response = await dio.get(
        '$baseUrl/exams',
        queryParameters: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ExamModel.fromJson(json).toEntity()).toList();
      } else {
        throw ServerException(message: 'Failed to fetch exams');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<Exam> createExam(Exam exam) async {
    try {
      final model = ExamModel.fromEntity(exam);
      final response = await dio.post('$baseUrl/exams', data: model.toJson());

      if (response.statusCode == 201) {
        return ExamModel.fromJson(response.data['data']).toEntity();
      } else {
        throw ServerException(message: 'Failed to create exam');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<void> addExam(String userId, Exam exam) async {
    try {
      final model = ExamModel.fromEntity(exam);
      final response = await dio.post('$baseUrl/exams', data: model.toJson());

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw ServerException(message: 'Failed to add exam');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<void> updateExam(String userId, Exam exam) async {
    try {
      final model = ExamModel.fromEntity(exam);
      final response = await dio.put(
        '$baseUrl/exams/${exam.id}',
        data: model.toJson(),
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to update exam');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<void> deleteExam(String userId, String examId) async {
    try {
      final response = await dio.delete('$baseUrl/exams/$examId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(message: 'Failed to delete exam');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  // Centralized Subjects
  @override
  Future<List<CentralizedSubject>> fetchCentralizedSubjects({
    int? streamId,
    int? yearId,
    bool activeOnly = true,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (streamId != null) queryParams['stream_id'] = streamId;
      if (yearId != null) queryParams['year_id'] = yearId;
      queryParams['active_only'] = activeOnly;
      // Planner needs all subjects regardless of content availability
      queryParams['with_content_only'] = false;

      final response = await dio.get(
        '$baseUrl/academic/subjects',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data
            .map((json) => CentralizedSubjectModel.fromJson(json).toEntity())
            .toList();
      } else {
        throw ServerException(message: 'Failed to fetch centralized subjects');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  // Achievements & Gamification
  @override
  Future<AchievementsResponse> fetchAchievements() async {
    try {
      debugPrint('[PlannerRemoteDataSource] Fetching achievements');
      final response = await dio.get('$baseUrl/planner/achievements');

      debugPrint('[PlannerRemoteDataSource] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return AchievementsResponseModel.fromJson(response.data).toEntity();
      } else {
        throw ServerException(message: 'Failed to fetch achievements');
      }
    } on DioException catch (e) {
      debugPrint('[PlannerRemoteDataSource] DioException: ${e.message}');
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<PointsHistory> fetchPointsHistory(int periodDays) async {
    try {
      debugPrint('[PlannerRemoteDataSource] Fetching points history for $periodDays days');
      final response = await dio.get(
        '$baseUrl/planner/points/history',
        queryParameters: {'period_days': periodDays},
      );

      debugPrint('[PlannerRemoteDataSource] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return PointsHistoryModel.fromJson(response.data).toEntity();
      } else {
        throw ServerException(message: 'Failed to fetch points history');
      }
    } on DioException catch (e) {
      debugPrint('[PlannerRemoteDataSource] DioException: ${e.message}');
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  // Exam Result Recording
  @override
  Future<ExamResultResponse> recordExamResult({
    required String examId,
    required double score,
    required double maxScore,
    String? notes,
  }) async {
    try {
      debugPrint('[PlannerRemoteDataSource] Recording exam result for exam: $examId');
      final response = await dio.post(
        '$baseUrl/v1/planner/exams/$examId/result',
        data: {
          'score': score,
          'max_score': maxScore,
          'percentage': maxScore > 0 ? (score / maxScore) * 100 : 0,
          if (notes != null) 'notes': notes,
        },
      );

      debugPrint('[PlannerRemoteDataSource] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final exam = ExamModel.fromJson(response.data['data']).toEntity();
        final adaptationTriggered = response.data['adaptation_triggered'] ?? false;
        final message = response.data['message'];

        return ExamResultResponse(
          exam: exam,
          adaptationTriggered: adaptationTriggered,
          message: message,
        );
      } else {
        throw ServerException(message: 'Failed to record exam result');
      }
    } on DioException catch (e) {
      debugPrint('[PlannerRemoteDataSource] DioException: ${e.message}');
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  // Schedule Adaptation
  @override
  Future<AdaptationResult> triggerAdaptation() async {
    try {
      debugPrint('[PlannerRemoteDataSource] Triggering schedule adaptation');
      final response = await dio.post('$baseUrl/planner/adapt');

      debugPrint('[PlannerRemoteDataSource] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return AdaptationResultModel.fromJson(response.data).toEntity();
      } else {
        throw ServerException(message: 'Failed to trigger adaptation');
      }
    } on DioException catch (e) {
      debugPrint('[PlannerRemoteDataSource] DioException: ${e.message}');
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  // Session Content (Curriculum Integration)
  @override
  Future<SessionContentResponse> fetchNextSessionContent({
    required String subjectId,
    required String sessionType,
    int durationMinutes = 30,
    int limit = 5,
    String? contentId, // Optional: filter to specific unit/topic
  }) async {
    try {
      debugPrint('[PlannerRemoteDataSource] Fetching session content for subject: $subjectId, type: $sessionType, contentId: $contentId');

      final queryParams = <String, dynamic>{
        'session_type': sessionType,
        'duration_minutes': durationMinutes,
        'limit': limit,
      };

      // If contentId is provided, use the content-specific endpoint
      // Otherwise use the subject-level endpoint
      final String endpoint;
      if (contentId != null) {
        endpoint = '$baseUrl/curriculum/content/$contentId/session-content';
      } else {
        endpoint = '$baseUrl/curriculum/subject/$subjectId/next-session-content';
      }

      final response = await dio.get(endpoint, queryParameters: queryParams);

      debugPrint('[PlannerRemoteDataSource] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return SessionContentResponse.fromJson(response.data);
      } else {
        throw ServerException(message: 'Failed to fetch session content');
      }
    } on DioException catch (e) {
      debugPrint('[PlannerRemoteDataSource] DioException: ${e.message}');
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<void> markContentPhaseComplete({
    required String contentId,
    required String phase,
    int durationMinutes = 0,
  }) async {
    try {
      debugPrint('[PlannerRemoteDataSource] Marking content $contentId phase $phase as complete');
      final response = await dio.post(
        '$baseUrl/curriculum/content/$contentId/progress',
        data: {
          'phase': phase,
          'duration_minutes': durationMinutes,
          'status': 'in_progress',
        },
      );

      debugPrint('[PlannerRemoteDataSource] Response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw ServerException(message: 'Failed to update content progress');
      }
    } on DioException catch (e) {
      debugPrint('[PlannerRemoteDataSource] DioException: ${e.message}');
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }
}
