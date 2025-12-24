Readme
Changelog
Installing
Versions
Scores
Orax Video Player 
A complete, feature-rich custom video player for Flutter with support for YouTube videos and direct video URLs.

Features 
✅ YouTube Video Support - Play YouTube videos directly in your app
✅ Quality Selection - Choose from available video qualities
✅ Playback Speed Control - Adjust speed from 0.25x to 4x
✅ Video Zoom - Zoom in/out on videos (1x to 3x)
✅ Fit Modes - Multiple video fit modes (Contain, Fill, Cover, FitWidth, FitHeight)
✅ Subtitle Support - Load and display subtitles (WebVTT and SRT formats)
✅ Clean UI - Modern, intuitive user interface
✅ Error Handling - User-friendly error messages
✅ Beginner-Friendly - Well-documented, easy to understand code

Installation 
Option 1: Use as Local Package (Recommended for Development) 
If you want to use this package in other projects, add it as a path dependency in your project's pubspec.yaml:

dependencies:
  flutter:
    sdk: flutter
  
  # Add Orax Video Player as a local path dependency
  orax_video_player:
    path: ../orax_video_player  # Adjust path to your package location
    # Or use absolute path:
    # path: C:\MYData\flutter projects\video_player\orax_video_player
Then run:

flutter pub get
Note: Adjust the path relative to your project's location. If your project is in a sibling directory, use ../orax_video_player. If in a different location, use an absolute path.

Option 2: Use from Git Repository 
If you have this package in a Git repository:

dependencies:
  orax_video_player:
    git:
      url: https://github.com/yourusername/orax_video_player.git
      ref: main  # or 'master', or a specific tag
Option 3: Install Dependencies Directly (If Not Using as Package) 
If you're using the code directly (not as a package), add these dependencies:

dependencies:
  flutter:
    sdk: flutter
  video_player: ^2.10.1
  youtube_explode_dart: ^3.0.5
  http: ^1.2.0
  xml: ^6.4.2
Then run:

flutter pub get
📖 For detailed instructions on using this package in other projects, see USAGE_GUIDE.md

Quick Start 
Basic Usage 
import 'package:orax_video_player/orax_video_player.dart';

// Create a controller
final controller = OraxVideoPlayerController();

// Initialize with a video URL (YouTube or direct URL)
await controller.initialize('https://www.youtube.com/watch?v=VIDEO_ID');

// Use the player widget
OraxVideoPlayer(
  controller: controller,
  autoPlay: false,
)
Complete Example 
import 'package:flutter/material.dart';
import 'package:orax_video_player/orax_video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late OraxVideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OraxVideoPlayerController();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    try {
      await _controller.initialize(
        'https://www.youtube.com/watch?v=VIDEO_ID',
        title: 'My Video Title',
      );
    } catch (e) {
      print('Error loading video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Player')),
      body: _controller.isInitialized
          ? OraxVideoPlayer(
              controller: _controller,
              autoPlay: false,
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
Features Guide 
Quality Selection 
// Get available qualities
List<VideoQuality> qualities = controller.availableQualities;

// Change quality
await controller.setQuality(qualities[0]); // Select first quality
Playback Speed 
// Available speeds: 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0, 3.5, 4.0
await controller.setPlaybackSpeed(2.0); // 2x speed
Video Zoom 
// Set zoom level (1.0 to 3.0)
controller.setZoomLevel(2.0); // 2x zoom

// Reset zoom
controller.resetZoom();
Fit Modes 
// Available modes: contain, fill, cover, fitWidth, fitHeight
controller.setFitMode(VideoFitMode.cover);
Subtitles 
// Get available subtitle tracks
List<SubtitleTrack> tracks = controller.availableSubtitles;

// Load a subtitle track
if (tracks.isNotEmpty) {
  await controller.loadSubtitle(tracks[0]);
}

// Disable subtitles
controller.disableSubtitles();
Playback Control 
// Play
await controller.play();

// Pause
await controller.pause();

// Toggle play/pause
await controller.togglePlayPause();

// Seek to position
await controller.seekTo(Duration(minutes: 5));
Supported Video Sources 
YouTube Videos 
Full YouTube URL support
Automatic quality detection
Subtitle extraction (when available)
Example: https://www.youtube.com/watch?v=VIDEO_ID
Direct Video URLs 
Any direct video URL (MP4, etc.)
Example: https://example.com/video.mp4
Project Structure 
lib/
├── controllers/
│   └── orax_video_player_controller.dart  # Main controller
├── models/
│   ├── playback_state.dart                # Playback state enum
│   ├── subtitle_track.dart               # Subtitle models
│   ├── video_fit_mode.dart                # Fit mode enum
│   └── video_quality.dart                 # Quality model
├── services/
│   ├── subtitle_service.dart              # Subtitle parsing
│   └── youtube_service.dart                # YouTube integration
├── widgets/
│   └── orax_video_player.dart             # Main player widget
├── main.dart                               # Example app
└── orax_video_player.dart                 # Library exports
Error Handling 
The player includes comprehensive error handling:

// Check for errors
if (controller.state == PlaybackState.error) {
  String? errorMessage = controller.errorMessage;
  // Display error to user
}
Customization 
Custom Loading Widget 
OraxVideoPlayer(
  controller: controller,
  loadingWidget: Center(
    child: CircularProgressIndicator(),
  ),
)
Custom Error Widget 
OraxVideoPlayer(
  controller: controller,
  errorWidget: Center(
    child: Text('Custom Error Message'),
  ),
)
Custom Colors 
OraxVideoPlayer(
  controller: controller,
  controlsColor: Colors.blue,
  backgroundColor: Colors.black,
)
Notes 
YouTube Videos: Requires internet connection and may be subject to YouTube's terms of service
Subtitles: Subtitle support depends on video source. YouTube videos may have auto-generated or manual subtitles
Quality: Available qualities depend on the video source. YouTube videos typically have multiple quality options
Performance: For best performance, dispose the controller when not in use
Troubleshooting 
Video Not Loading 
Check internet connection
Verify video URL is correct
Check if video is accessible (not private/restricted)
YouTube Videos Not Working 
Ensure youtube_explode_dart package is properly installed
Some videos may be region-restricted or age-restricted
YouTube's API may change, requiring package updates
Subtitles Not Showing 
Verify subtitles are available for the video
Check subtitle URL is accessible
Ensure subtitle format is supported (WebVTT or SRT)
License 
This project is open source and available for use in your projects.

Contributing 
Contributions are welcome! Feel free to submit issues or pull requests.

Support 
For issues or questions, please open an issue on the project repository.