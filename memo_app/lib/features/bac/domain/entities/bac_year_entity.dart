import 'package:equatable/equatable.dart';

/// Entity representing a BAC year (e.g., 2024, 2023)
class BacYearEntity extends Equatable {
  final int id;
  final int year;
  final String slug;
  final String? descriptionAr;
  final bool isActive;
  final int order;

  // Statistics
  final int totalSessions;
  final int totalExams;
  final int totalDownloads;

  const BacYearEntity({
    required this.id,
    required this.year,
    required this.slug,
    this.descriptionAr,
    required this.isActive,
    required this.order,
    this.totalSessions = 0,
    this.totalExams = 0,
    this.totalDownloads = 0,
  });

  /// Display label for the year
  String get displayLabel => 'BAC $year';

  @override
  List<Object?> get props => [
    id,
    year,
    slug,
    descriptionAr,
    isActive,
    order,
    totalSessions,
    totalExams,
    totalDownloads,
  ];
}
