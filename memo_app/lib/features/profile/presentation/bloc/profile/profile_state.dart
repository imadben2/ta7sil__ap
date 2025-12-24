import 'package:equatable/equatable.dart';
import '../../../domain/entities/profile_entity.dart';
import '../../../domain/entities/device_session_entity.dart';

/// حالات الملف الشخصي
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// جاري التحميل
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// تم التحميل بنجاح
class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// جاري التحديث
class ProfileUpdating extends ProfileState {
  final ProfileEntity currentProfile;

  const ProfileUpdating(this.currentProfile);

  @override
  List<Object?> get props => [currentProfile];
}

/// تم التحديث بنجاح
class ProfileUpdated extends ProfileState {
  final ProfileEntity profile;
  final String message;

  const ProfileUpdated(this.profile, this.message);

  @override
  List<Object?> get props => [profile, message];
}

/// جاري رفع الصورة
class ProfilePhotoUploading extends ProfileState {
  final ProfileEntity currentProfile;

  const ProfilePhotoUploading(this.currentProfile);

  @override
  List<Object?> get props => [currentProfile];
}

/// تم رفع الصورة بنجاح
class ProfilePhotoUploaded extends ProfileState {
  final ProfileEntity profile;

  const ProfilePhotoUploaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// جاري تغيير كلمة المرور
class PasswordChanging extends ProfileState {
  const PasswordChanging();
}

/// تم تغيير كلمة المرور بنجاح
class PasswordChanged extends ProfileState {
  const PasswordChanged();
}

/// جاري تصدير البيانات
class DataExporting extends ProfileState {
  const DataExporting();
}

/// تم تصدير البيانات بنجاح
class DataExported extends ProfileState {
  final String downloadUrl;

  const DataExported(this.downloadUrl);

  @override
  List<Object?> get props => [downloadUrl];
}

/// جاري حذف الحساب
class AccountDeleting extends ProfileState {
  const AccountDeleting();
}

/// تم حذف الحساب بنجاح
class AccountDeleted extends ProfileState {
  const AccountDeleted();
}

/// تم تحميل قائمة الأجهزة
class DevicesLoaded extends ProfileState {
  final List<DeviceSessionEntity> devices;

  const DevicesLoaded(this.devices);

  @override
  List<Object?> get props => [devices];
}

/// تم تسجيل الخروج من جهاز بنجاح
class DeviceLogoutSuccess extends ProfileState {
  final String message;

  const DeviceLogoutSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// خطأ
class ProfileError extends ProfileState {
  final String message;
  final ProfileEntity? currentProfile;

  const ProfileError(this.message, [this.currentProfile]);

  @override
  List<Object?> get props => [message, currentProfile];
}
