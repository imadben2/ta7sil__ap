import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../domain/usecases/get_profile_usecase.dart';
import '../../../domain/usecases/update_profile_usecase.dart';
import '../../../domain/usecases/change_password_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// BLoC الملف الشخصي
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final ProfileRepository profileRepository;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.changePasswordUseCase,
    required this.profileRepository,
  }) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<RefreshProfile>(_onRefreshProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<ChangePassword>(_onChangePassword);
    on<UploadProfilePhoto>(_onUploadProfilePhoto);
    on<ExportPersonalData>(_onExportPersonalData);
    on<DeleteAccount>(_onDeleteAccount);
    on<LoadDevices>(_onLoadDevices);
    on<RegisterCurrentDevice>(_onRegisterCurrentDevice);
    on<LogoutDevice>(_onLogoutDevice);
    on<LogoutAllOtherDevices>(_onLogoutAllOtherDevices);
  }

  /// تحميل الملف الشخصي
  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    print('🔵 PROFILE_BLOC: LoadProfile event received');
    emit(const ProfileLoading());

    print('🔵 PROFILE_BLOC: Calling getProfileUseCase...');
    final result = await getProfileUseCase();

    result.fold(
      (failure) {
        print('❌ PROFILE_BLOC: Error loading profile');
        print('   Error message: ${failure.message}');
        emit(ProfileError(failure.message));
      },
      (profile) {
        print('✅ PROFILE_BLOC: Profile loaded successfully');
        print('   Profile ID: ${profile.id}');
        print('   Profile email: ${profile.email}');
        print('   Profile name: ${profile.firstName} ${profile.lastName}');
        emit(ProfileLoaded(profile));
      },
    );
  }

  /// إعادة تحميل الملف الشخصي (تجاوز Cache)
  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    print('🔵 PROFILE_BLOC: RefreshProfile event received');
    // الاحتفاظ بالـ profile الحالي أثناء التحميل
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileUpdating(currentState.profile));
    } else {
      emit(const ProfileLoading());
    }

    print('🔵 PROFILE_BLOC: Calling refreshProfile (bypassing cache)...');
    final result = await profileRepository.refreshProfile();

    result.fold((failure) {
      print('❌ PROFILE_BLOC: RefreshProfile failed: ${failure.message}');
      if (currentState is ProfileLoaded) {
        emit(ProfileError(failure.message, currentState.profile));
      } else {
        emit(ProfileError(failure.message));
      }
    }, (profile) {
      print('✅ PROFILE_BLOC: Profile refreshed successfully');
      print('   Profile: ${profile.firstName} ${profile.lastName}');
      emit(ProfileLoaded(profile));
    });
  }

  /// تحديث الملف الشخصي
  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUpdating(currentState.profile));

    final params = UpdateProfileParams(
      firstName: event.firstName,
      lastName: event.lastName,
      phone: event.phone,
      bio: event.bio,
      dateOfBirth: event.dateOfBirth,
      gender: event.gender,
      city: event.city,
      country: event.country,
    );

    final result = await updateProfileUseCase(params);

    result.fold(
      (failure) => emit(ProfileError(failure.message, currentState.profile)),
      (profile) => emit(ProfileUpdated(profile, 'تم تحديث الملف الشخصي بنجاح')),
    );
  }

  /// تغيير كلمة المرور
  Future<void> _onChangePassword(
    ChangePassword event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const PasswordChanging());

    final params = ChangePasswordParams(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
      newPasswordConfirmation: event.newPasswordConfirmation,
    );

    final result = await changePasswordUseCase(params);

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const PasswordChanged()),
    );
  }

  /// رفع صورة الملف الشخصي
  Future<void> _onUploadProfilePhoto(
    UploadProfilePhoto event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    final currentProfile = currentState is ProfileLoaded
        ? currentState.profile
        : (currentState is ProfileUpdating ? currentState.currentProfile : null);

    if (currentProfile != null) {
      emit(ProfilePhotoUploading(currentProfile));
    } else {
      emit(const ProfileLoading());
    }

    final result = await profileRepository.uploadProfilePhoto(event.imageFile);

    result.fold(
      (failure) => emit(ProfileError(failure.message, currentProfile)),
      (profile) => emit(ProfilePhotoUploaded(profile)),
    );
  }

  /// تصدير البيانات الشخصية
  Future<void> _onExportPersonalData(
    ExportPersonalData event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const DataExporting());

    final result = await profileRepository.exportPersonalData(format: event.format);

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (downloadUrl) => emit(DataExported(downloadUrl)),
    );
  }

  /// حذف الحساب
  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const AccountDeleting());

    final result = await profileRepository.deleteAccount(
      password: event.password,
      reason: event.reason,
    );

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const AccountDeleted()),
    );
  }

  /// تحميل قائمة الأجهزة المتصلة
  Future<void> _onLoadDevices(
    LoadDevices event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await profileRepository.getDeviceSessions();

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (devices) => emit(DevicesLoaded(devices)),
    );
  }

  /// تسجيل الجهاز الحالي
  Future<void> _onRegisterCurrentDevice(
    RegisterCurrentDevice event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await profileRepository.registerDeviceSession(event.deviceInfo);

    result.fold(
      (failure) {
        // Silently fail - just reload devices
        add(const LoadDevices());
      },
      (session) {
        // After registering, load all devices
        add(const LoadDevices());
      },
    );
  }

  /// تسجيل الخروج من جهاز معين
  Future<void> _onLogoutDevice(
    LogoutDevice event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await profileRepository.logoutDevice(event.sessionId);

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const DeviceLogoutSuccess('تم تسجيل الخروج من الجهاز بنجاح')),
    );
  }

  /// تسجيل الخروج من جميع الأجهزة الأخرى
  Future<void> _onLogoutAllOtherDevices(
    LogoutAllOtherDevices event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await profileRepository.logoutAllOtherDevices();

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const DeviceLogoutSuccess('تم تسجيل الخروج من جميع الأجهزة الأخرى')),
    );
  }
}
