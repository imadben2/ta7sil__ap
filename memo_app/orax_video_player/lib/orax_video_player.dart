/// Orax Video Player - A complete, feature-rich video player for Flutter
///
/// Features:
/// - YouTube video support with automatic stream extraction
/// - Quality selection (multiple resolutions)
/// - Playback speed control (0.25x to 4x)
/// - Video zoom (1x to 3x)
/// - Fit modes (contain, fill, cover, fitWidth, fitHeight)
/// - Subtitle support (WebVTT and SRT formats)
/// - Clean, customizable UI
/// - Comprehensive error handling
library orax_video_player;

// Controllers
export 'controllers/orax_video_player_controller.dart';

// Models
export 'models/playback_state.dart';
export 'models/video_quality.dart';
export 'models/video_fit_mode.dart';
export 'models/subtitle_track.dart';

// Services
export 'services/youtube_service.dart';
export 'services/subtitle_service.dart';

// Widgets
export 'widgets/orax_video_player.dart';
