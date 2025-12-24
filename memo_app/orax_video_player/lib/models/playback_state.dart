/// Playback state for Orax Video Player
enum OraxPlaybackState {
  /// Player is idle, not initialized
  idle,

  /// Video is loading/initializing
  loading,

  /// Video is ready to play
  ready,

  /// Video is currently playing
  playing,

  /// Video is paused
  paused,

  /// Video is buffering
  buffering,

  /// Video playback completed
  completed,

  /// An error occurred
  error,
}
