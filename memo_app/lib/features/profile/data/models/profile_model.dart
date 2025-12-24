import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/profile_entity.dart';

part 'profile_model.g.dart';

/// نموذج الملف الشخصي للتعامل مع API
@JsonSerializable()
class ProfileModel {
  final int id;
  final String email;
  final String? name; // API returns full name as "name"
  @JsonKey(name: 'phone_number')
  final String? phone;
  @JsonKey(name: 'photo_url')
  final String? avatar;
  final String? bio;
  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;
  final String? gender;
  final String? city;
  final String? country;
  final String? timezone;

  // Academic info - not in API response yet
  @JsonKey(name: 'phase_id')
  final int? phaseId;
  @JsonKey(name: 'phase_name')
  final String? phaseName;
  @JsonKey(name: 'year_id')
  final int? yearId;
  @JsonKey(name: 'year_name')
  final String? yearName;
  @JsonKey(name: 'stream_id')
  final int? streamId;
  @JsonKey(name: 'stream_name')
  final String? streamName;

  // Gamification stats - using defaults since API doesn't provide them yet
  final int? points;
  final int? level;
  final int? streak;
  @JsonKey(name: 'total_study_time')
  final int? totalStudyTime;

  // Metadata
  @JsonKey(name: 'email_verified_at')
  final String? emailVerifiedAt;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  ProfileModel({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.avatar,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.city,
    this.country,
    this.timezone,
    this.phaseId,
    this.phaseName,
    this.yearId,
    this.yearName,
    this.streamId,
    this.streamName,
    this.points,
    this.level,
    this.streak,
    this.totalStudyTime,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);

  /// تحويل إلى Entity
  ProfileEntity toEntity() {
    // Split name into first and last name
    String firstName = '';
    String lastName = '';
    if (name != null && name!.isNotEmpty) {
      final parts = name!.split(' ');
      firstName = parts.first;
      if (parts.length > 1) {
        lastName = parts.sublist(1).join(' ');
      }
    }

    return ProfileEntity(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      avatar: avatar,
      bio: bio,
      dateOfBirth: dateOfBirth != null ? DateTime.parse(dateOfBirth!) : null,
      gender: gender,
      city: city,
      country: country,
      timezone: timezone,
      phaseId: phaseId,
      phaseName: phaseName,
      yearId: yearId,
      yearName: yearName,
      streamId: streamId,
      streamName: streamName,
      points: points ?? 0,
      level: level ?? 1,
      streak: streak ?? 0,
      totalStudyTime: totalStudyTime ?? 0,
      emailVerifiedAt: emailVerifiedAt != null
          ? DateTime.parse(emailVerifiedAt!)
          : null,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// إنشاء من Entity
  factory ProfileModel.fromEntity(ProfileEntity entity) {
    // Combine first and last name into single name field
    String fullName = '${entity.firstName} ${entity.lastName}'.trim();

    return ProfileModel(
      id: entity.id,
      email: entity.email,
      name: fullName.isNotEmpty ? fullName : null,
      phone: entity.phone,
      avatar: entity.avatar,
      bio: entity.bio,
      dateOfBirth: entity.dateOfBirth?.toIso8601String(),
      gender: entity.gender,
      city: entity.city,
      country: entity.country,
      timezone: entity.timezone,
      phaseId: entity.phaseId,
      phaseName: entity.phaseName,
      yearId: entity.yearId,
      yearName: entity.yearName,
      streamId: entity.streamId,
      streamName: entity.streamName,
      points: entity.points,
      level: entity.level,
      streak: entity.streak,
      totalStudyTime: entity.totalStudyTime,
      emailVerifiedAt: entity.emailVerifiedAt?.toIso8601String(),
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }
}
