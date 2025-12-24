import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

/// Use case for logging out a specific device session
///
/// This use case handles remote logout of a device session:
/// 1. Validates session ID is valid
/// 2. Calls repository to invalidate session on backend
/// 3. Returns success or failure
///
/// Backend behavior:
/// - Invalidates the specific device's access token
/// - User on that device will be forced to login again
/// - Current device is unaffected
///
/// Usage:
/// ```dart
/// final useCase = LogoutDeviceUseCase(profileRepository);
/// final result = await useCase(LogoutDeviceParams(sessionId: 123));
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (_) => print('Device logged out successfully'),
/// );
/// ```
class LogoutDeviceUseCase {
  final ProfileRepository repository;

  LogoutDeviceUseCase(this.repository);

  /// Execute the logout device operation
  ///
  /// Returns:
  /// - Right(void): Device logged out successfully
  /// - Left(Failure): Operation failed (validation, network, server error)
  Future<Either<Failure, void>> call(LogoutDeviceParams params) async {
    // Validate session ID
    if (params.sessionId <= 0) {
      return Left(ValidationFailure('معرف الجلسة غير صالح'));
    }

    // Call repository to logout device
    return await repository.logoutDevice(params.sessionId);
  }
}

/// Parameters for logout device use case
class LogoutDeviceParams {
  /// Device session ID to logout
  final int sessionId;

  const LogoutDeviceParams({
    required this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
    };
  }
}
