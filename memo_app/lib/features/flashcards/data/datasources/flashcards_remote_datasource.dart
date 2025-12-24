import 'package:dio/dio.dart';

import '../models/flashcard_deck_model.dart';
import '../models/flashcard_model.dart';
import '../models/flashcard_stats_model.dart';
import '../models/review_session_model.dart';

/// Remote data source for flashcards feature
abstract class FlashcardsRemoteDataSource {
  /// Get flashcard decks
  Future<List<FlashcardDeckModel>> getDecks({
    int? subjectId,
    int? chapterId,
    String? search,
    int page = 1,
    int perPage = 20,
  });

  /// Get deck details with cards
  Future<FlashcardDeckModel> getDeckDetails(int deckId);

  /// Get decks with due cards
  Future<List<FlashcardDeckModel>> getDecksWithDueCards();

  /// Get cards due for review
  Future<List<FlashcardModel>> getDueCards({int? deckId, int limit = 50});

  /// Get new cards
  Future<List<FlashcardModel>> getNewCards({int? deckId, int limit = 20});

  /// Start review session
  /// If browseMode is true, returns all cards instead of just due cards
  Future<StartSessionResponse> startReviewSession({
    int? deckId,
    int? cardLimit,
    bool browseMode = false,
  });

  /// Get current session
  Future<ReviewSessionModel?> getCurrentSession();

  /// Submit answer
  Future<AnswerResultModel> submitAnswer({
    required int sessionId,
    required int cardId,
    required String response,
    int? responseTimeSeconds,
  });

  /// Complete session
  Future<ReviewSessionModel> completeSession(int sessionId);

  /// Abandon session
  Future<ReviewSessionModel> abandonSession(int sessionId);

  /// Get review history
  Future<List<ReviewSessionModel>> getReviewHistory({
    int? deckId,
    int page = 1,
    int perPage = 20,
  });

  /// Get stats
  Future<FlashcardStatsModel> getStats({int? deckId});

  /// Get forecast
  Future<List<DailyForecastModel>> getForecast({int days = 7});

  /// Get heatmap
  Future<List<HeatmapEntryModel>> getHeatmap({int days = 365});

  /// Get today summary
  Future<TodaySummaryModel> getTodaySummary();

  /// Get deck stats
  Future<DeckStatsModel> getDeckStats(int deckId);
}

class FlashcardsRemoteDataSourceImpl implements FlashcardsRemoteDataSource {
  final Dio dio;

  // API endpoints
  static const String _decksEndpoint = '/v1/flashcard-decks';
  static const String _cardsEndpoint = '/v1/flashcards';
  static const String _reviewsEndpoint = '/v1/flashcard-reviews';
  static const String _statsEndpoint = '/v1/flashcard-stats';

  FlashcardsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<FlashcardDeckModel>> getDecks({
    int? subjectId,
    int? chapterId,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await dio.get(
      _decksEndpoint,
      queryParameters: {
        if (subjectId != null) 'subject_id': subjectId,
        if (chapterId != null) 'chapter_id': chapterId,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'per_page': perPage,
      },
    );

    final List<dynamic> decksJson = response.data['data']['decks'];
    return decksJson
        .map((json) => FlashcardDeckModel.fromJson(json))
        .toList();
  }

  @override
  Future<FlashcardDeckModel> getDeckDetails(int deckId) async {
    final response = await dio.get('$_decksEndpoint/$deckId');
    return FlashcardDeckModel.fromJson(response.data['data']['deck']);
  }

  @override
  Future<List<FlashcardDeckModel>> getDecksWithDueCards() async {
    final response = await dio.get('$_decksEndpoint/due');
    final List<dynamic> decksJson = response.data['data']['decks'];
    return decksJson
        .map((json) => FlashcardDeckModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<FlashcardModel>> getDueCards({int? deckId, int limit = 50}) async {
    final response = await dio.get(
      '$_cardsEndpoint/due',
      queryParameters: {
        if (deckId != null) 'deck_id': deckId,
        'limit': limit,
      },
    );

    final List<dynamic> cardsJson = response.data['data']['due_cards'];
    return cardsJson.map((json) => FlashcardModel.fromJson(json)).toList();
  }

  @override
  Future<List<FlashcardModel>> getNewCards({int? deckId, int limit = 20}) async {
    final response = await dio.get(
      '$_cardsEndpoint/new',
      queryParameters: {
        if (deckId != null) 'deck_id': deckId,
        'limit': limit,
      },
    );

    final List<dynamic> cardsJson = response.data['data']['new_cards'];
    return cardsJson.map((json) => FlashcardModel.fromJson(json)).toList();
  }

  @override
  Future<StartSessionResponse> startReviewSession({
    int? deckId,
    int? cardLimit,
    bool browseMode = false,
  }) async {
    final response = await dio.post(
      '$_reviewsEndpoint/start',
      data: {
        if (deckId != null) 'deck_id': deckId,
        if (cardLimit != null) 'card_limit': cardLimit,
        'browse_mode': browseMode,
      },
    );

    final data = response.data['data'];
    final session = ReviewSessionModel.fromJson(data['session']);
    final List<dynamic> cardsJson = data['cards'];
    final cards = cardsJson.map((json) => FlashcardModel.fromJson(json)).toList();
    final summary = data['summary'];

    return StartSessionResponse(
      session: session,
      cards: cards,
      totalDue: summary['due'] ?? 0,
      totalNew: summary['new'] ?? 0,
    );
  }

  @override
  Future<ReviewSessionModel?> getCurrentSession() async {
    final response = await dio.get('$_reviewsEndpoint/current');
    final sessionData = response.data['data']['session'];
    if (sessionData == null) return null;
    return ReviewSessionModel.fromJson(sessionData);
  }

  @override
  Future<AnswerResultModel> submitAnswer({
    required int sessionId,
    required int cardId,
    required String response,
    int? responseTimeSeconds,
  }) async {
    final apiResponse = await dio.post(
      '$_reviewsEndpoint/$sessionId/answer',
      data: {
        'card_id': cardId,
        'response': response,
        if (responseTimeSeconds != null)
          'response_time_seconds': responseTimeSeconds,
      },
    );

    return AnswerResultModel.fromJson(apiResponse.data['data']);
  }

  @override
  Future<ReviewSessionModel> completeSession(int sessionId) async {
    final response = await dio.post('$_reviewsEndpoint/$sessionId/complete');
    return ReviewSessionModel.fromJson(response.data['data']['session']);
  }

  @override
  Future<ReviewSessionModel> abandonSession(int sessionId) async {
    final response = await dio.post('$_reviewsEndpoint/$sessionId/abandon');
    return ReviewSessionModel.fromJson(response.data['data']['session']);
  }

  @override
  Future<List<ReviewSessionModel>> getReviewHistory({
    int? deckId,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await dio.get(
      '$_reviewsEndpoint/history',
      queryParameters: {
        if (deckId != null) 'deck_id': deckId,
        'page': page,
        'per_page': perPage,
      },
    );

    final List<dynamic> sessionsJson = response.data['data']['sessions'];
    return sessionsJson
        .map((json) => ReviewSessionModel.fromJson(json))
        .toList();
  }

  @override
  Future<FlashcardStatsModel> getStats({int? deckId}) async {
    final response = await dio.get(
      _statsEndpoint,
      queryParameters: {
        if (deckId != null) 'deck_id': deckId,
      },
    );

    return FlashcardStatsModel.fromJson(response.data['data']['stats']);
  }

  @override
  Future<List<DailyForecastModel>> getForecast({int days = 7}) async {
    final response = await dio.get(
      '$_statsEndpoint/forecast',
      queryParameters: {'days': days},
    );

    final List<dynamic> forecastJson = response.data['data']['forecast'];
    return forecastJson
        .map((json) => DailyForecastModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<HeatmapEntryModel>> getHeatmap({int days = 365}) async {
    final response = await dio.get(
      '$_statsEndpoint/heatmap',
      queryParameters: {'days': days},
    );

    final List<dynamic> heatmapJson = response.data['data']['heatmap'];
    return heatmapJson
        .map((json) => HeatmapEntryModel.fromJson(json))
        .toList();
  }

  @override
  Future<TodaySummaryModel> getTodaySummary() async {
    final response = await dio.get('$_statsEndpoint/today');
    final data = response.data['data'];

    return TodaySummaryModel(
      modelReviewsCompleted: data['today']['reviews_completed'] ?? 0,
      modelSessionsCompleted: data['today']['sessions_completed'] ?? 0,
      modelTimeStudied: data['today']['time_studied'] ?? '00:00:00',
      modelTimeStudiedSeconds: data['today']['time_studied_seconds'] ?? 0,
      modelCurrentStreak: data['streak']['current'] ?? 0,
      modelLongestStreak: data['streak']['longest'] ?? 0,
      modelCardsDue: data['overall']['cards_due'] ?? 0,
      modelCardsMastered: data['overall']['cards_mastered'] ?? 0,
      modelRetentionRate: (data['overall']['retention_rate'] ?? 0).toDouble(),
    );
  }

  @override
  Future<DeckStatsModel> getDeckStats(int deckId) async {
    final response = await dio.get('$_statsEndpoint/deck/$deckId');
    return DeckStatsModel.fromJson(response.data['data']);
  }
}

/// Response from starting a review session
class StartSessionResponse {
  final ReviewSessionModel session;
  final List<FlashcardModel> cards;
  final int totalDue;
  final int totalNew;

  StartSessionResponse({
    required this.session,
    required this.cards,
    required this.totalDue,
    required this.totalNew,
  });
}
