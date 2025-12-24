import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

/// User model for JSON serialization (Data layer)
@JsonSerializable(explicitToJson: true)
class UserModel {
  final int id;
  final String email;
  final String name;
  final String? phone;
  @JsonKey(name: 'photo_url')
  final String? avatar;
  @JsonKey(name: 'academic_phase_id')
  final int? academicPhaseId;
  @JsonKey(name: 'academic_year_id')
  final int? academicYearId;
  @JsonKey(name: 'stream_id')
  final int? streamId;
  @JsonKey(name: 'total_points')
  final int? totalPoints;
  @JsonKey(name: 'current_level')
  final int? currentLevel;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatar,
    this.academicPhaseId,
    this.academicYearId,
    this.streamId,
    this.totalPoints,
    this.currentLevel,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Convert to domain entity
  UserEntity toEntity() {
    try {
      print('🔵 USER_MODEL: toEntity() called');
      print('   Raw values:');
      print('   - id: $id (${id.runtimeType})');
      print('   - email: $email (${email.runtimeType})');
      print('   - name: $name (${name.runtimeType})');
      print('   - phone: $phone (${phone.runtimeType})');
      print('   - avatar: $avatar (${avatar.runtimeType})');
      print(
        '   - academicPhaseId: $academicPhaseId (${academicPhaseId.runtimeType})',
      );
      print(
        '   - academicYearId: $academicYearId (${academicYearId.runtimeType})',
      );
      print('   - streamId: $streamId (${streamId.runtimeType})');
      print('   - totalPoints: $totalPoints (${totalPoints.runtimeType})');
      print('   - currentLevel: $currentLevel (${currentLevel.runtimeType})');

      // Parse name into first and last name
      print('🔵 USER_MODEL: Parsing name...');
      final nameParts = name.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : name;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';
      print('   firstName: $firstName, lastName: $lastName');

      // Create academic profile if any field is present
      print('🔵 USER_MODEL: Creating academic profile...');
      AcademicProfileEntity? academicProfile;
      if (academicPhaseId != null ||
          academicYearId != null ||
          streamId != null) {
        academicProfile = AcademicProfileEntity(
          phaseId: academicPhaseId,
          yearId: academicYearId,
          streamId: streamId,
        );
        print('   Academic profile created');
      } else {
        print('   No academic profile (all IDs are null)');
      }

      // Create user profile if points/level present
      print('🔵 USER_MODEL: Creating user profile...');
      UserProfileEntity? profile;
      if (totalPoints != null || currentLevel != null) {
        profile = UserProfileEntity(
          points: totalPoints ?? 0,
          level: currentLevel ?? 1,
          streak: 0,
          totalStudyTime: 0,
        );
        print('   User profile created');
      } else {
        print('   No user profile (points and level are null)');
      }

      print('🔵 USER_MODEL: Creating UserEntity...');
      final entity = UserEntity(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        avatar: avatar,
        academicProfile: academicProfile,
        profile: profile,
      );
      print('✅ USER_MODEL: UserEntity created successfully');

      return entity;
    } catch (e, stackTrace) {
      print('💥 USER_MODEL: Exception in toEntity()');
      print('💥 USER_MODEL: Exception: $e');
      print('💥 USER_MODEL: StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Create from domain entity
  factory UserModel.fromEntity(UserEntity entity) => UserModel(
    id: entity.id,
    email: entity.email,
    name: '${entity.firstName} ${entity.lastName}',
    phone: entity.phone,
    avatar: entity.avatar,
    academicPhaseId: entity.academicProfile?.phaseId,
    academicYearId: entity.academicProfile?.yearId,
    streamId: entity.academicProfile?.streamId,
    totalPoints: entity.profile?.points,
    currentLevel: entity.profile?.level,
  );
}

/// Academic profile model for JSON serialization
@JsonSerializable()
class AcademicProfileModel {
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

  AcademicProfileModel({
    this.phaseId,
    this.phaseName,
    this.yearId,
    this.yearName,
    this.streamId,
    this.streamName,
  });

  factory AcademicProfileModel.fromJson(Map<String, dynamic> json) =>
      _$AcademicProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$AcademicProfileModelToJson(this);

  AcademicProfileEntity toEntity() => AcademicProfileEntity(
    phaseId: phaseId,
    phaseName: phaseName,
    yearId: yearId,
    yearName: yearName,
    streamId: streamId,
    streamName: streamName,
  );

  factory AcademicProfileModel.fromEntity(AcademicProfileEntity entity) =>
      AcademicProfileModel(
        phaseId: entity.phaseId,
        phaseName: entity.phaseName,
        yearId: entity.yearId,
        yearName: entity.yearName,
        streamId: entity.streamId,
        streamName: entity.streamName,
      );
}

/// User profile model for JSON serialization (gamification data)
@JsonSerializable()
class UserProfileModel {
  final int points;
  final int level;
  final int streak;
  @JsonKey(name: 'total_study_time')
  final int totalStudyTime;

  UserProfileModel({
    required this.points,
    required this.level,
    required this.streak,
    required this.totalStudyTime,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);

  UserProfileEntity toEntity() => UserProfileEntity(
    points: points,
    level: level,
    streak: streak,
    totalStudyTime: totalStudyTime,
  );

  factory UserProfileModel.fromEntity(UserProfileEntity entity) =>
      UserProfileModel(
        points: entity.points,
        level: entity.level,
        streak: entity.streak,
        totalStudyTime: entity.totalStudyTime,
      );
}
