import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json_converters.dart';
import '../../domain/entities/flashcard_deck_entity.dart';

part 'flashcard_deck_model.g.dart';

@JsonSerializable(explicitToJson: true)
class FlashcardDeckModel extends FlashcardDeckEntity {
  @JsonKey(name: 'id')
  @SafeIntConverter()
  final int modelId;

  @JsonKey(name: 'title_ar')
  final String modelTitleAr;

  @JsonKey(name: 'title_fr')
  final String? modelTitleFr;

  @JsonKey(name: 'description_ar')
  final String? modelDescriptionAr;

  @JsonKey(name: 'description_fr')
  final String? modelDescriptionFr;

  @JsonKey(name: 'subject_id')
  @SafeIntConverter()
  final int modelSubjectId;

  @JsonKey(name: 'subject')
  final SubjectInfoModel? modelSubject;

  @JsonKey(name: 'chapter_id')
  @SafeNullableIntConverter()
  final int? modelChapterId;

  @JsonKey(name: 'chapter')
  final ChapterInfoModel? modelChapter;

  @JsonKey(name: 'total_cards')
  @SafeIntConverter()
  final int modelTotalCards;

  @JsonKey(name: 'cover_image_url')
  final String? modelCoverImageUrl;

  @JsonKey(name: 'color')
  final String modelColor;

  @JsonKey(name: 'icon')
  final String? modelIcon;

  @JsonKey(name: 'difficulty_level')
  final String modelDifficultyLevel;

  @JsonKey(name: 'estimated_study_minutes')
  @SafeNullableIntConverter()
  final int? modelEstimatedStudyMinutes;

  @JsonKey(name: 'is_published')
  final bool modelIsPublished;

  @JsonKey(name: 'is_premium')
  final bool modelIsPremium;

  @JsonKey(name: 'created_at')
  final DateTime modelCreatedAt;

  @JsonKey(name: 'user_progress')
  final UserDeckProgressModel? modelUserProgress;

  FlashcardDeckModel({
    required this.modelId,
    required this.modelTitleAr,
    this.modelTitleFr,
    this.modelDescriptionAr,
    this.modelDescriptionFr,
    required this.modelSubjectId,
    this.modelSubject,
    this.modelChapterId,
    this.modelChapter,
    required this.modelTotalCards,
    this.modelCoverImageUrl,
    this.modelColor = '#6366F1',
    this.modelIcon,
    this.modelDifficultyLevel = 'medium',
    this.modelEstimatedStudyMinutes,
    this.modelIsPublished = true,
    this.modelIsPremium = false,
    required this.modelCreatedAt,
    this.modelUserProgress,
  }) : super(
          id: modelId,
          titleAr: modelTitleAr,
          titleFr: modelTitleFr,
          descriptionAr: modelDescriptionAr,
          descriptionFr: modelDescriptionFr,
          subjectId: modelSubjectId,
          subject: modelSubject,
          chapterId: modelChapterId,
          chapter: modelChapter,
          totalCards: modelTotalCards,
          coverImageUrl: modelCoverImageUrl,
          color: modelColor,
          icon: modelIcon,
          difficultyLevel: modelDifficultyLevel,
          estimatedStudyMinutes: modelEstimatedStudyMinutes,
          isPublished: modelIsPublished,
          isPremium: modelIsPremium,
          createdAt: modelCreatedAt,
          userProgress: modelUserProgress,
        );

  factory FlashcardDeckModel.fromJson(Map<String, dynamic> json) =>
      _$FlashcardDeckModelFromJson(json);

  Map<String, dynamic> toJson() => _$FlashcardDeckModelToJson(this);
}

@JsonSerializable()
class SubjectInfoModel extends SubjectInfo {
  @JsonKey(name: 'id')
  @SafeIntConverter()
  final int modelId;

  @JsonKey(name: 'name_ar')
  final String modelNameAr;

  @JsonKey(name: 'color')
  final String? modelColor;

  @JsonKey(name: 'icon')
  final String? modelIcon;

  SubjectInfoModel({
    required this.modelId,
    required this.modelNameAr,
    this.modelColor,
    this.modelIcon,
  }) : super(
          id: modelId,
          nameAr: modelNameAr,
          color: modelColor,
          icon: modelIcon,
        );

  factory SubjectInfoModel.fromJson(Map<String, dynamic> json) =>
      _$SubjectInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectInfoModelToJson(this);
}

@JsonSerializable()
class ChapterInfoModel extends ChapterInfo {
  @JsonKey(name: 'id')
  @SafeIntConverter()
  final int modelId;

  @JsonKey(name: 'title_ar')
  final String modelTitleAr;

  ChapterInfoModel({
    required this.modelId,
    required this.modelTitleAr,
  }) : super(
          id: modelId,
          titleAr: modelTitleAr,
        );

  factory ChapterInfoModel.fromJson(Map<String, dynamic> json) =>
      _$ChapterInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterInfoModelToJson(this);
}

@JsonSerializable()
class UserDeckProgressModel extends UserDeckProgress {
  @JsonKey(name: 'cards_studied')
  @SafeIntConverter()
  final int modelCardsStudied;

  @JsonKey(name: 'cards_mastered')
  @SafeIntConverter()
  final int modelCardsMastered;

  @JsonKey(name: 'cards_due')
  @SafeIntConverter()
  final int modelCardsDue;

  @JsonKey(name: 'cards_new')
  @SafeIntConverter()
  final int modelCardsNew;

  @JsonKey(name: 'mastery_percentage')
  @SafeDoubleConverter()
  final double modelMasteryPercentage;

  @JsonKey(name: 'average_retention')
  @SafeDoubleConverter()
  final double modelAverageRetention;

  @JsonKey(name: 'last_studied_at')
  final DateTime? modelLastStudiedAt;

  UserDeckProgressModel({
    this.modelCardsStudied = 0,
    this.modelCardsMastered = 0,
    this.modelCardsDue = 0,
    this.modelCardsNew = 0,
    this.modelMasteryPercentage = 0,
    this.modelAverageRetention = 0,
    this.modelLastStudiedAt,
  }) : super(
          cardsStudied: modelCardsStudied,
          cardsMastered: modelCardsMastered,
          cardsDue: modelCardsDue,
          cardsNew: modelCardsNew,
          masteryPercentage: modelMasteryPercentage,
          averageRetention: modelAverageRetention,
          lastStudiedAt: modelLastStudiedAt,
        );

  factory UserDeckProgressModel.fromJson(Map<String, dynamic> json) =>
      _$UserDeckProgressModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserDeckProgressModelToJson(this);
}
