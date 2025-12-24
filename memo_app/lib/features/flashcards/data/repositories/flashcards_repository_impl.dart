import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/flashcard_deck_entity.dart';
import '../../domain/entities/flashcard_entity.dart';
import '../../domain/entities/flashcard_stats_entity.dart';
import '../../domain/entities/review_session_entity.dart';
import '../../domain/repositories/flashcards_repository.dart';
import '../datasources/flashcards_remote_datasource.dart';

class FlashcardsRepositoryImpl implements FlashcardsRepository {
  final FlashcardsRemoteDataSource remoteDataSource;

  FlashcardsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<FlashcardDeckEntity>>> getDecks({
    int? subjectId,
    int? chapterId,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final decks = await remoteDataSource.getDecks(
        subjectId: subjectId,
        chapterId: chapterId,
        search: search,
        page: page,
        perPage: perPage,
      );
      return Right(decks);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('فشل تحميل مجموعات البطاقات: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FlashcardDeckEntity>> getDeckDetails(int deckId) async {
    try {
      final deck = await remoteDataSource.getDeckDetails(deckId);
      return Right(deck);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('فشل تحميل تفاصيل المجموعة: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FlashcardDeckEntity>>> getDecksWithDueCards() async {
    try {
      final decks = await remoteDataSource.getDecksWithDueCards();
      return Right(decks);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('فشل تحميل المجموعات: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FlashcardEntity>>> getDueCards({
    int? deckId,
    int limit = 50,
  }) async {
    try {
      final cards = await remoteDataSource.getDueCards(
        deckId: deckId,
        limit: limit,
      );
      return Right(cards);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('فشل تحميل البطاقات المستحقة: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FlashcardEntity>>> getNewCards({
    int? deckId,
    int limit = 20,
  }) async {
    try {
      final cards = await remoteDataSource.getNewCards(
        deckId: deckId,
        limit: limit,
      );
      return Right(cards);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('فشل تحميل البطاقات الجديدة: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ReviewSessionData>> startReviewSession({
    int? deckId,
    int? cardLimit,
    bool browseMode = false,
  }) async {
    try {
      final response = await remoteDataSource.startReviewSession(
        deckId: deckId,
        cardLimit: cardLimit,
        browseMode: browseMode,
      );

      return Right(ReviewSessionData(
        session: response.session,
        cards: response.cards,
        totalDue: response.totalDue,
        totalNew: response.totalNew,
      ));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('فشل بدء جلسة المراجعة: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ReviewSessionEntity?>> getCurrentSession() async {
    try {
      final session = await remoteDataSource.getCurrentSession();
      return Right(session);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('فشل تحميل الجلسة الحالية: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AnswerResult>> submitAnswer({
    required int sessionId,
    required int cardId,
    required String response,
    int? responseTimeSeconds,
  }) async {
    try {
      final result = await remoteDataSource.submitAnswer(
        sessionId: sessionId,
        cardId: cardId,
        response: response,
        responseTimeSeconds: responseTimeSeconds,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('فشل إرسال الإجابة: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ReviewSessionEntity>> completeSession(
      int sessionId) async {
    try {
      final session = await remoteDataSource.completeSession(sessionId);
      return Right(session);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('فشل إكمال الجلسة: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ReviewSessionEntity>> abandonSession(
      int sessionId) async {
    try {
      final session = await remoteDataSource.abandonSession(sessionId);
      return Right(session);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('فشل إلغاء الجلسة: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ReviewSessionEntity>>> getReviewHistory({
    int? deckId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final sessions = await remoteDataSource.getReviewHistory(
        deckId: deckId,
        page: page,
        perPage: perPage,
      );
      return Right(sessions);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('فشل تحميل سجل المراجعات: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FlashcardStatsEntity>> getStats({int? deckId}) async {
    try {
      final stats = await remoteDataSource.getStats(deckId: deckId);
      return Right(stats);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('فشل تحميل الإحصائيات: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DailyForecast>>> getForecast({int days = 7}) async {
    try {
      final forecast = await remoteDataSource.getForecast(days: days);
      return Right(forecast);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('فشل تحميل التوقعات: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<HeatmapEntry>>> getHeatmap({int days = 365}) async {
    try {
      final heatmap = await remoteDataSource.getHeatmap(days: days);
      return Right(heatmap);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('فشل تحميل خريطة النشاط: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, TodaySummary>> getTodaySummary() async {
    try {
      final summary = await remoteDataSource.getTodaySummary();
      return Right(summary);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('فشل تحميل ملخص اليوم: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DeckStats>> getDeckStats(int deckId) async {
    try {
      final stats = await remoteDataSource.getDeckStats(deckId);
      return Right(stats);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('فشل تحميل إحصائيات المجموعة: ${e.toString()}'));
    }
  }

  /// Handle Dio errors and convert to Failures
  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const NetworkFailure('انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت.');
    }

    if (e.type == DioExceptionType.connectionError) {
      return const NetworkFailure('فشل الاتصال بالخادم. تحقق من اتصالك بالإنترنت.');
    }

    final statusCode = e.response?.statusCode;
    final message = e.response?.data?['message'] as String?;

    switch (statusCode) {
      case 401:
        return AuthenticationFailure(message ?? 'يرجى تسجيل الدخول');
      case 403:
        return const AuthenticationFailure('غير مصرح لك بهذا الإجراء');
      case 404:
        return ServerFailure(message ?? 'المورد غير موجود');
      case 422:
        return ServerFailure(message ?? 'بيانات غير صالحة');
      case 429:
        return const ServerFailure('تم تجاوز الحد الأقصى للطلبات. يرجى المحاولة لاحقاً.');
      case 500:
      case 502:
      case 503:
        return const ServerFailure('خطأ في الخادم. يرجى المحاولة لاحقاً.');
      default:
        return ServerFailure(message ?? 'حدث خطأ غير متوقع');
    }
  }
}
