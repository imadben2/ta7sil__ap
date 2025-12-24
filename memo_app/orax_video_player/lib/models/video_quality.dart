/// Video quality model for Orax Video Player
class VideoQuality {
  /// Quality label (e.g., "720p", "1080p", "4K")
  final String label;

  /// Direct stream URL for this quality
  final String url;

  /// Video width in pixels
  final int? width;

  /// Video height in pixels
  final int? height;

  /// Video bitrate in bits per second
  final int? bitrate;

  /// Video codec (e.g., "h264", "vp9")
  final String? codec;

  /// File size in bytes (if known)
  final int? fileSize;

  /// Creates a VideoQuality instance
  const VideoQuality({
    required this.label,
    required this.url,
    this.width,
    this.height,
    this.bitrate,
    this.codec,
    this.fileSize,
  });

  /// Create from YouTube stream info
  factory VideoQuality.fromYoutubeStream({
    required String label,
    required String url,
    int? width,
    int? height,
    int? bitrate,
    String? codec,
    int? fileSize,
  }) {
    return VideoQuality(
      label: label,
      url: url,
      width: width,
      height: height,
      bitrate: bitrate,
      codec: codec,
      fileSize: fileSize,
    );
  }

  /// Get quality in pixels (height)
  int get qualityPixels => height ?? 0;

  /// Check if this is HD quality (720p+)
  bool get isHD => (height ?? 0) >= 720;

  /// Check if this is Full HD quality (1080p+)
  bool get isFullHD => (height ?? 0) >= 1080;

  /// Check if this is 4K quality (2160p+)
  bool get is4K => (height ?? 0) >= 2160;

  /// Get formatted bitrate string
  String get formattedBitrate {
    if (bitrate == null) return '';
    if (bitrate! >= 1000000) {
      return '${(bitrate! / 1000000).toStringAsFixed(1)} Mbps';
    }
    return '${(bitrate! / 1000).toStringAsFixed(0)} Kbps';
  }

  /// Get formatted file size string
  String get formattedFileSize {
    if (fileSize == null) return '';
    if (fileSize! >= 1073741824) {
      return '${(fileSize! / 1073741824).toStringAsFixed(2)} GB';
    }
    if (fileSize! >= 1048576) {
      return '${(fileSize! / 1048576).toStringAsFixed(1)} MB';
    }
    return '${(fileSize! / 1024).toStringAsFixed(0)} KB';
  }

  @override
  String toString() => 'VideoQuality($label, ${width}x$height)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoQuality &&
        other.label == label &&
        other.url == url;
  }

  @override
  int get hashCode => label.hashCode ^ url.hashCode;
}
