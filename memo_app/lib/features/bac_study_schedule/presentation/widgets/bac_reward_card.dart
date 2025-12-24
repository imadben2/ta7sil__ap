import 'package:flutter/material.dart';
import '../../domain/entities/bac_weekly_reward.dart';

/// Card widget for displaying a weekly break (استراحة)
/// New horizontal design for better UX
class BacRewardCard extends StatelessWidget {
  final BacWeeklyReward reward;
  final VoidCallback? onTap;

  const BacRewardCard({
    super.key,
    required this.reward,
    this.onTap,
  });

  // Color palette
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFF06B6D4);
  static const Color successColor = Color(0xFF10B981);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: reward.isUnlocked
                  ? successColor.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: reward.isUnlocked
                ? successColor.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Left side - Image
            _buildImageSection(),

            // Right side - Content
            Expanded(
              child: _buildContentSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Image container
        ClipRRect(
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(20),
          ),
          child: SizedBox(
            width: 120,
            height: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                if (reward.movieImage != null)
                  Image.network(
                    reward.movieImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholder(),
                  )
                else
                  _buildPlaceholder(),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Lock overlay for locked items
                if (!reward.isUnlocked)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          color: textSecondary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Week badge
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryColor, secondaryColor],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'الأسبوع ${reward.weekNumber}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                reward.titleAr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              // Movie title if available
              if (reward.movieTitle != null)
                Text(
                  reward.movieTitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: textSecondary.withValues(alpha: 0.9),
                  ),
                ),
            ],
          ),

          // Bottom section - badges
          Row(
            children: [
              // Day range badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      reward.dayRangeAr,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: reward.isUnlocked
                      ? successColor.withValues(alpha: 0.1)
                      : textSecondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      reward.isUnlocked
                          ? Icons.check_circle_rounded
                          : Icons.schedule_rounded,
                      size: 12,
                      color: reward.isUnlocked ? successColor : textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      reward.isUnlocked ? 'متاحة' : 'قريباً',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: reward.isUnlocked ? successColor : textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Arrow icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: reward.isUnlocked
                      ? primaryColor.withValues(alpha: 0.1)
                      : textSecondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 14,
                  color: reward.isUnlocked ? primaryColor : textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            primaryColor.withValues(alpha: 0.4),
            secondaryColor.withValues(alpha: 0.4),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.movie_rounded,
              size: 28,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
