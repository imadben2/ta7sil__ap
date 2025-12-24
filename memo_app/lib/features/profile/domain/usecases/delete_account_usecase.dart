import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

/// Use case for deleting user account (GDPR compliance)
///
/// This use case handles the complete account deletion flow:
/// 1. Validates password is not empty
/// 2. Calls repository to soft-delete account on backend
/// 3. Returns success or failure
///
/// Backend behavior:
/// - Soft delete: Account marked as deleted, data retained for 30 days
/// - Hard delete: After 30 days, all data permanently removed
/// - All tokens invalidated immediately
/// - User can recover within 30-day grace period by logging in
class DeleteAccountUseCase {
  final ProfileRepository repository;

  DeleteAccountUseCase(this.repository);

  /// Execute the delete account operation
  ///
  /// Returns:
  /// - Right(void): Account deleted successfully
  /// - Left(Failure): Operation failed (validation, network, server error)
  Future<Either<Failure, void>> call(DeleteAccountParams params) async {
    // Validate password
    if (params.password.trim().isEmpty) {
      return Left(ValidationFailure('كلمة المرور مطلوبة للتأكيد'));
    }

    // Call repository to delete account
    return await repository.deleteAccount(
      password: params.password,
      reason: params.reason,
    );
  }
}

/// Parameters for delete account use case
class DeleteAccountParams {
  /// Password for confirmation
  final String password;

  /// Optional reason for deletion (from predefined list)
  final String? reason;

  const DeleteAccountParams({
    required this.password,
    this.reason,
  });

  /// Predefined deletion reasons (for UI dropdown)
  static const List<String> predefinedReasons = [
    'لم أعد أستخدم التطبيق',
    'وجدت تطبيقاً بديلاً أفضل',
    'مشاكل في الأداء أو الاستقرار',
    'قلق بشأن الخصوصية',
    'أخرى',
  ];

  Map<String, dynamic> toJson() {
    return {
      'password': password,
      if (reason != null) 'reason': reason,
    };
  }
}
