import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide VideoQuality;
import '../models/video_quality.dart';
import '../models/subtitle_track.dart';

/// Service for extracting YouTube video information
class YoutubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  /// Regular expressions for YouTube URL patterns
  static final RegExp _youtubeRegex = RegExp(
    r'^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?$',
    caseSensitive: false,
  );

  static final RegExp _shortUrlRegex = RegExp(
    r'^((?:https?:)?\/\/)?youtu\.be\/([\w\-]+)',
    caseSensitive: false,
  );

  /// Check if URL is a YouTube video URL
  bool isYoutubeUrl(String url) {
    return _youtubeRegex.hasMatch(url) || _shortUrlRegex.hasMatch(url);
  }

  /// Extract video ID from YouTube URL
  String? extractVideoId(String url) {
    // Handle youtu.be short URLs
    final shortMatch = _shortUrlRegex.firstMatch(url);
    if (shortMatch != null && shortMatch.groupCount >= 2) {
      return shortMatch.group(2);
    }

    // Handle full YouTube URLs
    final match = _youtubeRegex.firstMatch(url);
    if (match != null && match.groupCount >= 5) {
      return match.group(5);
    }

    // Try to extract from query parameter
    final uri = Uri.tryParse(url);
    if (uri != null) {
      final vParam = uri.queryParameters['v'];
      if (vParam != null && vParam.isNotEmpty) {
        return vParam;
      }
    }

    return null;
  }

  /// Get video metadata (title, author, duration, etc.)
  Future<VideoMetadata?> getVideoMetadata(String videoId) async {
    try {
      final video = await _yt.videos.get(videoId);
      return VideoMetadata(
        id: video.id.value,
        title: video.title,
        author: video.author,
        duration: video.duration ?? Duration.zero,
        thumbnailUrl: video.thumbnails.highResUrl,
        description: video.description,
        viewCount: video.engagement.viewCount,
        uploadDate: video.uploadDate,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get available video qualities/streams
  Future<List<VideoQuality>> getVideoQualities(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final qualities = <VideoQuality>[];

      // Get muxed streams (video + audio combined)
      for (final stream in manifest.muxed) {
        qualities.add(VideoQuality.fromYoutubeStream(
          label: stream.qualityLabel,
          url: stream.url.toString(),
          width: stream.videoResolution.width,
          height: stream.videoResolution.height,
          bitrate: stream.bitrate.bitsPerSecond,
          codec: stream.videoCodec,
          fileSize: stream.size.totalBytes,
        ));
      }

      // Sort by quality (highest first)
      qualities.sort((a, b) => (b.height ?? 0).compareTo(a.height ?? 0));

      // Remove duplicates (keep highest bitrate for same resolution)
      final uniqueQualities = <String, VideoQuality>{};
      for (final quality in qualities) {
        final key = quality.label;
        if (!uniqueQualities.containsKey(key) ||
            (quality.bitrate ?? 0) > (uniqueQualities[key]!.bitrate ?? 0)) {
          uniqueQualities[key] = quality;
        }
      }

      return uniqueQualities.values.toList()
        ..sort((a, b) => (b.height ?? 0).compareTo(a.height ?? 0));
    } catch (e) {
      return [];
    }
  }

  /// Get best quality stream URL
  Future<String?> getBestQualityUrl(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);

      // Prefer muxed streams for simplicity
      if (manifest.muxed.isNotEmpty) {
        final bestMuxed = manifest.muxed.withHighestBitrate();
        return bestMuxed.url.toString();
      }

      // Fallback to video-only (would need audio mixing)
      if (manifest.videoOnly.isNotEmpty) {
        final bestVideo = manifest.videoOnly.withHighestBitrate();
        return bestVideo.url.toString();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get a specific quality stream URL
  Future<String?> getQualityUrl(String videoId, String qualityLabel) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);

      // Find matching muxed stream
      for (final stream in manifest.muxed) {
        if (stream.qualityLabel == qualityLabel) {
          return stream.url.toString();
        }
      }

      // Fallback to any muxed stream
      if (manifest.muxed.isNotEmpty) {
        return manifest.muxed.first.url.toString();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get available subtitle tracks
  Future<List<SubtitleTrack>> getSubtitles(String videoId) async {
    try {
      final manifest = await _yt.videos.closedCaptions.getManifest(videoId);
      final subtitles = <SubtitleTrack>[];

      for (final track in manifest.tracks) {
        subtitles.add(SubtitleTrack(
          label: track.language.name,
          languageCode: track.language.code,
          url: track.url.toString(),
          isAutoGenerated: track.isAutoGenerated,
          format: 'vtt',
        ));
      }

      // Sort: non-auto-generated first, then by language
      subtitles.sort((a, b) {
        if (a.isAutoGenerated != b.isAutoGenerated) {
          return a.isAutoGenerated ? 1 : -1;
        }
        return a.languageCode.compareTo(b.languageCode);
      });

      return subtitles;
    } catch (e) {
      return [];
    }
  }

  /// Get subtitle content as string
  Future<String?> getSubtitleContent(String videoId, String languageCode) async {
    try {
      final manifest = await _yt.videos.closedCaptions.getManifest(videoId);
      final track = manifest.tracks.firstWhere(
        (t) => t.language.code == languageCode,
        orElse: () => throw Exception('Track not found'),
      );

      final closedCaptions = await _yt.videos.closedCaptions.get(track);

      // Convert to VTT format
      final buffer = StringBuffer('WEBVTT\n\n');
      for (final caption in closedCaptions.captions) {
        buffer.writeln(_formatVttTime(caption.offset));
        buffer.writeln(' --> ');
        buffer.writeln(_formatVttTime(caption.offset + caption.duration));
        buffer.writeln(caption.text);
        buffer.writeln();
      }

      return buffer.toString();
    } catch (e) {
      return null;
    }
  }

  String _formatVttTime(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    final millis = (d.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds.$millis';
  }

  /// Dispose resources
  void dispose() {
    _yt.close();
  }
}

/// Video metadata model
class VideoMetadata {
  final String id;
  final String title;
  final String author;
  final Duration duration;
  final String? thumbnailUrl;
  final String? description;
  final int viewCount;
  final DateTime? uploadDate;

  const VideoMetadata({
    required this.id,
    required this.title,
    required this.author,
    required this.duration,
    this.thumbnailUrl,
    this.description,
    required this.viewCount,
    this.uploadDate,
  });

  @override
  String toString() => 'VideoMetadata($title by $author)';
}
