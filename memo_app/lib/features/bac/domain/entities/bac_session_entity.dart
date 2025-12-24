import 'package:equatable/equatable.dart';

/// Entity representing a BAC session (e.g., Principal, Rattrapage, Contrôle)
class BacSessionEntity extends Equatable {
  final int id;
  final int bacYearId;
  final String nameAr;
  final String? nameEn;
  final String? nameFr;
  final String slug;
  final String? descriptionAr;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final int order;

  // Statistics
  final int totalExams;
  final int totalDownloads;
  final int totalSubjects;

  const BacSessionEntity({
    required this.id,
    required this.bacYearId,
    required this.nameAr,
    this.nameEn,
    this.nameFr,
    required this.slug,
    this.descriptionAr,
    this.startDate,
    this.endDate,
    required this.isActive,
    required this.order,
    this.totalExams = 0,
    this.totalDownloads = 0,
    this.totalSubjects = 0,
  });

  /// Check if session is currently active (between start and end dates)
  bool get isCurrentlyActive {
    if (startDate == null || endDate == null) return isActive;
    final now = DateTime.now();
    return isActive && now.isAfter(startDate!) && now.isBefore(endDate!);
  }

  @override
  List<Object?> get props => [
    id,
    bacYearId,
    nameAr,
    nameEn,
    nameFr,
    slug,
    descriptionAr,
    startDate,
    endDate,
    isActive,
    order,
    totalExams,
    totalDownloads,
    totalSubjects,
  ];
}
