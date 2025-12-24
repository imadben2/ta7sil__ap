import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

/// Use Case: تغيير كلمة المرور
class ChangePasswordUseCase {
  final ProfileRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(ChangePasswordParams params) async {
    return await repository.changePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
      newPasswordConfirmation: params.newPasswordConfirmation,
    );
  }
}

class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });
}
