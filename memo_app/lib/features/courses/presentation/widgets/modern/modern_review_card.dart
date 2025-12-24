import 'package:flutter/material.dart';
import '../../../domain/entities/course_review_entity.dart';

/// Modern Review Card Widget
/// Displays a single course review
class ModernReviewCard extends StatelessWidget {
  final CourseReviewEntity review;
  final VoidCallback? onHelpful;
  final VoidCallback? onReport;

  const ModernReviewCard({
    super.key,
    required this.review,
    this.onHelpful,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Row
          Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3B82F6),
                      const Color(0xFF8B5CF6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: review.userAvatar != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          review.userAvatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildAvatarPlaceholder(),
                        ),
                      )
                    : _buildAvatarPlaceholder(),
              ),
              const SizedBox(width: 12),

              // Name and Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.displayName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      review.createdAtText,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // Rating Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getRatingColor(review.rating).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: _getRatingColor(review.rating),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${review.rating}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getRatingColor(review.rating),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Rating Description
          if (review.rating > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                review.ratingDescription,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],

          // Review Text
          if (review.hasReviewText) ...[
            const SizedBox(height: 12),
            Text(
              review.reviewTextAr!,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Color(0xFF475569),
                height: 1.6,
              ),
            ),
          ],

          // Actions Row
          if (onHelpful != null || onReport != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onHelpful != null)
                  _buildActionButton(
                    icon: Icons.thumb_up_outlined,
                    label: 'مفيد',
                    onTap: onHelpful!,
                    color: Colors.grey[600]!,
                  ),
                const Spacer(),
                if (onReport != null)
                  _buildActionButton(
                    icon: Icons.flag_outlined,
                    label: 'إبلاغ',
                    onTap: onReport!,
                    color: Colors.grey[500]!,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Center(
      child: Text(
        review.displayName.isNotEmpty
            ? review.displayName[0].toUpperCase()
            : '?',
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) return const Color(0xFF10B981);
    if (rating >= 3) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

/// Empty reviews state
class EmptyReviewsState extends StatelessWidget {
  final VoidCallback? onAddReview;

  const EmptyReviewsState({super.key, this.onAddReview});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.star_outline_rounded,
                size: 40,
                color: Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد تقييمات بعد',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'كن أول من يقيم هذه الدورة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (onAddReview != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onAddReview,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text(
                  'أضف تقييمك',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
