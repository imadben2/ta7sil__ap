import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../controllers/orax_video_player_controller.dart';
import '../models/playback_state.dart';
import '../models/video_fit_mode.dart';
import '../models/video_quality.dart';
import '../models/subtitle_track.dart';

/// Main Orax Video Player widget
class OraxVideoPlayer extends StatefulWidget {
  /// The controller for this player
  final OraxVideoPlayerController controller;

  /// Whether to auto-play when initialized
  final bool autoPlay;

  /// Whether to show player controls
  final bool showControls;

  /// Custom loading widget
  final Widget? loadingWidget;

  /// Custom error widget
  final Widget? errorWidget;

  /// Controls color theme
  final Color? controlsColor;

  /// Background color
  final Color? backgroundColor;

  /// Callback when fullscreen is requested
  final VoidCallback? onFullscreenRequest;

  /// Callback when fullscreen exit is requested
  final VoidCallback? onFullscreenExit;

  /// Creates an OraxVideoPlayer widget
  const OraxVideoPlayer({
    super.key,
    required this.controller,
    this.autoPlay = false,
    this.showControls = true,
    this.loadingWidget,
    this.errorWidget,
    this.controlsColor,
    this.backgroundColor,
    this.onFullscreenRequest,
    this.onFullscreenExit,
  });

  @override
  State<OraxVideoPlayer> createState() => _OraxVideoPlayerState();
}

class _OraxVideoPlayerState extends State<OraxVideoPlayer> {
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool _isDraggingProgress = false;

  OraxVideoPlayerController get _controller => widget.controller;
  Color get _accentColor => widget.controlsColor ?? Colors.blue;
  Color get _backgroundColor => widget.backgroundColor ?? Colors.black;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _startHideTimer();

    // Auto-play if enabled
    if (widget.autoPlay && _controller.isInitialized) {
      _controller.play();
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startHideTimer() {
    _hideControlsTimer?.cancel();
    if (_showControls && !_isDraggingProgress) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _controller.isPlaying) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  void _showControlsTemporarily() {
    setState(() => _showControls = true);
    _startHideTimer();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _startHideTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _backgroundColor,
      child: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video layer
            _buildVideoLayer(),

            // Subtitle layer
            if (_controller.currentSubtitleText != null) _buildSubtitleLayer(),

            // Loading overlay
            if (_controller.state == OraxPlaybackState.loading ||
                _controller.state == OraxPlaybackState.buffering)
              _buildLoadingOverlay(),

            // Error overlay
            if (_controller.state == OraxPlaybackState.error) _buildErrorOverlay(),

            // Controls layer
            if (widget.showControls && _showControls && _controller.isInitialized)
              _buildControlsLayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoLayer() {
    if (!_controller.isInitialized || _controller.videoController == null) {
      return Container(color: _backgroundColor);
    }

    return Center(
      child: Transform.scale(
        scale: _controller.zoomLevel,
        child: AspectRatio(
          aspectRatio: _controller.aspectRatio,
          child: FittedBox(
            fit: _controller.fitMode.toBoxFit(),
            child: SizedBox(
              width: _controller.videoController!.value.size.width,
              height: _controller.videoController!.value.size.height,
              child: VideoPlayer(_controller.videoController!),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitleLayer() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 80,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _controller.currentSubtitleText!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: widget.loadingWidget ??
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
            ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: widget.errorWidget ??
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 64),
                const SizedBox(height: 16),
                Text(
                  'خطأ في تشغيل الفيديو',
                  style: TextStyle(color: Colors.red[400], fontSize: 18),
                ),
                if (_controller.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ),
                ],
              ],
            ),
      ),
    );
  }

  Widget _buildControlsLayer() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ),
      ),
      child: Column(
        children: [
          // Top bar
          _buildTopBar(),

          // Center controls
          Expanded(child: _buildCenterControls()),

          // Bottom bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Title
          if (_controller.videoTitle != null)
            Expanded(
              child: Text(
                _controller.videoTitle!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const Spacer(),
          // Settings menu
          _buildSettingsButton(),
        ],
      ),
    );
  }

  Widget _buildSettingsButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings, color: Colors.white),
      color: Colors.grey[900],
      onSelected: (value) {
        switch (value) {
          case 'quality':
            _showQualitySelector();
            break;
          case 'speed':
            _showSpeedSelector();
            break;
          case 'subtitle':
            _showSubtitleSelector();
            break;
          case 'fit':
            _showFitModeSelector();
            break;
          case 'zoom':
            _showZoomControls();
            break;
        }
      },
      itemBuilder: (context) => [
        _buildPopupItem('quality', Icons.high_quality, 'الجودة'),
        _buildPopupItem('speed', Icons.speed, 'السرعة'),
        _buildPopupItem('subtitle', Icons.subtitles, 'الترجمة'),
        _buildPopupItem('fit', Icons.aspect_ratio, 'الملاءمة'),
        _buildPopupItem('zoom', Icons.zoom_in, 'التكبير'),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Seek backward
        _buildControlButton(
          icon: Icons.replay_10,
          onPressed: () => _controller.seekBackward(const Duration(seconds: 10)),
          size: 48,
        ),

        const SizedBox(width: 32),

        // Play/Pause
        _buildPlayPauseButton(),

        const SizedBox(width: 32),

        // Seek forward
        _buildControlButton(
          icon: Icons.forward_10,
          onPressed: () => _controller.seekForward(const Duration(seconds: 10)),
          size: 48,
        ),
      ],
    );
  }

  Widget _buildPlayPauseButton() {
    return GestureDetector(
      onTap: () {
        _controller.togglePlayPause();
        _showControlsTemporarily();
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: _accentColor.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _controller.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 32,
  }) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: size),
      onPressed: () {
        onPressed();
        _showControlsTemporarily();
      },
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          _buildProgressBar(),

          const SizedBox(height: 8),

          // Time and controls row
          Row(
            children: [
              // Current time
              Text(
                _formatDuration(_controller.position),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const Text(' / ', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(
                _formatDuration(_controller.duration),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),

              const Spacer(),

              // Speed indicator
              if (_controller.playbackSpeed != 1.0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _accentColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${_controller.playbackSpeed}x',
                    style: TextStyle(color: _accentColor, fontSize: 12),
                  ),
                ),

              const SizedBox(width: 8),

              // Quality indicator
              if (_controller.currentQuality != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _controller.currentQuality!.label,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),

              const SizedBox(width: 16),

              // Fullscreen button
              IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                onPressed: widget.onFullscreenRequest,
                iconSize: 28,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _controller.duration.inMilliseconds > 0
        ? _controller.position.inMilliseconds / _controller.duration.inMilliseconds
        : 0.0;

    return GestureDetector(
      onHorizontalDragStart: (_) {
        _isDraggingProgress = true;
        _hideControlsTimer?.cancel();
      },
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final width = box.size.width - 32; // Account for padding
        final position = (details.localPosition.dx / width).clamp(0.0, 1.0);
        final seekPosition = Duration(
          milliseconds: (position * _controller.duration.inMilliseconds).round(),
        );
        _controller.seekTo(seekPosition);
      },
      onHorizontalDragEnd: (_) {
        _isDraggingProgress = false;
        _startHideTimer();
      },
      child: Container(
        height: 24,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Background track
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Progress track
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: _accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Thumb
            Positioned(
              left: (progress.clamp(0.0, 1.0) *
                      (MediaQuery.of(context).size.width - 32)) -
                  8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQualitySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => _buildSelectorSheet(
        title: 'اختر الجودة',
        items: _controller.availableQualities.map((q) {
          return _SelectorItem(
            label: q.label,
            subtitle: q.formattedBitrate,
            isSelected: q == _controller.currentQuality,
            onTap: () {
              _controller.setQuality(q);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showSpeedSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => _buildSelectorSheet(
        title: 'سرعة التشغيل',
        items: OraxVideoPlayerController.availableSpeeds.map((speed) {
          return _SelectorItem(
            label: '${speed}x',
            subtitle: speed == 1.0 ? 'عادي' : null,
            isSelected: speed == _controller.playbackSpeed,
            onTap: () {
              _controller.setPlaybackSpeed(speed);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showSubtitleSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => _buildSelectorSheet(
        title: 'الترجمة',
        items: [
          _SelectorItem(
            label: 'إيقاف',
            isSelected: _controller.currentSubtitleTrack == null,
            onTap: () {
              _controller.disableSubtitles();
              Navigator.pop(context);
            },
          ),
          ..._controller.availableSubtitles.map((track) {
            return _SelectorItem(
              label: track.languageDisplayName,
              subtitle: track.isAutoGenerated ? 'تلقائي' : null,
              isSelected: track == _controller.currentSubtitleTrack,
              onTap: () {
                _controller.loadSubtitle(track);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }

  void _showFitModeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => _buildSelectorSheet(
        title: 'وضع العرض',
        items: VideoFitMode.values.map((mode) {
          return _SelectorItem(
            label: mode.displayNameAr,
            isSelected: mode == _controller.fitMode,
            onTap: () {
              _controller.setFitMode(mode);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showZoomControls() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'التكبير',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.white),
                    onPressed: () {
                      _controller.zoomOut();
                      setSheetState(() {});
                    },
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${(_controller.zoomLevel * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      _controller.zoomIn();
                      setSheetState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Slider(
                value: _controller.zoomLevel,
                min: 1.0,
                max: 3.0,
                activeColor: _accentColor,
                onChanged: (value) {
                  _controller.setZoomLevel(value);
                  setSheetState(() {});
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _controller.resetZoom();
                  setSheetState(() {});
                },
                child: Text(
                  'إعادة تعيين',
                  style: TextStyle(color: _accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorSheet({
    required String title,
    required List<_SelectorItem> items,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: Colors.white24),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: items.map((item) {
                return ListTile(
                  leading: item.isSelected
                      ? Icon(Icons.check, color: _accentColor)
                      : const SizedBox(width: 24),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      color: item.isSelected ? _accentColor : Colors.white,
                      fontWeight: item.isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: item.subtitle != null
                      ? Text(
                          item.subtitle!,
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        )
                      : null,
                  onTap: item.onTap,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}

class _SelectorItem {
  final String label;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  _SelectorItem({
    required this.label,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });
}
