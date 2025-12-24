import 'package:equatable/equatable.dart';

/// Course Review Entity - يمثل مراجعة/تقييم لدورة
class CourseReviewEntity extends Equatable {
  final int id;
  final int userId;
  final int courseId;
  final int rating; // 1-5
  final String? reviewTextAr;
  final String? reviewTextEn;
  final String? reviewTextFr;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;

  // User info
  final String? userName;
  final String? userAvatar;

  const CourseReviewEntity({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.rating,
    this.reviewTextAr,
    this.reviewTextEn,
    this.reviewTextFr,
    this.isApproved = false,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userAvatar,
  });

  /// هل المراجعة لها نص؟
  bool get hasReviewText => reviewTextAr != null && reviewTextAr!.isNotEmpty;

  /// تقييم النجوم كنص
  String get starsText => '⭐' * rating;

  /// اسم المستخدم أو افتراضي
  String get displayName => userName ?? 'مستخدم';

  /// نص التاريخ
  String get createdAtText {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inDays < 30) {
      return 'منذ ${(difference.inDays / 7).floor()} أسبوع';
    } else if (difference.inDays < 365) {
      return 'منذ ${(difference.inDays / 30).floor()} شهر';
    } else {
      return 'منذ ${(difference.inDays / 365).floor()} سنة';
    }
  }

  /// نص وصف التقييم
  String get ratingDescription {
    switch (rating) {
      case 5:
        return 'ممتاز';
      case 4:
        return 'جيد جداً';
      case 3:
        return 'جيد';
      case 2:
        return 'مقبول';
      case 1:
        return 'ضعيف';
      default:
        return '';
    }
  }

  CourseReviewEntity copyWith({
    int? id,
    int? userId,
    int? courseId,
    int? rating,
    String? reviewTextAr,
    String? reviewTextEn,
    String? reviewTextFr,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userAvatar,
  }) {
    return CourseReviewEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      rating: rating ?? this.rating,
      reviewTextAr: reviewTextAr ?? this.reviewTextAr,
      reviewTextEn: reviewTextEn ?? this.reviewTextEn,
      reviewTextFr: reviewTextFr ?? this.reviewTextFr,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    courseId,
    rating,
    reviewTextAr,
    reviewTextEn,
    reviewTextFr,
    isApproved,
    createdAt,
    updatedAt,
    userName,
    userAvatar,
  ];
}
