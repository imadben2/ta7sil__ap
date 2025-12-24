import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any authentication check
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during authentication operations
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when user is authenticated
class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State when user is not authenticated
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// State when authentication operation fails
class AuthError extends AuthState {
  final String message;
  final String? errorType; // 'device_mismatch', 'validation', 'network', etc.

  const AuthError({required this.message, this.errorType});

  @override
  List<Object?> get props => [message, errorType];

  /// Check if error is device mismatch
  bool get isDeviceMismatch => errorType == 'device_mismatch';

  /// Check if error is network related
  bool get isNetworkError => errorType == 'network';

  /// Check if error is validation related
  bool get isValidationError => errorType == 'validation';
}

/// State during academic profile update
class AcademicProfileUpdating extends AuthState {
  final UserEntity currentUser;

  const AcademicProfileUpdating({required this.currentUser});

  @override
  List<Object?> get props => [currentUser];
}

/// State when academic profile is updated successfully
class AcademicProfileUpdated extends AuthState {
  final UserEntity user;

  const AcademicProfileUpdated({required this.user});

  @override
  List<Object?> get props => [user];
}
