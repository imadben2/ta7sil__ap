import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/leaderboard_entity.dart';

/// List item for rankings beyond top 3
class LeaderboardListItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final Color? accentColor;

  const LeaderboardListItem({
    super.key,
    required this.entry,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: entry.isCurrentUser ? AppColors.purpleBgLight : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: entry.isCurrentUser
              ? color.withOpacity(0.3)
              : Colors.grey.withOpacity(0.12),
          width: entry.isCurrentUser ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: entry.isCurrentUser
                ? color.withOpacity(0.1)
                : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Rank number
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: entry.isCurrentUser
                    ? color
                    : AppColors.slate600.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${entry.rank}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: entry.isCurrentUser ? Colors.white : AppColors.slate600,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: entry.avatar != null && entry.avatar!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        entry.avatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      ),
                    )
                  : _buildPlaceholder(),
            ),

            const SizedBox(width: 12),

            // Name and stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.name,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: entry.isCurrentUser
                                ? color
                                : AppColors.slate900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (entry.isCurrentUser) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'أنت',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildStatChip(
                        icon: Icons.quiz_rounded,
                        label: '${entry.totalAttempts}',
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        icon: Icons.star_rounded,
                        label: '${entry.totalPoints}',
                        color: AppColors.amber500,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Score badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: entry.isCurrentUser
                      ? [color, color.withOpacity(0.8)]
                      : [AppColors.emerald500, AppColors.emerald500.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                entry.formattedScore,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Text(
        entry.avatarInitial,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    Color color = AppColors.slate500,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
