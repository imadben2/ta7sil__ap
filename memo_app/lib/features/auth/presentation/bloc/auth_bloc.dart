import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/services/fcm_token_service.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/validate_token_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LoginWithGoogleUseCase loginWithGoogleUseCase;
  final RegisterUseCase registerUseCase;
  final ValidateTokenUseCase validateTokenUseCase;
  final LogoutUseCase logoutUseCase;
  final SecureStorageService secureStorage;
  final FcmTokenService? fcmTokenService;

  AuthBloc({
    required this.loginUseCase,
    required this.loginWithGoogleUseCase,
    required this.registerUseCase,
    required this.validateTokenUseCase,
    required this.logoutUseCase,
    required this.secureStorage,
    this.fcmTokenService,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AcademicProfileUpdateRequested>(_onAcademicProfileUpdateRequested);
  }

  /// Handle authentication check on app start
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔵 AUTH_BLOC: AuthCheckRequested event received');
    emit(const AuthLoading());

    try {
      print('🔵 AUTH_BLOC: Calling validateTokenUseCase...');
      final result = await validateTokenUseCase();

      result.fold(
        (failure) {
          print('❌ AUTH_BLOC: Token validation failed');
          print('❌ AUTH_BLOC: Failure type: ${failure.runtimeType}');
          print('❌ AUTH_BLOC: Failure message: ${failure.message}');
          emit(const Unauthenticated());
        },
        (user) {
          print('✅ AUTH_BLOC: Token validation successful');
          print('✅ AUTH_BLOC: User ID: ${user.id}');
          print('✅ AUTH_BLOC: User email: ${user.email}');
          print('✅ AUTH_BLOC: User name: ${user.firstName} ${user.lastName}');
          print(
            '✅ AUTH_BLOC: Has academic profile: ${user.academicProfile != null}',
          );
          if (user.academicProfile != null) {
            print('   Academic phaseId: ${user.academicProfile!.phaseId}');
            print('   Academic phaseName: ${user.academicProfile!.phaseName}');
            print('   Academic yearId: ${user.academicProfile!.yearId}');
            print('   Academic yearName: ${user.academicProfile!.yearName}');
            print('   Academic streamId: ${user.academicProfile!.streamId}');
            print(
              '   Academic streamName: ${user.academicProfile!.streamName}',
            );
          }
          emit(Authenticated(user: user));
        },
      );
    } catch (e, stackTrace) {
      print('💥 AUTH_BLOC: Exception caught in _onAuthCheckRequested');
      print('💥 AUTH_BLOC: Exception: $e');
      print('💥 AUTH_BLOC: StackTrace: $stackTrace');
      emit(AuthError(message: 'حدث خطأ غير متوقع: $e', errorType: 'generic'));
    }
  }

  /// Handle login request
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔵 AUTH_BLOC: LoginRequested event received');
    print('🔵 AUTH_BLOC: Email: ${event.email}');
    emit(const AuthLoading());

    try {
      // Get or generate device ID
      print('🔵 AUTH_BLOC: Getting or generating device ID...');
      final deviceId = await _getOrGenerateDeviceId();
      print('🔵 AUTH_BLOC: Device ID: $deviceId');

      // Save remember me preference
      await secureStorage.saveRememberMe(event.rememberMe);

      print('🔵 AUTH_BLOC: Calling loginUseCase...');
      final result = await loginUseCase(
        email: event.email,
        password: event.password,
        deviceId: deviceId,
      );

      await result.fold(
        (failure) async {
          print('❌ AUTH_BLOC: Login failed');
          print('❌ AUTH_BLOC: Failure type: ${failure.runtimeType}');
          print('❌ AUTH_BLOC: Failure message: ${failure.message}');

          String errorType = 'generic';
          final isDeviceMismatch =
              failure.message.contains('مسجل على جهاز آخر') ||
              failure.message.contains('device');

          if (isDeviceMismatch) {
            errorType = 'device_mismatch';
          } else if (failure.message.contains('اتصال') ||
              failure.message.contains('network')) {
            errorType = 'network';
          } else if (failure.message.contains('غير صالح') ||
              failure.message.contains('validation')) {
            errorType = 'validation';
          }

          emit(AuthError(message: failure.message, errorType: errorType));
        },
        (user) async {
          print('✅ AUTH_BLOC: Login successful');
          print('✅ AUTH_BLOC: User ID: ${user.id}');
          print('✅ AUTH_BLOC: User email: ${user.email}');
          print('✅ AUTH_BLOC: User name: ${user.firstName} ${user.lastName}');
          print(
            '✅ AUTH_BLOC: Has academic profile: ${user.academicProfile != null}',
          );
          if (user.academicProfile != null) {
            print('   Academic phaseId: ${user.academicProfile!.phaseId}');
            print('   Academic phaseName: ${user.academicProfile!.phaseName}');
            print('   Academic yearId: ${user.academicProfile!.yearId}');
            print('   Academic yearName: ${user.academicProfile!.yearName}');
            print('   Academic streamId: ${user.academicProfile!.streamId}');
            print(
              '   Academic streamName: ${user.academicProfile!.streamName}',
            );
          }

          // Register FCM token after successful login (don't await to not block UI)
          if (fcmTokenService != null) {
            print('🔔 AUTH_BLOC: Registering FCM token...');
            fcmTokenService!.registerToken().then((registered) {
              print('🔔 AUTH_BLOC: FCM token registered: $registered');
            }).catchError((e) {
              print('⚠️ AUTH_BLOC: FCM token registration failed: $e');
            });
          }

          emit(Authenticated(user: user));
        },
      );
    } catch (e, stackTrace) {
      print('💥 AUTH_BLOC: Exception caught in _onLoginRequested');
      print('💥 AUTH_BLOC: Exception: $e');
      print('💥 AUTH_BLOC: StackTrace: $stackTrace');
      emit(AuthError(message: 'حدث خطأ غير متوقع: $e', errorType: 'generic'));
    }
  }

  /// Handle Google login request
  Future<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔵 AUTH_BLOC: GoogleLoginRequested event received');
    emit(const AuthLoading());

    try {
      // Get or generate device ID
      print('🔵 AUTH_BLOC: Getting or generating device ID...');
      final deviceId = await _getOrGenerateDeviceId();
      print('🔵 AUTH_BLOC: Device ID: $deviceId');

      print('🔵 AUTH_BLOC: Calling loginWithGoogleUseCase...');
      final result = await loginWithGoogleUseCase(
        idToken: event.idToken,
        deviceId: deviceId,
      );

      await result.fold(
        (failure) async {
          print('❌ AUTH_BLOC: Google login failed');
          print('❌ AUTH_BLOC: Failure type: ${failure.runtimeType}');
          print('❌ AUTH_BLOC: Failure message: ${failure.message}');

          String errorType = 'generic';
          final isDeviceMismatch =
              failure.message.contains('مسجل على جهاز آخر') ||
              failure.message.contains('مرتبط بجهاز آخر') ||
              failure.message.contains('device');

          if (isDeviceMismatch) {
            errorType = 'device_mismatch';
          } else if (failure.message.contains('Google') ||
              failure.message.contains('google')) {
            errorType = 'google_auth';
          } else if (failure.message.contains('اتصال') ||
              failure.message.contains('network')) {
            errorType = 'network';
          }

          emit(AuthError(message: failure.message, errorType: errorType));
        },
        (user) async {
          print('✅ AUTH_BLOC: Google login successful');
          print('✅ AUTH_BLOC: User ID: ${user.id}');
          print('✅ AUTH_BLOC: User email: ${user.email}');
          print('✅ AUTH_BLOC: User name: ${user.firstName} ${user.lastName}');
          print(
            '✅ AUTH_BLOC: Has academic profile: ${user.academicProfile != null}',
          );

          // Register FCM token after successful login (don't await to not block UI)
          if (fcmTokenService != null) {
            print('🔔 AUTH_BLOC: Registering FCM token...');
            fcmTokenService!.registerToken().then((registered) {
              print('🔔 AUTH_BLOC: FCM token registered: $registered');
            }).catchError((e) {
              print('⚠️ AUTH_BLOC: FCM token registration failed: $e');
            });
          }

          emit(Authenticated(user: user));
        },
      );
    } catch (e, stackTrace) {
      print('💥 AUTH_BLOC: Exception caught in _onGoogleLoginRequested');
      print('💥 AUTH_BLOC: Exception: $e');
      print('💥 AUTH_BLOC: StackTrace: $stackTrace');
      emit(AuthError(
        message: 'حدث خطأ أثناء تسجيل الدخول بحساب Google: $e',
        errorType: 'google_auth',
      ));
    }
  }

  /// Handle register request
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // Get or generate device ID
    final deviceId = await _getOrGenerateDeviceId();

    final result = await registerUseCase(
      email: event.email,
      password: event.password,
      firstName: event.firstName,
      lastName: event.lastName,
      phone: event.phone,
      deviceId: deviceId,
    );

    result.fold((failure) {
      String errorType = 'generic';
      if (failure.message.contains('غير صالح') ||
          failure.message.contains('validation')) {
        errorType = 'validation';
      } else if (failure.message.contains('اتصال') ||
          failure.message.contains('network')) {
        errorType = 'network';
      }

      emit(AuthError(message: failure.message, errorType: errorType));
    }, (user) => emit(Authenticated(user: user)));
  }

  /// Handle logout request
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await logoutUseCase();

    result.fold((failure) {
      // Even if logout fails, clear local auth state
      emit(const Unauthenticated());
    }, (_) => emit(const Unauthenticated()));
  }

  /// Handle academic profile update
  Future<void> _onAcademicProfileUpdateRequested(
    AcademicProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Get current user from state
    if (state is! Authenticated) return;

    final currentUser = (state as Authenticated).user;
    emit(AcademicProfileUpdating(currentUser: currentUser));

    // TODO: Implement academic profile update use case
    // For now, just emit the current user state
    await Future.delayed(const Duration(seconds: 1));

    emit(Authenticated(user: currentUser));
  }

  /// Get or generate device ID
  Future<String> _getOrGenerateDeviceId() async {
    // Try to get saved device ID
    String? deviceId = await secureStorage.getDeviceId();

    if (deviceId != null && deviceId.isNotEmpty) {
      return deviceId;
    }

    // Generate new device ID using device info
    try {
      final deviceInfo = DeviceInfoPlugin();
      final uuid = const Uuid();

      // Try to get device-specific ID
      String? hardwareId;

      if (DeviceInfoPlugin().androidInfo != null) {
        final androidInfo = await deviceInfo.androidInfo;
        hardwareId = androidInfo.id; // Android ID
      } else if (DeviceInfoPlugin().iosInfo != null) {
        final iosInfo = await deviceInfo.iosInfo;
        hardwareId = iosInfo.identifierForVendor; // iOS vendor ID
      }

      // Use hardware ID if available, otherwise generate UUID
      deviceId = hardwareId ?? uuid.v4();

      // Save device ID
      await secureStorage.saveDeviceId(deviceId);

      return deviceId;
    } catch (e) {
      // Fallback to UUID if device info fails
      deviceId = const Uuid().v4();
      await secureStorage.saveDeviceId(deviceId);
      return deviceId;
    }
  }
}
