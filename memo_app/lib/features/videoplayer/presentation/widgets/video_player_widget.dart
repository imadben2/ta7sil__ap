import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/video_config.dart';
import '../bloc/video_player_bloc.dart';
import '../bloc/video_player_event.dart';
import '../bloc/video_player_state.dart';
import 'player_type_badge.dart';
import 'video_loading_state.dart';
import 'video_error_state.dart';
import 'video_player_controls.dart';

/// Main video player widget
///
/// A reusable video player component that handles all video playback logic.
/// Uses BLoC for state management and supports multiple player implementations.
///
/// Example usage:
/// ```dart
/// VideoPlayerWidget(
///   config: VideoConfig.contentLibrary(
///     videoUrl: 'https://www.youtube.com/watch?v=...',
///     accentColorValue: Colors.blue.value,
///   ),
///   onProgress: (progress) => print('Progress: $progress'),
///   onCompleted: () => print('Video completed'),
/// )
/// ```
class VideoPlayerWidget extends StatefulWidget {
  /// Video configuration
  final VideoConfig config;

  /// Callback when progress changes (0.0 to 1.0)
  final ValueChanged<double>? onProgress;

  /// Callback when video completes
  final VoidCallback? onCompleted;

  /// Callback when error occurs
  final ValueChanged<String>? onError;

  /// Whether to show quick action controls below the player
  final bool showQuickControls;

  /// Whether to show the progress bar
  final bool showProgressBar;

  /// Custom accent color (overrides config)
  final Color? accentColor;

  /// Whether to show player fallback notification
  final bool showFallbackNotification;

  const VideoPlayerWidget({
    super.key,
    required this.config,
    this.onProgress,
    this.onCompleted,
    this.onError,
    this.showQuickControls = true,
    this.showProgressBar = true,
    this.accentColor,
    this.showFallbackNotification = true,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerBloc _bloc;
  bool _hasShownFallbackNotification = false;

  Color get _accentColor =>
      widget.accentColor ??
      (widget.config.accentColorValue != null
          ? Color(widget.config.accentColorValue!)
          : AppColors.primary);

  @override
  void initState() {
    super.initState();
    _bloc = VideoPlayerBloc();
    _bloc.add(InitializeVideo(widget.config));
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.videoUrl != widget.config.videoUrl) {
      _bloc.add(ChangeVideoSource(widget.config));
    }
  }

  @override
  void dispose() {
    _bloc.add(const DisposePlayer());
    _bloc.close();
    super.dispose();
  }

  void _showFallbackNotification(BuildContext context) {
    if (_hasShownFallbackNotification || !widget.showFallbackNotification) return;
    _hasShownFallbackNotification = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'المشغل المحدد لا يدعم فيديوهات يوتيوب. تم استخدام مشغل يوتيوب بدلاً منه.',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
              ),
            ),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'حسناً',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<VideoPlayerBloc, VideoPlayerState>(
        listener: (context, state) {
          if (state is VideoPlayerReady) {
            // Report progress
            widget.onProgress?.call(state.progress);

            // Show fallback notification if needed
            if (state.didFallback) {
              _showFallbackNotification(context);
            }
          } else if (state is VideoPlayerCompleted) {
            widget.onCompleted?.call();
          } else if (state is VideoPlayerError) {
            widget.onError?.call(state.message);
          }
        },
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Video player container
              _buildVideoPlayer(state),

              // Quick controls
              if (widget.showQuickControls && state is VideoPlayerReady) ...[
                const SizedBox(height: 16),
                VideoPlayerControls(
                  accentColor: _accentColor,
                  enabled: true,
                  onFullscreen: () => _bloc.add(const ToggleFullscreen()),
                  onSeekForward: () => _bloc.add(const SeekForward()),
                  onSeekBackward: () => _bloc.add(const SeekBackward()),
                ),
              ],

              // Progress bar
              if (widget.showProgressBar && state is VideoPlayerReady) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: VideoProgressBar(
                    position: state.position,
                    duration: state.duration,
                    accentColor: _accentColor,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildVideoPlayer(VideoPlayerState state) {
    if (state is VideoPlayerLoading || state is VideoPlayerInitial) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: VideoLoadingState(accentColor: _accentColor),
        ),
      );
    }

    if (state is VideoPlayerError) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: VideoErrorState(
            message: state.message,
            accentColor: _accentColor,
            canRetry: state.canRetry,
            onRetry: () => _bloc.add(const RetryLoad()),
          ),
        ),
      );
    }

    if (state is VideoPlayerReady) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Video player
            AspectRatio(
              aspectRatio: 16 / 9,
              child: state.player.buildPlayer(context, showControls: widget.config.showControls),
            ),

            // Buffering overlay
            if (state.isBuffering)
              const Positioned.fill(
                child: VideoBufferingOverlay(),
              ),

            // Player type badge
            if (widget.config.showPlayerBadge)
              Positioned(
                top: 12,
                right: 12,
                child: PlayerTypeBadge(
                  playerType: state.effectivePlayerType,
                  accentColor: _accentColor,
                ),
              ),
          ],
        ),
      );
    }

    if (state is VideoPlayerCompleted) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.successGreen,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'اكتمل الفيديو',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    _bloc.add(const SeekTo(Duration.zero));
                    _bloc.add(const PlayVideo());
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text(
                    'إعادة المشاهدة',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Simplified video player widget without controls
///
/// Use this for embedded video players or when you want to handle
/// controls externally.
class VideoPlayerSimple extends StatelessWidget {
  final VideoConfig config;
  final Color? accentColor;

  const VideoPlayerSimple({
    super.key,
    required this.config,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return VideoPlayerWidget(
      config: config.copyWith(showPlayerBadge: false),
      accentColor: accentColor,
      showQuickControls: false,
      showProgressBar: false,
      showFallbackNotification: false,
    );
  }
}
