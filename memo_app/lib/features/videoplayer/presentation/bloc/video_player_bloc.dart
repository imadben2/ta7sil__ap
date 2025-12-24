import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/video_player/domain/video_player_interface.dart';
import '../../../../core/video_player/domain/video_player_factory.dart';
import '../../domain/entities/video_config.dart';
import 'video_player_event.dart';
import 'video_player_state.dart';

/// BLoC for managing video player state
///
/// Handles video initialization, playback control, progress tracking,
/// and error handling for any video player implementation.
class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  IVideoPlayer? _player;
  StreamSubscription<PlayerPlaybackState>? _stateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<bool>? _bufferingSubscription;
  StreamSubscription<String>? _errorSubscription;

  VideoConfig? _currentConfig;
  bool _hasReportedError = false;
  int _retryCount = 0;
  static const int _maxRetries = 2;

  VideoPlayerBloc() : super(const VideoPlayerInitial()) {
    on<InitializeVideo>(_onInitializeVideo);
    on<PlayVideo>(_onPlayVideo);
    on<PauseVideo>(_onPauseVideo);
    on<TogglePlayPause>(_onTogglePlayPause);
    on<SeekTo>(_onSeekTo);
    on<SeekForward>(_onSeekForward);
    on<SeekBackward>(_onSeekBackward);
    on<SetPlaybackSpeed>(_onSetPlaybackSpeed);
    on<SetVideoQuality>(_onSetVideoQuality);
    on<ToggleFullscreen>(_onToggleFullscreen);
    on<UpdatePosition>(_onUpdatePosition);
    on<UpdateBuffering>(_onUpdateBuffering);
    on<ReportError>(_onReportError);
    on<RetryLoad>(_onRetryLoad);
    on<VideoCompleted>(_onVideoCompleted);
    on<DisposePlayer>(_onDisposePlayer);
    on<ChangeVideoSource>(_onChangeVideoSource);
  }

  /// Get the current player instance
  IVideoPlayer? get player => _player;

  Future<void> _onInitializeVideo(
    InitializeVideo event,
    Emitter<VideoPlayerState> emit,
  ) async {
    _currentConfig = event.config;
    _hasReportedError = false;
    emit(VideoPlayerLoading(event.config));

    try {
      // Clean up existing player
      await _disposeCurrentPlayer();

      // Determine which player to use based on retry count
      String effectivePlayerType = event.config.effectivePlayerType;

      // On retry, try fallback players for YouTube
      if (_retryCount > 0 && event.config.isYouTubeUrl) {
        final fallbackPlayers = ['simple_youtube', 'orax', 'chewie'];
        final currentIndex = fallbackPlayers.indexOf(effectivePlayerType);
        if (currentIndex < fallbackPlayers.length - 1) {
          effectivePlayerType = fallbackPlayers[
            (_retryCount < fallbackPlayers.length) ? _retryCount : fallbackPlayers.length - 1
          ];
          debugPrint('🔄 Retry #$_retryCount: Using fallback player: $effectivePlayerType');
        }
      }

      final didFallback = effectivePlayerType != event.config.preferredPlayer;

      debugPrint('🎬 Initializing video player: $effectivePlayerType');
      debugPrint('🎬 Video URL: ${event.config.videoUrl}');
      debugPrint('🎬 Did fallback: $didFallback');

      // Create player using factory
      _player = VideoPlayerFactory.create(effectivePlayerType);

      // Try to initialize
      try {
        await _player!.initialize(
          event.config.videoUrl,
          startPosition: event.config.startPosition,
        );
      } catch (initError) {
        debugPrint('⚠️ Player $effectivePlayerType failed to initialize: $initError');

        // If not already using simple_youtube and it's a YouTube URL, try fallback
        if (effectivePlayerType != 'simple_youtube' && event.config.isYouTubeUrl) {
          debugPrint('🔄 Falling back to simple_youtube player');
          await _player?.dispose();
          _player = VideoPlayerFactory.create('simple_youtube');
          await _player!.initialize(
            event.config.videoUrl,
            startPosition: event.config.startPosition,
          );
        } else {
          rethrow;
        }
      }

      // Subscribe to player streams
      _subscribeToPlayerStreams(event.config, emit);

      // Reset retry count on success
      _retryCount = 0;

      // Emit ready state
      emit(VideoPlayerReady(
        player: _player!,
        config: event.config,
        effectivePlayerType: _player!.playerType,
        didFallback: didFallback,
        duration: _player!.duration,
        availableQualities: _player!.availableQualities,
        currentQuality: _player!.currentQuality,
      ));

      // Auto-play if configured
      if (event.config.autoPlay) {
        await _player!.play();
      }

      debugPrint('✅ Video player initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing video player: $e');

      // Auto-retry with fallback player if retries remaining
      if (_retryCount < _maxRetries && event.config.isYouTubeUrl) {
        _retryCount++;
        debugPrint('🔄 Auto-retrying with fallback player (attempt $_retryCount/$_maxRetries)');
        add(InitializeVideo(event.config));
        return;
      }

      emit(VideoPlayerError(
        message: 'حدث خطأ أثناء تحميل الفيديو. جرب مشغل آخر.',
        config: event.config,
        canRetry: true,
        errorDetails: e.toString(),
      ));
    }
  }

  void _subscribeToPlayerStreams(VideoConfig config, Emitter<VideoPlayerState> emit) {
    // State changes
    _stateSubscription = _player!.stateStream.listen((playbackState) {
      if (playbackState == PlayerPlaybackState.completed) {
        add(const VideoCompleted());
      } else if (playbackState == PlayerPlaybackState.error) {
        // Only report error once to avoid spamming
        if (!_hasReportedError) {
          _hasReportedError = true;
          add(const ReportError('حدث خطأ أثناء تشغيل الفيديو'));
        }
      }
    });

    // Position updates
    _positionSubscription = _player!.positionStream.listen((position) {
      add(UpdatePosition(position: position, duration: _player!.duration));
    }, onError: (error) {
      debugPrint('⚠️ Position stream error: $error');
    });

    // Buffering state
    _bufferingSubscription = _player!.bufferingStream.listen((isBuffering) {
      add(UpdateBuffering(isBuffering));
    }, onError: (error) {
      debugPrint('⚠️ Buffering stream error: $error');
    });

    // Error stream - handles internal player errors (like noembed.com failure)
    _errorSubscription = _player!.errorStream.listen((error) {
      debugPrint('🔴 Player error stream: $error');
      if (!_hasReportedError) {
        _hasReportedError = true;
        // Check if we should auto-retry with fallback
        if (_retryCount < _maxRetries && _currentConfig != null && _currentConfig!.isYouTubeUrl) {
          _retryCount++;
          debugPrint('🔄 Auto-retrying due to player error (attempt $_retryCount/$_maxRetries)');
          add(InitializeVideo(_currentConfig!));
        } else {
          add(ReportError(error));
        }
      }
    }, onError: (error) {
      debugPrint('⚠️ Error stream error: $error');
    });
  }

  Future<void> _onPlayVideo(
    PlayVideo event,
    Emitter<VideoPlayerState> emit,
  ) async {
    if (_player != null && state is VideoPlayerReady) {
      await _player!.play();
      emit((state as VideoPlayerReady).copyWith(isPlaying: true));
    }
  }

  Future<void> _onPauseVideo(
    PauseVideo event,
    Emitter<VideoPlayerState> emit,
  ) async {
    if (_player != null && state is VideoPlayerReady) {
      await _player!.pause();
      emit((state as VideoPlayerReady).copyWith(isPlaying: false));
    }
  }

  Future<void> _onTogglePlayPause(
    TogglePlayPause event,
    Emitter<VideoPlayerState> emit,
  ) async {
    if (_player != null && state is VideoPlayerReady) {
      final currentState = state as VideoPlayerReady;
      if (currentState.isPlaying) {
        await _player!.pause();
        emit(currentState.copyWith(isPlaying: false));
      } else {
        await _player!.play();
        emit(currentState.copyWith(isPlaying: true));
      }
    }
  }

  Future<void> _onSeekTo(
    SeekTo event,
    Emitter<VideoPlayerState> emit,
  ) async {
    if (_player != null && state is VideoPlayerReady) {
      await _player!.seekTo(event.position);
      emit((state as VideoPlayerReady).copyWith(position: event.position));
    }
  }

  Future<void> _onSeekForward(
    SeekForward event,
    Emitter<VideoPlayerState> emit,
  ) async {
    if (_player != null && state is VideoPlayerReady) {
      final currentState = state as VideoPlayerReady;
      final newPosition = currentState.position + event.duration;
      final clampedPosition = newPosition > currentState.duration
          ? currentState.duration
          : newPosition;
      await _player!.seekTo(clampedPosition);
      emit(currentState.copyWith(position: clampedPosition));
    }
  }

  Future<void> _onSeekBackward(
    SeekBackward event,
    Emitter<VideoPlayerState> emit,
  ) async {
    if (_player != null && state is VideoPlayerReady) {
      final currentState = state as VideoPlayerReady;
      final newPosition = currentState.position - event.duration;
      final clampedPosition = newPosition < Duration.zero
          ? Duration.zero
          : newPosition;
      await _player!.seekTo(clampedPosition);
      emit(currentState.copyWith(position: clampedPosition));
    }
  }

  Future<void> _onSetPlaybackSpeed(
    SetPlaybackSpeed event,
    Emitter<VideoPlayerState> emit,
  ) async {
    if (_player != null && state is VideoPlayerReady) {
      await _player!.setPlaybackSpeed(event.speed);
      emit((state as VideoPlayerReady).copyWith(playbackSpeed: event.speed));
    }
  }

  Future<void> _onSetVideoQuality(
    SetVideoQuality event,
    Emitter<VideoPlayerState> emit,
  ) async {
    if (_player != null && state is VideoPlayerReady) {
      await _player!.setQuality(event.quality);
      emit((state as VideoPlayerReady).copyWith(currentQuality: event.quality));
    }
  }

  Future<void> _onToggleFullscreen(
    ToggleFullscreen event,
    Emitter<VideoPlayerState> emit,
  ) async {
    if (_player != null && state is VideoPlayerReady) {
      final currentState = state as VideoPlayerReady;
      await _player!.setFullscreen(!currentState.isFullscreen);
      emit(currentState.copyWith(isFullscreen: !currentState.isFullscreen));
    }
  }

  void _onUpdatePosition(
    UpdatePosition event,
    Emitter<VideoPlayerState> emit,
  ) {
    if (state is VideoPlayerReady) {
      emit((state as VideoPlayerReady).copyWith(
        position: event.position,
        duration: event.duration,
        isPlaying: _player?.isPlaying ?? false,
      ));
    }
  }

  void _onUpdateBuffering(
    UpdateBuffering event,
    Emitter<VideoPlayerState> emit,
  ) {
    if (state is VideoPlayerReady) {
      emit((state as VideoPlayerReady).copyWith(isBuffering: event.isBuffering));
    }
  }

  void _onReportError(
    ReportError event,
    Emitter<VideoPlayerState> emit,
  ) {
    emit(VideoPlayerError(
      message: event.message,
      config: _currentConfig,
      canRetry: true,
    ));
  }

  Future<void> _onRetryLoad(
    RetryLoad event,
    Emitter<VideoPlayerState> emit,
  ) async {
    if (_currentConfig != null) {
      // Increment retry count to try next fallback player
      _retryCount++;
      _hasReportedError = false;
      debugPrint('🔄 Manual retry requested (attempt $_retryCount)');
      add(InitializeVideo(_currentConfig!));
    }
  }

  void _onVideoCompleted(
    VideoCompleted event,
    Emitter<VideoPlayerState> emit,
  ) {
    if (_currentConfig != null) {
      emit(VideoPlayerCompleted(_currentConfig!));
    }
  }

  Future<void> _onDisposePlayer(
    DisposePlayer event,
    Emitter<VideoPlayerState> emit,
  ) async {
    await _disposeCurrentPlayer();
    emit(const VideoPlayerInitial());
  }

  Future<void> _onChangeVideoSource(
    ChangeVideoSource event,
    Emitter<VideoPlayerState> emit,
  ) async {
    add(InitializeVideo(event.newConfig));
  }

  Future<void> _disposeCurrentPlayer() async {
    _stateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _bufferingSubscription?.cancel();
    _errorSubscription?.cancel();

    await _player?.dispose();
    _player = null;
  }

  @override
  Future<void> close() {
    _disposeCurrentPlayer();
    return super.close();
  }
}
