import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/promo_entity.dart';
import 'countdown_promo_card.dart';

/// Promotional slider widget for home page
/// Simple, safe design with gradient cards
class PromoSliderWidget extends StatefulWidget {
  final List<PromoItem> items;
  final double height;
  final Duration autoPlayDuration;
  final VoidCallback? onItemTap;

  const PromoSliderWidget({
    super.key,
    required this.items,
    this.height = 130,
    this.autoPlayDuration = const Duration(seconds: 5),
    this.onItemTap,
  });

  @override
  State<PromoSliderWidget> createState() => _PromoSliderWidgetState();
}

class _PromoSliderWidgetState extends State<PromoSliderWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.92,
      initialPage: 0,
    );
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    if (widget.items.length <= 1) return;

    _autoPlayTimer = Timer.periodic(widget.autoPlayDuration, (_) {
      if (_pageController.hasClients && mounted) {
        final nextPage = (_currentPage + 1) % widget.items.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int page) {
    if (mounted) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    // Total height includes card + dots indicator
    final dotsHeight = widget.items.length > 1 ? 24.0 : 0.0;

    return SizedBox(
      height: widget.height + dotsHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: widget.height,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                // Use countdown card for countdown promos
                if (item.isCountdown && item.promoEntity != null) {
                  return CountdownPromoCard(
                    promo: item.promoEntity!,
                    onTap: () {
                      item.onTap?.call();
                      widget.onItemTap?.call();
                    },
                  );
                }
                return _buildPromoCard(item);
              },
            ),
          ),
          if (widget.items.length > 1) ...[
            const SizedBox(height: 12),
            _buildDotsIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildPromoCard(PromoItem item) {
    return GestureDetector(
      onTap: () {
        item.onTap?.call();
        widget.onItemTap?.call();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: item.gradientColors ?? [
              const Color(0xFF7C3AED),
              const Color(0xFF4F46E5),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: (item.gradientColors?.first ?? const Color(0xFF7C3AED))
                  .withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background decorations
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Title
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Subtitle
                          if (item.subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle!,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.85),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          // CTA Button
                          if (item.actionText != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_back_ios_rounded,
                                    size: 10,
                                    color: item.gradientColors?.first ??
                                        const Color(0xFF7C3AED),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.actionText!,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: item.gradientColors?.first ??
                                          const Color(0xFF7C3AED),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Icon
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        item.icon ?? Icons.play_arrow_rounded,
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.items.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentPage == index
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.25),
          ),
        ),
      ),
    );
  }
}

/// Model for promo slider items
class PromoItem {
  final int? id;
  final String title;
  final String? subtitle;
  final String? badge;
  final String? actionText;
  final IconData? icon;
  final String? imageUrl;
  final List<Color>? gradientColors;
  final LinearGradient? gradient;
  final String? actionType;
  final String? actionValue;
  final VoidCallback? onTap;

  // Countdown properties
  final bool isCountdown;
  final PromoEntity? promoEntity; // Store original entity for countdown

  const PromoItem({
    this.id,
    required this.title,
    this.subtitle,
    this.badge,
    this.actionText,
    this.icon,
    this.imageUrl,
    this.gradientColors,
    this.gradient,
    this.actionType,
    this.actionValue,
    this.onTap,
    this.isCountdown = false,
    this.promoEntity,
  });

  /// Create PromoItem from PromoEntity
  factory PromoItem.fromEntity(PromoEntity entity, {VoidCallback? onTap}) {
    return PromoItem(
      id: entity.id,
      title: entity.title,
      subtitle: entity.subtitle,
      badge: entity.badge,
      actionText: entity.actionText,
      icon: _iconFromName(entity.iconName),
      imageUrl: entity.imageUrl,
      gradientColors: _parseGradientColors(entity.gradientColors),
      actionType: entity.actionType,
      actionValue: entity.actionValue,
      onTap: onTap,
      isCountdown: entity.isCountdown,
      promoEntity: entity.isCountdown ? entity : null,
    );
  }

  /// Convert list of PromoEntity to list of PromoItem
  /// Countdown promos are placed first in the list
  static List<PromoItem> fromEntities(
    List<PromoEntity> entities, {
    void Function(PromoEntity entity)? onItemTap,
  }) {
    // Separate countdown and regular promos
    final countdownPromos = entities.where((e) => e.isCountdown).toList();
    final regularPromos = entities.where((e) => !e.isCountdown).toList();

    // Combine with countdown promos first
    final sortedEntities = [...countdownPromos, ...regularPromos];

    return sortedEntities.map((entity) {
      return PromoItem.fromEntity(
        entity,
        onTap: onItemTap != null ? () => onItemTap(entity) : null,
      );
    }).toList();
  }

  /// Parse icon name string to IconData
  static IconData? _iconFromName(String? iconName) {
    if (iconName == null) return null;

    final iconMap = <String, IconData>{
      'school': Icons.school_rounded,
      'emoji_events': Icons.emoji_events_rounded,
      'assignment': Icons.assignment_rounded,
      'people': Icons.people_rounded,
      'quiz': Icons.quiz_rounded,
      'book': Icons.book_rounded,
      'timer': Icons.timer_rounded,
      'star': Icons.star_rounded,
      'trending_up': Icons.trending_up_rounded,
      'local_offer': Icons.local_offer_rounded,
      'celebration': Icons.celebration_rounded,
      'rocket_launch': Icons.rocket_launch_rounded,
      'rocket': Icons.rocket_launch_rounded,
      'workspace_premium': Icons.workspace_premium_rounded,
      'lightbulb': Icons.lightbulb_rounded,
      'psychology': Icons.psychology_rounded,
      'play_arrow': Icons.play_arrow_rounded,
      'play_circle': Icons.play_circle_rounded,
      'calendar_month': Icons.calendar_month_rounded,
      'bolt': Icons.bolt_rounded,
      'hourglass_empty': Icons.hourglass_empty_rounded,
      'alarm': Icons.alarm_rounded,
      'schedule': Icons.schedule_rounded,
    };

    return iconMap[iconName] ?? Icons.play_arrow_rounded;
  }

  /// Parse hex color strings to Color list
  static List<Color>? _parseGradientColors(List<String>? hexColors) {
    if (hexColors == null || hexColors.isEmpty) return null;

    return hexColors.map((hex) {
      final cleanHex = hex.replaceAll('#', '');
      final colorValue = int.tryParse(cleanHex, radix: 16);
      if (colorValue == null) return AppColors.primary;

      if (cleanHex.length == 6) {
        return Color(0xFF000000 | colorValue);
      }
      return Color(colorValue);
    }).toList();
  }

  /// Default promotional items for the app
  static List<PromoItem> get defaultItems => [
        const PromoItem(
          title: 'دوراتنا التعليمية',
          subtitle: 'دورات متخصصة مع أفضل الأساتذة',
          actionText: 'استكشف جميع الدورات',
          icon: Icons.play_arrow_rounded,
          gradientColors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
        ),
        const PromoItem(
          title: 'تحدي الأسبوع',
          subtitle: 'أكمل 5 اختبارات واربح نقاط إضافية',
          actionText: 'ابدأ التحدي',
          icon: Icons.emoji_events_rounded,
          gradientColors: [Color(0xFFFF9800), Color(0xFFE65100)],
        ),
        const PromoItem(
          title: 'محاكاة البكالوريا',
          subtitle: 'جرب نفسك في ظروف امتحان حقيقية',
          actionText: 'ابدأ المحاكاة',
          icon: Icons.assignment_rounded,
          gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
        const PromoItem(
          title: 'ادعُ أصدقاءك',
          subtitle: 'اربح نقاط عن كل صديق يسجل',
          actionText: 'دعوة صديق',
          icon: Icons.people_rounded,
          gradientColors: [Color(0xFFEC4899), Color(0xFFBE185D)],
        ),
      ];
}
