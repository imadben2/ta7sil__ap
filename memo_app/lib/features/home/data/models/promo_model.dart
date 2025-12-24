import '../../domain/entities/promo_entity.dart';

/// Model for promo data from API
class PromoModel extends PromoEntity {
  const PromoModel({
    required super.id,
    required super.title,
    super.subtitle,
    super.badge,
    super.actionText,
    super.iconName,
    super.imageUrl,
    super.gradientColors,
    super.actionType,
    super.actionValue,
    super.order,
    super.isActive,
    super.promoType,
    super.targetDate,
    super.countdownLabel,
  });

  /// Create from JSON
  factory PromoModel.fromJson(Map<String, dynamic> json) {
    // Parse gradient colors from API (can be array of hex strings)
    List<String>? gradientColors;
    if (json['gradient_colors'] != null) {
      if (json['gradient_colors'] is List) {
        gradientColors = (json['gradient_colors'] as List)
            .map((e) => e.toString())
            .toList();
      } else if (json['gradient_colors'] is String) {
        // Handle comma-separated string format
        gradientColors = (json['gradient_colors'] as String)
            .split(',')
            .map((e) => e.trim())
            .toList();
      }
    }

    // Parse target date for countdown promos
    DateTime? targetDate;
    if (json['target_date'] != null) {
      try {
        targetDate = DateTime.parse(json['target_date'] as String);
      } catch (_) {
        // Invalid date format, ignore
      }
    }

    return PromoModel(
      id: json['id'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      badge: json['badge'] as String?,
      actionText: json['action_text'] as String?,
      iconName: json['icon_name'] as String?,
      imageUrl: json['image_url'] as String?,
      gradientColors: gradientColors,
      actionType: json['action_type'] as String?,
      actionValue: json['action_value'] as String?,
      order: json['display_order'] as int? ?? json['order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      promoType: json['promo_type'] as String? ?? json['type'] as String?,
      targetDate: targetDate,
      countdownLabel: json['countdown_label'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'badge': badge,
      'action_text': actionText,
      'icon_name': iconName,
      'image_url': imageUrl,
      'gradient_colors': gradientColors,
      'action_type': actionType,
      'action_value': actionValue,
      'display_order': order,
      'is_active': isActive,
      'promo_type': promoType,
      'target_date': targetDate?.toIso8601String(),
      'countdown_label': countdownLabel,
    };
  }

  /// Convert to entity
  PromoEntity toEntity() {
    return PromoEntity(
      id: id,
      title: title,
      subtitle: subtitle,
      badge: badge,
      actionText: actionText,
      iconName: iconName,
      imageUrl: imageUrl,
      gradientColors: gradientColors,
      actionType: actionType,
      actionValue: actionValue,
      order: order,
      isActive: isActive,
      promoType: promoType,
      targetDate: targetDate,
      countdownLabel: countdownLabel,
    );
  }
}

/// API response wrapper
class PromoApiResponse {
  final List<PromoModel> promos;
  final bool sectionEnabled;

  PromoApiResponse({
    required this.promos,
    this.sectionEnabled = true,
  });

  factory PromoApiResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    // Handle new format: { data: { section_enabled, promos } }
    if (data is Map<String, dynamic> && data.containsKey('promos')) {
      final promosList = (data['promos'] as List?)
          ?.map((e) => PromoModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      return PromoApiResponse(
        promos: promosList,
        sectionEnabled: data['section_enabled'] as bool? ?? true,
      );
    }

    // Handle old format: { data: [ promo1, promo2, ... ] }
    if (data is List) {
      final promosList = data
          .map((e) => PromoModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return PromoApiResponse(
        promos: promosList,
        sectionEnabled: true,
      );
    }

    // Fallback: empty list
    return PromoApiResponse(promos: [], sectionEnabled: false);
  }
}
