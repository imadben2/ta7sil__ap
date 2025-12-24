import 'package:equatable/equatable.dart';

/// Entity representing a promotional item/banner
class PromoEntity extends Equatable {
  final int id;
  final String title;
  final String? subtitle;
  final String? badge;
  final String? actionText;
  final String? iconName;
  final String? imageUrl;
  final List<String>? gradientColors;
  final String? actionType;
  final String? actionValue;
  final int order;
  final bool isActive;

  // Countdown promo fields
  final String? promoType; // 'default', 'countdown'
  final DateTime? targetDate; // Target date for countdown
  final String? countdownLabel; // e.g., "يوم على البكالوريا"

  const PromoEntity({
    required this.id,
    required this.title,
    this.subtitle,
    this.badge,
    this.actionText,
    this.iconName,
    this.imageUrl,
    this.gradientColors,
    this.actionType,
    this.actionValue,
    this.order = 0,
    this.isActive = true,
    this.promoType,
    this.targetDate,
    this.countdownLabel,
  });

  /// Check if this is a countdown promo
  bool get isCountdown => promoType == 'countdown' && targetDate != null;

  /// Get days remaining for countdown
  int get daysRemaining {
    if (targetDate == null) return 0;
    final now = DateTime.now();
    final difference = targetDate!.difference(now);
    return difference.inDays.clamp(0, 999);
  }

  /// Get hours remaining (after days)
  int get hoursRemaining {
    if (targetDate == null) return 0;
    final now = DateTime.now();
    final difference = targetDate!.difference(now);
    return (difference.inHours % 24).clamp(0, 23);
  }

  /// Get minutes remaining (after hours)
  int get minutesRemaining {
    if (targetDate == null) return 0;
    final now = DateTime.now();
    final difference = targetDate!.difference(now);
    return (difference.inMinutes % 60).clamp(0, 59);
  }

  /// Get seconds remaining (after minutes)
  int get secondsRemaining {
    if (targetDate == null) return 0;
    final now = DateTime.now();
    final difference = targetDate!.difference(now);
    return (difference.inSeconds % 60).clamp(0, 59);
  }

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        badge,
        actionText,
        iconName,
        imageUrl,
        gradientColors,
        actionType,
        actionValue,
        order,
        isActive,
        promoType,
        targetDate,
        countdownLabel,
      ];
}

/// Response wrapper for promos API
class PromosResponse extends Equatable {
  final List<PromoEntity> promos;
  final bool sectionEnabled;

  const PromosResponse({
    required this.promos,
    this.sectionEnabled = true,
  });

  @override
  List<Object?> get props => [promos, sectionEnabled];
}
