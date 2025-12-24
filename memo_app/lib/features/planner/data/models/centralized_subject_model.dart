import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/centralized_subject.dart';

part 'centralized_subject_model.g.dart';

/// Data model for centralized subjects from API
@JsonSerializable(fieldRename: FieldRename.snake)
class CentralizedSubjectModel extends CentralizedSubject {
  @override
  @JsonKey(name: 'academic_stream_ids')
  // ignore: overridden_fields
  final List<int>? academicStreamIds;

  const CentralizedSubjectModel({
    required super.id,
    required super.nameAr,
    required super.slug,
    required super.coefficient,
    super.descriptionAr,
    super.color,
    super.icon,
    this.academicStreamIds,
    super.academicYearId,
    super.isActive,
  }) : super(academicStreamIds: academicStreamIds);

  /// Create model from JSON
  factory CentralizedSubjectModel.fromJson(Map<String, dynamic> json) =>
      _$CentralizedSubjectModelFromJson(json);

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$CentralizedSubjectModelToJson(this);

  /// Create model from entity
  factory CentralizedSubjectModel.fromEntity(CentralizedSubject entity) {
    return CentralizedSubjectModel(
      id: entity.id,
      nameAr: entity.nameAr,
      slug: entity.slug,
      coefficient: entity.coefficient,
      descriptionAr: entity.descriptionAr,
      color: entity.color,
      icon: entity.icon,
      academicStreamIds: entity.academicStreamIds,
      academicYearId: entity.academicYearId,
      isActive: entity.isActive,
    );
  }

  /// Convert model to entity
  CentralizedSubject toEntity() {
    return CentralizedSubject(
      id: id,
      nameAr: nameAr,
      slug: slug,
      coefficient: coefficient,
      descriptionAr: descriptionAr,
      color: color,
      icon: icon,
      academicStreamIds: academicStreamIds,
      academicYearId: academicYearId,
      isActive: isActive,
    );
  }

  /// Copy with method
  @override
  CentralizedSubjectModel copyWith({
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
    return CentralizedSubjectModel(
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
