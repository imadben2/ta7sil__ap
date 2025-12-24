import 'package:equatable/equatable.dart';

/// Entity representing a BAC subject (e.g., Math, Physics, Arabic)
class BacSubjectEntity extends Equatable {
  final int id;
  final int bacSessionId;
  final String nameAr;
  final String? nameEn;
  final String? nameFr;
  final String slug;
  final String? descriptionAr;
  final String color;
  final String? icon;
  final int coefficient;
  final int duration; // Duration in minutes
  final bool isActive;
  final int order;

  // Statistics
  final int totalChapters;
  final int totalExams;
  final int totalDownloads;
  final double? averageScore;

  // User progress
  final int completedChapters;
  final int attemptedSimulations;
  final double completionPercentage;

  // File URLs for PDF viewing
  final String? fileUrl;
  final String? correctionUrl;
  final String? downloadUrl;
  final String? correctionDownloadUrl;
  final bool hasCorrection;

  // Year and session info (for bookmarks display)
  final int? bacYear;
  final String? bacSessionName;

  const BacSubjectEntity({
    required this.id,
    required this.bacSessionId,
    required this.nameAr,
    this.nameEn,
    this.nameFr,
    required this.slug,
    this.descriptionAr,
    required this.color,
    this.icon,
    required this.coefficient,
    required this.duration,
    required this.isActive,
    required this.order,
    this.totalChapters = 0,
    this.totalExams = 0,
    this.totalDownloads = 0,
    this.averageScore,
    this.completedChapters = 0,
    this.attemptedSimulations = 0,
    this.completionPercentage = 0.0,
    this.fileUrl,
    this.correctionUrl,
    this.downloadUrl,
    this.correctionDownloadUrl,
    this.hasCorrection = false,
    this.bacYear,
    this.bacSessionName,
  });

  /// Formatted duration label (e.g., "3 ساعات")
  String get durationLabel {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    if (hours > 0 && minutes > 0) {
      return '$hours ساعة و $minutes دقيقة';
    } else if (hours > 0) {
      return '$hours ساعة';
    } else {
      return '$minutes دقيقة';
    }
  }

  /// Coefficient label with star "معامل 7"
  String get coefficientLabel => 'معامل $coefficient';

  /// Progress label "5 / 20"
  String get progressLabel => '$completedChapters / $totalChapters';

  @override
  List<Object?> get props => [
    id,
    bacSessionId,
    nameAr,
    nameEn,
    nameFr,
    slug,
    descriptionAr,
    color,
    icon,
    coefficient,
    duration,
    isActive,
    order,
    totalChapters,
    totalExams,
    totalDownloads,
    averageScore,
    completedChapters,
    attemptedSimulations,
    completionPercentage,
    fileUrl,
    correctionUrl,
    downloadUrl,
    correctionDownloadUrl,
    hasCorrection,
    bacYear,
    bacSessionName,
  ];
}
