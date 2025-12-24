import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/subscription_repository.dart';

/// Use case for validating a subscription code before redemption
/// Calls POST /api/v1/subscriptions/validate-code
class ValidateSubscriptionCodeUseCase
    implements UseCase<SubscriptionCodeValidationResult, ValidateCodeParams> {
  final SubscriptionRepository repository;

  ValidateSubscriptionCodeUseCase(this.repository);

  @override
  Future<Either<Failure, SubscriptionCodeValidationResult>> call(
    ValidateCodeParams params,
  ) async {
    // Trim whitespace from code
    final trimmedCode = params.code.trim().toUpperCase();

    // Basic validation
    if (trimmedCode.isEmpty) {
      return Left(ValidationFailure('يرجى إدخال رمز الاشتراك'));
    }

    if (trimmedCode.length < 6) {
      return Left(ValidationFailure('رمز الاشتراك يجب أن يكون 6 أحرف على الأقل'));
    }

    return await repository.validateSubscriptionCode(trimmedCode);
  }
}

/// Parameters for validating a subscription code
class ValidateCodeParams {
  final String code;

  ValidateCodeParams({required this.code});
}

/// Result of subscription code validation
class SubscriptionCodeValidationResult {
  final bool isValid;
  final String? message;
  final String? codeType; // 'single_course' or 'package'
  final int? courseId;
  final int? packageId;
  final String? courseTitleAr;
  final String? packageNameAr;
  final int? durationDays;
  final int? remainingUses;

  SubscriptionCodeValidationResult({
    required this.isValid,
    this.message,
    this.codeType,
    this.courseId,
    this.packageId,
    this.courseTitleAr,
    this.packageNameAr,
    this.durationDays,
    this.remainingUses,
  });

  factory SubscriptionCodeValidationResult.fromJson(Map<String, dynamic> json) {
    return SubscriptionCodeValidationResult(
      isValid: json['is_valid'] ?? false,
      message: json['message'],
      codeType: json['code_type'],
      courseId: json['course_id'],
      packageId: json['package_id'],
      courseTitleAr: json['course_title_ar'],
      packageNameAr: json['package_name_ar'],
      durationDays: json['duration_days'],
      remainingUses: json['remaining_uses'],
    );
  }

  /// Get UI-friendly title in Arabic
  String get displayTitle {
    if (codeType == 'single_course' && courseTitleAr != null) {
      return courseTitleAr!;
    } else if (codeType == 'package' && packageNameAr != null) {
      return packageNameAr!;
    }
    return 'رمز اشتراك';
  }

  /// Get UI-friendly description in Arabic
  String get displayDescription {
    final List<String> parts = [];

    if (codeType == 'single_course') {
      parts.add('رمز لدورة واحدة');
    } else if (codeType == 'package') {
      parts.add('رمز لباقة اشتراك');
    }

    if (durationDays != null) {
      parts.add('صالح لمدة $durationDays يوم');
    }

    if (remainingUses != null && remainingUses! > 0) {
      parts.add('متبقي $remainingUses استخدام');
    }

    return parts.join(' • ');
  }

  /// Check if code is for a single course
  bool get isSingleCourse => codeType == 'single_course';

  /// Check if code is for a package
  bool get isPackage => codeType == 'package';

  /// Check if code has remaining uses
  bool get hasRemainingUses => remainingUses != null && remainingUses! > 0;
}
