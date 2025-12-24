import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../leaderboard/domain/entities/leaderboard_entity.dart';

/// Compact leaderboard preview widget for the home page
/// Shows top 3 users and current user's position
class LeaderboardPreviewWidget extends StatelessWidget {
  /// Top 3 entries from the leaderboard
  final List<LeaderboardEntry> topThree;

  /// Current user's rank info
  final CurrentUserRank? currentUserRank;

  /// Stream name to display (e.g., "علوم تجريبية")
  final String? streamName;

  /// Callback when "View All" is tapped
  final VoidCallback? onViewAll;

  const LeaderboardPreviewWidget({
    super.key,
    required this.topThree,
    this.currentUserRank,
    this.streamName,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (topThree.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.leaderboard_rounded,
                  size: 20,
                  color: Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ترتيب الفصل',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (streamName != null)
                      Text(
                        streamName!,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'عرض الكل',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          // Top 3 row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 2nd place
              if (topThree.length > 1)
                _buildCompactPodiumItem(topThree[1], 2)
              else
                const SizedBox(width: 80),

              // 1st place
              if (topThree.isNotEmpty)
                _buildCompactPodiumItem(topThree[0], 1),

              // 3rd place
              if (topThree.length > 2)
                _buildCompactPodiumItem(topThree[2], 3)
              else
                const SizedBox(width: 80),
            ],
          ),

          // Current user's rank (if not in top 3)
          if (_shouldShowCurrentUser())
            _buildCurrentUserRank(),
        ],
      ),
    );
  }

  bool _shouldShowCurrentUser() {
    if (currentUserRank == null || currentUserRank!.rank == null) return false;
    // Don't show if already in top 3
    return currentUserRank!.rank! > 3;
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.leaderboard_rounded,
              size: 32,
              color: Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'لا توجد بيانات للترتيب',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPodiumItem(LeaderboardEntry entry, int rank) {
    final colors = _getRankColors(rank);
    final double avatarSize = rank == 1 ? 56 : 48;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown for 1st place
        if (rank == 1)
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text('👑', style: TextStyle(fontSize: 20)),
          )
        else
          const SizedBox(height: 24),

        // Avatar with rank badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: entry.avatar != null && entry.avatar!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        entry.avatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(entry),
                      ),
                    )
                  : _buildAvatarPlaceholder(entry),
            ),
            // Rank badge
            Positioned(
              bottom: -6,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getRankEmoji(rank),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Name
        SizedBox(
          width: 70,
          child: Text(
            entry.name,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: entry.isCurrentUser ? AppColors.primary : AppColors.slate900,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Points
        Text(
          '${entry.totalPoints}',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colors[0],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder(LeaderboardEntry entry) {
    return Center(
      child: Text(
        entry.avatarInitial,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCurrentUserRank() {
    final entry = currentUserRank!.entry;
    final rank = currentUserRank!.rank!;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ترتيبك',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  entry?.name ?? 'أنت',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry?.totalPoints ?? 0}',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'نقطة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }

  List<Color> _getRankColors(int rank) {
    switch (rank) {
      case 1:
        return [const Color(0xFFFFD700), const Color(0xFFFFA500)]; // Gold
      case 2:
        return [const Color(0xFFC0C0C0), const Color(0xFF9E9E9E)]; // Silver
      case 3:
        return [const Color(0xFFCD7F32), const Color(0xFFB87333)]; // Bronze
      default:
        return [AppColors.primary, AppColors.primaryDark];
    }
  }
}
