import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../entities/academic_entities.dart';

/// Authentication repository interface (Domain layer)
abstract class AuthRepository {
  /// Login with email, password and device ID
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
    required String deviceId,
  });

  /// Login or register with Google
  Future<Either<Failure, UserEntity>> loginWithGoogle({
    required String idToken,
    required String deviceId,
  });

  /// Register new user
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    required String deviceId,
  });

  /// Validate token and get current user
  Future<Either<Failure, UserEntity>> validateToken();

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Logout from all devices
  Future<Either<Failure, void>> logoutAll();

  /// Check if user is authenticated (has valid token)
  Future<bool> isAuthenticated();

  /// Get cached user data
  Future<Either<Failure, UserEntity>> getCachedUser();

  /// Get all academic phases
  Future<Either<Failure, AcademicPhasesResponse>> getAcademicPhases();

  /// Get academic years for a specific phase
  Future<Either<Failure, AcademicYearsResponse>> getAcademicYears(int phaseId);

  /// Get academic streams for a specific year
  Future<Either<Failure, AcademicStreamsResponse>> getAcademicStreams(
    int yearId,
  );

  /// Update academic profile
  Future<Either<Failure, UserEntity>> updateAcademicProfile({
    required int phaseId,
    required int yearId,
    required int streamId,
  });
}
