import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/settings_entity.dart';
import '../repositories/settings_repository.dart';

/// Use Case: تحديث الإعدادات
class UpdateSettingsUseCase {
  final SettingsRepository repository;

  UpdateSettingsUseCase(this.repository);

  Future<Either<Failure, SettingsEntity>> call(SettingsEntity settings) async {
    return await repository.updateSettings(settings);
  }
}
