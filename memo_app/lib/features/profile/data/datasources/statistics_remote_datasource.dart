import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/statistics_model.dart';

/// مصدر البيانات البعيد للإحصائيات
abstract class StatisticsRemoteDataSource {
  /// GET /api/statistics
  Future<StatisticsModel> getStatistics();

  /// GET /api/statistics/weekly
  Future<List<WeeklyDataPointModel>> getWeeklyChart({
    DateTime? startDate,
    DateTime? endDate,
  });
}

class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  final DioClient dioClient;

  StatisticsRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<StatisticsModel> getStatistics() async {
    try {
      final response = await dioClient.get('/statistics');

      if (response.statusCode == 200) {
        return StatisticsModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'فشل في جلب الإحصائيات',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'خطأ في الاتصال بالخادم',
      );
    }
  }

  @override
  Future<List<WeeklyDataPointModel>> getWeeklyChart({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await dioClient.get(
        '/statistics/weekly',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => WeeklyDataPointModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message:
              response.data['message'] ?? 'فشل في جلب بيانات الرسم البياني',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'خطأ في الاتصال بالخادم',
      );
    }
  }
}
