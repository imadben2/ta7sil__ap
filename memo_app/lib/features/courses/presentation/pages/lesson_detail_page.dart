import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/course_lesson_entity.dart';
import '../../domain/entities/course_module_entity.dart';
import '../../domain/entities/lesson_attachment_entity.dart';
import '../bloc/courses/courses_bloc.dart';
import '../bloc/courses/courses_event.dart';
import '../bloc/courses/courses_state.dart';
import '../widgets/attachment_card.dart';
import '../../../videoplayer/videoplayer.dart';

/// صفحة تفاصيل الدرس الموحدة - عرض الفيديو مباشرة مع المعلومات والمرفقات
/// Unified lesson page with embedded video player (design from video_player_page)
class LessonDetailPage extends StatefulWidget {
  final int courseId;
  final int lessonId;

  const LessonDetailPage({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  CourseLessonEntity? _lesson;
  List<CourseModuleEntity>? _modules;
  bool _isLoading = true;
  String? _errorMessage;

  // All lessons in the course for navigation
  List<CourseLessonEntity> _allLessons = [];
  int _currentLessonIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final bloc = context.read<CoursesBloc>();
    bloc.add(LoadLessonDetailsEvent(lessonId: widget.lessonId));
    bloc.add(LoadCourseModulesEvent(courseId: widget.courseId));
  }

  void _extractAllLessons() {
    if (_modules == null) return;

    _allLessons = [];
    for (final module in _modules!) {
      if (module.lessons != null) {
        _allLessons.addAll(module.lessons!);
      }
    }

    _currentLessonIndex = _allLessons.indexWhere((l) => l.id == widget.lessonId);

    // Update the lesson with real data from modules if we find it
    if (_currentLessonIndex >= 0 && _currentLessonIndex < _allLessons.length) {
      _lesson = _allLessons[_currentLessonIndex];
    }
  }

  bool get _hasNext =>
      _allLessons.isNotEmpty &&
      _currentLessonIndex >= 0 &&
      _currentLessonIndex < _allLessons.length - 1;

  bool get _hasPrevious =>
      _allLessons.isNotEmpty && _currentLessonIndex > 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: BlocListener<CoursesBloc, CoursesState>(
          listener: (context, state) {
            if (state is LessonDetailsLoaded) {
              setState(() {
                if (_lesson == null || _lesson!.titleAr == 'جاري تحميل الدرس...') {
                  _lesson = state.lesson;
                }
                _isLoading = false;
                _errorMessage = null;
              });
            } else if (state is CourseModulesLoaded) {
              setState(() {
                _modules = state.modules;
                _extractAllLessons();
                _isLoading = false;
              });
            } else if (state is CoursesError) {
              setState(() {
                _errorMessage = state.message;
                _isLoading = false;
              });
            }
          },
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildErrorState(_errorMessage!);
    }

    if (_isLoading || _lesson == null) {
      return _buildLoadingState();
    }

    return Column(
      children: [
        // App bar
        _buildAppBar(),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video player widget
                _buildVideoPlayer(),

                const SizedBox(height: 24),

                // Lesson info card
                _buildLessonInfoCard(),

                const SizedBox(height: 16),

                // Description card
                if (_lesson!.descriptionAr != null && _lesson!.descriptionAr!.isNotEmpty)
                  _buildDescriptionCard(),

                // Attachments section
                if (_lesson!.hasAttachments) ...[
                  const SizedBox(height: 16),
                  _buildAttachmentsSection(),
                ],

                // Quiz section
                if (_lesson!.hasQuiz) ...[
                  const SizedBox(height: 16),
                  _buildQuizSection(),
                ],

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Bottom navigation bar
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.black,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              Expanded(
                child: Text(
                  _lesson?.titleAr ?? 'الدرس',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Lesson index indicator
              if (_allLessons.isNotEmpty && _currentLessonIndex >= 0)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentLessonIndex + 1}/${_allLessons.length}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    final videoUrl = _lesson?.videoUrl ?? '';

    if (videoUrl.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam_off_rounded, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'الفيديو غير متاح',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final config = VideoConfig.course(
      videoUrl: videoUrl,
      accentColorValue: AppColors.emerald500.toARGB32(),
    );

    return VideoPlayerWidget(
      key: ValueKey('video_${_lesson!.id}'),
      config: config,
      accentColor: AppColors.emerald500,
      onProgress: (progress) {
        debugPrint('📊 Lesson ${_lesson!.id} progress: ${(progress * 100).toStringAsFixed(1)}%');
      },
      onCompleted: () {
        debugPrint('🎉 Lesson ${_lesson!.id} completed!');
        _showCompletedDialog();
      },
      onError: (error) {
        debugPrint('❌ Video error: $error');
      },
    );
  }

  Widget _buildLessonInfoCard() {
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
          Text(
            _lesson!.titleAr,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTag(
                icon: Icons.play_circle_filled_rounded,
                text: 'درس',
                color: AppColors.emerald500,
              ),
              const SizedBox(width: 10),
              if (_lesson!.videoDurationSeconds > 0)
                _buildTag(
                  icon: Icons.schedule_rounded,
                  text: _lesson!.formattedDuration,
                  color: Colors.grey[600]!,
                  bgColor: Colors.grey[100],
                ),
              const SizedBox(width: 10),
              _buildTag(
                icon: Icons.format_list_numbered_rounded,
                text: 'الدرس ${_lesson!.order}',
                color: AppColors.emerald500,
                bgColor: AppColors.emerald500.withValues(alpha: 0.1),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _lesson!.descriptionAr!,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String text,
    required Color color,
    Color? bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor ?? color.withValues(alpha: 0.15),
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

  Widget _buildAttachmentsSection() {
    final attachments = _lesson!.attachments ?? [];
    if (attachments.isEmpty) return const SizedBox.shrink();

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.emerald500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.attach_file_rounded, color: AppColors.emerald500, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'المرفقات',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${attachments.length} ملفات متاحة للتحميل',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...attachments.map((attachment) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AttachmentCard(
              attachment: attachment,
              onPreview: () => _previewAttachment(attachment),
              onDownload: () => _downloadAttachment(attachment),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildQuizSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.emerald500.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald500.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.emerald500,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.quiz_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'اختبار الدرس',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'اختبر فهمك للدرس',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.emerald500.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'اختبار قصير',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'تأكد من مشاهدة الفيديو أولاً',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _startQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald500,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'بدء الاختبار',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            // Lesson progress indicator
            if (_allLessons.isNotEmpty && _currentLessonIndex >= 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'الدرس ${_currentLessonIndex + 1} من ${_allLessons.length}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            // Buttons row
            Row(
              children: [
                // Previous button (السابق)
                if (_hasPrevious)
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _goToPreviousLesson,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: const Text(
                          'السابق',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_hasPrevious) const SizedBox(width: 8),
                // Complete button (إتمام) - smaller
                SizedBox(
                  width: 80,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _markAsCompleted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald500,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_rounded, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'إتمام',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Next button (التالي)
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _hasNext ? _goToNextLesson : null,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: Text(
                        _hasNext ? 'التالي' : 'لا يوجد تالي',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald500,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[500],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  void _markAsCompleted() {
    // Mark lesson as completed and go to next
    _showCompletedDialog();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.emerald500),
    );
  }

  Widget _buildErrorState(String message) {
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
              child: Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 16),
            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald500,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== Actions ==========

  void _previewAttachment(LessonAttachmentEntity attachment) {
    if (attachment.isPdf) {
      context.push('/pdf-viewer', extra: attachment);
    } else if (attachment.isImage) {
      _showImageViewer(attachment);
    } else {
      _downloadAttachment(attachment);
    }
  }

  void _downloadAttachment(LessonAttachmentEntity attachment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'جاري تحميل: ${attachment.fileNameAr}',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppColors.emerald500,
      ),
    );
  }

  void _showImageViewer(LessonAttachmentEntity attachment) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  attachment.fileUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white, size: 64),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startQuiz() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'سيتم إضافة الاختبار قريباً',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppColors.emerald500,
      ),
    );
  }

  void _goToPreviousLesson() {
    if (_currentLessonIndex > 0) {
      final previousLesson = _allLessons[_currentLessonIndex - 1];
      context.pushReplacement(
        '/courses/${widget.courseId}/lessons/${previousLesson.id}',
      );
    }
  }

  void _goToNextLesson() {
    if (_currentLessonIndex < _allLessons.length - 1) {
      final nextLesson = _allLessons[_currentLessonIndex + 1];
      context.pushReplacement(
        '/courses/${widget.courseId}/lessons/${nextLesson.id}',
      );
    }
  }

  void _showCompletedDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.emerald500.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.emerald500,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'تهانينا!',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'لقد أكملت هذا الدرس بنجاح!',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            if (_hasNext)
              TextButton.icon(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _goToNextLesson();
                },
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text(
                  'الدرس التالي',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'حسناً',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
