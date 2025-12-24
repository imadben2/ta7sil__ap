import 'package:flutter/material.dart';
import '../../domain/entities/subscription_package_entity.dart';

/// Modern subscription package card with gradient effects and animations
///
/// Features:
/// - Gradient overlay for popular packages
/// - Animated discount badge with pulse effect
/// - Modern shadow and border radius (20px)
/// - Feature list with custom check icons
/// - Gradient subscribe button
/// - RTL support with Cairo font
class SubscriptionPackageCard extends StatefulWidget {
  final SubscriptionPackageEntity package;
  final VoidCallback onSubscribe;

  const SubscriptionPackageCard({
    super.key,
    required this.package,
    required this.onSubscribe,
  });

  @override
  State<SubscriptionPackageCard> createState() => _SubscriptionPackageCardState();
}

class _SubscriptionPackageCardState extends State<SubscriptionPackageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool get isPopular => widget.package.isPopular ?? false;
  bool get hasDiscount =>
      widget.package.discountPercentage != null &&
      widget.package.discountPercentage! > 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (hasDiscount) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isPopular
            ? Border.all(color: const Color(0xFF2196F3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isPopular
                ? const Color(0xFF2196F3).withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: isPopular ? 24 : 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gradient overlay for popular packages
          if (isPopular) _buildGradientOverlay(),

          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with badges space
                if (isPopular || hasDiscount) const SizedBox(height: 24),

                // Package Name
                Text(
                  widget.package.nameAr,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isPopular
                        ? const Color(0xFF2196F3)
                        : const Color(0xFF1E293B),
                  ),
                ),

                const SizedBox(height: 8),

                // Description
                if (widget.package.descriptionAr != null &&
                    widget.package.descriptionAr!.isNotEmpty)
                  Text(
                    widget.package.descriptionAr!,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),

                const SizedBox(height: 20),

                // Price Section
                _buildPriceSection(),

                if (widget.package.durationDays != null) ...[
                  const SizedBox(height: 12),
                  _buildDurationBadge(),
                ],

                const SizedBox(height: 20),

                // Features
                if (widget.package.features != null &&
                    widget.package.features!.isNotEmpty) ...[
                  _buildFeaturesDivider(),
                  const SizedBox(height: 16),
                  _buildFeaturesList(),
                  const SizedBox(height: 20),
                ],

                // Subscribe Button
                _buildSubscribeButton(),
              ],
            ),
          ),

          // Popular Badge
          if (isPopular) _buildPopularBadge(),

          // Discount Badge
          if (hasDiscount) _buildDiscountBadge(),
        ],
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 100,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2196F3).withOpacity(0.08),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (hasDiscount) ...[
          Text(
            '${widget.package.priceDzd} دج',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              color: Colors.grey[500],
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.grey[500],
            ),
          ),
          const SizedBox(width: 12),
        ],
        Text(
          '${widget.package.finalPrice}',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2196F3),
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            'دج',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer_outlined,
            size: 16,
            color: Color(0xFF8B5CF6),
          ),
          const SizedBox(width: 6),
          Text(
            _formatDuration(widget.package.durationDays!),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B5CF6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesDivider() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.verified_rounded,
            color: Color(0xFF10B981),
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'المميزات',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      children: widget.package.features!.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF10B981),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feature,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubscribeButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: widget.onSubscribe,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPopular
              ? const Color(0xFF2196F3)
              : const Color(0xFF64748B),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart_rounded, size: 20),
            const SizedBox(width: 8),
            const Text(
              'اشترك الآن',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularBadge() {
    return Positioned(
      top: 0,
      left: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x402196F3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text(
              'الأكثر شعبية',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountBadge() {
    return Positioned(
      top: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x40EF4444),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_offer_rounded, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                '-${widget.package.discountPercentage}%',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int days) {
    if (days >= 365) {
      final years = (days / 365).floor();
      return years == 1 ? 'سنة واحدة' : '$years سنوات';
    } else if (days >= 30) {
      final months = (days / 30).floor();
      return months == 1 ? 'شهر واحد' : '$months أشهر';
    } else {
      return days == 1 ? 'يوم واحد' : '$days يوم';
    }
  }
}
