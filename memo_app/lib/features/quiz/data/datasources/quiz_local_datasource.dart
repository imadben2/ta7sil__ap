import 'package:hive/hive.dart';
import '../models/quiz_model.dart';
import '../models/attempt_model.dart';

/// Local data source for quiz feature
///
/// Handles offline caching and answer queue
abstract class QuizLocalDataSource {
  /// Cache quiz list
  Future<void> cacheQuizzes(List<QuizModel> quizzes, String key);

  /// Get cached quizzes
  Future<List<QuizModel>?> getCachedQuizzes(String key);

  /// Cache quiz details
  Future<void> cacheQuizDetails(QuizModel quiz);

  /// Get cached quiz details
  Future<QuizModel?> getCachedQuizDetails(int quizId);

  /// Cache current attempt
  Future<void> cacheCurrentAttempt(QuizAttemptModel attempt);

  /// Get cached current attempt
  Future<QuizAttemptModel?> getCachedCurrentAttempt();

  /// Clear current attempt cache
  Future<void> clearCurrentAttempt();

  /// Queue answer for sync (offline support)
  Future<void> queueAnswer({
    required int attemptId,
    required int questionId,
    required dynamic answer,
    required DateTime timestamp,
  });

  /// Get queued answers
  Future<List<Map<String, dynamic>>> getQueuedAnswers();

  /// Clear queued answer
  Future<void> clearQueuedAnswer(String id);

  /// Clear all caches
  Future<void> clearAll();
}

class QuizLocalDataSourceImpl implements QuizLocalDataSource {
  static const String _quizzesBox = 'quizzes';
  static const String _quizDetailsBox = 'quiz_details';
  static const String _attemptBox = 'quiz_attempt';
  static const String _answerQueueBox = 'answer_queue';

  Future<Box<dynamic>> _getBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  @override
  Future<void> cacheQuizzes(List<QuizModel> quizzes, String key) async {
    try {
      final box = await _getBox(_quizzesBox);
      final jsonList = quizzes.map((q) => q.toJson()).toList();
      await box.put(key, jsonList);
    } catch (e) {
      throw Exception('فشل حفظ الاختبارات في الذاكرة المؤقتة: $e');
    }
  }

  @override
  Future<List<QuizModel>?> getCachedQuizzes(String key) async {
    try {
      final box = await _getBox(_quizzesBox);
      final cached = box.get(key);

      if (cached == null) return null;

      final List<dynamic> jsonList = cached as List<dynamic>;
      return jsonList
          .map((json) => QuizModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheQuizDetails(QuizModel quiz) async {
    try {
      final box = await _getBox(_quizDetailsBox);
      await box.put('quiz_${quiz.modelId}', quiz.toJson());
    } catch (e) {
      throw Exception('فشل حفظ تفاصيل الاختبار: $e');
    }
  }

  @override
  Future<QuizModel?> getCachedQuizDetails(int quizId) async {
    try {
      final box = await _getBox(_quizDetailsBox);
      final cached = box.get('quiz_$quizId');

      if (cached == null) return null;

      return QuizModel.fromJson(Map<String, dynamic>.from(cached));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheCurrentAttempt(QuizAttemptModel attempt) async {
    try {
      final box = await _getBox(_attemptBox);
      await box.put('current_attempt', attempt.toJson());
    } catch (e) {
      throw Exception('فشل حفظ المحاولة الحالية: $e');
    }
  }

  @override
  Future<QuizAttemptModel?> getCachedCurrentAttempt() async {
    try {
      final box = await _getBox(_attemptBox);
      final cached = box.get('current_attempt');

      if (cached == null) return null;

      return QuizAttemptModel.fromJson(Map<String, dynamic>.from(cached));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCurrentAttempt() async {
    try {
      final box = await _getBox(_attemptBox);
      await box.delete('current_attempt');
    } catch (e) {
      throw Exception('فشل مسح المحاولة الحالية: $e');
    }
  }

  @override
  Future<void> queueAnswer({
    required int attemptId,
    required int questionId,
    required dynamic answer,
    required DateTime timestamp,
  }) async {
    try {
      final box = await _getBox(_answerQueueBox);
      final id =
          '${attemptId}_${questionId}_${timestamp.millisecondsSinceEpoch}';

      await box.put(id, {
        'id': id,
        'attempt_id': attemptId,
        'question_id': questionId,
        'answer': answer,
        'timestamp': timestamp.toIso8601String(),
        'synced': false,
      });
    } catch (e) {
      throw Exception('فشل إضافة الإجابة إلى قائمة الانتظار: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getQueuedAnswers() async {
    try {
      final box = await _getBox(_answerQueueBox);
      final List<Map<String, dynamic>> answers = [];

      for (var key in box.keys) {
        final value = box.get(key);
        if (value != null) {
          answers.add(Map<String, dynamic>.from(value));
        }
      }

      return answers;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> clearQueuedAnswer(String id) async {
    try {
      final box = await _getBox(_answerQueueBox);
      await box.delete(id);
    } catch (e) {
      throw Exception('فشل مسح الإجابة من قائمة الانتظار: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      final boxes = [
        _quizzesBox,
        _quizDetailsBox,
        _attemptBox,
        _answerQueueBox,
      ];
      for (var boxName in boxes) {
        final box = await _getBox(boxName);
        await box.clear();
      }
    } catch (e) {
      throw Exception('فشل مسح الذاكرة المؤقتة: $e');
    }
  }
}
