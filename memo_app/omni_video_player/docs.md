ntroduction 
omni_video_player is a Flutter video player built on top of Flutter’s official video_player plugin (a beta version also exists).

It supports YouTube (via youtube_explode_dart with an automatic WebView-based fallback implemented using webview_flutter to handle cases where YouTube rate-limits requests, temporarily blocking direct extraction — see issue #323),

Vimeo videos (now using webview_flutter for improved stability and maintainability), as well as network and asset videos.

A single unified controller is provided to manage playback across all supported video types seamlessly.

🎨 Highly customizable — tweak UI, show/hide controls, and easily integrate your own widgets. 🎮 The controller gives full control over video state and callbacks for smooth video management on mobile and web.

🎯 Long-term goal: to create a universal, flexible, and feature-rich video player that works flawlessly across all platforms and video sources, using the most robust and actively maintained technologies to ensure consistent behavior over time.


Supported Platforms & Status 
Video Source Type	Android	iOS	Web	Status
YouTube	✅	✅	✅	✅ Supported — uses youtube_explode_dart by default on mobile, and WebView (webview_flutter) on web or as fallback on mobile to bypass temporary rate-limit blocks
Vimeo	✅	✅	❌	✅ Supported — uses webview_flutter
Network	✅	✅	✅	✅ Supported — also .m3u8
Asset	✅	✅	✅	✅ Supported
File	✅	✅	❌	✅ Supported
Twitch	-	-	-	🔜 Planned
TikTok	-	-	-	🔜 Planned
Dailymotion	-	-	-	🔜 Planned

✨ Features 
✅ Play videos from:

YouTube (live and regular videos, with automatic WebView fallback powered by webview_flutter to keep playback working even under temporary YouTube rate-limit restrictions)
Vimeo (public — now using official webview_flutter for stable playback)
Network video URLs
Flutter app assets
File from device
🎛 Customizable player UI (controls, theme, overlays, labels)

🔁 Autoplay, replay, mute/unmute, volume control

⏪ Seek bar & scrubbing

🖼 Thumbnail support (custom or auto-generated for YouTube and Vimeo)

🔊 Global playback & mute sync across players

⛶ Fullscreen player

⚙️ Custom error and loading widgets

⏱ Playback Speed

🎚️ Quality selection UI:

Supports YouTube quality switching
Supports HLS/network stream quality switching

🧪 Demo 


🚀 Getting Started 
Installation 
Check the latest version on: Pub Version

dependencies:
  omni_video_player: <latest_version>
🛠️ Android Setup 
In your Flutter project, open:

android/app/src/main/AndroidManifest.xml
<!-- Add inside <manifest> -->
<uses-permission android:name="android.permission.INTERNET"/>

<!-- Add inside <application> -->
<application
    android:usesCleartextTraffic="true"
    ... >
</application>
✅ The INTERNET permission is required for streaming videos.

⚠️ The usesCleartextTraffic="true" is only needed if you're using HTTP (not HTTPS) URLs.

🍎 iOS Setup 
To allow video streaming over HTTP (especially for development or non-HTTPS sources), add the following to your Info.plist file:

<!-- ios/Runner/Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>

📦 Usage Examples 
Network 
VideoSourceConfiguration.network(
  videoUrl: Uri.parse('https://example.com/video.mp4'),
);
YouTube 
VideoSourceConfiguration.youtube(
  videoUrl: Uri.parse('https://youtu.be/xyz'),
  preferredQualities: [OmniVideoQuality.high720, OmniVideoQuality.low144],
);
Vimeo 
VideoSourceConfiguration.vimeo(
  videoId: '123456789',
  preferredQualities: [OmniVideoQuality.high720],
);
Asset 
VideoSourceConfiguration.asset(
  videoDataSource: 'assets/video.mp4',
);
File 
VideoSourceConfiguration.file(
  videoFile: ...,
);

📱 Example App 
Explore the example/ folder for working demos:

Full demo using different video sources: main.dart
Full YouTube setup with controller and all available configuration options: example.dart
💡 Great starting points to understand how to integrate and customize the player.


🎯 Sync UI with Controller Listener 
Observe OmniPlaybackController property changes directly and update the UI safely.

OmniPlaybackController? _controller;

void _update() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) setState(() {});
  });
}

OmniVideoPlayer(
  callbacks: VideoPlayerCallbacks(
    onControllerCreated: (controller) {
      _controller?.removeListener(_update);
      _controller = controller..addListener(_update);
    },
  ),
);

if (_controller == null)
  const CircularProgressIndicator();
else
  ElevatedButton.icon(
    onPressed: () => _controller!.isPlaying
        ? _controller!.pause()
        : _controller!.play(),
    icon: Icon(_controller!.isPlaying ? Icons.pause : Icons.play_arrow),
    label: Text(_controller!.isPlaying ? 'Pause' : 'Play'),
  );

🔮 Future Developments 
Feature	Description	Implemented
📃 Playlist Support	YouTube playlist playback and custom video URL lists	❌
⏩ Double Tap Seek	Skip forward/backward by configurable duration	✅
📚 Side Command Bars	Left and right customizable sidebars for placing user-defined widgets or controls	❌
🧭 Header Bar	Custom header with title, channel info, and actions	❌
🖼 Picture-in-Picture (PiP)	Play video in floating overlay while multitasking	❌
📶 Quality Selection	Switch between 360p, 720p, 1080p, etc. during playback	✅ (YouTube, Network HLS)
⏱ Playback Speed Control	Adjust speed: 0.5x, 1.5x, 2x, etc.	✅
🔁 Looping / Repeat	Loop a single video or an entire playlist	❌
♿ Accessibility	Screen reader support, keyboard nav, captions, ARIA, high contrast, etc.	✅
⬇️ Download / Offline Mode	Save videos temporarily for offline playback	❌
📺 Chromecast & AirPlay	Stream to external devices like TVs or smart displays	❌
🔒 Parental Controls	Restrict age-inappropriate or sensitive content	❌
⚙️ Settings Button	Easily access and configure playback preferences	❌
👉 Swipe to Exit Fullscreen	Swipe down (or specific gesture) to exit fullscreen mode	✅

🧪 Beta Version 
Starting from version 3.3.3-beta, omni_video_player introduces a new video handling implementation to address a known issue with the video_player plugin on iOS:

Currently, the video_player package on iOS preloads the entire video before starting playback, causing delays. (see flutter/flutter#126760).

The beta version uses media_kit which enables:

🎬 Much faster video loading on both iOS and Android
🌐 Better support for multiple resolutions
Important note: on the iOS Simulator, audio does not work yet, but it works perfectly on real devices and android simulator.

⚡ Initialization 
Before using any video player in your app, you must call:

OmniVideoPlayer.ensureInitialized();
This ensures the underlying media engine is properly initialized.

📦 Installing the Beta 
To use the beta version, specify the full version in your pubspec.yaml:

dependencies:
  omni_video_player: 3.4.0-beta

📄 License 
BSD 3-Clause License – see LICENSE