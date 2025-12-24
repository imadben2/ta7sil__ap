import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Quick action controls for video player
///
/// Provides fullscreen, seek forward, and seek backward actions.
class VideoPlayerControls extends StatelessWidget {
  /// Accent color for the controls
  final Color accentColor;

  /// Callback for fullscreen button
  final VoidCallback? onFullscreen;

  /// Callback for seek forward (10 seconds)
  final VoidCallback? onSeekForward;

  /// Callback for seek backward (10 seconds)
  final VoidCallback? onSeekBackward;

  /// Whether controls are enabled
  final bool enabled;

  const VideoPlayerControls({
    super.key,
    required this.accentColor,
    this.onFullscreen,
    this.onSeekForward,
    this.onSeekBackward,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionButton(
              icon: Icons.fullscreen_rounded,
              label: 'ملء الشاشة',
              onTap: enabled ? onFullscreen : null,
              accentColor: accentColor,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[200],
          ),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.replay_10_rounded,
              label: 'تراجع 10 ث',
              onTap: enabled ? onSeekBackward : null,
              accentColor: accentColor,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[200],
          ),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.forward_10_rounded,
              label: 'تقدم 10 ث',
              onTap: enabled ? onSeekForward : null,
              accentColor: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color accentColor;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isEnabled ? accentColor : Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: isEnabled ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact floating controls overlay
class VideoPlayerControlsOverlay extends StatelessWidget {
  final VoidCallback? onPlayPause;
  final VoidCallback? onSeekForward;
  final VoidCallback? onSeekBackward;
  final bool isPlaying;
  final Color accentColor;

  const VideoPlayerControlsOverlay({
    super.key,
    this.onPlayPause,
    this.onSeekForward,
    this.onSeekBackward,
    this.isPlaying = false,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Seek backward
        GestureDetector(
          onTap: onSeekBackward,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.replay_10_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 32),

        // Play/Pause
        GestureDetector(
          onTap: onPlayPause,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        const SizedBox(width: 32),

        // Seek forward
        GestureDetector(
          onTap: onSeekForward,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.forward_10_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}

/// Progress bar with time display
class VideoProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final Color accentColor;
  final ValueChanged<Duration>? onSeek;

  const VideoProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.accentColor,
    this.onSeek,
  });

  double get _progress {
    if (duration.inSeconds == 0) return 0.0;
    return position.inSeconds / duration.inSeconds;
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: accentColor.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
          ),
        ),
        const SizedBox(height: 8),

        // Time display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(position),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(_progress * 100).toInt()}%',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
            Text(
              _formatDuration(duration),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
