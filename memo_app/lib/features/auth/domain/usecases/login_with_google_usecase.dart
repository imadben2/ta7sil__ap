import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Login with Google use case
class LoginWithGoogleUseCase {
  final AuthRepository repository;

  LoginWithGoogleUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String idToken,
    required String deviceId,
  }) async {
    return await repository.loginWithGoogle(
      idToken: idToken,
      deviceId: deviceId,
    );
  }
}
