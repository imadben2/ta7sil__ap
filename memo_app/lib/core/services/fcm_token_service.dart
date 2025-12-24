import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import 'notification_service.dart';

/// Service for managing FCM token registration with the API
class FcmTokenService {
  final Dio _dio;
  final NotificationService _notificationService;
  final DeviceInfoPlugin _deviceInfo;

  String? _deviceUuid;
  String? _platform;

  FcmTokenService({
    required Dio dio,
    required NotificationService notificationService,
    DeviceInfoPlugin? deviceInfo,
  })  : _dio = dio,
        _notificationService = notificationService,
        _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  /// Initialize and get device info
  Future<void> init() async {
    await _getDeviceInfo();

    // Listen for token refresh
    _notificationService.onTokenRefresh.listen((newToken) {
      _refreshToken(newToken);
    });
  }

  /// Get device UUID and platform
  Future<void> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _deviceUuid = androidInfo.id;
        _platform = 'android';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _deviceUuid = iosInfo.identifierForVendor;
        _platform = 'ios';
      }
      debugPrint('[FcmTokenService] Device: $_platform, UUID: $_deviceUuid');
    } catch (e) {
      debugPrint('[FcmTokenService] Error getting device info: $e');
      _deviceUuid = 'unknown';
      _platform = Platform.isAndroid ? 'android' : 'ios';
    }
  }

  /// Register FCM token with the API
  Future<bool> registerToken() async {
    try {
      final token = _notificationService.fcmToken;

      if (token == null) {
        debugPrint('[FcmTokenService] No FCM token available');
        return false;
      }

      if (_deviceUuid == null) {
        await _getDeviceInfo();
      }

      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.notificationsFcmToken}',
        data: {
          'fcm_token': token,
          'device_uuid': _deviceUuid,
          'device_platform': _platform,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[FcmTokenService] Token registered successfully');
        return true;
      }

      debugPrint('[FcmTokenService] Registration failed: ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('[FcmTokenService] Registration error: $e');
      return false;
    }
  }

  /// Refresh FCM token with the API
  Future<bool> _refreshToken(String newToken) async {
    try {
      final oldToken = _notificationService.fcmToken;

      final response = await _dio.post(
        '${ApiConstants.baseUrl}/v1/notifications/refresh-token',
        data: {
          'old_token': oldToken,
          'new_token': newToken,
          'device_uuid': _deviceUuid,
          'device_platform': _platform,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[FcmTokenService] Token refreshed successfully');
        return true;
      }

      debugPrint('[FcmTokenService] Refresh failed: ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('[FcmTokenService] Refresh error: $e');
      return false;
    }
  }

  /// Unregister device (for logout)
  Future<bool> unregisterDevice() async {
    try {
      final response = await _dio.delete(
        '${ApiConstants.baseUrl}/v1/notifications/unregister-device',
        data: {
          'device_uuid': _deviceUuid,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('[FcmTokenService] Device unregistered successfully');
        // Also delete the local token
        await _notificationService.deleteToken();
        return true;
      }

      debugPrint('[FcmTokenService] Unregister failed: ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('[FcmTokenService] Unregister error: $e');
      return false;
    }
  }

  /// Get list of registered devices for the user
  Future<List<Map<String, dynamic>>> getDevices() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/v1/notifications/devices',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['devices'] != null) {
          return List<Map<String, dynamic>>.from(data['devices']);
        }
      }

      return [];
    } catch (e) {
      debugPrint('[FcmTokenService] Get devices error: $e');
      return [];
    }
  }
}
