import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/settings_entity.dart';
import '../repositories/settings_repository.dart';

/// Use Case: جلب الإعدادات
class GetSettingsUseCase {
  final SettingsRepository repository;

  GetSettingsUseCase(this.repository);

  Future<Either<Failure, SettingsEntity>> call() async {
    return await repository.getSettings();
  }
}
