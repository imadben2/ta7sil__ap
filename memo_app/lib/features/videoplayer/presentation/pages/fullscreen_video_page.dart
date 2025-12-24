import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/video_player_bloc.dart';
import '../bloc/video_player_event.dart';
import '../bloc/video_player_state.dart';

/// Fullscreen video player page
///
/// Provides an immersive fullscreen video experience with custom controls.
/// Supports landscape orientation and auto-hiding controls.
class FullscreenVideoPage extends StatefulWidget {
  /// Video player BLoC (reuses existing instance)
  final VideoPlayerBloc bloc;

  /// Video title
  final String title;

  /// Subtitle (e.g., subject name)
  final String? subtitle;

  /// Accent color for controls
  final Color accentColor;

  /// Callback when video completes
  final VoidCallback? onCompleted;

  const FullscreenVideoPage({
    super.key,
    required this.bloc,
    required this.title,
    this.subtitle,
    required this.accentColor,
    this.onCompleted,
  });

  /// Navigate to fullscreen video page
  static Future<void> show(
    BuildContext context, {
    required VideoPlayerBloc bloc,
    required String title,
    String? subtitle,
    required Color accentColor,
    VoidCallback? onCompleted,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPage(
          bloc: bloc,
          title: title,
          subtitle: subtitle,
          accentColor: accentColor,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<FullscreenVideoPage> {
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _enterFullscreen();
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _exitFullscreen();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        final state = widget.bloc.state;
        if (state is VideoPlayerReady && state.isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      }
    });
  }

  void _onInteraction() {
    if (!_showControls) {
      setState(() {
        _showControls = true;
      });
    }
    _startHideControlsTimer();
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocConsumer<VideoPlayerBloc, VideoPlayerState>(
          bloc: widget.bloc,
          listener: (context, state) {
            if (state is VideoPlayerCompleted) {
              widget.onCompleted?.call();
            }
          },
          builder: (context, state) {
            return GestureDetector(
              onTap: _toggleControls,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Video player
                  if (state is VideoPlayerReady)
                    Center(
                      child: state.player.buildPlayer(context, showControls: false),
                    ),

                  // Controls overlay
                  AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: IgnorePointer(
                      ignoring: !_showControls,
                      child: _buildControlsOverlay(state),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlsOverlay(VideoPlayerState state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.8),
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(),

            // Center controls
            Expanded(
              child: _buildCenterControls(state),
            ),

            // Bottom bar with progress
            if (state is VideoPlayerReady) _buildBottomBar(state),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.subtitle != null)
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls(VideoPlayerState state) {
    if (state is! VideoPlayerReady) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Rewind 10s
        GestureDetector(
          onTap: () {
            _onInteraction();
            widget.bloc.add(const SeekBackward());
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.replay_10_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(width: 40),

        // Play/Pause
        GestureDetector(
          onTap: () {
            _onInteraction();
            widget.bloc.add(const TogglePlayPause());
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.accentColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.accentColor.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
        const SizedBox(width: 40),

        // Forward 10s
        GestureDetector(
          onTap: () {
            _onInteraction();
            widget.bloc.add(const SeekForward());
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.forward_10_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(VideoPlayerReady state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Progress slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: widget.accentColor,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
              thumbColor: widget.accentColor,
              overlayColor: widget.accentColor.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: state.progress.clamp(0.0, 1.0),
              onChanged: (value) {
                _onInteraction();
                final newPosition = Duration(
                  seconds: (value * state.duration.inSeconds).round(),
                );
                widget.bloc.add(SeekTo(newPosition));
              },
            ),
          ),
          const SizedBox(height: 8),

          // Time display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(state.position),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),

              // Progress percentage
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${state.progressPercent}%',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.accentColor,
                  ),
                ),
              ),

              Text(
                _formatDuration(state.duration),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
