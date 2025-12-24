import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/subject_progress_entity.dart';

part 'subject_progress_model.g.dart';

@JsonSerializable()
class SubjectProgressModel {
  final int id;
  final String name;
  @JsonKey(name: 'name_ar')
  final String nameAr;
  final String color;
  final double coefficient;
  @JsonKey(name: 'total_lessons')
  final int totalLessons;
  @JsonKey(name: 'completed_lessons')
  final int completedLessons;
  @JsonKey(name: 'total_quizzes')
  final int totalQuizzes;
  @JsonKey(name: 'completed_quizzes')
  final int completedQuizzes;
  @JsonKey(name: 'average_score')
  final double averageScore;
  @JsonKey(name: 'next_exam_date')
  final String? nextExamDate; // ISO 8601 or null
  @JsonKey(name: 'icon_emoji')
  final String? iconEmoji;

  const SubjectProgressModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.color,
    required this.coefficient,
    required this.totalLessons,
    required this.completedLessons,
    required this.totalQuizzes,
    required this.completedQuizzes,
    required this.averageScore,
    this.nextExamDate,
    this.iconEmoji,
  });

  factory SubjectProgressModel.fromJson(Map<String, dynamic> json) =>
      _$SubjectProgressModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectProgressModelToJson(this);

  SubjectProgressEntity toEntity() {
    return SubjectProgressEntity(
      id: id,
      name: name,
      nameAr: nameAr,
      color: color,
      coefficient: coefficient,
      totalLessons: totalLessons,
      completedLessons: completedLessons,
      totalQuizzes: totalQuizzes,
      completedQuizzes: completedQuizzes,
      averageScore: averageScore,
      nextExamDate: nextExamDate != null ? DateTime.parse(nextExamDate!) : null,
      iconEmoji: iconEmoji,
    );
  }
}
