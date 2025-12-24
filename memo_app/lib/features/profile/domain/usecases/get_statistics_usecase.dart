import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/statistics_entity.dart';
import '../repositories/statistics_repository.dart';

/// Use Case: جلب الإحصائيات
class GetStatisticsUseCase {
  final StatisticsRepository repository;

  GetStatisticsUseCase(this.repository);

  Future<Either<Failure, StatisticsEntity>> call() async {
    return await repository.getStatistics();
  }
}
