import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

/// Use Case: تحديث الملف الشخصي
class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, ProfileEntity>> call(
    UpdateProfileParams params,
  ) async {
    return await repository.updateProfile(
      firstName: params.firstName,
      lastName: params.lastName,
      phone: params.phone,
      bio: params.bio,
      dateOfBirth: params.dateOfBirth,
      gender: params.gender,
      city: params.city,
      country: params.country,
    );
  }
}

class UpdateProfileParams {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? city;
  final String? country;

  UpdateProfileParams({
    this.firstName,
    this.lastName,
    this.phone,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.city,
    this.country,
  });
}
