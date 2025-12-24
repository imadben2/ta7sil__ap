import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import '../models/playback_state.dart';
import '../models/video_quality.dart';
import '../models/video_fit_mode.dart';
import '../models/subtitle_track.dart';
import '../services/youtube_service.dart';
import '../services/subtitle_service.dart';

/// Main controller for Orax Video Player
///
/// Handles video playback, quality selection, subtitles, and all player controls.
class OraxVideoPlayerController extends ChangeNotifier {
  // ============ Internal Components ============

  /// Internal video player controller
  VideoPlayerController? _videoController;

  /// YouTube service for extracting video streams
  final YoutubeService _youtubeService = YoutubeService();

  /// Subtitle service for parsing subtitles
  final SubtitleService _subtitleService = SubtitleService();

  // ============ State Properties ============

  /// Current playback state
  OraxPlaybackState _state = OraxPlaybackState.idle;

  /// Error message if state is error
  String? _errorMessage;

  /// Current playback position
  Duration _position = Duration.zero;

  /// Total video duration
  Duration _duration = Duration.zero;

  /// Current playback speed
  double _playbackSpeed = 1.0;

  /// Current zoom level
  double _zoomLevel = 1.0;

  /// Current fit mode
  VideoFitMode _fitMode = VideoFitMode.contain;

  /// Current video quality
  VideoQuality? _currentQuality;

  /// Available video qualities
  List<VideoQuality> _availableQualities = [];

  /// Available subtitle tracks
  List<SubtitleTrack> _availableSubtitles = [];

  /// Current subtitle track
  SubtitleTrack? _currentSubtitleTrack;

  /// Parsed subtitle cues
  List<SubtitleCue> _subtitleCues = [];

  /// Current subtitle text to display
  String? _currentSubtitleText;

  /// Video title
  String? _videoTitle;

  /// Whether the player is initialized
  bool _isInitialized = false;

  /// Whether we're using a YouTube video
  bool _isYoutubeVideo = false;

  /// YouTube video ID (if applicable)
  String? _youtubeVideoId;

  /// Original video URL
  String? _originalUrl;

  /// Position update timer
  Timer? _positionTimer;

  // ============ Available Playback Speeds ============

  /// Available playback speed options
  static const List<double> availableSpeeds = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
    2.5,
    3.0,
    3.5,
    4.0,
  ];

  // ============ Getters ============

  /// Get current playback state
  OraxPlaybackState get state => _state;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Get current playback position
  Duration get position => _position;

  /// Get total video duration
  Duration get duration => _duration;

  /// Get current playback speed
  double get playbackSpeed => _playbackSpeed;

  /// Get current zoom level
  double get zoomLevel => _zoomLevel;

  /// Get current fit mode
  VideoFitMode get fitMode => _fitMode;

  /// Get current video quality
  VideoQuality? get currentQuality => _currentQuality;

  /// Get available video qualities
  List<VideoQuality> get availableQualities => List.unmodifiable(_availableQualities);

  /// Get available subtitle tracks
  List<SubtitleTrack> get availableSubtitles => List.unmodifiable(_availableSubtitles);

  /// Get current subtitle track
  SubtitleTrack? get currentSubtitleTrack => _currentSubtitleTrack;

  /// Get current subtitle text
  String? get currentSubtitleText => _currentSubtitleText;

  /// Get video title
  String? get videoTitle => _videoTitle;

  /// Check if player is initialized
  bool get isInitialized => _isInitialized;

  /// Check if video is playing
  bool get isPlaying => _videoController?.value.isPlaying ?? false;

  /// Check if video is buffering
  bool get isBuffering => _videoController?.value.isBuffering ?? false;

  /// Get video aspect ratio
  double get aspectRatio => _videoController?.value.aspectRatio ?? 16 / 9;

  /// Get internal video controller (for widget)
  VideoPlayerController? get videoController => _videoController;

  // ============ Initialization ============

  /// Initialize the player with a video URL
  ///
  /// [url] - YouTube URL or direct video URL
  /// [title] - Optional video title
  Future<void> initialize(String url, {String? title}) async {
    _state = OraxPlaybackState.loading;
    _errorMessage = null;
    _originalUrl = url;
    _videoTitle = title;
    notifyListeners();

    try {
      String videoUrl;

      // Check if it's a YouTube URL
      if (_youtubeService.isYoutubeUrl(url)) {
        _isYoutubeVideo = true;
        _youtubeVideoId = _youtubeService.extractVideoId(url);

        if (_youtubeVideoId == null) {
          throw Exception('Invalid YouTube URL');
        }

        // Get video metadata for title
        if (title == null) {
          final metadata = await _youtubeService.getVideoMetadata(_youtubeVideoId!);
          _videoTitle = metadata?.title;
        }

        // Get available qualities
        _availableQualities = await _youtubeService.getVideoQualities(_youtubeVideoId!);

        if (_availableQualities.isEmpty) {
          throw Exception('No video streams available');
        }

        // Use best quality by default
        _currentQuality = _availableQualities.first;
        videoUrl = _currentQuality!.url;

        // Get available subtitles
        _availableSubtitles = await _youtubeService.getSubtitles(_youtubeVideoId!);
      } else {
        // Direct video URL
        _isYoutubeVideo = false;
        videoUrl = url;

        // For direct URLs, create a single quality option
        _availableQualities = [
          VideoQuality(label: 'Default', url: url),
        ];
        _currentQuality = _availableQualities.first;
      }

      // Initialize video player
      await _initializeVideoController(videoUrl);

      _isInitialized = true;
      _state = OraxPlaybackState.ready;
      notifyListeners();
    } catch (e) {
      _state = OraxPlaybackState.error;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Initialize the internal video controller
  Future<void> _initializeVideoController(String url) async {
    // Dispose existing controller
    await _videoController?.dispose();
    _positionTimer?.cancel();

    // Create new controller
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));

    // Add listener for state changes
    _videoController!.addListener(_onVideoControllerChanged);

    // Initialize
    await _videoController!.initialize();

    // Get duration
    _duration = _videoController!.value.duration;

    // Start position timer
    _startPositionTimer();
  }

  /// Start position update timer
  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_videoController != null && _isInitialized) {
        final newPosition = _videoController!.value.position;
        if (newPosition != _position) {
          _position = newPosition;
          _updateSubtitleText();
          notifyListeners();
        }
      }
    });
  }

  /// Handle video controller state changes
  void _onVideoControllerChanged() {
    if (_videoController == null) return;

    final value = _videoController!.value;

    // Update state based on video controller state
    if (value.hasError) {
      _state = OraxPlaybackState.error;
      _errorMessage = value.errorDescription ?? 'Unknown error';
    } else if (value.isBuffering) {
      _state = OraxPlaybackState.buffering;
    } else if (value.isPlaying) {
      _state = OraxPlaybackState.playing;
    } else if (value.isCompleted) {
      _state = OraxPlaybackState.completed;
    } else if (value.isInitialized) {
      _state = OraxPlaybackState.paused;
    }

    notifyListeners();
  }

  // ============ Playback Control ============

  /// Start or resume playback
  Future<void> play() async {
    if (_videoController != null && _isInitialized) {
      await _videoController!.play();
      _state = OraxPlaybackState.playing;
      notifyListeners();
    }
  }

  /// Pause playback
  Future<void> pause() async {
    if (_videoController != null && _isInitialized) {
      await _videoController!.pause();
      _state = OraxPlaybackState.paused;
      notifyListeners();
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Seek to position
  Future<void> seekTo(Duration position) async {
    if (_videoController != null && _isInitialized) {
      // Clamp position to valid range
      final clampedPosition = Duration(
        milliseconds: position.inMilliseconds.clamp(0, _duration.inMilliseconds),
      );
      await _videoController!.seekTo(clampedPosition);
      _position = clampedPosition;
      _updateSubtitleText();
      notifyListeners();
    }
  }

  /// Seek forward by duration
  Future<void> seekForward(Duration duration) async {
    await seekTo(_position + duration);
  }

  /// Seek backward by duration
  Future<void> seekBackward(Duration duration) async {
    await seekTo(_position - duration);
  }

  // ============ Playback Speed ============

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    if (_videoController != null && _isInitialized) {
      // Clamp to available speeds
      final validSpeed = availableSpeeds.reduce(
        (a, b) => (a - speed).abs() < (b - speed).abs() ? a : b,
      );
      await _videoController!.setPlaybackSpeed(validSpeed);
      _playbackSpeed = validSpeed;
      notifyListeners();
    }
  }

  // ============ Quality Control ============

  /// Set video quality
  Future<void> setQuality(VideoQuality quality) async {
    if (!_availableQualities.contains(quality)) return;
    if (quality == _currentQuality) return;

    // Save current position
    final currentPosition = _position;
    final wasPlaying = isPlaying;

    _state = OraxPlaybackState.loading;
    notifyListeners();

    try {
      // Initialize with new quality URL
      await _initializeVideoController(quality.url);

      // Restore position
      await _videoController!.seekTo(currentPosition);

      // Restore playback state
      if (wasPlaying) {
        await _videoController!.play();
      }

      // Restore playback speed
      await _videoController!.setPlaybackSpeed(_playbackSpeed);

      _currentQuality = quality;
      _state = wasPlaying ? OraxPlaybackState.playing : OraxPlaybackState.paused;
      notifyListeners();
    } catch (e) {
      _state = OraxPlaybackState.error;
      _errorMessage = 'Failed to change quality: ${e.toString()}';
      notifyListeners();
    }
  }

  // ============ Zoom Control ============

  /// Set zoom level (1.0 to 3.0)
  void setZoomLevel(double zoom) {
    _zoomLevel = zoom.clamp(1.0, 3.0);
    notifyListeners();
  }

  /// Reset zoom to default
  void resetZoom() {
    _zoomLevel = 1.0;
    notifyListeners();
  }

  /// Increase zoom
  void zoomIn({double step = 0.25}) {
    setZoomLevel(_zoomLevel + step);
  }

  /// Decrease zoom
  void zoomOut({double step = 0.25}) {
    setZoomLevel(_zoomLevel - step);
  }

  // ============ Fit Mode ============

  /// Set video fit mode
  void setFitMode(VideoFitMode mode) {
    _fitMode = mode;
    notifyListeners();
  }

  /// Cycle through fit modes
  void cycleFitMode() {
    final modes = VideoFitMode.values;
    final currentIndex = modes.indexOf(_fitMode);
    final nextIndex = (currentIndex + 1) % modes.length;
    setFitMode(modes[nextIndex]);
  }

  // ============ Subtitle Control ============

  /// Load a subtitle track
  Future<void> loadSubtitle(SubtitleTrack track) async {
    try {
      // Load subtitle cues
      _subtitleCues = await _subtitleService.loadSubtitles(track.url);
      _currentSubtitleTrack = track;
      _updateSubtitleText();
      notifyListeners();
    } catch (e) {
      _subtitleCues = [];
      _currentSubtitleTrack = null;
      _currentSubtitleText = null;
      notifyListeners();
    }
  }

  /// Disable subtitles
  void disableSubtitles() {
    _subtitleCues = [];
    _currentSubtitleTrack = null;
    _currentSubtitleText = null;
    notifyListeners();
  }

  /// Update current subtitle text based on position
  void _updateSubtitleText() {
    if (_subtitleCues.isEmpty) {
      _currentSubtitleText = null;
      return;
    }

    final cue = _subtitleService.getCueAtPosition(_subtitleCues, _position);
    _currentSubtitleText = cue?.text;
  }

  // ============ Volume Control ============

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (_videoController != null && _isInitialized) {
      await _videoController!.setVolume(volume.clamp(0.0, 1.0));
      notifyListeners();
    }
  }

  /// Mute/unmute
  Future<void> toggleMute() async {
    if (_videoController != null) {
      final currentVolume = _videoController!.value.volume;
      await setVolume(currentVolume > 0 ? 0.0 : 1.0);
    }
  }

  // ============ Lifecycle ============

  @override
  void dispose() {
    _positionTimer?.cancel();
    _videoController?.removeListener(_onVideoControllerChanged);
    _videoController?.dispose();
    _youtubeService.dispose();
    super.dispose();
  }
}

/// Extension to check if video is completed
extension VideoPlayerValueExtension on VideoPlayerValue {
  bool get isCompleted {
    return position >= duration && duration > Duration.zero;
  }
}
