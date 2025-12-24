import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';
import '../models/login_response_model.dart';
import '../models/academic_models.dart';

/// Remote data source for authentication
abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(
    String email,
    String password,
    String deviceId,
  );
  Future<LoginResponseModel> loginWithGoogle(String idToken, String deviceId);
  Future<LoginResponseModel> register(Map<String, dynamic> data);
  Future<UserModel> validateToken();
  Future<void> logout();
  Future<void> logoutAll();
  Future<AcademicPhasesResponseModel> getAcademicPhases();
  Future<AcademicYearsResponseModel> getAcademicYears(int phaseId);
  Future<AcademicStreamsResponseModel> getAcademicStreams(int yearId);
  Future<UserModel> updateAcademicProfile({
    required int phaseId,
    required int yearId,
    required int streamId,
  });
}

/// Implementation of remote data source
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<LoginResponseModel> login(
    String email,
    String password,
    String deviceId,
  ) async {
    try {
      final response = await client.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
          'device_uuid': deviceId,
          'device_id': deviceId,
          'device_name': 'Android Device',
          'device_model': 'Flutter Emulator',
          'device_os': 'Android',
        },
      );

      // API response structure: { "success": true, "data": { ... } }
      final data = response.data['data'] ?? response.data;
      return LoginResponseModel.fromJson(data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<LoginResponseModel> loginWithGoogle(
    String idToken,
    String deviceId,
  ) async {
    try {
      final response = await client.post(
        ApiConstants.loginWithGoogle,
        data: {
          'id_token': idToken,
          'device_uuid': deviceId,
          'device_id': deviceId,
          'device_name': 'Android Device',
          'device_model': 'Flutter App',
          'device_os': 'Android',
        },
      );

      // API response structure: { "success": true, "data": { ... } }
      final data = response.data['data'] ?? response.data;
      return LoginResponseModel.fromJson(data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<LoginResponseModel> register(Map<String, dynamic> data) async {
    try {
      final response = await client.post(ApiConstants.register, data: data);

      final responseData = response.data['data'] ?? response.data;
      return LoginResponseModel.fromJson(responseData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel> validateToken() async {
    try {
      final response = await client.get(ApiConstants.me);
      final data = response.data['data'] ?? response.data;
      return UserModel.fromJson(data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await client.post(ApiConstants.logout);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> logoutAll() async {
    try {
      await client.post(ApiConstants.logoutAll);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<AcademicPhasesResponseModel> getAcademicPhases() async {
    try {
      final response = await client.get(ApiConstants.academicPhases);
      return AcademicPhasesResponseModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<AcademicYearsResponseModel> getAcademicYears(int phaseId) async {
    try {
      final response = await client.get(
        ApiConstants.academicYears,
        queryParameters: {'phase_id': phaseId},
      );
      return AcademicYearsResponseModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<AcademicStreamsResponseModel> getAcademicStreams(int yearId) async {
    try {
      final response = await client.get(
        ApiConstants.academicStreams,
        queryParameters: {'year_id': yearId},
      );
      return AcademicStreamsResponseModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel> updateAcademicProfile({
    required int phaseId,
    required int yearId,
    required int streamId,
  }) async {
    try {
      final response = await client.post(
        ApiConstants.updateAcademicProfile,
        data: {
          'academic_phase_id': phaseId,
          'academic_year_id': yearId,
          'stream_id': streamId,
        },
      );

      final data = response.data['data'] ?? response.data;
      return UserModel.fromJson(data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle and convert errors to appropriate exceptions
  AppException _handleError(dynamic error) {
    if (error is AppException) {
      return error;
    }
    return ServerException(message: error.toString(), details: error);
  }
}
