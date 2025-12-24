import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/leaderboard_entity.dart';

/// Podium widget showing top 3 users (like Queezy template)
class LeaderboardPodium extends StatelessWidget {
  final List<LeaderboardEntry> podium;
  final Color? accentColor;

  const LeaderboardPodium({
    super.key,
    required this.podium,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (podium.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            (accentColor ?? AppColors.primary).withOpacity(0.08),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place (left)
          if (podium.length > 1)
            Expanded(child: _buildPodiumItem(podium[1], 2))
          else
            const Expanded(child: SizedBox()),

          const SizedBox(width: 8),

          // 1st place (center, taller)
          if (podium.isNotEmpty)
            Expanded(child: _buildPodiumItem(podium[0], 1)),

          const SizedBox(width: 8),

          // 3rd place (right)
          if (podium.length > 2)
            Expanded(child: _buildPodiumItem(podium[2], 3))
          else
            const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(LeaderboardEntry entry, int rank) {
    final colors = _getRankColors(rank);
    final double standHeight = rank == 1 ? 100 : (rank == 2 ? 80 : 60);
    final double avatarSize = rank == 1 ? 72 : 60;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown for 1st place
        if (rank == 1)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFFFD700),
              size: 32,
            ),
          ),

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
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: entry.avatar != null && entry.avatar!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        entry.avatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(entry, colors[0]),
                      ),
                    )
                  : _buildAvatarPlaceholder(entry, colors[0]),
            ),
            // Rank badge
            Positioned(
              bottom: -4,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colors[0].withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Name
        SizedBox(
          width: 90,
          child: Text(
            entry.name,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: rank == 1 ? 14 : 12,
              fontWeight: FontWeight.w700,
              color: entry.isCurrentUser ? AppColors.primary : AppColors.slate900,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(height: 2),

        // Score
        Text(
          entry.formattedScore,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: rank == 1 ? 18 : 16,
            fontWeight: FontWeight.w800,
            color: colors[0],
          ),
        ),

        const SizedBox(height: 12),

        // Podium stand
        Container(
          width: 80,
          height: standHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors[0].withOpacity(0.85), colors[1].withOpacity(0.65)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: colors[0].withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: rank == 1 ? 36 : 28,
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder(LeaderboardEntry entry, Color color) {
    return Center(
      child: Text(
        entry.avatarInitial,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
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
