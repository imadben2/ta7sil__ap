import 'package:equatable/equatable.dart';
import 'lesson_attachment_entity.dart';

/// Course Lesson Entity - يمثل درس في الدورة
class CourseLessonEntity extends Equatable {
  final int id;
  final int courseModuleId;
  final String titleAr;
  final String? titleEn;
  final String? titleFr;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? descriptionFr;

  // Video Info
  final String? videoUrl;
  final String? videoType; // "hls", "mp4", "youtube"
  final int videoDurationSeconds;

  final int order;
  final bool isPublished;
  final bool isFreePreview;
  final bool hasQuiz;

  final DateTime createdAt;
  final DateTime updatedAt;

  // Attachments
  final List<LessonAttachmentEntity>? attachments;

  const CourseLessonEntity({
    required this.id,
    required this.courseModuleId,
    required this.titleAr,
    this.titleEn,
    this.titleFr,
    this.descriptionAr,
    this.descriptionEn,
    this.descriptionFr,
    this.videoUrl,
    this.videoType,
    required this.videoDurationSeconds,
    required this.order,
    this.isPublished = true,
    this.isFreePreview = false,
    this.hasQuiz = false,
    required this.createdAt,
    required this.updatedAt,
    this.attachments,
  });

  /// المدة بالدقائق
  int get durationMinutes => (videoDurationSeconds / 60).ceil();

  /// المدة المنسقة (مثال: "15:30")
  String get formattedDuration {
    final minutes = videoDurationSeconds ~/ 60;
    final seconds = videoDurationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// المدة بالنص (مثال: "15 دقيقة")
  String get durationText {
    if (durationMinutes < 60) {
      return '$durationMinutes دقيقة';
    } else {
      final hours = durationMinutes ~/ 60;
      final mins = durationMinutes % 60;
      if (mins > 0) {
        return '$hours ساعة و $mins دقيقة';
      }
      return '$hours ساعة';
    }
  }

  /// عنوان الدرس مع رقمه
  String get titleWithNumber => 'الدرس $order: $titleAr';

  /// هل الدرس يحتوي على مرفقات؟
  bool get hasAttachments => attachments != null && attachments!.isNotEmpty;

  /// Compatibility getter
  String? get videoUrlHls => videoUrl;

  /// أيقونة نوع الفيديو
  String get videoTypeIcon {
    switch (videoType?.toLowerCase()) {
      case 'youtube':
        return '🎬';
      case 'hls':
        return '📺';
      default:
        return '▶️';
    }
  }

  CourseLessonEntity copyWith({
    int? id,
    int? courseModuleId,
    String? titleAr,
    String? titleEn,
    String? titleFr,
    String? descriptionAr,
    String? descriptionEn,
    String? descriptionFr,
    String? videoUrl,
    String? videoType,
    int? videoDurationSeconds,
    int? order,
    bool? isPublished,
    bool? isFreePreview,
    bool? hasQuiz,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<LessonAttachmentEntity>? attachments,
  }) {
    return CourseLessonEntity(
      id: id ?? this.id,
      courseModuleId: courseModuleId ?? this.courseModuleId,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      titleFr: titleFr ?? this.titleFr,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionFr: descriptionFr ?? this.descriptionFr,
      videoUrl: videoUrl ?? this.videoUrl,
      videoType: videoType ?? this.videoType,
      videoDurationSeconds: videoDurationSeconds ?? this.videoDurationSeconds,
      order: order ?? this.order,
      isPublished: isPublished ?? this.isPublished,
      isFreePreview: isFreePreview ?? this.isFreePreview,
      hasQuiz: hasQuiz ?? this.hasQuiz,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attachments: attachments ?? this.attachments,
    );
  }

  @override
  List<Object?> get props => [
    id,
    courseModuleId,
    titleAr,
    titleEn,
    titleFr,
    descriptionAr,
    descriptionEn,
    descriptionFr,
    videoUrl,
    videoType,
    videoDurationSeconds,
    order,
    isPublished,
    isFreePreview,
    hasQuiz,
    createdAt,
    updatedAt,
    attachments,
  ];
}
