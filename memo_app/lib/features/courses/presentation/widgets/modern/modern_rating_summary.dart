import 'package:flutter/material.dart';

/// Modern Rating Summary Widget
/// Shows average rating with star breakdown
class ModernRatingSummary extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // star -> count

  const ModernRatingSummary({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Average Rating Display
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStarsRow(averageRating),
                const SizedBox(height: 8),
                Text(
                  '$totalReviews تقييم',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            width: 1,
            height: 120,
            color: Colors.grey[200],
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // Rating Distribution
          Expanded(
            flex: 3,
            child: Column(
              children: [5, 4, 3, 2, 1]
                  .map((star) => _buildRatingBar(
                        star,
                        ratingDistribution[star] ?? 0,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarsRow(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        if (rating >= starValue) {
          return const Icon(
            Icons.star_rounded,
            color: Color(0xFFF59E0B),
            size: 20,
          );
        } else if (rating >= starValue - 0.5) {
          return const Icon(
            Icons.star_half_rounded,
            color: Color(0xFFF59E0B),
            size: 20,
          );
        } else {
          return Icon(
            Icons.star_outline_rounded,
            color: Colors.grey[300],
            size: 20,
          );
        }
      }),
    );
  }

  Widget _buildRatingBar(int stars, int count) {
    final maxCount = ratingDistribution.values.isEmpty
        ? 1
        : ratingDistribution.values.reduce((a, b) => a > b ? a : b);
    final percentage = maxCount > 0 ? count / maxCount : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          // Star number
          SizedBox(
            width: 16,
            child: Text(
              '$stars',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.star_rounded,
            color: Color(0xFFF59E0B),
            size: 14,
          ),
          const SizedBox(width: 8),

          // Progress bar
          Expanded(
            child: Stack(
              children: [
                // Background
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Fill
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Count
          SizedBox(
            width: 30,
            child: Text(
              '$count',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact rating display for headers
class CompactRatingDisplay extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final Color? color;

  const CompactRatingDisplay({
    super.key,
    required this.rating,
    this.reviewCount,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          color: color ?? const Color(0xFFF59E0B),
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? const Color(0xFF1E293B),
          ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: color?.withOpacity(0.7) ?? Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }
}
