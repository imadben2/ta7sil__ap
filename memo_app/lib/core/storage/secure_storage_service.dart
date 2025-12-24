import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

/// Secure storage service for sensitive data (tokens, credentials)
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // Auth Token
  Future<void> saveToken(String token) async {
    await _storage.write(key: ApiConstants.storageKeyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: ApiConstants.storageKeyToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: ApiConstants.storageKeyToken);
  }

  // Refresh Token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(
      key: ApiConstants.storageKeyRefreshToken,
      value: token,
    );
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: ApiConstants.storageKeyRefreshToken);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: ApiConstants.storageKeyRefreshToken);
  }

  // Device ID
  Future<void> saveDeviceId(String deviceId) async {
    await _storage.write(key: ApiConstants.storageKeyDeviceId, value: deviceId);
  }

  Future<String?> getDeviceId() async {
    return await _storage.read(key: ApiConstants.storageKeyDeviceId);
  }

  // Remember Me
  Future<void> saveRememberMe(bool remember) async {
    await _storage.write(
      key: ApiConstants.storageKeyRememberMe,
      value: remember.toString(),
    );
  }

  Future<bool> getRememberMe() async {
    final value = await _storage.read(key: ApiConstants.storageKeyRememberMe);
    return value == 'true';
  }

  // Clear all secure data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Check if user is logged in (has token)
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Generic methods for custom key-value storage
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }
}
