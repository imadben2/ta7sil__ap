import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../constants/app_colors.dart';

/// Image handling utility for profile photos
///
/// Provides centralized image operations:
/// - Pick from camera
/// - Pick from gallery
/// - Crop to 1:1 aspect ratio
/// - Compress to < 2MB
/// - Handle permissions
///
/// Usage:
/// ```dart
/// final file = await ImageHelper.pickAndCropImage(context, source: ImageSource.gallery);
/// if (file != null) {
///   // Upload file
/// }
/// ```
class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from camera with permission handling
  ///
  /// Returns:
  /// - File if successful
  /// - null if cancelled or permission denied
  static Future<File?> pickImageFromCamera() async {
    // Check camera permission
    final cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) {
      return null;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick image from gallery with permission handling
  ///
  /// Returns:
  /// - File if successful
  /// - null if cancelled or permission denied
  static Future<File?> pickImageFromGallery() async {
    // Check storage permission (Android only, iOS doesn't need it)
    if (Platform.isAndroid) {
      final storageStatus = await Permission.photos.request();
      if (!storageStatus.isGranted) {
        // Try legacy storage permission for older Android versions
        final legacyStatus = await Permission.storage.request();
        if (!legacyStatus.isGranted) {
          return null;
        }
      }
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Crop image to 1:1 aspect ratio (square)
  ///
  /// Uses platform-native image cropper UI:
  /// - iOS: TOCropViewController
  /// - Android: uCrop
  ///
  /// Returns:
  /// - Cropped File if successful
  /// - null if cancelled
  static Future<File?> cropImage(
    File source, {
    BuildContext? context,
  }) async {
    if (kIsWeb) {
      // Web doesn't support image cropper, return original
      return source;
    }

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: source.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          // Android settings
          AndroidUiSettings(
            toolbarTitle: 'قص الصورة',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: AppColors.primary,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          // iOS settings
          IOSUiSettings(
            title: 'قص الصورة',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );

      if (croppedFile == null) return null;

      return File(croppedFile.path);
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return null;
    }
  }

  /// Compress image to ensure size < maxSizeKB
  ///
  /// Strategy:
  /// 1. Check current file size
  /// 2. If already < maxSizeKB, return original
  /// 3. Otherwise, progressively reduce quality until size is acceptable
  ///
  /// Returns:
  /// - Compressed File (or original if already small enough)
  static Future<File> compressImage(
    File source, {
    int maxSizeKB = 2048, // 2MB default
  }) async {
    try {
      // Check current size
      final currentSize = await source.length();
      final currentSizeKB = currentSize / 1024;

      if (currentSizeKB <= maxSizeKB) {
        // Already small enough
        return source;
      }

      // Need to compress
      // Strategy: Reduce quality progressively
      int quality = 85;
      File? compressedFile;

      while (quality >= 20) {
        // Pick with reduced quality
        final XFile? compressed = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: quality,
        );

        if (compressed == null) break;

        compressedFile = File(compressed.path);
        final newSize = await compressedFile.length();
        final newSizeKB = newSize / 1024;

        if (newSizeKB <= maxSizeKB) {
          return compressedFile;
        }

        quality -= 10; // Reduce quality by 10%
      }

      // If still too large, return best effort
      return compressedFile ?? source;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return source;
    }
  }

  /// Complete flow: Pick image, crop, and compress
  ///
  /// Convenience method that combines all steps:
  /// 1. Pick from camera or gallery
  /// 2. Crop to 1:1
  /// 3. Compress to < 2MB
  ///
  /// Returns:
  /// - Ready-to-upload File
  /// - null if cancelled at any step
  static Future<File?> pickAndCropImage(
    BuildContext context, {
    required ImageSource source,
    int maxSizeKB = 2048,
  }) async {
    // Step 1: Pick image
    File? pickedFile;
    if (source == ImageSource.camera) {
      pickedFile = await pickImageFromCamera();
    } else {
      pickedFile = await pickImageFromGallery();
    }

    if (pickedFile == null) return null;

    // Step 2: Crop to 1:1
    final croppedFile = await cropImage(pickedFile, context: context);
    if (croppedFile == null) return null;

    // Step 3: Compress to < 2MB
    final compressedFile = await compressImage(croppedFile, maxSizeKB: maxSizeKB);

    return compressedFile;
  }

  /// Show bottom sheet to select image source (camera or gallery)
  ///
  /// Returns:
  /// - ImageSource.camera if user selects camera
  /// - ImageSource.gallery if user selects gallery
  /// - null if user cancels
  static Future<ImageSource?> showImageSourceSelector(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                'اختر مصدر الصورة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Camera option
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text(
                  'التقاط صورة',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Colors.grey[100],
              ),
              const SizedBox(height: 12),

              // Gallery option
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text(
                  'اختيار من المعرض',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Colors.grey[100],
              ),
              const SizedBox(height: 12),

              // Cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Validate image file
  ///
  /// Checks:
  /// - File exists
  /// - File size < maxSizeKB
  /// - File is valid image format (jpg, png, jpeg)
  ///
  /// Returns:
  /// - null if valid
  /// - Error message if invalid
  static Future<String?> validateImage(File file, {int maxSizeKB = 2048}) async {
    // Check if file exists
    if (!await file.exists()) {
      return 'الملف غير موجود';
    }

    // Check file size
    final size = await file.length();
    final sizeKB = size / 1024;
    if (sizeKB > maxSizeKB) {
      return 'حجم الصورة كبير جداً (الحد الأقصى ${maxSizeKB / 1024}MB)';
    }

    // Check file extension
    final ext = file.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png'].contains(ext)) {
      return 'صيغة الصورة غير مدعومة (يُقبل فقط JPG, PNG)';
    }

    return null; // Valid
  }

  /// Get cache directory for temporary image storage
  static Future<Directory> getCacheDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Delete temporary image files
  static Future<void> clearCache() async {
    try {
      final cacheDir = await getCacheDirectory();
      final files = cacheDir.listSync();
      for (var file in files) {
        if (file is File && file.path.contains('image_picker')) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error clearing image cache: $e');
    }
  }
}
