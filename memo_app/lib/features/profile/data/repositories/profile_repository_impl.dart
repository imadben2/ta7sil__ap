import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/device_session_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../datasources/profile_local_datasource.dart';

/// تطبيق مستودع الملف الشخصي
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    try {
      // محاولة الجلب من Cache
      final cachedProfile = await localDataSource.getCachedProfile();
      if (cachedProfile != null) {
        return Right(cachedProfile.toEntity());
      }

      // الجلب من API
      final remoteProfile = await remoteDataSource.getProfile();

      // حفظ في Cache
      await localDataSource.cacheProfile(remoteProfile);

      return Right(remoteProfile.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? bio,
    DateTime? dateOfBirth,
    String? gender,
    String? city,
    String? country,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (phone != null) data['phone'] = phone;
      if (bio != null) data['bio'] = bio;
      if (dateOfBirth != null) {
        data['date_of_birth'] = dateOfBirth.toIso8601String().split('T')[0];
      }
      if (gender != null) data['gender'] = gender;
      if (city != null) data['city'] = city;
      if (country != null) data['country'] = country;

      final updatedProfile = await remoteDataSource.updateProfile(data);

      // تحديث Cache
      await localDataSource.cacheProfile(updatedProfile);

      return Right(updatedProfile.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء تحديث الملف الشخصي'));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateAcademicProfile({
    required int phaseId,
    required int yearId,
    int? streamId,
  }) async {
    try {
      final data = {
        'phase_id': phaseId,
        'year_id': yearId,
        if (streamId != null) 'stream_id': streamId,
      };

      final updatedProfile = await remoteDataSource.updateAcademicProfile(data);

      // تحديث Cache
      await localDataSource.cacheProfile(updatedProfile);

      return Right(updatedProfile.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء تحديث المعلومات الأكاديمية'));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> uploadProfilePhoto(
    File imageFile,
  ) async {
    try {
      final updatedProfile = await remoteDataSource.uploadProfilePhoto(
        imageFile,
      );

      // تحديث Cache
      await localDataSource.cacheProfile(updatedProfile);

      return Right(updatedProfile.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء رفع الصورة'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final data = {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      };

      await remoteDataSource.changePassword(data);

      // مسح Cache (سيتم تحديث Token)
      await localDataSource.clearProfileCache();

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء تغيير كلمة المرور'));
    }
  }

  @override
  Future<Either<Failure, String>> exportPersonalData({
    String format = 'json',
  }) async {
    try {
      final downloadUrl = await remoteDataSource.exportPersonalData(format);
      return Right(downloadUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء تصدير البيانات'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount({
    required String password,
    String? reason,
  }) async {
    try {
      final data = {'password': password, if (reason != null) 'reason': reason};

      await remoteDataSource.deleteAccount(data);

      // مسح جميع Cache
      await localDataSource.clearProfileCache();

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء حذف الحساب'));
    }
  }

  @override
  Future<Either<Failure, List<DeviceSessionEntity>>> getDeviceSessions() async {
    try {
      final devices = await remoteDataSource.getDeviceSessions();
      final entities = devices.map((d) => d.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء جلب الأجهزة'));
    }
  }

  @override
  Future<Either<Failure, DeviceSessionEntity>> registerDeviceSession(Map<String, dynamic> deviceInfo) async {
    try {
      final session = await remoteDataSource.registerDeviceSession(deviceInfo);
      return Right(session.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء تسجيل الجهاز'));
    }
  }

  @override
  Future<Either<Failure, void>> logoutDevice(int sessionId) async {
    try {
      await remoteDataSource.logoutDevice(sessionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء تسجيل الخروج من الجهاز'));
    }
  }

  @override
  Future<Either<Failure, void>> logoutAllOtherDevices() async {
    try {
      await remoteDataSource.logoutAllOtherDevices();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء تسجيل الخروج من جميع الأجهزة'));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> refreshProfile() async {
    try {
      // تجاوز Cache والجلب مباشرة من API
      final remoteProfile = await remoteDataSource.getProfile();

      // تحديث Cache
      await localDataSource.cacheProfile(remoteProfile);

      return Right(remoteProfile.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء تحديث الملف الشخصي'));
    }
  }
}
