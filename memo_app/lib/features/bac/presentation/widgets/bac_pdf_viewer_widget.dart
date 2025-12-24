import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart';
import '../bloc/bac_bookmark/bac_bookmark_bloc.dart';
import '../bloc/bac_bookmark/bac_bookmark_event.dart';
import '../bloc/bac_bookmark/bac_bookmark_state.dart';

/// Modern PDF viewer widget for BAC exams with download and share functionality
/// Matches the design language of the home page
class BacPdfViewerWidget extends StatefulWidget {
  final String? pdfUrl;
  final String title;
  final int subjectId;
  final String type; // 'subject' or 'correction'
  final Color? accentColor;

  const BacPdfViewerWidget({
    super.key,
    required this.pdfUrl,
    required this.title,
    required this.subjectId,
    required this.type,
    this.accentColor,
  });

  @override
  State<BacPdfViewerWidget> createState() => _BacPdfViewerWidgetState();
}

class _BacPdfViewerWidgetState extends State<BacPdfViewerWidget>
    with AutomaticKeepAliveClientMixin {
  String? _localPath;
  bool _isLoading = true;
  bool _isDownloading = false;
  double _downloadProgress = 0;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 0;
  PDFViewController? _pdfController;
  bool _isPermanentlySaved = false;

  // Bookmark state
  bool _isBookmarked = false;
  bool _isBookmarkLoading = false;
  late BacBookmarkBloc _bookmarkBloc;

  @override
  bool get wantKeepAlive => true;

  Color get _accentColor => widget.accentColor ?? AppColors.primary;

  @override
  void initState() {
    super.initState();
    debugPrint('📄 BacPdfViewerWidget: subjectId=${widget.subjectId}, type=${widget.type}');
    debugPrint('📄 BacPdfViewerWidget: pdfUrl=${widget.pdfUrl}');
    _bookmarkBloc = sl<BacBookmarkBloc>();
    // Check bookmark status for this BAC subject
    _bookmarkBloc.add(CheckBacBookmarkStatus(widget.subjectId));
    _loadPdf();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Get the local file path for this PDF (permanent storage)
  Future<String> _getLocalFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final bacExamsDir = Directory('${dir.path}/bac_exams');
    if (!await bacExamsDir.exists()) {
      await bacExamsDir.create(recursive: true);
    }
    return '${bacExamsDir.path}/${widget.subjectId}_${widget.type}.pdf';
  }

  /// Get temporary file path for caching
  Future<String> _getTempFilePath() async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/bac_${widget.subjectId}_${widget.type}.pdf';
  }

  /// Load PDF - check local first, then download if needed
  Future<void> _loadPdf() async {
    if (widget.pdfUrl == null || widget.pdfUrl!.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'لا يوجد ملف متاح';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Check if file exists locally (permanently downloaded)
      final localPath = await _getLocalFilePath();
      final localFile = File(localPath);
      if (await localFile.exists() && await _isValidPdf(localFile)) {
        setState(() {
          _localPath = localPath;
          _isLoading = false;
          _isPermanentlySaved = true;
        });
        return;
      }

      // Check if file exists in temp cache
      final tempPath = await _getTempFilePath();
      final tempFile = File(tempPath);
      if (await tempFile.exists() && await _isValidPdf(tempFile)) {
        setState(() {
          _localPath = tempPath;
          _isLoading = false;
          _isPermanentlySaved = false;
        });
        return;
      }

      // Download the PDF to temp
      await _downloadToPath(tempPath);
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في تحميل الملف';
        _isLoading = false;
      });
    }
  }

  /// Check if file is a valid PDF
  Future<bool> _isValidPdf(File file) async {
    try {
      if (!await file.exists()) return false;
      final bytes = await file.readAsBytes();
      if (bytes.length < 5) return false;
      // Check PDF magic number: %PDF-
      return bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46 &&
          bytes[4] == 0x2D;
    } catch (e) {
      return false;
    }
  }

  /// Download PDF to specified path with retry logic
  Future<void> _downloadToPath(String path, {int retryCount = 0}) async {
    const maxRetries = 5;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    debugPrint('📥 PDF Download: Starting download from ${widget.pdfUrl} (attempt ${retryCount + 1})');
    debugPrint('📥 PDF Download: Saving to $path');

    try {
      final dio = Dio();
      dio.options.followRedirects = true;
      dio.options.maxRedirects = 5;
      // Increase timeouts significantly for chunked streaming
      dio.options.connectTimeout = const Duration(seconds: 120);
      dio.options.receiveTimeout = const Duration(minutes: 5);
      dio.options.validateStatus = (status) => status != null && status < 500;
      // Add headers to work with chunked streaming
      dio.options.headers = {
        'Connection': 'keep-alive',
        'Accept': 'application/pdf,application/octet-stream,*/*',
        'Accept-Encoding': 'identity', // Disable compression to avoid issues
      };
      // Reduce receive buffer size to handle small chunks
      dio.options.receiveDataWhenStatusError = true;

      final response = await dio.download(
        widget.pdfUrl!,
        path,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          receiveTimeout: const Duration(minutes: 5),
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
            // Log progress every 10%
            if (received % (total ~/ 10) < 8192) {
              debugPrint('📥 PDF Download: Progress ${(received * 100 / total).toStringAsFixed(1)}% ($received / $total)');
            }
          }
        },
      );

      debugPrint('📥 PDF Download: Response status ${response.statusCode}');

      // Check if response is valid
      if (response.statusCode != 200) {
        throw Exception('فشل في تحميل الملف: ${response.statusCode}');
      }

      // Verify downloaded file is a valid PDF
      final downloadedFile = File(path);
      if (!await _isValidPdf(downloadedFile)) {
        // Read first bytes to check what we got (JSON error? HTML?)
        String errorDetail = 'الملف المحمل ليس بصيغة PDF صالحة';
        try {
          final bytes = await downloadedFile.readAsBytes();
          if (bytes.isNotEmpty) {
            final preview = String.fromCharCodes(bytes.take(100));
            if (preview.contains('{') && preview.contains('"')) {
              // Looks like JSON - possibly an API error response
              errorDetail = 'الخادم أرجع خطأ بدلاً من ملف PDF';
            } else if (preview.contains('<html') || preview.contains('<!DOCTYPE')) {
              errorDetail = 'الخادم أرجع صفحة HTML بدلاً من PDF';
            }
          }
        } catch (_) {}
        // Delete invalid file
        await downloadedFile.delete();
        throw Exception(errorDetail);
      }

      setState(() {
        _localPath = path;
        _isLoading = false;
        _isDownloading = false;
        _isPermanentlySaved = false;
      });
    } on DioException catch (e) {
      debugPrint('📥 PDF Download: DioException - Type: ${e.type}');
      debugPrint('📥 PDF Download: DioException - Message: ${e.message}');
      debugPrint('📥 PDF Download: DioException - Response: ${e.response?.statusCode}');
      debugPrint('📥 PDF Download: DioException - Error: ${e.error}');

      // Check if it's a connection closed error and we can retry
      final errorStr = e.error.toString();
      final isConnectionClosed = errorStr.contains('Connection closed') ||
          errorStr.contains('SocketException') ||
          e.type == DioExceptionType.connectionError;
      if (isConnectionClosed && retryCount < maxRetries) {
        debugPrint('📥 PDF Download: Connection issue, retrying... (${retryCount + 1}/$maxRetries)');
        debugPrint('📥 PDF Download: Error was: $errorStr');
        // Delete partial file if exists
        final partialFile = File(path);
        if (await partialFile.exists()) {
          await partialFile.delete();
        }
        // Exponential backoff: 1s, 2s, 4s, 8s, 16s
        final delaySeconds = 1 << retryCount;
        debugPrint('📥 PDF Download: Waiting ${delaySeconds}s before retry...');
        await Future.delayed(Duration(seconds: delaySeconds));
        return _downloadToPath(path, retryCount: retryCount + 1);
      }

      String errorMsg = 'فشل في تحميل الملف';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg = 'انتهت مهلة الاتصال';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'انتهت مهلة التحميل';
      } else if (e.type == DioExceptionType.connectionError || isConnectionClosed) {
        errorMsg = 'انقطع الاتصال أثناء التحميل';
      } else if (e.response?.statusCode == 403) {
        errorMsg = 'رابط التحميل منتهي الصلاحية';
      } else if (e.response?.statusCode == 404) {
        errorMsg = 'الملف غير موجود على الخادم';
      }
      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
        _isDownloading = false;
      });
    } catch (e) {
      debugPrint('📥 PDF Download: General Error - $e');
      setState(() {
        _errorMessage = e.toString().contains('PDF')
            ? e.toString().replaceAll('Exception: ', '')
            : 'فشل في تحميل الملف';
        _isLoading = false;
        _isDownloading = false;
      });
    }
  }

  /// Save PDF permanently to documents folder
  Future<void> _savePdfLocally() async {
    if (_localPath == null) return;

    try {
      final permanentPath = await _getLocalFilePath();
      final sourceFile = File(_localPath!);

      // If already at permanent path, skip
      if (_localPath == permanentPath) {
        _showSnackBar('الملف محفوظ مسبقاً', AppColors.primary);
        return;
      }

      await sourceFile.copy(permanentPath);

      setState(() {
        _localPath = permanentPath;
        _isPermanentlySaved = true;
      });

      _showSnackBar('تم حفظ الملف بنجاح', AppColors.successGreen);
    } catch (e) {
      _showSnackBar('فشل في حفظ الملف', AppColors.error);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocListener<BacBookmarkBloc, BacBookmarkState>(
      bloc: _bookmarkBloc,
      listener: (context, state) {
        if (state is BacBookmarkToggling) {
          if (state.bacSubjectId == widget.subjectId) {
            setState(() {
              _isBookmarkLoading = true;
            });
          }
        } else if (state is BacBookmarkToggled) {
          if (state.bacSubjectId == widget.subjectId) {
            setState(() {
              _isBookmarked = state.isBookmarked;
              _isBookmarkLoading = false;
            });
            _showSnackBar(state.message, AppColors.primary);
          }
        } else if (state is BacBookmarkStatusChecked) {
          if (state.bacSubjectId == widget.subjectId) {
            setState(() {
              _isBookmarked = state.isBookmarked;
            });
          }
        } else if (state is BacBookmarksLoaded) {
          setState(() {
            _isBookmarked = state.bookmarkStatus[widget.subjectId] ?? false;
          });
        } else if (state is BacBookmarkError) {
          setState(() {
            _isBookmarkLoading = false;
            _isBookmarked = !_isBookmarked; // Revert optimistic update
          });
          _showSnackBar('خطأ: ${state.message}', AppColors.error);
        }
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (widget.pdfUrl == null || widget.pdfUrl!.isEmpty) {
      return _buildNoPdfState();
    }

    if (_isLoading || _isDownloading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_localPath == null) {
      return _buildErrorState();
    }

    return Column(
      children: [
        Expanded(child: _buildPdfView()),
        _buildModernBottomBar(),
      ],
    );
  }

  Widget _buildPdfView() {
    return Container(
      color: Colors.grey[100],
      child: PDFView(
        filePath: _localPath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false, // Disable for better performance
        pageFling: true, // Enable for smoother page transitions
        pageSnap: true, // Snap to pages - better performance
        fitPolicy: FitPolicy.BOTH,
        preventLinkNavigation: false,
        nightMode: false,
        defaultPage: _currentPage,
        onRender: (pages) {
          setState(() {
            _totalPages = pages ?? 0;
          });
        },
        onError: (error) {
          setState(() {
            _errorMessage = 'فشل في عرض الملف';
          });
        },
        onViewCreated: (controller) {
          _pdfController = controller;
        },
        onPageChanged: (page, total) {
          // Only update if page actually changed to reduce rebuilds
          if (_currentPage != page) {
            setState(() {
              _currentPage = page ?? 0;
              _totalPages = total ?? 0;
            });
          }
        },
      ),
    );
  }

  Widget _buildModernBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Navigation buttons
            _buildCircularButton(
              icon: Icons.chevron_right_rounded,
              onTap: _currentPage > 0 ? _goToPreviousPage : null,
              isNavigation: true,
            ),
            const SizedBox(width: 8),

            // Page indicator - Modern pill style
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _accentColor.withValues(alpha: 0.1),
                      _accentColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _accentColor,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),
            _buildCircularButton(
              icon: Icons.chevron_left_rounded,
              onTap:
                  _currentPage < _totalPages - 1 ? _goToNextPage : null,
              isNavigation: true,
            ),
            const SizedBox(width: 12),

            // Action buttons
            _buildCircularButton(
              icon: Icons.fullscreen_rounded,
              onTap: _openFullscreen,
              isAction: true,
            ),
            const SizedBox(width: 6),
            _buildCircularButton(
              icon: _isPermanentlySaved
                  ? Icons.download_done_rounded
                  : Icons.download_rounded,
              onTap: _savePdfLocally,
              isAction: true,
              showBadge: _isPermanentlySaved,
            ),
            const SizedBox(width: 6),
            _buildBookmarkButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    VoidCallback? onTap,
    bool isNavigation = false,
    bool isAction = false,
    bool showBadge = false,
  }) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isNavigation
                  ? (isEnabled ? _accentColor : Colors.grey[200])
                  : _accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              boxShadow: isNavigation && isEnabled
                  ? [
                      BoxShadow(
                        color: _accentColor.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isNavigation
                  ? (isEnabled ? Colors.white : Colors.grey[400])
                  : _accentColor,
              size: 20,
            ),
          ),
          if (showBadge)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookmarkButton() {
    return GestureDetector(
      onTap: _isBookmarkLoading
          ? null
          : () {
              // Optimistic UI update
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
              _bookmarkBloc.add(ToggleBacBookmark(widget.subjectId));
            },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _isBookmarked
              ? _accentColor.withValues(alpha: 0.2)
              : _accentColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: _isBookmarkLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _accentColor,
                  ),
                )
              : Icon(
                  _isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: _accentColor,
                  size: 20,
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Modern loading animation container
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: _isDownloading
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: _downloadProgress,
                              color: _accentColor,
                              backgroundColor:
                                  _accentColor.withValues(alpha: 0.2),
                              strokeWidth: 4,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(_downloadProgress * 100).toInt()}%',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _accentColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          color: _accentColor,
                          strokeWidth: 3,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _isDownloading ? 'جاري تحميل الملف...' : 'جاري التحضير...',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isDownloading
                  ? 'يرجى الانتظار قليلاً'
                  : 'جاري التحقق من الملفات المحلية',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Modern error icon container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 50,
                  color: AppColors.error.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'فشل في عرض الملف',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage ?? 'حدث خطأ غير متوقع',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Retry button - Modern style
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadPdf,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'إعادة المحاولة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
    );
  }

  Widget _buildNoPdfState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Modern icon container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.type == 'correction'
                      ? Icons.fact_check_outlined
                      : Icons.description_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                widget.type == 'correction'
                    ? 'الحل غير متوفر حالياً'
                    : 'الموضوع غير متوفر حالياً',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.hourglass_empty_rounded,
                      size: 20,
                      color: _accentColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.type == 'correction'
                          ? 'سيتم إضافة الحل قريباً'
                          : 'سيتم إضافة الموضوع قريباً',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  /// Open fullscreen PDF viewer
  void _openFullscreen() {
    if (_localPath == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullscreenPdfViewer(
          filePath: _localPath!,
          title: widget.title,
          initialPage: _currentPage,
          totalPages: _totalPages,
          accentColor: _accentColor,
          onPageChanged: (page) {
            // Sync page with parent widget
            if (mounted && _pdfController != null) {
              _pdfController!.setPage(page);
            }
          },
        ),
      ),
    );
  }
}

/// Fullscreen PDF viewer with immersive mode
class _FullscreenPdfViewer extends StatefulWidget {
  final String filePath;
  final String title;
  final int initialPage;
  final int totalPages;
  final Color accentColor;
  final Function(int)? onPageChanged;

  const _FullscreenPdfViewer({
    required this.filePath,
    required this.title,
    required this.initialPage,
    required this.totalPages,
    required this.accentColor,
    this.onPageChanged,
  });

  @override
  State<_FullscreenPdfViewer> createState() => _FullscreenPdfViewerState();
}

class _FullscreenPdfViewerState extends State<_FullscreenPdfViewer> {
  late int _currentPage;
  late int _totalPages;
  PDFViewController? _pdfController;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _totalPages = widget.totalPages;
    // Enter fullscreen immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Set landscape orientation for better PDF viewing
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Notify parent of final page
    widget.onPageChanged?.call(_currentPage);
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // PDF View
            PDFView(
              filePath: widget.filePath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: false,
              pageFling: true,
              pageSnap: true,
              fitPolicy: FitPolicy.BOTH,
              preventLinkNavigation: false,
              nightMode: false,
              defaultPage: _currentPage,
              onRender: (pages) {
                setState(() {
                  _totalPages = pages ?? widget.totalPages;
                });
              },
              onViewCreated: (controller) {
                _pdfController = controller;
              },
              onPageChanged: (page, total) {
                if (_currentPage != page) {
                  setState(() {
                    _currentPage = page ?? 0;
                    _totalPages = total ?? _totalPages;
                  });
                }
              },
            ),

            // Top bar with title and close button
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: _showControls ? 0 : -100,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Close button
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Title
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom bar with page indicator and navigation
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              bottom: _showControls ? 0 : -100,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Previous page
                    _buildFullscreenButton(
                      icon: Icons.chevron_right_rounded,
                      onTap: _currentPage > 0
                          ? () => _pdfController?.setPage(_currentPage - 1)
                          : null,
                    ),
                    const SizedBox(width: 20),

                    // Page indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentPage + 1} / $_totalPages',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Next page
                    _buildFullscreenButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: _currentPage < _totalPages - 1
                          ? () => _pdfController?.setPage(_currentPage + 1)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullscreenButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isEnabled
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isEnabled
              ? Colors.white
              : Colors.white.withValues(alpha: 0.4),
          size: 30,
        ),
      ),
    );
  }
}
