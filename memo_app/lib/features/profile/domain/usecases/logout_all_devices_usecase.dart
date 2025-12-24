import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

import '../../../../core/usecase/usecase.dart';

/// Use case for logging out all other device sessions
///
/// This use case handles remote logout of all devices except current:
/// 1. Calls repository to invalidate all other sessions on backend
/// 2. Returns success or failure
///
/// Backend behavior:
/// - Invalidates all access tokens except the current one
/// - Users on other devices will be forced to login again
/// - Current device session remains active
/// - Useful for security (password changed, suspicious activity)
///
/// Usage:
/// ```dart
/// final useCase = LogoutAllDevicesUseCase(profileRepository);
/// final result = await useCase(NoParams());
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (_) => print('All other devices logged out'),
/// );
/// ```
class LogoutAllDevicesUseCase implements UseCase<void, NoParams> {
  final ProfileRepository repository;

  LogoutAllDevicesUseCase(this.repository);

  /// Execute the logout all other devices operation
  ///
  /// Returns:
  /// - Right(void): All other devices logged out successfully
  /// - Left(Failure): Operation failed (network, server error)
  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    // Call repository to logout all other devices
    return await repository.logoutAllOtherDevices();
  }
}
