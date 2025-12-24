import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/course_lesson_entity.dart';
import '../../../videoplayer/videoplayer.dart';

/// Video Player Page for Courses
///
/// This page uses the unified video player from the videoplayer feature.
/// It provides video playback for course lessons with playlist navigation.
class VideoPlayerPage extends StatefulWidget {
  final CourseLessonEntity lesson;
  final List<CourseLessonEntity>? playlistLessons;

  const VideoPlayerPage({
    super.key,
    required this.lesson,
    this.playlistLessons,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late int _currentLessonIndex;

  @override
  void initState() {
    super.initState();
    _currentLessonIndex = _findCurrentLessonIndex();
  }

  int _findCurrentLessonIndex() {
    if (widget.playlistLessons != null) {
      final index = widget.playlistLessons!.indexWhere((l) => l.id == widget.lesson.id);
      return index == -1 ? 0 : index;
    }
    return 0;
  }

  CourseLessonEntity get _currentLesson {
    if (widget.playlistLessons != null && _currentLessonIndex < widget.playlistLessons!.length) {
      return widget.playlistLessons![_currentLessonIndex];
    }
    return widget.lesson;
  }

  bool get _hasNext =>
      widget.playlistLessons != null &&
      _currentLessonIndex < widget.playlistLessons!.length - 1;

  bool get _hasPrevious =>
      widget.playlistLessons != null && _currentLessonIndex > 0;

  void _goToNextLesson() {
    if (_hasNext) {
      setState(() {
        _currentLessonIndex++;
      });
    }
  }

  void _goToPreviousLesson() {
    if (_hasPrevious) {
      setState(() {
        _currentLessonIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = VideoConfig.course(
      videoUrl: _currentLesson.videoUrl ?? '',
      accentColorValue: AppColors.emerald500.toARGB32(),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            _currentLesson.titleAr,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            // Lesson index indicator
            if (widget.playlistLessons != null)
              Container(
                margin: const EdgeInsets.only(left: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentLessonIndex + 1}/${widget.playlistLessons!.length}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Video Player
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video player widget
                      VideoPlayerWidget(
                        key: ValueKey('video_${_currentLesson.id}'),
                        config: config,
                        accentColor: AppColors.emerald500,
                        onProgress: (progress) {
                          debugPrint('📊 Lesson ${_currentLesson.id} progress: ${(progress * 100).toStringAsFixed(1)}%');
                        },
                        onCompleted: () {
                          debugPrint('🎉 Lesson ${_currentLesson.id} completed!');
                          _showCompletedDialog();
                        },
                        onError: (error) {
                          debugPrint('❌ Video error: $error');
                        },
                      ),

                      const SizedBox(height: 24),

                      // Lesson info card
                      _buildLessonInfoCard(),

                      const SizedBox(height: 16),

                      // Description
                      if (_currentLesson.descriptionAr != null &&
                          _currentLesson.descriptionAr!.isNotEmpty)
                        _buildDescriptionCard(),
                    ],
                  ),
                ),
              ),

              // Bottom navigation bar
              _buildBottomBar(),
            ],
          ),
        ),
      ),
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
            _currentLesson.titleAr,
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
              if (_currentLesson.videoDurationSeconds > 0)
                _buildTag(
                  icon: Icons.schedule_rounded,
                  text: _currentLesson.formattedDuration,
                  color: Colors.grey[600]!,
                  bgColor: Colors.grey[100],
                ),
              const SizedBox(width: 10),
              _buildTag(
                icon: Icons.format_list_numbered_rounded,
                text: 'الدرس ${_currentLesson.order}',
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
            _currentLesson.descriptionAr!,
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

  Widget _buildBottomBar() {
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
            // Previous button
            if (_hasPrevious)
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _goToPreviousLesson,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                    label: const Text(
                      'السابق',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            if (_hasPrevious && _hasNext) const SizedBox(width: 12),
            // Next button
            Expanded(
              flex: _hasPrevious ? 2 : 1,
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _hasNext ? _goToNextLesson : null,
                  icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  label: Text(
                    _hasNext ? 'الدرس التالي' : 'لا يوجد درس تالي',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
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
