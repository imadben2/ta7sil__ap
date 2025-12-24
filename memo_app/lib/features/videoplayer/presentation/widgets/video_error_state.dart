import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Error state widget for video player
///
/// Displays an error message with retry option when video fails to load.
class VideoErrorState extends StatelessWidget {
  /// Error message to display
  final String message;

  /// Accent color for the retry button
  final Color accentColor;

  /// Callback when retry is pressed
  final VoidCallback? onRetry;

  /// Whether retry is available
  final bool canRetry;

  const VideoErrorState({
    super.key,
    required this.message,
    this.accentColor = AppColors.primary,
    this.onRetry,
    this.canRetry = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.videocam_off_rounded,
                size: 40,
                color: AppColors.error.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),

            // Error title
            const Text(
              'فشل في تحميل الفيديو',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Error message
            Text(
              message,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Help text
            Text(
              'تأكد من اتصالك بالإنترنت وحاول مرة أخرى',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),

            // Retry button
            if (canRetry && onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact error indicator for inline display
class VideoErrorIndicator extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final Color accentColor;

  const VideoErrorIndicator({
    super.key,
    this.message,
    this.onRetry,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              message ?? 'خطأ في تحميل الفيديو',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.error,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 12),
            IconButton(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh_rounded,
                color: accentColor,
              ),
              tooltip: 'إعادة المحاولة',
            ),
          ],
        ],
      ),
    );
  }
}

/// No video available state
class NoVideoState extends StatelessWidget {
  final Color accentColor;

  const NoVideoState({
    super.key,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.videocam_off_outlined,
                size: 35,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد فيديو متاح',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'هذا المحتوى لا يتضمن فيديو',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
