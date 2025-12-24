import 'dart:io';
import 'package:equatable/equatable.dart';

/// أحداث الملف الشخصي
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// تحميل الملف الشخصي
class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

/// إعادة تحميل الملف الشخصي (تجاوز Cache)
class RefreshProfile extends ProfileEvent {
  const RefreshProfile();
}

/// تحديث الملف الشخصي
class UpdateProfile extends ProfileEvent {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? city;
  final String? country;

  const UpdateProfile({
    this.firstName,
    this.lastName,
    this.phone,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.city,
    this.country,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    phone,
    bio,
    dateOfBirth,
    gender,
    city,
    country,
  ];
}

/// رفع صورة الملف الشخصي
class UploadProfilePhoto extends ProfileEvent {
  final File imageFile;

  const UploadProfilePhoto(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

/// تغيير كلمة المرور
class ChangePassword extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  const ChangePassword({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  @override
  List<Object?> get props => [
    currentPassword,
    newPassword,
    newPasswordConfirmation,
  ];
}

/// تصدير البيانات الشخصية
class ExportPersonalData extends ProfileEvent {
  final String format; // 'json' or 'pdf'

  const ExportPersonalData({this.format = 'json'});

  @override
  List<Object?> get props => [format];
}

/// حذف الحساب
class DeleteAccount extends ProfileEvent {
  final String password;
  final String? reason;

  const DeleteAccount({required this.password, this.reason});

  @override
  List<Object?> get props => [password, reason];
}

/// تحميل قائمة الأجهزة المتصلة
class LoadDevices extends ProfileEvent {
  const LoadDevices();
}

/// تسجيل الجهاز الحالي
class RegisterCurrentDevice extends ProfileEvent {
  final Map<String, dynamic> deviceInfo;

  const RegisterCurrentDevice(this.deviceInfo);

  @override
  List<Object?> get props => [deviceInfo];
}

/// تسجيل الخروج من جهاز معين
class LogoutDevice extends ProfileEvent {
  final int sessionId;

  const LogoutDevice(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// تسجيل الخروج من جميع الأجهزة الأخرى
class LogoutAllOtherDevices extends ProfileEvent {
  const LogoutAllOtherDevices();
}
