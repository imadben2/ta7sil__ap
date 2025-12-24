import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/course_review_entity.dart';

part 'course_review_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CourseReviewModel {
  final int id;
  @JsonKey(name: 'course_id')
  final int courseId;
  @JsonKey(name: 'user_id')
  final int userId;
  final int rating;
  @JsonKey(name: 'review_text_ar')
  final String reviewTextAr;
  @JsonKey(name: 'is_approved')
  final bool isApproved;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'user_name')
  final String userName;
  @JsonKey(name: 'user_avatar')
  final String? userAvatar;

  const CourseReviewModel({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.rating,
    required this.reviewTextAr,
    this.isApproved = false,
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    this.userAvatar,
  });

  factory CourseReviewModel.fromJson(Map<String, dynamic> json) =>
      _$CourseReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$CourseReviewModelToJson(this);

  CourseReviewEntity toEntity() {
    return CourseReviewEntity(
      id: id,
      userId: userId,
      courseId: courseId,
      rating: rating,
      reviewTextAr: reviewTextAr,
      reviewTextEn: null,
      reviewTextFr: null,
      isApproved: isApproved,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userName: userName,
      userAvatar: userAvatar,
    );
  }

  factory CourseReviewModel.fromEntity(CourseReviewEntity entity) {
    return CourseReviewModel(
      id: entity.id,
      courseId: entity.courseId,
      userId: entity.userId,
      rating: entity.rating,
      reviewTextAr: entity.reviewTextAr ?? '',
      isApproved: entity.isApproved,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      userName: entity.userName ?? 'مستخدم',
      userAvatar: entity.userAvatar,
    );
  }
}
