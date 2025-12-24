import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/profile_model.dart';
import '../models/device_session_model.dart';

/// مصدر البيانات البعيد للملف الشخصي
///
/// يتعامل مع جميع طلبات API المتعلقة بالملف الشخصي
abstract class ProfileRemoteDataSource {
  /// GET /api/profile
  Future<ProfileModel> getProfile();

  /// PUT /api/profile
  Future<ProfileModel> updateProfile(Map<String, dynamic> data);

  /// POST /api/profile/academic
  Future<ProfileModel> updateAcademicProfile(Map<String, dynamic> data);

  /// POST /api/profile/photo
  Future<ProfileModel> uploadProfilePhoto(File imageFile);

  /// POST /api/profile/change-password
  Future<void> changePassword(Map<String, dynamic> data);

  /// POST /api/profile/export
  Future<String> exportPersonalData(String format);

  /// POST /api/profile/delete-account
  Future<void> deleteAccount(Map<String, dynamic> data);

  /// GET /api/sessions/devices
  Future<List<DeviceSessionModel>> getDeviceSessions();

  /// PUT /api/sessions/device - Register/update current device session
  Future<DeviceSessionModel> registerDeviceSession(Map<String, dynamic> deviceInfo);

  /// DELETE /api/sessions/devices/{id}
  Future<void> logoutDevice(int sessionId);

  /// DELETE /api/sessions/devices
  Future<void> logoutAllOtherDevices();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient dioClient;

  ProfileRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await dioClient.get('/profile');

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'فشل في جلب الملف الشخصي',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'خطأ في الاتصال بالخادم',
      );
    }
  }

  @override
  Future<ProfileModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.put('/profile', data: data);

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'فشل في تحديث الملف الشخصي',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        // Validation errors
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        final firstError = errors?.values.first;
        throw ServerException(
          message: firstError is List ? firstError.first : 'خطأ في البيانات',
        );
      }
      throw ServerException(
        message: e.response?.data['message'] ?? 'خطأ في الاتصال بالخادم',
      );
    }
  }

  @override
  Future<ProfileModel> updateAcademicProfile(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post('/profile/academic', data: data);

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message:
              response.data['message'] ?? 'فشل في تحديث المعلومات الأكاديمية',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'خطأ في الاتصال بالخادم',
      );
    }
  }

  @override
  Future<ProfileModel> uploadProfilePhoto(File imageFile) async {
    try {
      // إنشاء FormData لرفع الصورة
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await dioClient.post('/profile/photo', data: formData);

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'فشل في رفع الصورة',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'الصورة غير صالحة',
        );
      }
      throw ServerException(
        message: e.response?.data['message'] ?? 'خطأ في الاتصال بالخادم',
      );
    }
  }

  @override
  Future<void> changePassword(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(
        '/profile/change-password',
        data: data,
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'فشل في تغيير كلمة المرور',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        final firstError = errors?.values.first;
        throw ServerException(
          message: firstError is List ? firstError.first : 'خطأ في البيانات',
        );
      } else if (e.response?.statusCode == 401) {
        throw ServerException(message: 'كلمة المرور الحالية غير صحيحة');
      } else if (e.response?.statusCode == 429) {
        throw ServerException(
          message: 'لقد تجاوزت عدد المحاولات المسموحة. حاول لاحقًا.',
        );
      }
      throw ServerException(
        message: e.response?.data['message'] ?? 'خطأ في الاتصال بالخادم',
      );
    }
  }

  @override
  Future<String> exportPersonalData(String format) async {
    try {
      final response = await dioClient.post(
        '/profile/export',
        data: {'format': format},
      );

      if (response.statusCode == 200) {
        return response.data['data']['download_url'] as String;
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'فشل في تصدير البيانات',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'خطأ في الاتصال بالخادم',
      );
    }
  }

  @override
  Future<void> deleteAccount(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(
        '/profile/delete-account',
        data: data,
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'فشل في حذف الحساب',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ServerException(message: 'كلمة المرور غير صحيحة');
      } else if (e.response?.statusCode == 403) {
        throw ServerException(
          message: 'لا يمكن حذف الحساب. يوجد اشتراكات نشطة.',
        );
      }
      throw ServerException(
        message: e.response?.data['message'] ?? 'خطأ في الاتصال بالخادم',
      );
    }
  }

  @override
  Future<List<DeviceSessionModel>> getDeviceSessions() async {
    try {
      final response = await dioClient.get('/sessions/devices');

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        // Handle nested structure: {"data": {"sessions": [...]}}
        final List<dynamic> sessions = responseData is Map
            ? (responseData['sessions'] ?? [])
            : (responseData ?? []);
        return sessions.map((json) => DeviceSessionModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'فشل في جلب الأجهزة',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'خطأ في الاتصال بالخادم',
      );
    }
  }

  @override
  Future<DeviceSessionModel> registerDeviceSession(Map<String, dynamic> deviceInfo) async {
    try {
      final response = await dioClient.put('/sessions/device', data: deviceInfo);

      if (response.statusCode == 200) {
        return DeviceSessionModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'فشل في تسجيل الجهاز',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'خطأ في الاتصال بالخادم',
      );
    }
  }

  @override
  Future<void> logoutDevice(int sessionId) async {
    try {
      final response = await dioClient.delete('/sessions/devices/$sessionId');

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'فشل في تسجيل الخروج من الجهاز',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'خطأ في الاتصال بالخادم',
      );
    }
  }

  @override
  Future<void> logoutAllOtherDevices() async {
    try {
      final response = await dioClient.delete('/sessions/devices');

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'فشل في تسجيل الخروج من الأجهزة',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'خطأ في الاتصال بالخادم',
      );
    }
  }
}
