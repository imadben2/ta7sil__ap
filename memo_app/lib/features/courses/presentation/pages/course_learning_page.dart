import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/course_module_entity.dart';
import '../bloc/courses/courses_bloc.dart';
import '../bloc/courses/courses_state.dart';

/// صفحة متابعة التعلم - تعرض محتوى الدورة فقط (الوحدات والدروس)
class CourseLearningPage extends StatefulWidget {
  final int courseId;

  const CourseLearningPage({super.key, required this.courseId});

  @override
  State<CourseLearningPage> createState() => _CourseLearningPageState();
}

class _CourseLearningPageState extends State<CourseLearningPage> {
  CourseEntity? _course;
  List<CourseModuleEntity>? _modules;
  bool _isLoading = true;
  String? _errorMessage;

  // Track expanded modules - all expanded by default
  Set<int> _expandedModules = {};

  // Colors - Using AppColors for consistency
  static const _primaryPurple = AppColors.primary;
  static const _secondaryPurple = AppColors.primaryDark;
  static const _bgColor = AppColors.slateBackground;
  static const _cardColor = AppColors.surface;
  static const _textPrimary = AppColors.slate900;
  static const _textSecondary = AppColors.slate600;
  static const _textMuted = AppColors.slate500;
  static const _borderColor = AppColors.borderLight;
  static const _completedColor = AppColors.emerald500;

  @override
  void initState() {
    super.initState();
  }

  void _initExpandedModules() {
    // Keep all modules collapsed by default
    _expandedModules = {};
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: BlocListener<CoursesBloc, CoursesState>(
          listener: (context, state) {
            if (state is CourseDetailsLoaded) {
              setState(() {
                _course = state.course;
                _isLoading = _modules == null;
                _errorMessage = null;
              });
            } else if (state is CourseModulesLoaded) {
              setState(() {
                _modules = state.modules;
                _initExpandedModules();
                _isLoading = _course == null;
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

    if (_isLoading || _course == null || _modules == null) {
      return _buildLoadingState();
    }

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(),
            // Spacing between header and first module
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            _buildModulesList(),
            // Bottom padding for the action button
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildHeader() {
    final totalLessons = _modules!.fold<int>(
      0, (sum, m) => sum + (m.lessons?.length ?? 0),
    );

    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      elevation: 0,
      backgroundColor: _primaryPurple,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primaryPurple, _secondaryPurple],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Course Title
                  Text(
                    _course!.titleAr,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Progress indicator
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_circle_outline_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$totalLessons درس',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _course!.formattedDuration,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModulesList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final module = _modules![index];
          return _buildModuleCard(module, index);
        },
        childCount: _modules!.length,
      ),
    );
  }

  Widget _buildModuleCard(CourseModuleEntity module, int index) {
    final isExpanded = _expandedModules.contains(module.id);
    final lessonsCount = module.lessons?.length ?? 0;

    // Calculate module duration
    int moduleDuration = 0;
    for (var lesson in module.lessons ?? []) {
      moduleDuration += (lesson.videoDurationSeconds as num).toInt();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? _primaryPurple.withOpacity(0.3) : _borderColor,
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: _primaryPurple.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Module Header
          InkWell(
            onTap: () => setState(() {
              if (isExpanded) {
                _expandedModules.remove(module.id);
              } else {
                _expandedModules.add(module.id);
              }
            }),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Module number
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: isExpanded
                          ? const LinearGradient(
                              colors: [_primaryPurple, _secondaryPurple],
                            )
                          : null,
                      color: isExpanded ? null : _primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isExpanded ? Colors.white : _primaryPurple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Module info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.titleAr,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isExpanded ? _primaryPurple : _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.play_circle_outline_rounded,
                              size: 14,
                              color: _textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$lessonsCount درس',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: _textMuted,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: _textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDuration(moduleDuration),
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Expand/Collapse icon
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? _primaryPurple.withOpacity(0.1)
                            : _bgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: isExpanded ? _primaryPurple : _textMuted,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Lessons list
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: isExpanded && module.lessons != null
                ? Column(
                    children: [
                      const Divider(height: 1, color: _borderColor),
                      ...module.lessons!.asMap().entries.map((entry) {
                        final lessonIndex = entry.key;
                        final lesson = entry.value;
                        return _buildLessonTile(lesson, lessonIndex);
                      }),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonTile(dynamic lesson, int lessonIndex) {
    return InkWell(
      onTap: () => context.push('/courses/${widget.courseId}/lessons/${lesson.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: _borderColor.withOpacity(0.5)),
          ),
        ),
        child: Row(
          children: [
            // Play icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _primaryPurple.withOpacity(0.1),
                    _secondaryPurple.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: _primaryPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Lesson info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.titleAr,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: _textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(lesson.videoDurationSeconds),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: _textMuted,
                        ),
                      ),
                      if (lesson.isFreePreview) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _completedColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'مجاني',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _completedColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Arrow
            const Icon(
              Icons.arrow_back_ios_rounded,
              size: 14,
              color: _textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: _cardColor,
          border: const Border(
            top: BorderSide(color: _borderColor),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_primaryPurple, _secondaryPurple],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _primaryPurple.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to first lesson
                if (_modules != null && _modules!.isNotEmpty) {
                  final lessons = _modules!.first.lessons;
                  if (lessons != null && lessons.isNotEmpty) {
                    context.push('/courses/${widget.courseId}/lessons/${lessons.first.id}');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'متابعة من حيث توقفت',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_primaryPurple),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'جاري تحميل المحتوى...',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
        ],
      ),
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
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'رجوع',
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

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '$minutes دقيقة';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '$hours ساعة';
    return '$hours:${remainingMinutes.toString().padLeft(2, '0')}';
  }
}
