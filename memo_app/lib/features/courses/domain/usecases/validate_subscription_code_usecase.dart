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
    // API response format:
    // { success: true, valid: true, code: {...}, course: {...} or package: {...} }
    final codeData = json['code'] as Map<String, dynamic>?;
    final courseData = json['course'] as Map<String, dynamic>?;
    final packageData = json['package'] as Map<String, dynamic>?;

    // Determine code type from the code object
    final codeType = codeData?['type'] as String?;

    // Get duration_days from course or package
    int? durationDays;
    if (courseData != null && courseData['duration_days'] != null) {
      durationDays = courseData['duration_days'] as int?;
    } else if (packageData != null && packageData['duration_days'] != null) {
      durationDays = packageData['duration_days'] as int?;
    }

    return SubscriptionCodeValidationResult(
      isValid: json['valid'] ?? json['is_valid'] ?? false,
      message: json['message'],
      codeType: codeType,
      courseId: courseData?['id'] as int?,
      packageId: packageData?['id'] as int?,
      courseTitleAr: courseData?['title_ar'] as String?,
      packageNameAr: packageData?['name_ar'] as String?,
      durationDays: durationDays,
      remainingUses: codeData?['remaining_uses'] as int?,
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
