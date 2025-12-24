// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_deck_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlashcardDeckModel _$FlashcardDeckModelFromJson(Map<String, dynamic> json) =>
    FlashcardDeckModel(
      modelId: const SafeIntConverter().fromJson(json['id']),
      modelTitleAr: json['title_ar'] as String,
      modelTitleFr: json['title_fr'] as String?,
      modelDescriptionAr: json['description_ar'] as String?,
      modelDescriptionFr: json['description_fr'] as String?,
      modelSubjectId: const SafeIntConverter().fromJson(json['subject_id']),
      modelSubject: json['subject'] == null
          ? null
          : SubjectInfoModel.fromJson(json['subject'] as Map<String, dynamic>),
      modelChapterId:
          const SafeNullableIntConverter().fromJson(json['chapter_id']),
      modelChapter: json['chapter'] == null
          ? null
          : ChapterInfoModel.fromJson(json['chapter'] as Map<String, dynamic>),
      modelTotalCards: const SafeIntConverter().fromJson(json['total_cards']),
      modelCoverImageUrl: json['cover_image_url'] as String?,
      modelColor: json['color'] as String? ?? '#6366F1',
      modelIcon: json['icon'] as String?,
      modelDifficultyLevel: json['difficulty_level'] as String? ?? 'medium',
      modelEstimatedStudyMinutes: const SafeNullableIntConverter()
          .fromJson(json['estimated_study_minutes']),
      modelIsPublished: json['is_published'] as bool? ?? true,
      modelIsPremium: json['is_premium'] as bool? ?? false,
      modelCreatedAt: DateTime.parse(json['created_at'] as String),
      modelUserProgress: json['user_progress'] == null
          ? null
          : UserDeckProgressModel.fromJson(
              json['user_progress'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FlashcardDeckModelToJson(FlashcardDeckModel instance) =>
    <String, dynamic>{
      'id': const SafeIntConverter().toJson(instance.modelId),
      'title_ar': instance.modelTitleAr,
      'title_fr': instance.modelTitleFr,
      'description_ar': instance.modelDescriptionAr,
      'description_fr': instance.modelDescriptionFr,
      'subject_id': const SafeIntConverter().toJson(instance.modelSubjectId),
      'subject': instance.modelSubject?.toJson(),
      'chapter_id':
          const SafeNullableIntConverter().toJson(instance.modelChapterId),
      'chapter': instance.modelChapter?.toJson(),
      'total_cards': const SafeIntConverter().toJson(instance.modelTotalCards),
      'cover_image_url': instance.modelCoverImageUrl,
      'color': instance.modelColor,
      'icon': instance.modelIcon,
      'difficulty_level': instance.modelDifficultyLevel,
      'estimated_study_minutes': const SafeNullableIntConverter()
          .toJson(instance.modelEstimatedStudyMinutes),
      'is_published': instance.modelIsPublished,
      'is_premium': instance.modelIsPremium,
      'created_at': instance.modelCreatedAt.toIso8601String(),
      'user_progress': instance.modelUserProgress?.toJson(),
    };

SubjectInfoModel _$SubjectInfoModelFromJson(Map<String, dynamic> json) =>
    SubjectInfoModel(
      modelId: const SafeIntConverter().fromJson(json['id']),
      modelNameAr: json['name_ar'] as String,
      modelColor: json['color'] as String?,
      modelIcon: json['icon'] as String?,
    );

Map<String, dynamic> _$SubjectInfoModelToJson(SubjectInfoModel instance) =>
    <String, dynamic>{
      'id': const SafeIntConverter().toJson(instance.modelId),
      'name_ar': instance.modelNameAr,
      'color': instance.modelColor,
      'icon': instance.modelIcon,
    };

ChapterInfoModel _$ChapterInfoModelFromJson(Map<String, dynamic> json) =>
    ChapterInfoModel(
      modelId: const SafeIntConverter().fromJson(json['id']),
      modelTitleAr: json['title_ar'] as String,
    );

Map<String, dynamic> _$ChapterInfoModelToJson(ChapterInfoModel instance) =>
    <String, dynamic>{
      'id': const SafeIntConverter().toJson(instance.modelId),
      'title_ar': instance.modelTitleAr,
    };

UserDeckProgressModel _$UserDeckProgressModelFromJson(
        Map<String, dynamic> json) =>
    UserDeckProgressModel(
      modelCardsStudied: json['cards_studied'] == null
          ? 0
          : const SafeIntConverter().fromJson(json['cards_studied']),
      modelCardsMastered: json['cards_mastered'] == null
          ? 0
          : const SafeIntConverter().fromJson(json['cards_mastered']),
      modelCardsDue: json['cards_due'] == null
          ? 0
          : const SafeIntConverter().fromJson(json['cards_due']),
      modelCardsNew: json['cards_new'] == null
          ? 0
          : const SafeIntConverter().fromJson(json['cards_new']),
      modelMasteryPercentage: json['mastery_percentage'] == null
          ? 0
          : const SafeDoubleConverter().fromJson(json['mastery_percentage']),
      modelAverageRetention: json['average_retention'] == null
          ? 0
          : const SafeDoubleConverter().fromJson(json['average_retention']),
      modelLastStudiedAt: json['last_studied_at'] == null
          ? null
          : DateTime.parse(json['last_studied_at'] as String),
    );

Map<String, dynamic> _$UserDeckProgressModelToJson(
        UserDeckProgressModel instance) =>
    <String, dynamic>{
      'cards_studied':
          const SafeIntConverter().toJson(instance.modelCardsStudied),
      'cards_mastered':
          const SafeIntConverter().toJson(instance.modelCardsMastered),
      'cards_due': const SafeIntConverter().toJson(instance.modelCardsDue),
      'cards_new': const SafeIntConverter().toJson(instance.modelCardsNew),
      'mastery_percentage':
          const SafeDoubleConverter().toJson(instance.modelMasteryPercentage),
      'average_retention':
          const SafeDoubleConverter().toJson(instance.modelAverageRetention),
      'last_studied_at': instance.modelLastStudiedAt?.toIso8601String(),
    };
