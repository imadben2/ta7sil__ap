import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/stats_model.dart';
import '../models/study_session_model.dart';
import '../models/subject_progress_model.dart';

abstract class HomeRemoteDataSource {
  Future<StatsModel> getStats();
  Future<List<StudySessionModel>> getTodaySessions();
  Future<List<SubjectProgressModel>> getSubjectsProgress();
  Future<void> markSessionCompleted(int sessionId);
  Future<void> markSessionMissed(int sessionId);
  Future<void> updateStudyTime(int minutes);
  Future<Map<String, dynamic>> getWeeklyProgress();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient client;

  HomeRemoteDataSourceImpl({required this.client});

  @override
  Future<StatsModel> getStats() async {
    print('📊 HOME_DATASOURCE: Fetching stats from API');

    try {
      final response = await client.get(ApiConstants.dashboardStats);
      return StatsModel.fromJson(response.data['data']);
    } catch (e) {
      print('❌ HOME_DATASOURCE: Error fetching stats: $e');
      rethrow;
    }
  }

  @override
  Future<List<StudySessionModel>> getTodaySessions() async {
    print('📅 HOME_DATASOURCE: Fetching today sessions from API');

    try {
      final response = await client.get(ApiConstants.todaySessions);
      final List<dynamic> sessions = response.data['data'];
      return sessions.map((json) => StudySessionModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ HOME_DATASOURCE: Error fetching today sessions: $e');
      rethrow;
    }
  }

  @override
  Future<List<SubjectProgressModel>> getSubjectsProgress() async {
    print('🔶 HOME_DATASOURCE: Fetching subjects from Content Library API');

    try {
      // Fetch subjects from Content Library API
      final response = await client.get(ApiConstants.subjects);
      final List<dynamic> subjectsData = response.data['data'];

      // Convert to SubjectProgressModel and sort by coefficient (highest first)
      final subjects = subjectsData.map((json) {
        // Safely handle coefficient field (can be null, int, or double)
        final coefficientValue = json['coefficient'];
        final coefficient = coefficientValue is int
            ? coefficientValue.toDouble()
            : coefficientValue is double
            ? coefficientValue
            : 1.0;

        return SubjectProgressModel(
          id: json['id'] as int,
          name: json['name_en'] as String? ?? json['name_ar'] as String,
          nameAr: json['name_ar'] as String,
          color: json['color'] as String? ?? '#4CAF50',
          coefficient: coefficient,
          totalLessons: 0, // Not provided by API yet
          completedLessons: 0, // Not provided by API yet
          totalQuizzes: 0, // Not provided by API yet
          completedQuizzes: 0, // Not provided by API yet
          averageScore: 0.0, // Not provided by API yet
          nextExamDate: null, // Not provided by API yet
          iconEmoji: _getIconForSubject(json['icon'] as String?),
        );
      }).toList();

      // Sort by coefficient in descending order (highest first)
      subjects.sort((a, b) => b.coefficient.compareTo(a.coefficient));

      // Return only top 4 subjects with highest coefficient
      return subjects.take(4).toList();
    } catch (e) {
      print('❌ HOME_DATASOURCE: Error fetching subjects: $e');
      rethrow;
    }
  }

  String _getIconForSubject(String? iconString) {
    // Map icon strings to emoji
    final iconMap = {
      'calculator': '📐',
      'atom': '⚡',
      'leaf': '🌿',
      'book': '📚',
      'language': '🌍',
      'globe': '🌍',
      'pen': '✏️',
      'history': '🏛️',
      'mosque': '🕌',
      'gavel': '⚖️',
    };

    if (iconString != null && iconMap.containsKey(iconString.toLowerCase())) {
      return iconMap[iconString.toLowerCase()]!;
    }
    return '📖';
  }

  @override
  Future<void> markSessionCompleted(int sessionId) async {
    print('✅ HOME_DATASOURCE: Marking session $sessionId as completed');

    try {
      await client.post(
        '${ApiConstants.plannerSessions}/$sessionId/complete',
        data: {'status': 'completed'},
      );
    } catch (e) {
      print('❌ HOME_DATASOURCE: Error marking session completed: $e');
      rethrow;
    }
  }

  @override
  Future<void> markSessionMissed(int sessionId) async {
    print('⏭️ HOME_DATASOURCE: Marking session $sessionId as missed');

    try {
      await client.post(
        '${ApiConstants.plannerSessions}/$sessionId/status',
        data: {'status': 'missed'},
      );
    } catch (e) {
      print('❌ HOME_DATASOURCE: Error marking session missed: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateStudyTime(int minutes) async {
    print('⏱️ HOME_DATASOURCE: Updating study time with $minutes minutes');

    try {
      await client.post(
        ApiConstants.updateStudyTime,
        data: {
          'minutes': minutes,
          'date': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('❌ HOME_DATASOURCE: Error updating study time: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getWeeklyProgress() async {
    print('📈 HOME_DATASOURCE: Fetching weekly progress from API');

    try {
      final response = await client.get(ApiConstants.weeklyStats);
      return response.data['data'];
    } catch (e) {
      print('❌ HOME_DATASOURCE: Error fetching weekly progress: $e');
      rethrow;
    }
  }
}
