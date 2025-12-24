import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/api_constants.dart';

/// Local data source for content library offline features
/// Handles downloading, caching, and managing offline content
class ContentLibraryLocalDataSource {
  final Dio dio;
  static const String _downloadedContentBoxName = 'downloaded_content';
  static const String _downloadFolderName = 'content_downloads';

  ContentLibraryLocalDataSource({required this.dio});

  /// Get the downloads directory path
  Future<Directory> _getDownloadsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${appDir.path}/$_downloadFolderName');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir;
  }

  /// Get the Hive box for downloaded content metadata
  Future<Box<Map>> _getDownloadedContentBox() async {
    if (!Hive.isBoxOpen(_downloadedContentBoxName)) {
      return await Hive.openBox<Map>(_downloadedContentBoxName);
    }
    return Hive.box<Map>(_downloadedContentBoxName);
  }

  /// Download content file to local storage
  /// Returns the local file path
  Future<String> downloadContent({
    required int contentId,
    required String downloadUrl,
    String? fileName,
    void Function(int received, int total)? onProgress,
  }) async {
    final dir = await _getDownloadsDirectory();
    final localFileName = fileName ?? 'content_$contentId.pdf';
    final filePath = '${dir.path}/$localFileName';

    // Download the file
    await dio.download(
      downloadUrl,
      filePath,
      onReceiveProgress: onProgress,
      options: Options(
        headers: {
          ApiConstants.headerAccept: '*/*',
        },
      ),
    );

    // Save metadata to Hive
    final box = await _getDownloadedContentBox();
    await box.put(contentId.toString(), {
      'content_id': contentId,
      'file_path': filePath,
      'file_name': localFileName,
      'download_url': downloadUrl,
      'downloaded_at': DateTime.now().toIso8601String(),
    });

    return filePath;
  }

  /// Check if content is downloaded
  Future<bool> isContentDownloaded(int contentId) async {
    final box = await _getDownloadedContentBox();
    final metadata = box.get(contentId.toString());
    if (metadata == null) return false;

    // Also verify the file exists
    final filePath = metadata['file_path'] as String?;
    if (filePath == null) return false;

    return File(filePath).existsSync();
  }

  /// Get the local file path for downloaded content
  Future<String?> getDownloadedContentPath(int contentId) async {
    final box = await _getDownloadedContentBox();
    final metadata = box.get(contentId.toString());
    if (metadata == null) return null;

    final filePath = metadata['file_path'] as String?;
    if (filePath == null) return null;

    // Verify file exists
    if (!File(filePath).existsSync()) {
      // File was deleted externally, clean up metadata
      await box.delete(contentId.toString());
      return null;
    }

    return filePath;
  }

  /// Delete downloaded content
  Future<bool> deleteDownloadedContent(int contentId) async {
    final box = await _getDownloadedContentBox();
    final metadata = box.get(contentId.toString());
    if (metadata == null) return false;

    final filePath = metadata['file_path'] as String?;
    if (filePath != null) {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    await box.delete(contentId.toString());
    return true;
  }

  /// Get all downloaded content IDs
  Future<List<int>> getDownloadedContentIds() async {
    final box = await _getDownloadedContentBox();
    return box.keys.map((k) => int.parse(k.toString())).toList();
  }

  /// Get metadata for all downloaded content
  Future<List<Map<String, dynamic>>> getAllDownloadedContentMetadata() async {
    final box = await _getDownloadedContentBox();
    final validMetadata = <Map<String, dynamic>>[];

    for (final key in box.keys) {
      final metadata = box.get(key);
      if (metadata != null) {
        final filePath = metadata['file_path'] as String?;
        if (filePath != null && File(filePath).existsSync()) {
          validMetadata.add(Map<String, dynamic>.from(metadata));
        } else {
          // Clean up invalid entries
          await box.delete(key);
        }
      }
    }

    return validMetadata;
  }

  /// Get total size of downloaded content in bytes
  Future<int> getTotalDownloadedSize() async {
    final metadata = await getAllDownloadedContentMetadata();
    int totalSize = 0;

    for (final item in metadata) {
      final filePath = item['file_path'] as String?;
      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          totalSize += await file.length();
        }
      }
    }

    return totalSize;
  }

  /// Delete all downloaded content
  Future<void> clearAllDownloads() async {
    final dir = await _getDownloadsDirectory();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      await dir.create();
    }

    final box = await _getDownloadedContentBox();
    await box.clear();
  }
}
