import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

/// Content widget for image-based flashcard type
class ImageCardContent extends StatelessWidget {
  final String imageUrl;
  final String? caption;
  final bool showFullscreen;
  final VoidCallback? onImageTap;

  const ImageCardContent({
    super.key,
    required this.imageUrl,
    this.caption,
    this.showFullscreen = false,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onImageTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildLoadingIndicator(loadingProgress);
                    },
                  ),
                  if (onImageTap != null)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.overlay,
                          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.zoom_in_rounded,
                              color: AppColors.textOnPrimary,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'اضغط للتكبير',
                              style: TextStyle(
                                color: AppColors.textOnPrimary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (caption != null && caption!.isNotEmpty) ...[
          const SizedBox(height: AppSizes.spacingMD),
          Text(
            caption!,
            style: const TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.overlayWhite10,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: AppColors.textOnPrimary.withOpacity(0.5),
            size: 64,
          ),
          const SizedBox(height: AppSizes.spacingMD),
          Text(
            'تعذر تحميل الصورة',
            style: TextStyle(
              color: AppColors.textOnPrimary.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(ImageChunkEvent loadingProgress) {
    final progress = loadingProgress.expectedTotalBytes != null
        ? loadingProgress.cumulativeBytesLoaded /
            loadingProgress.expectedTotalBytes!
        : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.overlayWhite10,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              value: progress,
              color: AppColors.textOnPrimary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: AppSizes.spacingMD),
          Text(
            'جاري التحميل...',
            style: TextStyle(
              color: AppColors.textOnPrimary.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fullscreen image viewer dialog
class ImageViewerDialog extends StatelessWidget {
  final String imageUrl;
  final String? caption;

  const ImageViewerDialog({
    super.key,
    required this.imageUrl,
    this.caption,
  });

  static Future<void> show(
    BuildContext context, {
    required String imageUrl,
    String? caption,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => ImageViewerDialog(
        imageUrl: imageUrl,
        caption: caption,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Close on tap outside
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.transparent),
          ),

          // Image with zoom
          InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white54,
                  size: 100,
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
              color: Colors.white,
              iconSize: 28,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black38,
              ),
            ),
          ),

          // Caption at bottom
          if (caption != null && caption!.isNotEmpty)
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(AppSizes.paddingMD),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                ),
                child: Text(
                  caption!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
