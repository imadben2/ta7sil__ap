import 'dart:convert';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Local data source for authentication (cache)
abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel> getCachedUser();
  Future<void> clearCache();
  Future<bool> hasCache();
}

/// Implementation of local data source
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService secureStorage;
  final HiveService hiveService;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.hiveService,
  });

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await hiveService.save(
        ApiConstants.hiveBoxAuth,
        ApiConstants.storageKeyUser,
        userJson,
      );
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache user',
        details: e.toString(),
      );
    }
  }

  @override
  Future<UserModel> getCachedUser() async {
    try {
      final userJson = hiveService.get(
        ApiConstants.hiveBoxAuth,
        ApiConstants.storageKeyUser,
      );

      if (userJson == null) {
        throw CacheException(message: 'No cached user found');
      }

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to get cached user',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      // Clear Hive auth box
      await hiveService.clearBox(ApiConstants.hiveBoxAuth);

      // Clear secure storage
      await secureStorage.clearAll();
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear cache',
        details: e.toString(),
      );
    }
  }

  @override
  Future<bool> hasCache() async {
    try {
      return hiveService.has(
        ApiConstants.hiveBoxAuth,
        ApiConstants.storageKeyUser,
      );
    } catch (e) {
      return false;
    }
  }
}
