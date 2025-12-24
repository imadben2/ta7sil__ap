import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/academic_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

/// Implementation of authentication repository (Data layer)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final SecureStorageService secureStorage;
  final Connectivity connectivity;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.secureStorage,
    required this.connectivity,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
    required String deviceId,
  }) async {
    try {
      print('🔵 AUTH_REPO: login called for email: $email');
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      print('🔵 AUTH_REPO: Connectivity result: $connectivityResult');
      // Note: On Android emulator, connectivity may report 'none' even when host is reachable
      // For production, keep this check. For development/emulator testing, you may skip it.
      if (connectivityResult.contains(ConnectivityResult.none)) {
        print('⚠️ AUTH_REPO: Connectivity reports none, but attempting connection anyway (emulator workaround)');
        // Uncomment the following lines to enforce connectivity check in production:
        // print('❌ AUTH_REPO: No network connectivity');
        // return const Left(NetworkFailure());
      }

      // Call remote API
      print('🔵 AUTH_REPO: Calling remoteDataSource.login()...');
      final response = await remoteDataSource.login(email, password, deviceId);
      print('✅ AUTH_REPO: Received login response');
      print('   UserModel ID: ${response.user.id}');
      print('   UserModel email: ${response.user.email}');
      print('   UserModel name: ${response.user.name}');
      print('   UserModel academicPhaseId: ${response.user.academicPhaseId}');
      print('   UserModel academicYearId: ${response.user.academicYearId}');
      print('   UserModel streamId: ${response.user.streamId}');

      // Save tokens
      await secureStorage.saveToken(response.token);
      if (response.refreshToken != null) {
        await secureStorage.saveRefreshToken(response.refreshToken!);
      }

      // Save device ID
      await secureStorage.saveDeviceId(deviceId);

      // Cache user data
      await localDataSource.cacheUser(response.user);

      print('🔵 AUTH_REPO: Converting user model to entity...');
      final entity = response.user.toEntity();
      print('✅ AUTH_REPO: Successfully converted to entity');

      return Right(entity);
    } on DeviceMismatchException catch (e) {
      print('❌ AUTH_REPO: DeviceMismatchException: ${e.message}');
      return Left(DeviceMismatchFailure(e.message));
    } on AuthenticationException catch (e) {
      print('❌ AUTH_REPO: AuthenticationException: ${e.message}');
      return Left(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      print('❌ AUTH_REPO: NetworkException: ${e.message}');
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      print('❌ AUTH_REPO: ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } on ClientException catch (e) {
      print('❌ AUTH_REPO: ClientException: ${e.message}');
      return Left(ClientFailure(e.message));
    } on TimeoutException catch (e) {
      print('❌ AUTH_REPO: TimeoutException: ${e.message}');
      return Left(TimeoutFailure(e.message));
    } catch (e, stackTrace) {
      print('💥 AUTH_REPO: Exception in login');
      print('💥 AUTH_REPO: Exception: $e');
      print('💥 AUTH_REPO: StackTrace: $stackTrace');
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle({
    required String idToken,
    required String deviceId,
  }) async {
    try {
      print('🔵 AUTH_REPO: loginWithGoogle called');

      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      print('🔵 AUTH_REPO: Connectivity result: $connectivityResult');
      if (connectivityResult.contains(ConnectivityResult.none)) {
        print('⚠️ AUTH_REPO: Connectivity reports none, but attempting connection anyway');
      }

      // Call remote API
      print('🔵 AUTH_REPO: Calling remoteDataSource.loginWithGoogle()...');
      final response = await remoteDataSource.loginWithGoogle(idToken, deviceId);
      print('✅ AUTH_REPO: Received Google login response');
      print('   UserModel ID: ${response.user.id}');
      print('   UserModel email: ${response.user.email}');
      print('   UserModel name: ${response.user.name}');

      // Save tokens
      await secureStorage.saveToken(response.token);
      if (response.refreshToken != null) {
        await secureStorage.saveRefreshToken(response.refreshToken!);
      }

      // Save device ID
      await secureStorage.saveDeviceId(deviceId);

      // Cache user data
      await localDataSource.cacheUser(response.user);

      print('🔵 AUTH_REPO: Converting user model to entity...');
      final entity = response.user.toEntity();
      print('✅ AUTH_REPO: Successfully converted to entity');

      return Right(entity);
    } on DeviceMismatchException catch (e) {
      print('❌ AUTH_REPO: DeviceMismatchException: ${e.message}');
      return Left(DeviceMismatchFailure(e.message));
    } on AuthenticationException catch (e) {
      print('❌ AUTH_REPO: AuthenticationException: ${e.message}');
      return Left(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      print('❌ AUTH_REPO: NetworkException: ${e.message}');
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      print('❌ AUTH_REPO: ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } on ClientException catch (e) {
      print('❌ AUTH_REPO: ClientException: ${e.message}');
      return Left(ClientFailure(e.message));
    } on TimeoutException catch (e) {
      print('❌ AUTH_REPO: TimeoutException: ${e.message}');
      return Left(TimeoutFailure(e.message));
    } catch (e, stackTrace) {
      print('💥 AUTH_REPO: Exception in loginWithGoogle');
      print('💥 AUTH_REPO: Exception: $e');
      print('💥 AUTH_REPO: StackTrace: $stackTrace');
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    required String deviceId,
  }) async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure());
      }

      // Prepare registration data
      final data = {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        if (phone != null) 'phone': phone,
        'device_uuid': deviceId,
      };

      // Call remote API
      final response = await remoteDataSource.register(data);

      // Save tokens
      await secureStorage.saveToken(response.token);
      if (response.refreshToken != null) {
        await secureStorage.saveRefreshToken(response.refreshToken!);
      }

      // Save device ID
      await secureStorage.saveDeviceId(deviceId);

      // Cache user data
      await localDataSource.cacheUser(response.user);

      return Right(response.user.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ClientException catch (e) {
      return Left(ClientFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> validateToken() async {
    try {
      print('🔵 AUTH_REPO: validateToken called');

      // Always fetch fresh data from API first
      print('🔵 AUTH_REPO: Calling remoteDataSource.validateToken()...');
      final user = await remoteDataSource.validateToken();
      print('✅ AUTH_REPO: Received user model from remote');
      print('   UserModel ID: ${user.id}');
      print('   UserModel email: ${user.email}');
      print('   UserModel name: ${user.name}');
      print('   UserModel academicPhaseId: ${user.academicPhaseId}');
      print('   UserModel academicYearId: ${user.academicYearId}');
      print('   UserModel streamId: ${user.streamId}');

      // Cache the fresh data
      await localDataSource.cacheUser(user);

      print('🔵 AUTH_REPO: Converting user model to entity...');
      final entity = user.toEntity();
      print('✅ AUTH_REPO: Successfully converted to entity');

      return Right(entity);
    } on AuthenticationException catch (e) {
      print('❌ AUTH_REPO: AuthenticationException: ${e.message}');
      return Left(AuthenticationFailure(e.message));
    } on NetworkException {
      print('⚠️  AUTH_REPO: NetworkException, trying cache...');
      // If network fails, try to get cached user
      try {
        final cachedUser = await localDataSource.getCachedUser();
        return Right(cachedUser.toEntity());
      } on CacheException catch (e) {
        print('❌ AUTH_REPO: CacheException: ${e.message}');
        return Left(CacheFailure(e.message));
      }
    } on ServerException catch (e) {
      print('⚠️  AUTH_REPO: ServerException, trying cache...');
      // If server error, try to get cached user
      try {
        final cachedUser = await localDataSource.getCachedUser();
        return Right(cachedUser.toEntity());
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } catch (e, stackTrace) {
      print('💥 AUTH_REPO: Exception in validateToken');
      print('💥 AUTH_REPO: Exception: $e');
      print('💥 AUTH_REPO: StackTrace: $stackTrace');
      // Any other error, try cache
      try {
        final cachedUser = await localDataSource.getCachedUser();
        return Right(cachedUser.toEntity());
      } on CacheException {
        return Left(GenericFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Try to logout from remote
      try {
        await remoteDataSource.logout();
      } catch (e) {
        // Continue even if remote logout fails
      }

      // Always clear local data
      await localDataSource.clearCache();

      return const Right(null);
    } catch (e) {
      // Even if error, try to clear cache
      try {
        await localDataSource.clearCache();
      } catch (_) {}

      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logoutAll() async {
    try {
      // Try to logout from all devices
      try {
        await remoteDataSource.logoutAll();
      } catch (e) {
        // Continue even if remote logout fails
      }

      // Always clear local data
      await localDataSource.clearCache();

      return const Right(null);
    } catch (e) {
      // Even if error, try to clear cache
      try {
        await localDataSource.clearCache();
      } catch (_) {}

      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return await secureStorage.hasToken();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCachedUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AcademicPhasesResponse>> getAcademicPhases() async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure());
      }

      // Call remote API
      final response = await remoteDataSource.getAcademicPhases();
      return Right(response.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ClientException catch (e) {
      return Left(ClientFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AcademicYearsResponse>> getAcademicYears(
    int phaseId,
  ) async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure());
      }

      // Call remote API
      final response = await remoteDataSource.getAcademicYears(phaseId);
      return Right(response.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ClientException catch (e) {
      return Left(ClientFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AcademicStreamsResponse>> getAcademicStreams(
    int yearId,
  ) async {
    try {
      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure());
      }

      // Call remote API
      final response = await remoteDataSource.getAcademicStreams(yearId);
      return Right(response.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ClientException catch (e) {
      return Left(ClientFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateAcademicProfile({
    required int phaseId,
    required int yearId,
    required int streamId,
  }) async {
    try {
      print('🔵 AUTH_REPO: updateAcademicProfile called');
      print('   phaseId: $phaseId, yearId: $yearId, streamId: $streamId');

      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        print('❌ AUTH_REPO: No internet connection');
        return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
      }

      // Call remote API to update profile
      print('🔵 AUTH_REPO: Calling remoteDataSource.updateAcademicProfile...');
      final userModel = await remoteDataSource.updateAcademicProfile(
        phaseId: phaseId,
        yearId: yearId,
        streamId: streamId,
      );

      print('✅ AUTH_REPO: Received updated user model from API');

      // Cache the updated user
      await localDataSource.cacheUser(userModel);
      print('✅ AUTH_REPO: Cached updated user with academic profile');

      return Right(userModel.toEntity());
    } on CacheException catch (e) {
      print('❌ AUTH_REPO: CacheException: ${e.message}');
      return Left(CacheFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ClientException catch (e) {
      return Left(ClientFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } catch (e, stackTrace) {
      print('💥 AUTH_REPO: Exception in updateAcademicProfile');
      print('💥 AUTH_REPO: Exception: $e');
      print('💥 AUTH_REPO: StackTrace: $stackTrace');
      return Left(GenericFailure(e.toString()));
    }
  }
}
