import 'package:equatable/equatable.dart';

/// Entity representing a sponsor/professor that appears in the sponsors carousel
/// هاد التطبيق برعاية - Sponsored by section
class SponsorEntity extends Equatable {
  /// Unique identifier
  final int id;

  /// Sponsor name (Arabic)
  final String nameAr;

  /// Sponsor photo URL
  final String photoUrl;

  /// External link to open when clicked (legacy field, kept for compatibility)
  final String? externalLink;

  /// YouTube channel/video link
  final String? youtubeLink;

  /// Facebook page/profile link
  final String? facebookLink;

  /// Instagram profile link
  final String? instagramLink;

  /// Telegram channel/group link
  final String? telegramLink;

  /// Sponsor title/description (e.g., "أستاذ الرياضيات")
  final String? title;

  /// Subject specialty (e.g., "الرياضيات", "الفيزياء")
  final String? specialty;

  /// Total click count
  final int clickCount;

  /// YouTube link clicks
  final int youtubeClicks;

  /// Facebook link clicks
  final int facebookClicks;

  /// Instagram link clicks
  final int instagramClicks;

  /// Telegram link clicks
  final int telegramClicks;

  /// Whether this sponsor is active/visible
  final bool isActive;

  /// Display order (lower = first)
  final int order;

  const SponsorEntity({
    required this.id,
    required this.nameAr,
    required this.photoUrl,
    this.externalLink,
    this.youtubeLink,
    this.facebookLink,
    this.instagramLink,
    this.telegramLink,
    this.title,
    this.specialty,
    this.clickCount = 0,
    this.youtubeClicks = 0,
    this.facebookClicks = 0,
    this.instagramClicks = 0,
    this.telegramClicks = 0,
    this.isActive = true,
    this.order = 0,
  });

  /// Get formatted click count (e.g., "1.2K")
  String get formattedClickCount {
    if (clickCount >= 1000000) {
      return '${(clickCount / 1000000).toStringAsFixed(1)}M';
    }
    if (clickCount >= 1000) {
      return '${(clickCount / 1000).toStringAsFixed(1)}K';
    }
    return clickCount.toString();
  }

  /// Check if sponsor has any social links
  bool get hasSocialLinks =>
      youtubeLink != null ||
      facebookLink != null ||
      instagramLink != null ||
      telegramLink != null;

  /// Get available social links count
  int get socialLinksCount {
    int count = 0;
    if (youtubeLink != null) count++;
    if (facebookLink != null) count++;
    if (instagramLink != null) count++;
    if (telegramLink != null) count++;
    return count;
  }

  @override
  List<Object?> get props => [
        id,
        nameAr,
        photoUrl,
        externalLink,
        youtubeLink,
        facebookLink,
        instagramLink,
        telegramLink,
        title,
        specialty,
        clickCount,
        youtubeClicks,
        facebookClicks,
        instagramClicks,
        telegramClicks,
        isActive,
        order,
      ];

  SponsorEntity copyWith({
    int? id,
    String? nameAr,
    String? photoUrl,
    String? externalLink,
    String? youtubeLink,
    String? facebookLink,
    String? instagramLink,
    String? telegramLink,
    String? title,
    String? specialty,
    int? clickCount,
    int? youtubeClicks,
    int? facebookClicks,
    int? instagramClicks,
    int? telegramClicks,
    bool? isActive,
    int? order,
  }) {
    return SponsorEntity(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      photoUrl: photoUrl ?? this.photoUrl,
      externalLink: externalLink ?? this.externalLink,
      youtubeLink: youtubeLink ?? this.youtubeLink,
      facebookLink: facebookLink ?? this.facebookLink,
      instagramLink: instagramLink ?? this.instagramLink,
      telegramLink: telegramLink ?? this.telegramLink,
      title: title ?? this.title,
      specialty: specialty ?? this.specialty,
      clickCount: clickCount ?? this.clickCount,
      youtubeClicks: youtubeClicks ?? this.youtubeClicks,
      facebookClicks: facebookClicks ?? this.facebookClicks,
      instagramClicks: instagramClicks ?? this.instagramClicks,
      telegramClicks: telegramClicks ?? this.telegramClicks,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
    );
  }
}
