import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/lesson_attachment_entity.dart';

/// صفحة عرض ملفات PDF
class PdfViewerPage extends StatefulWidget {
  final LessonAttachmentEntity attachment;

  const PdfViewerPage({
    super.key,
    required this.attachment,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? _localPath;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 0;
  PDFViewController? _pdfController;

  // Colors - Using AppColors for consistency
  static const _primaryPurple = AppColors.primary;
  static const _secondaryPurple = AppColors.primaryLight;
  static const _bgColor = AppColors.slateBackground;
  static const _textPrimary = AppColors.slate900;
  static const _textMuted = AppColors.slate500;

  @override
  void initState() {
    super.initState();
    _downloadAndOpenPdf();
  }

  Future<void> _downloadAndOpenPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final dir = await getTemporaryDirectory();
      final fileName = 'pdf_${widget.attachment.id}.pdf';
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);

      // Check if file already exists
      if (await file.exists()) {
        setState(() {
          _localPath = filePath;
          _isLoading = false;
        });
        return;
      }

      // Download the PDF
      final dio = Dio();
      await dio.download(
        widget.attachment.fileUrl,
        filePath,
        onReceiveProgress: (received, total) {
          // Could add progress indicator here
        },
      );

      setState(() {
        _localPath = filePath;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في تحميل الملف: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bgColor,
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: _localPath != null ? _buildBottomBar() : null,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _primaryPurple,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.attachment.fileNameAr,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded, color: Colors.white),
          onPressed: _sharePdf,
          tooltip: 'مشاركة',
        ),
        IconButton(
          icon: const Icon(Icons.download_rounded, color: Colors.white),
          onPressed: _downloadPdf,
          tooltip: 'تحميل',
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_localPath == null) {
      return _buildErrorState();
    }

    return PDFView(
      filePath: _localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      pageSnap: true,
      fitPolicy: FitPolicy.BOTH,
      preventLinkNavigation: false,
      onRender: (pages) {
        setState(() {
          _totalPages = pages ?? 0;
        });
      },
      onError: (error) {
        setState(() {
          _errorMessage = error.toString();
        });
      },
      onPageError: (page, error) {
        // Handle page-specific errors
      },
      onViewCreated: (controller) {
        _pdfController = controller;
      },
      onPageChanged: (page, total) {
        setState(() {
          _currentPage = page ?? 0;
          _totalPages = total ?? 0;
        });
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Previous page button
            _buildPageNavButton(
              icon: Icons.chevron_right_rounded,
              onTap: _currentPage > 0 ? _goToPreviousPage : null,
            ),
            const SizedBox(width: 12),
            // Page indicator
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'صفحة ${_currentPage + 1} من $_totalPages',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _primaryPurple,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Next page button
            _buildPageNavButton(
              icon: Icons.chevron_left_rounded,
              onTap: _currentPage < _totalPages - 1 ? _goToNextPage : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageNavButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isEnabled ? _primaryPurple : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.white : _textMuted,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _primaryPurple.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: _primaryPurple,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'جاري تحميل الملف...',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.attachment.formattedFileSize,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: _textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'فشل في عرض الملف',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'حدث خطأ غير متوقع',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: _textMuted,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _downloadAndOpenPdf,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== Actions ==========

  void _goToPreviousPage() {
    if (_pdfController != null && _currentPage > 0) {
      _pdfController!.setPage(_currentPage - 1);
    }
  }

  void _goToNextPage() {
    if (_pdfController != null && _currentPage < _totalPages - 1) {
      _pdfController!.setPage(_currentPage + 1);
    }
  }

  Future<void> _sharePdf() async {
    if (_localPath != null) {
      await Share.shareXFiles(
        [XFile(_localPath!)],
        text: widget.attachment.fileNameAr,
      );
    }
  }

  Future<void> _downloadPdf() async {
    try {
      // Get downloads directory
      final dir = await getApplicationDocumentsDirectory();
      final fileName = widget.attachment.fileNameAr.endsWith('.pdf')
          ? widget.attachment.fileNameAr
          : '${widget.attachment.fileNameAr}.pdf';
      final savePath = '${dir.path}/$fileName';

      if (_localPath != null) {
        // Copy from temp to documents
        final sourceFile = File(_localPath!);
        await sourceFile.copy(savePath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم حفظ الملف: $fileName',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'فتح',
                textColor: Colors.white,
                onPressed: () {
                  // Could open the file here
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل في حفظ الملف: ${e.toString()}',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
