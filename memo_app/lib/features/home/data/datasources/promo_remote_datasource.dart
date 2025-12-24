import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/promo_model.dart';

/// Abstract interface for promo remote data source
abstract class PromoRemoteDataSource {
  /// Fetch all active promos from API
  Future<PromoApiResponse> getPromos();

  /// Record a click on a promo (for analytics tracking)
  Future<void> recordPromoClick(int promoId);
}

/// Implementation of promo remote data source
class PromoRemoteDataSourceImpl implements PromoRemoteDataSource {
  final Dio dio;

  PromoRemoteDataSourceImpl({required this.dio});

  @override
  Future<PromoApiResponse> getPromos() async {
    try {
      final response = await dio.get(ApiConstants.promos);

      if (response.statusCode == 200 && response.data != null) {
        return PromoApiResponse.fromJson(response.data as Map<String, dynamic>);
      }

      throw ServerException(message: 'فشل في تحميل العروض الترويجية');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw TimeoutException(message: 'انتهت مهلة الاتصال');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'لا يوجد اتصال بالإنترنت');
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        if (statusCode != null && statusCode >= 500) {
          throw ServerException(message: 'خطأ في الخادم');
        }
        if (statusCode == 404) {
          throw NotFoundException(message: 'العروض غير متوفرة');
        }
      }

      throw ServerException(message: 'فشل في تحميل العروض: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ParseException(message: 'خطأ في معالجة البيانات');
    }
  }

  @override
  Future<void> recordPromoClick(int promoId) async {
    try {
      await dio.post(
        ApiConstants.promoClick(promoId),
        data: {'platform': 'mobile'},
      );
    } catch (e) {
      // Silent fail for analytics tracking
      // Don't throw error as this shouldn't affect user experience
    }
  }
}
