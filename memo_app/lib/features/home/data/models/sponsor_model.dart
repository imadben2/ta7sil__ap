import '../../domain/entities/sponsor_entity.dart';

/// Data model for Sponsor API responses
/// Maps JSON from API to SponsorEntity
class SponsorModel extends SponsorEntity {
  const SponsorModel({
    required super.id,
    required super.nameAr,
    required super.photoUrl,
    super.externalLink,
    super.youtubeLink,
    super.facebookLink,
    super.instagramLink,
    super.telegramLink,
    super.title,
    super.specialty,
    super.clickCount = 0,
    super.youtubeClicks = 0,
    super.facebookClicks = 0,
    super.instagramClicks = 0,
    super.telegramClicks = 0,
    super.isActive = true,
    super.order = 0,
  });

  /// Create SponsorModel from JSON response
  factory SponsorModel.fromJson(Map<String, dynamic> json) {
    return SponsorModel(
      id: json['id'] as int,
      nameAr: json['name_ar'] as String,
      photoUrl: json['photo_url'] as String,
      externalLink: json['external_link'] as String?,
      youtubeLink: json['youtube_link'] as String?,
      facebookLink: json['facebook_link'] as String?,
      instagramLink: json['instagram_link'] as String?,
      telegramLink: json['telegram_link'] as String?,
      title: json['title'] as String?,
      specialty: json['specialty'] as String?,
      clickCount: json['click_count'] as int? ?? 0,
      youtubeClicks: json['youtube_clicks'] as int? ?? 0,
      facebookClicks: json['facebook_clicks'] as int? ?? 0,
      instagramClicks: json['instagram_clicks'] as int? ?? 0,
      telegramClicks: json['telegram_clicks'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      order: json['display_order'] as int? ?? 0,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'photo_url': photoUrl,
      'external_link': externalLink,
      'youtube_link': youtubeLink,
      'facebook_link': facebookLink,
      'instagram_link': instagramLink,
      'telegram_link': telegramLink,
      'title': title,
      'specialty': specialty,
      'click_count': clickCount,
      'youtube_clicks': youtubeClicks,
      'facebook_clicks': facebookClicks,
      'instagram_clicks': instagramClicks,
      'telegram_clicks': telegramClicks,
      'is_active': isActive,
      'display_order': order,
    };
  }

  /// Create SponsorModel from SponsorEntity
  factory SponsorModel.fromEntity(SponsorEntity entity) {
    return SponsorModel(
      id: entity.id,
      nameAr: entity.nameAr,
      photoUrl: entity.photoUrl,
      externalLink: entity.externalLink,
      youtubeLink: entity.youtubeLink,
      facebookLink: entity.facebookLink,
      instagramLink: entity.instagramLink,
      telegramLink: entity.telegramLink,
      title: entity.title,
      specialty: entity.specialty,
      clickCount: entity.clickCount,
      youtubeClicks: entity.youtubeClicks,
      facebookClicks: entity.facebookClicks,
      instagramClicks: entity.instagramClicks,
      telegramClicks: entity.telegramClicks,
      isActive: entity.isActive,
      order: entity.order,
    );
  }

  /// Convert to SponsorEntity
  SponsorEntity toEntity() {
    return SponsorEntity(
      id: id,
      nameAr: nameAr,
      photoUrl: photoUrl,
      externalLink: externalLink,
      youtubeLink: youtubeLink,
      facebookLink: facebookLink,
      instagramLink: instagramLink,
      telegramLink: telegramLink,
      title: title,
      specialty: specialty,
      clickCount: clickCount,
      youtubeClicks: youtubeClicks,
      facebookClicks: facebookClicks,
      instagramClicks: instagramClicks,
      telegramClicks: telegramClicks,
      isActive: isActive,
      order: order,
    );
  }
}
