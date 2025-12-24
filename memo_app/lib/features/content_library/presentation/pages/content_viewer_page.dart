import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/content_entity.dart';
import '../../domain/entities/subject_entity.dart';
import '../../data/datasources/content_library_remote_datasource.dart';
import '../../data/repositories/content_library_repository_impl.dart';
import '../../../profile/domain/usecases/get_settings_usecase.dart';
import '../../../videoplayer/videoplayer.dart';
import '../bloc/content_viewer/content_viewer_bloc.dart';
import '../bloc/content_viewer/content_viewer_event.dart';
import '../bloc/content_viewer/content_viewer_state.dart';
import '../bloc/bookmark/bookmark_bloc.dart';
import '../bloc/bookmark/bookmark_event.dart';
import '../bloc/bookmark/bookmark_state.dart';

/// Page for viewing content (video or PDF) with progress tracking
/// PDF content is displayed directly like BAC page (no TabBar)
class ContentViewerPage extends StatefulWidget {
  final ContentEntity content;
  final SubjectEntity subject;
  final Color subjectColor;
  final List<ContentEntity>? allContents;
  final int? currentIndex;

  const ContentViewerPage({
    super.key,
    required this.content,
    required this.subject,
    required this.subjectColor,
    this.allContents,
    this.currentIndex,
  });

  @override
  State<ContentViewerPage> createState() => _ContentViewerPageState();
}

class _ContentViewerPageState extends State<ContentViewerPage> {
  // PDF viewer state
  String? _localPath;
  bool _isLoading = true;
  bool _isDownloading = false;
  double _downloadProgress = 0;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 0;
  PDFViewController? _pdfController;
  bool _isPermanentlySaved = false;

  // Progress tracking
  double _currentProgress = 0.0;
  bool _isCompleted = false;
  Timer? _autoSaveTimer;
  int _elapsedSeconds = 0;
  static const int _autoSaveIntervalSeconds = 30;

  // Loaded content from API (with file info)
  ContentEntity? _loadedContent;
  bool _pdfLoadStarted = false;

  // Bookmark state
  bool _isBookmarked = false;
  bool _isBookmarkLoading = false;

  // Video player settings
  String _preferredVideoPlayer = 'simple_youtube';
  bool _settingsLoaded = false;

  Color get _accentColor => widget.subjectColor;

  /// Get current content (loaded from API or initial)
  ContentEntity get _currentContent => _loadedContent ?? widget.content;

  /// Check if content has a PDF file
  bool get _hasPdfFile =>
      _currentContent.hasFile &&
      (_currentContent.fileType?.toLowerCase() == 'pdf' ||
       _currentContent.filePath?.toLowerCase().endsWith('.pdf') == true);

  /// Get file URL (either filePath or construct from API base)
  String? get _fileUrl => _currentContent.filePath;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.content.progressPercentage ?? 0.0;
    _isCompleted = widget.content.isCompleted;

    _startAutoSaveTimer();

    // Load preferred video player BEFORE any other initialization
    _loadPreferredVideoPlayer();

    // Load content detail from API (will include file info)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentViewerBloc>().add(
        LoadContentDetail(widget.content.id),
      );
      context.read<ContentViewerBloc>().add(
        RecordContentView(widget.content.id),
      );
      // Check bookmark status
      context.read<BookmarkBloc>().add(
        CheckBookmarkStatus(widget.content.id),
      );
    });
  }

  Future<void> _loadPreferredVideoPlayer() async {
    try {
      final getSettingsUseCase = sl<GetSettingsUseCase>();
      final result = await getSettingsUseCase();
      result.fold(
        (failure) {
          debugPrint('❌ Failed to load video player settings: ${failure.message}');
          // Even if loading fails, mark as loaded so video can initialize with default
          if (mounted) {
            setState(() {
              _settingsLoaded = true;
            });
          }
        },
        (settings) {
          if (mounted) {
            setState(() {
              _preferredVideoPlayer = settings.preferredVideoPlayer;
              _settingsLoaded = true;
            });
            debugPrint('✅ Loaded preferred video player: $_preferredVideoPlayer');
          }
        },
      );
    } catch (e) {
      debugPrint('❌ Error loading video player settings: $e');
      // Even if error, mark as loaded so video can initialize with default
      if (mounted) {
        setState(() {
          _settingsLoaded = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    if (_currentProgress > 0 && !_isCompleted) {
      context.read<ContentViewerBloc>().add(
        UpdateContentProgress(
          contentId: widget.content.id,
          progressPercentage: _currentProgress * 100,
          timeSpentMinutes: (_elapsedSeconds / 60).round(),
        ),
      );
    }
    super.dispose();
  }

  void _startAutoSaveTimer() {
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: _autoSaveIntervalSeconds),
      (_) {
        _elapsedSeconds += _autoSaveIntervalSeconds;
        if (_currentProgress > 0 && !_isCompleted) {
          context.read<ContentViewerBloc>().add(
            AutoSaveProgress(
              contentId: widget.content.id,
              progressPercentage: _currentProgress * 100,
              timeSpentSeconds: _elapsedSeconds,
            ),
          );
        }
      },
    );
  }

  // ============ PDF Loading Methods ============

  Future<String> _getLocalFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final contentDir = Directory('${dir.path}/content_library');
    if (!await contentDir.exists()) {
      await contentDir.create(recursive: true);
    }
    return '${contentDir.path}/content_${widget.content.id}.pdf';
  }

  Future<String> _getTempFilePath() async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/content_${widget.content.id}.pdf';
  }

  Future<void> _loadPdf() async {
    final pdfUrl = _fileUrl;

    // Debug log
    debugPrint('=== PDF Loading Debug ===');
    debugPrint('Content ID: ${widget.content.id}');
    debugPrint('hasFile: ${widget.content.hasFile}');
    debugPrint('fileType: ${widget.content.fileType}');
    debugPrint('filePath (URL): $pdfUrl');
    debugPrint('========================');

    if (pdfUrl == null || pdfUrl.isEmpty) {
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

      // Check local permanent file
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

      // Check temp cache
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

      // Download
      await _downloadToPath(tempPath);
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في تحميل الملف';
        _isLoading = false;
      });
    }
  }

  Future<bool> _isValidPdf(File file) async {
    try {
      if (!await file.exists()) return false;
      final bytes = await file.readAsBytes();
      if (bytes.length < 5) return false;
      return bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46 &&
          bytes[4] == 0x2D;
    } catch (e) {
      return false;
    }
  }

  Future<void> _downloadToPath(String path, {int retryCount = 0}) async {
    const maxRetries = 5;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final dio = Dio();
      dio.options.followRedirects = true;
      dio.options.maxRedirects = 5;
      dio.options.connectTimeout = const Duration(seconds: 120);
      dio.options.receiveTimeout = const Duration(minutes: 5);
      dio.options.validateStatus = (status) => status != null && status < 500;
      dio.options.headers = {
        'Connection': 'keep-alive',
        'Accept': 'application/pdf,application/octet-stream,*/*',
        'Accept-Encoding': 'identity',
      };

      final response = await dio.download(
        _fileUrl!,
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
          }
        },
      );

      if (response.statusCode != 200) {
        throw Exception('فشل في تحميل الملف: ${response.statusCode}');
      }

      final downloadedFile = File(path);
      if (!await _isValidPdf(downloadedFile)) {
        await downloadedFile.delete();
        throw Exception('الملف المحمل ليس بصيغة PDF صالحة');
      }

      setState(() {
        _localPath = path;
        _isLoading = false;
        _isDownloading = false;
        _isPermanentlySaved = false;
      });
    } on DioException catch (e) {
      final errorStr = e.error.toString();
      final isConnectionClosed = errorStr.contains('Connection closed') ||
          errorStr.contains('SocketException') ||
          e.type == DioExceptionType.connectionError;

      if (isConnectionClosed && retryCount < maxRetries) {
        final partialFile = File(path);
        if (await partialFile.exists()) {
          await partialFile.delete();
        }
        final delaySeconds = 1 << retryCount;
        await Future.delayed(Duration(seconds: delaySeconds));
        return _downloadToPath(path, retryCount: retryCount + 1);
      }

      String errorMsg = 'فشل في تحميل الملف';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg = 'انتهت مهلة الاتصال';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'انتهت مهلة التحميل';
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
      setState(() {
        _errorMessage = 'فشل في تحميل الملف';
        _isLoading = false;
        _isDownloading = false;
      });
    }
  }

  Future<void> _savePdfLocally() async {
    if (_localPath == null) return;

    try {
      final permanentPath = await _getLocalFilePath();
      final sourceFile = File(_localPath!);

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

  Future<void> _sharePdf() async {
    if (_localPath != null) {
      await Share.shareXFiles(
        [XFile(_localPath!)],
        text: widget.content.titleAr,
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _markAsCompleted() {
    setState(() {
      _currentProgress = 1.0;
      _isCompleted = true;
    });
    context.read<ContentViewerBloc>().add(
      MarkContentCompleted(widget.content.id),
    );
    _showSnackBar('🎉 تم إتمام الدرس بنجاح!', AppColors.successGreen);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ContentViewerBloc, ContentViewerState>(
          listener: (context, state) {
            if (state is ContentViewerLoaded) {
              // Content detail loaded from API - now we have file info
              setState(() {
                _loadedContent = state.content;
                // Update progress and completion status from API response
                if (state.progress != null) {
                  _currentProgress = (state.progress!.progressPercentage ?? 0) / 100;
                  _isCompleted = state.progress!.isCompleted;
                  debugPrint('📊 Progress loaded: ${state.progress!.progressPercentage}%, completed: $_isCompleted');
                }
              });

              // Start PDF loading if not already started and content has PDF
              if (!_pdfLoadStarted && _hasPdfFile) {
                _pdfLoadStarted = true;
                debugPrint('📄 Content loaded with PDF, starting download...');
                _loadPdf();
              } else if (!_hasPdfFile) {
                setState(() {
                  _isLoading = false;
                });
              }
            } else if (state is ContentViewerProgressUpdated) {
              _showSnackBar('✅ تم حفظ التقدم بنجاح', AppColors.successGreen);
            } else if (state is ContentViewerError) {
              _showSnackBar('❌ خطأ: ${state.message}', Colors.red);
            }
          },
        ),
        BlocListener<BookmarkBloc, BookmarkState>(
          listener: (context, state) {
            if (state is BookmarkToggling) {
              if (state.contentId == widget.content.id) {
                setState(() {
                  _isBookmarkLoading = true;
                });
              }
            } else if (state is BookmarkToggled) {
              if (state.contentId == widget.content.id) {
                setState(() {
                  _isBookmarked = state.isBookmarked;
                  _isBookmarkLoading = false;
                });
                _showSnackBar(state.message, AppColors.primary);
              }
            } else if (state is BookmarkStatusChecked) {
              if (state.contentId == widget.content.id) {
                setState(() {
                  _isBookmarked = state.isBookmarked;
                });
              }
            } else if (state is BookmarksLoaded) {
              // Update bookmark status from loaded bookmarks
              setState(() {
                _isBookmarked = state.bookmarkStatus[widget.content.id] ?? false;
              });
            } else if (state is BookmarkError) {
              setState(() {
                _isBookmarkLoading = false;
                // Revert optimistic update on error
                _isBookmarked = !_isBookmarked;
              });
              _showSnackBar('خطأ: ${state.message}', AppColors.error);
            }
          },
        ),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            // Always return true to trigger refresh in parent
            Navigator.pop(context, true);
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: _buildMainContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build main content based on loading state
  Widget _buildMainContent() {
    // Still loading content details from API
    if (_loadedContent == null) {
      return _buildLoadingState();
    }

    // Content loaded, check what type to display
    if (_hasPdfFile) {
      return _buildPdfContent();
    } else if (_currentContent.hasVideo) {
      return _buildVideoContent();
    } else {
      return _buildNoContentState();
    }
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.content.titleAr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.subject.nameAr,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Cairo',
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Bookmark button
          GestureDetector(
            onTap: _isBookmarkLoading
                ? null
                : () {
                    setState(() {
                      _isBookmarked = !_isBookmarked;
                    });
                    context
                        .read<BookmarkBloc>()
                        .add(ToggleBookmark(widget.content.id));
                  },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isBookmarkLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                      ),
                    )
                  : Icon(
                      _isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 22,
                      color: _isBookmarked ? _accentColor : AppColors.textPrimary,
                    ),
            ),
          ),
          const SizedBox(width: 8),
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfContent() {
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
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildPdfView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: PDFView(
        filePath: _localPath!,
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
          if (_currentPage != page) {
            setState(() {
              _currentPage = page ?? 0;
              _totalPages = total ?? 0;
              // Update progress based on pages viewed
              if (_totalPages > 0) {
                _currentProgress = (_currentPage + 1) / _totalPages;
              }
            });
          }
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // PDF Navigation row
            Row(
              children: [
                _buildCircularButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: _currentPage > 0 ? _goToPreviousPage : null,
                  isNavigation: true,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
                  onTap: _currentPage < _totalPages - 1 ? _goToNextPage : null,
                  isNavigation: true,
                ),
                const SizedBox(width: 12),
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
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isCompleted ? null : _markAsCompleted,
                    icon: Icon(_isCompleted ? Icons.check : Icons.done_all, size: 20),
                    label: Text(
                      _isCompleted ? 'مكتمل' : 'وضع علامة كمكتمل',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: _isCompleted ? AppColors.successGreen : _accentColor,
                      ),
                      foregroundColor: _isCompleted ? AppColors.successGreen : _accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _canNavigateToNext() ? _navigateToNext : null,
                    icon: const Icon(Icons.arrow_back, size: 20),
                    label: const Text(
                      'التالي',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: _accentColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[600],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

  Widget _buildLoadingState() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                              backgroundColor: _accentColor.withValues(alpha: 0.2),
                              strokeWidth: 4,
                            ),
                          ),
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
              _isDownloading ? 'يرجى الانتظار قليلاً' : 'جاري التحقق من الملفات المحلية',
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
      margin: const EdgeInsets.all(16),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  /// Build video content using the VideoPlayerWidget from videoplayer feature
  Widget _buildVideoContent() {
    // Wait for settings to load before initializing video player
    if (!_settingsLoaded) {
      return VideoLoadingState(accentColor: _accentColor);
    }

    final videoUrl = _currentContent.videoUrl;
    if (videoUrl == null || videoUrl.isEmpty) {
      return const NoVideoState();
    }

    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        children: [
          // Video Player Card
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video Player Widget (from videoplayer feature)
                  VideoPlayerWidget(
                    config: VideoConfig.contentLibrary(
                      videoUrl: videoUrl,
                      preferredPlayer: _preferredVideoPlayer,
                      accentColorValue: _accentColor.value,
                    ),
                    accentColor: _accentColor,
                    showQuickControls: true,
                    showProgressBar: false, // We show our own progress section
                    onProgress: (progress) {
                      if (mounted) {
                        setState(() {
                          _currentProgress = progress;
                        });
                      }
                    },
                    onCompleted: _markAsCompleted,
                    onError: (error) {
                      _showSnackBar(error, AppColors.error);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Video Info Card
                  _buildVideoInfoCard(),

                  // Description
                  if (_currentContent.descriptionAr != null &&
                      _currentContent.descriptionAr!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDescriptionCard(),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          _buildVideoBottomBar(),
        ],
      ),
    );
  }

  /// Build video info card with title, tags, and progress
  Widget _buildVideoInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            _currentContent.titleAr,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Tags row
          Row(
            children: [
              _buildVideoTag(
                icon: Icons.play_circle_filled_rounded,
                text: 'فيديو شرح',
                color: _accentColor,
              ),
              const SizedBox(width: 10),
              if (_currentContent.videoDurationSeconds != null &&
                  _currentContent.videoDurationSeconds! > 0)
                _buildVideoTag(
                  icon: Icons.schedule_rounded,
                  text: _formatDuration(_currentContent.videoDurationSeconds!),
                  color: Colors.grey[600]!,
                  bgColor: Colors.grey[100],
                ),
              const SizedBox(width: 10),
              if (_currentContent.difficultyLevel != null)
                _buildVideoTag(
                  icon: Icons.signal_cellular_alt_rounded,
                  text: _getDifficultyText(_currentContent.difficultyLevel!),
                  color: _getDifficultyColor(_currentContent.difficultyLevel!),
                  bgColor: _getDifficultyColor(_currentContent.difficultyLevel!).withValues(alpha: 0.1),
                ),
            ],
          ),

          // Progress Section
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'التقدم في المشاهدة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(_currentProgress * 100).toInt()}%',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _currentProgress,
              minHeight: 8,
              backgroundColor: _accentColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
            ),
          ),
        ],
      ),
    );
  }

  /// Build description card
  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'وصف الدرس',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentContent.descriptionAr!,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoTag({
    required IconData icon,
    required String text,
    required Color color,
    Color? bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor ?? color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyText(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.easy:
        return 'سهل';
      case DifficultyLevel.medium:
        return 'متوسط';
      case DifficultyLevel.hard:
        return 'صعب';
    }
  }

  Color _getDifficultyColor(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.easy:
        return AppColors.successGreen;
      case DifficultyLevel.medium:
        return Colors.orange;
      case DifficultyLevel.hard:
        return AppColors.error;
    }
  }

  Widget _buildVideoBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            // Mark Complete Button
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _isCompleted ? null : _markAsCompleted,
                  icon: Icon(
                    _isCompleted ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                    size: 22,
                  ),
                  label: Text(
                    _isCompleted ? 'مكتمل' : 'إتمام',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _isCompleted ? AppColors.successGreen : _accentColor,
                      width: 1.5,
                    ),
                    foregroundColor: _isCompleted ? AppColors.successGreen : _accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Next Button
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _canNavigateToNext() ? _navigateToNext : null,
                  icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  label: const Text(
                    'الدرس التالي',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[500],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildNoContentState() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content info card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        _currentContent.titleAr,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Type and difficulty badges
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.category_outlined, size: 14, color: _accentColor),
                                const SizedBox(width: 4),
                                Text(
                                  _getContentTypeName(_currentContent.type),
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_currentContent.difficultyLevel != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(_currentContent.difficultyLevel!).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getDifficultyText(_currentContent.difficultyLevel!),
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getDifficultyColor(_currentContent.difficultyLevel!),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Description
                      if (_currentContent.descriptionAr != null && _currentContent.descriptionAr!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'وصف المحتوى',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentContent.descriptionAr!,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],

                      // Duration info
                      if (_currentContent.estimatedDurationMinutes != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text(
                              'المدة المقدرة: ${_currentContent.estimatedDurationMinutes} دقيقة',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // No file message
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange[700], size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'لا يوجد ملف أو فيديو مرفق بهذا المحتوى.\nيمكنك وضع علامة كمكتمل بعد مراجعة المعلومات.',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: Colors.orange[800],
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom bar with complete button
        _buildBottomBar(),
      ],
    );
  }

  String _getContentTypeName(ContentType type) {
    switch (type) {
      case ContentType.lesson:
        return 'درس';
      case ContentType.summary:
        return 'ملخص';
      case ContentType.exercise:
        return 'تمرين';
      case ContentType.test:
        return 'اختبار';
    }
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

  void _openFullscreen() {
    if (_localPath == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullscreenPdfViewer(
          filePath: _localPath!,
          title: widget.content.titleAr,
          initialPage: _currentPage,
          totalPages: _totalPages,
          accentColor: _accentColor,
          onPageChanged: (page) {
            if (mounted && _pdfController != null) {
              _pdfController!.setPage(page);
            }
          },
        ),
      ),
    );
  }

  bool _canNavigateToNext() {
    if (widget.allContents == null || widget.currentIndex == null) {
      return false;
    }
    return widget.currentIndex! < widget.allContents!.length - 1;
  }

  void _navigateToNext() {
    if (!_canNavigateToNext()) return;

    final nextIndex = widget.currentIndex! + 1;
    final nextContent = widget.allContents![nextIndex];

    final dio = sl<Dio>();
    final dataSource = ContentLibraryRemoteDataSource(dio: dio);
    final repository = ContentLibraryRepositoryImpl(remoteDataSource: dataSource);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ContentViewerBloc(repository: repository),
            ),
            BlocProvider(
              create: (context) => sl<BookmarkBloc>(),
            ),
          ],
          child: ContentViewerPage(
            content: nextContent,
            subject: widget.subject,
            subjectColor: widget.subjectColor,
            allContents: widget.allContents,
            currentIndex: nextIndex,
          ),
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
            // Top bar
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
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 8),
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
            // Bottom bar
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
                    _buildFullscreenButton(
                      icon: Icons.chevron_right_rounded,
                      onTap: _currentPage > 0
                          ? () => _pdfController?.setPage(_currentPage - 1)
                          : null,
                    ),
                    const SizedBox(width: 20),
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
