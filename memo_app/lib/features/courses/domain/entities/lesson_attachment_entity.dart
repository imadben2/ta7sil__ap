import 'package:equatable/equatable.dart';

/// Lesson Attachment Entity - يمثل مرفق (ملف) خاص بدرس
class LessonAttachmentEntity extends Equatable {
  final int id;
  final int courseLessonId;
  final String fileNameAr;
  final String? fileNameEn;
  final String? fileNameFr;
  final String fileUrl;
  final String fileType; // "pdf", "doc", "docx", "ppt", "xlsx", etc.
  final int fileSizeKb;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LessonAttachmentEntity({
    required this.id,
    required this.courseLessonId,
    required this.fileNameAr,
    this.fileNameEn,
    this.fileNameFr,
    required this.fileUrl,
    required this.fileType,
    required this.fileSizeKb,
    required this.createdAt,
    required this.updatedAt,
  });

  /// حجم الملف بالميجابايت
  double get fileSizeMb => fileSizeKb / 1024.0;

  /// حجم الملف المنسق
  String get formattedFileSize {
    if (fileSizeKb < 1024) {
      return '$fileSizeKb ك.ب';
    } else if (fileSizeMb < 1024) {
      return '${fileSizeMb.toStringAsFixed(1)} م.ب';
    } else {
      final gb = fileSizeMb / 1024.0;
      return '${gb.toStringAsFixed(2)} ج.ب';
    }
  }

  /// أيقونة نوع الملف
  String get fileIcon {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'ppt':
      case 'pptx':
        return '📊';
      case 'xls':
      case 'xlsx':
        return '📈';
      case 'zip':
      case 'rar':
        return '📦';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return '🖼️';
      default:
        return '📎';
    }
  }

  /// هل الملف من نوع PDF؟
  bool get isPdf => fileType.toLowerCase() == 'pdf';

  /// هل الملف من نوع صورة؟
  bool get isImage =>
      ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileType.toLowerCase());

  /// هل الملف من نوع مستند نصي؟
  bool get isDocument =>
      ['doc', 'docx', 'txt', 'rtf'].contains(fileType.toLowerCase());

  LessonAttachmentEntity copyWith({
    int? id,
    int? courseLessonId,
    String? fileNameAr,
    String? fileNameEn,
    String? fileNameFr,
    String? fileUrl,
    String? fileType,
    int? fileSizeKb,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LessonAttachmentEntity(
      id: id ?? this.id,
      courseLessonId: courseLessonId ?? this.courseLessonId,
      fileNameAr: fileNameAr ?? this.fileNameAr,
      fileNameEn: fileNameEn ?? this.fileNameEn,
      fileNameFr: fileNameFr ?? this.fileNameFr,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSizeKb: fileSizeKb ?? this.fileSizeKb,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    courseLessonId,
    fileNameAr,
    fileNameEn,
    fileNameFr,
    fileUrl,
    fileType,
    fileSizeKb,
    createdAt,
    updatedAt,
  ];
}
