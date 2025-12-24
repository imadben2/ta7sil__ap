import 'package:equatable/equatable.dart';

/// User entity (Domain layer)
class UserEntity extends Equatable {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatar;
  final AcademicProfileEntity? academicProfile;
  final UserProfileEntity? profile;

  const UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatar,
    this.academicProfile,
    this.profile,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    phone,
    avatar,
    academicProfile,
    profile,
  ];
}

/// Academic profile entity
class AcademicProfileEntity extends Equatable {
  final int? phaseId;
  final String? phaseName;
  final int? yearId;
  final String? yearName;
  final int? streamId;
  final String? streamName;

  const AcademicProfileEntity({
    this.phaseId,
    this.phaseName,
    this.yearId,
    this.yearName,
    this.streamId,
    this.streamName,
  });

  @override
  List<Object?> get props => [
    phaseId,
    phaseName,
    yearId,
    yearName,
    streamId,
    streamName,
  ];
}

/// User profile entity (gamification data)
class UserProfileEntity extends Equatable {
  final int points;
  final int level;
  final int streak;
  final int totalStudyTime; // in minutes

  const UserProfileEntity({
    required this.points,
    required this.level,
    required this.streak,
    required this.totalStudyTime,
  });

  @override
  List<Object?> get props => [points, level, streak, totalStudyTime];
}
