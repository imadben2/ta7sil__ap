import 'package:http/http.dart' as http;
import '../models/subtitle_track.dart';

/// Service for parsing and loading subtitles
class SubtitleService {
  /// Load subtitles from URL
  Future<List<SubtitleCue>> loadSubtitles(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        return [];
      }

      final content = response.body;

      // Detect format and parse
      if (content.trim().startsWith('WEBVTT')) {
        return parseWebVTT(content);
      } else if (_looksLikeSRT(content)) {
        return parseSRT(content);
      }

      // Try VTT first, then SRT as fallback
      var cues = parseWebVTT(content);
      if (cues.isEmpty) {
        cues = parseSRT(content);
      }

      return cues;
    } catch (e) {
      return [];
    }
  }

  /// Check if content looks like SRT format
  bool _looksLikeSRT(String content) {
    final lines = content.split('\n');
    if (lines.length < 3) return false;

    // SRT starts with a number
    final firstLine = lines.first.trim();
    return int.tryParse(firstLine) != null;
  }

  /// Parse WebVTT subtitle content
  List<SubtitleCue> parseWebVTT(String content) {
    final cues = <SubtitleCue>[];
    final lines = content.split('\n');

    int i = 0;

    // Skip header
    while (i < lines.length && !lines[i].contains('-->')) {
      i++;
    }

    while (i < lines.length) {
      final line = lines[i].trim();

      // Look for timestamp line
      if (line.contains('-->')) {
        final timestamps = _parseVttTimestamps(line);
        if (timestamps != null) {
          // Collect text lines
          final textLines = <String>[];
          i++;
          while (i < lines.length && lines[i].trim().isNotEmpty && !lines[i].contains('-->')) {
            textLines.add(_cleanSubtitleText(lines[i]));
            i++;
          }

          if (textLines.isNotEmpty) {
            cues.add(SubtitleCue(
              start: timestamps.$1,
              end: timestamps.$2,
              text: textLines.join('\n'),
            ));
          }
          continue;
        }
      }
      i++;
    }

    return cues;
  }

  /// Parse SRT subtitle content
  List<SubtitleCue> parseSRT(String content) {
    final cues = <SubtitleCue>[];
    final blocks = content.split(RegExp(r'\n\s*\n'));

    for (final block in blocks) {
      final lines = block.split('\n').where((l) => l.trim().isNotEmpty).toList();
      if (lines.length < 2) continue;

      // Find timestamp line (second line typically)
      int timestampIndex = -1;
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('-->')) {
          timestampIndex = i;
          break;
        }
      }

      if (timestampIndex == -1) continue;

      final timestamps = _parseSrtTimestamps(lines[timestampIndex]);
      if (timestamps == null) continue;

      // Get text lines after timestamp
      final textLines = lines.skip(timestampIndex + 1).map(_cleanSubtitleText).toList();
      if (textLines.isEmpty) continue;

      cues.add(SubtitleCue(
        start: timestamps.$1,
        end: timestamps.$2,
        text: textLines.join('\n'),
      ));
    }

    return cues;
  }

  /// Parse VTT timestamp line
  (Duration, Duration)? _parseVttTimestamps(String line) {
    // Format: 00:00:00.000 --> 00:00:00.000
    final parts = line.split('-->');
    if (parts.length != 2) return null;

    final start = _parseVttTime(parts[0].trim());
    final end = _parseVttTime(parts[1].trim().split(' ').first);

    if (start == null || end == null) return null;
    return (start, end);
  }

  /// Parse SRT timestamp line
  (Duration, Duration)? _parseSrtTimestamps(String line) {
    // Format: 00:00:00,000 --> 00:00:00,000
    final parts = line.split('-->');
    if (parts.length != 2) return null;

    final start = _parseSrtTime(parts[0].trim());
    final end = _parseSrtTime(parts[1].trim());

    if (start == null || end == null) return null;
    return (start, end);
  }

  /// Parse VTT time format (00:00:00.000 or 00:00.000)
  Duration? _parseVttTime(String time) {
    try {
      final parts = time.split(':');
      int hours = 0;
      int minutes = 0;
      double seconds = 0;

      if (parts.length == 3) {
        hours = int.parse(parts[0]);
        minutes = int.parse(parts[1]);
        seconds = double.parse(parts[2].replaceAll(',', '.'));
      } else if (parts.length == 2) {
        minutes = int.parse(parts[0]);
        seconds = double.parse(parts[1].replaceAll(',', '.'));
      } else {
        return null;
      }

      return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds.floor(),
        milliseconds: ((seconds - seconds.floor()) * 1000).round(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Parse SRT time format (00:00:00,000)
  Duration? _parseSrtTime(String time) {
    try {
      // Replace comma with dot for parsing
      time = time.replaceAll(',', '.');
      return _parseVttTime(time);
    } catch (e) {
      return null;
    }
  }

  /// Clean subtitle text (remove tags, etc.)
  String _cleanSubtitleText(String text) {
    // Remove VTT/SRT formatting tags
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');
    // Remove position tags
    text = text.replaceAll(RegExp(r'\{[^}]+\}'), '');
    // Trim whitespace
    return text.trim();
  }

  /// Get current cue at position
  SubtitleCue? getCueAtPosition(List<SubtitleCue> cues, Duration position) {
    for (final cue in cues) {
      if (cue.isActiveAt(position)) {
        return cue;
      }
    }
    return null;
  }
}
