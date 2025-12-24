import 'package:flutter/material.dart';

/// Badge widget showing the current video player type
///
/// Displays a small indicator badge in the corner of the video player
/// to show which player implementation is being used.
class PlayerTypeBadge extends StatelessWidget {
  /// The player type identifier
  final String playerType;

  /// Accent color for the badge
  final Color accentColor;

  /// Font size for the badge text
  final double fontSize;

  const PlayerTypeBadge({
    super.key,
    required this.playerType,
    required this.accentColor,
    this.fontSize = 12,
  });

  /// Get display name for player type
  String get _playerName {
    switch (playerType.toLowerCase()) {
      case 'chewie':
        return 'Chewie Player';
      case 'media_kit':
        return 'Media Kit Player';
      case 'simple_youtube':
        return 'YouTube Player';
      case 'omni':
        return 'Omni Player';
      case 'orax_video_player':
      case 'orax':
        return 'Orax Player';
      default:
        return playerType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor,
            accentColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.play_circle_filled,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            _playerName,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact version of the player type badge
class PlayerTypeBadgeCompact extends StatelessWidget {
  final String playerType;
  final Color accentColor;

  const PlayerTypeBadgeCompact({
    super.key,
    required this.playerType,
    required this.accentColor,
  });

  IconData get _playerIcon {
    switch (playerType.toLowerCase()) {
      case 'simple_youtube':
        return Icons.play_circle_outline;
      case 'media_kit':
        return Icons.high_quality;
      case 'omni':
        return Icons.smart_display;
      case 'orax':
      case 'orax_video_player':
        return Icons.video_settings;
      default:
        return Icons.play_circle_filled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        _playerIcon,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}
