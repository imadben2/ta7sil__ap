import 'package:equatable/equatable.dart';

/// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when app starts to validate existing token
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event triggered when user requests login
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequested({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

/// Event triggered when user requests registration
class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phone;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName, phone];
}

/// Event triggered when user requests logout
class LogoutRequested extends AuthEvent {
  final bool logoutFromAllDevices;

  const LogoutRequested({this.logoutFromAllDevices = false});

  @override
  List<Object?> get props => [logoutFromAllDevices];
}

/// Event triggered when user updates academic profile
class AcademicProfileUpdateRequested extends AuthEvent {
  final int phaseId;
  final int yearId;
  final int? streamId;

  const AcademicProfileUpdateRequested({
    required this.phaseId,
    required this.yearId,
    this.streamId,
  });

  @override
  List<Object?> get props => [phaseId, yearId, streamId];
}

/// Event triggered when user requests Google login
class GoogleLoginRequested extends AuthEvent {
  final String idToken;
  final String? accessToken;

  const GoogleLoginRequested({
    required this.idToken,
    this.accessToken,
  });

  @override
  List<Object?> get props => [idToken, accessToken];
}
