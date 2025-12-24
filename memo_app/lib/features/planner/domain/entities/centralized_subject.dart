import 'package:equatable/equatable.dart';

/// Centralized subject entity from the shared subjects API
/// These subjects are managed centrally and shared across features
/// (Planner, Content Management, etc.)
class CentralizedSubject extends Equatable {
  final int id;
  final String nameAr;
  final String slug;
  final String? descriptionAr;
  final String? color;
  final String? icon;
  final double coefficient;
  final List<int>? academicStreamIds;
  final int? academicYearId;
  final bool isActive;

  const CentralizedSubject({
    required this.id,
    required this.nameAr,
    required this.slug,
    required this.coefficient,
    this.descriptionAr,
    this.color,
    this.icon,
    this.academicStreamIds,
    this.academicYearId,
    this.isActive = true,
  });

  /// Check if subject belongs to a specific stream
  bool belongsToStream(int streamId) =>
      academicStreamIds?.contains(streamId) ?? false;

  @override
  List<Object?> get props => [
    id,
    nameAr,
    slug,
    descriptionAr,
    color,
    icon,
    coefficient,
    academicStreamIds,
    academicYearId,
    isActive,
  ];

  /// Copy with method for immutability
  CentralizedSubject copyWith({
    int? id,
    String? nameAr,
    String? slug,
    String? descriptionAr,
    String? color,
    String? icon,
    double? coefficient,
    List<int>? academicStreamIds,
    int? academicYearId,
    bool? isActive,
  }) {
    return CentralizedSubject(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      slug: slug ?? this.slug,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      coefficient: coefficient ?? this.coefficient,
      academicStreamIds: academicStreamIds ?? this.academicStreamIds,
      academicYearId: academicYearId ?? this.academicYearId,
      isActive: isActive ?? this.isActive,
    );
  }
}
