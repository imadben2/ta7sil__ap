import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Loading state widget for video player
///
/// Displays a loading spinner with text while video is being initialized.
class VideoLoadingState extends StatelessWidget {
  /// Accent color for the loading indicator
  final Color accentColor;

  /// Loading message text
  final String? message;

  /// Secondary message text
  final String? submessage;

  const VideoLoadingState({
    super.key,
    this.accentColor = AppColors.primary,
    this.message,
    this.submessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Loading spinner
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message ?? 'جاري تحميل الفيديو...',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              submessage ?? 'الرجاء الانتظار',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact loading indicator for inline use
class VideoLoadingIndicator extends StatelessWidget {
  final Color accentColor;
  final double size;

  const VideoLoadingIndicator({
    super.key,
    this.accentColor = AppColors.primary,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.6,
          height: size * 0.6,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

/// Buffering overlay for video player
class VideoBufferingOverlay extends StatelessWidget {
  final Color accentColor;
  final bool isVisible;

  const VideoBufferingOverlay({
    super.key,
    this.accentColor = AppColors.primary,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                strokeWidth: 3,
              ),
              const SizedBox(height: 12),
              const Text(
                'جاري التحميل...',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
