import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'bac_pdf_viewer_widget.dart';

/// BAC PDF Viewer Modal Wrapper
///
/// Wraps the existing BacPdfViewerWidget in a modal presentation
/// for use during simulations. The timer continues running in the
/// background while the user views the PDF.
///
/// Features:
/// - Fullscreen modal presentation
/// - Close button to return to simulation
/// - Reuses existing PDF viewer functionality
class BacPdfViewerModal extends StatelessWidget {
  final String pdfUrl;
  final String title;
  final int subjectId;
  final String type;
  final Color? accentColor;

  const BacPdfViewerModal({
    super.key,
    required this.pdfUrl,
    required this.title,
    required this.subjectId,
    required this.type,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: accentColor ?? AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, size: 28),
            onPressed: () => Navigator.pop(context),
            tooltip: 'إغلاق',
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            // Info icon
            IconButton(
              icon: const Icon(Icons.info_outline_rounded),
              onPressed: () => _showInfo(context),
              tooltip: 'معلومات',
            ),
          ],
        ),
        body: BacPdfViewerWidget(
          pdfUrl: pdfUrl,
          title: title,
          subjectId: subjectId,
          type: type,
          accentColor: accentColor ?? AppColors.primary,
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.timer_outlined, color: accentColor ?? AppColors.primary),
              const SizedBox(width: 12),
              const Text(
                'المحاكاة مستمرة',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'العداد التنازلي للمحاكاة مستمر في العمل. يمكنك إغلاق هذه النافذة في أي وقت للعودة إلى شاشة المحاكاة والتحقق من الوقت المتبقي.',
            style: TextStyle(fontFamily: 'Cairo', height: 1.5),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor ?? AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'فهمت',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
