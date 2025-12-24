// Video Player Feature Module
//
// A reusable video player module that supports multiple video player
// implementations (Chewie, MediaKit, YouTube, Omni, Orax).
//
// ## Usage
//
// ```dart
// import 'package:memo_app/features/videoplayer/videoplayer.dart';
//
// VideoPlayerWidget(
//   config: VideoConfig.contentLibrary(
//     videoUrl: 'https://www.youtube.com/watch?v=...',
//     accentColorValue: Colors.blue.value,
//   ),
//   onProgress: (progress) => print('Progress: $progress'),
//   onCompleted: () => print('Video completed'),
// )
// ```

// Domain
export 'domain/entities/video_config.dart';

// Presentation - BLoC
export 'presentation/bloc/video_player_bloc.dart';
export 'presentation/bloc/video_player_event.dart';
export 'presentation/bloc/video_player_state.dart';

// Presentation - Widgets
export 'presentation/widgets/video_player_widget.dart';
export 'presentation/widgets/video_player_controls.dart';
export 'presentation/widgets/player_type_badge.dart';
export 'presentation/widgets/video_loading_state.dart';
export 'presentation/widgets/video_error_state.dart';

// Presentation - Pages
export 'presentation/pages/fullscreen_video_page.dart';

// DI
export 'di/videoplayer_injection.dart';
