import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/academic_entities.dart';
import '../../../auth/domain/usecases/get_academic_phases_usecase.dart';
import '../../../courses/domain/entities/course_entity.dart';
import '../../../courses/presentation/bloc/courses/courses_bloc.dart';
import '../../../courses/presentation/bloc/courses/courses_event.dart';
import '../../../courses/presentation/bloc/courses/courses_state.dart';

/// Modern Courses view - صفحة الدورات الحديثة
class CoursesView extends StatefulWidget {
  const CoursesView({super.key});

  @override
  State<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<CoursesView> {
  final PageController _featuredPageController = PageController(viewportFraction: 0.85);
  int _currentFeaturedPage = 0;
  int? _selectedPhaseId;
  bool? _isFreeFilter;
  String _sortBy = 'created_at';

  @override
  void initState() {
    super.initState();
    context.read<CoursesBloc>().add(const LoadFeaturedCoursesEvent(limit: 10));
    context.read<CoursesBloc>().add(const LoadCoursesEvent());
  }

  @override
  void dispose() {
    _featuredPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
        onRefresh: () async {
          context.read<CoursesBloc>().add(const LoadFeaturedCoursesEvent(limit: 10));
          context.read<CoursesBloc>().add(const LoadCoursesEvent());
          await Future.delayed(const Duration(seconds: 1));
        },
        color: const Color(0xFF667EEA),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Modern Header
            SliverToBoxAdapter(child: _buildHeader()),

            // Featured Courses Section
            SliverToBoxAdapter(child: _buildSectionHeader('الدورات المميزة', Icons.star_rounded, const Color(0xFFF59E0B))),
            SliverToBoxAdapter(child: _buildFeaturedCourses()),

            // All Courses Section
            SliverToBoxAdapter(child: _buildSectionHeader('جميع الدورات', Icons.school_rounded, const Color(0xFF667EEA))),
            SliverToBoxAdapter(child: _buildAllCourses()),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Filter Button
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.filter_list_rounded,
                size: 22,
                color: Colors.white,
              ),
            ),
          ),

          // Title with gradient
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ).createShader(bounds),
            child: const Text(
              'الدورات',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Search Button
          GestureDetector(
            onTap: () => context.push('/courses'),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 22,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // View All Button
          GestureDetector(
            onTap: () => context.push('/courses'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'عرض الكل',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_back_ios_rounded, size: 12, color: color),
                ],
              ),
            ),
          ),

          // Title with Icon
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCourses() {
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, state) {
        List<CourseEntity> courses = [];

        if (state is CoursesLoaded && state.featuredCourses.isNotEmpty) {
          courses = state.featuredCourses;
        } else if (state is FeaturedCoursesLoaded && state.courses.isNotEmpty) {
          courses = state.courses;
        }

        if (courses.isEmpty) {
          if (state is CoursesLoading) {
            return _buildLoadingState();
          }
          return _buildEmptyState(
            icon: Icons.video_library_outlined,
            title: 'لا توجد دورات مميزة حالياً',
          );
        }

        return Column(
          children: [
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _featuredPageController,
                onPageChanged: (index) {
                  setState(() => _currentFeaturedPage = index);
                },
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  return _buildFeaturedCard(courses[index], index);
                },
              ),
            ),
            const SizedBox(height: 16),
            // Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                courses.length > 5 ? 5 : courses.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentFeaturedPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: _currentFeaturedPage == index
                        ? const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          )
                        : null,
                    color: _currentFeaturedPage == index
                        ? null
                        : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeaturedCard(CourseEntity course, int index) {
    final gradientColors = _getGradientColors(course.subjectNameAr);

    return GestureDetector(
      onTap: () => context.push('/courses/${course.id}'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(
          left: 8,
          right: 8,
          top: _currentFeaturedPage == index ? 0 : 12,
          bottom: _currentFeaturedPage == index ? 12 : 0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background Gradient (shown when no image)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                ),
              ),

              // Image if available - full cover
              if (course.thumbnailUrl != null)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: course.thumbnailUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const SizedBox(),
                    errorWidget: (context, url, error) => const SizedBox(),
                  ),
                ),

              // Only show content when NO image
              if (course.thumbnailUrl == null) ...[
                // Content (RTL) - only when no image
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          course.titleAr,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Stats Row (RTL: Price on right, stats on left)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Rating & Lessons (left side in RTL)
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFBBF24)),
                                      const SizedBox(width: 4),
                                      Text(
                                        course.averageRating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.menu_book_rounded, size: 14, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${course.totalLessons}',
                                        style: const TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Price (right side in RTL)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                course.isFreeAccess ? 'مجاني' : '${course.priceDzd} دج',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: course.isFreeAccess
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF667EEA),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Featured Badge - small, top right (always shown)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 10, color: Colors.white),
                      SizedBox(width: 3),
                      Text(
                        'مميزة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

  Widget _buildAllCourses() {
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, state) {
        if (state is CoursesLoading) {
          return _buildLoadingState();
        }

        List<CourseEntity> courses = [];
        if (state is CoursesLoaded) {
          courses = state.courses;
        }

        if (courses.isEmpty) {
          return _buildEmptyState(
            icon: Icons.school_outlined,
            title: 'لا توجد دورات متاحة',
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: courses.take(5).map((course) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildCourseListItem(course),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCourseListItem(CourseEntity course) {
    final gradientColors = _getGradientColors(course.subjectNameAr);

    return GestureDetector(
      onTap: () => context.push('/courses/${course.id}'),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            // Image Section (Right side for RTL)
            Container(
              width: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  // Cover Image
                  if (course.thumbnailUrl != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                      child: CachedNetworkImage(
                        imageUrl: course.thumbnailUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: gradientColors,
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.school_rounded, color: Colors.white54, size: 32),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: gradientColors,
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.school_rounded, color: Colors.white54, size: 32),
                          ),
                        ),
                      ),
                    )
                  else
                    // Default gradient with icon when no thumbnail
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: gradientColors,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.school_rounded, color: Colors.white54, size: 32),
                        ),
                      ),
                    ),

                  // Gradient Overlay for better visibility
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          gradientColors[1].withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),

                  // Lessons Badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.play_lesson_rounded, size: 10, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            '${course.totalLessons}',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Section (Left side for RTL)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      course.titleAr,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        height: 1.3,
                      ),
                    ),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      textDirection: TextDirection.rtl,
                      children: [
                        // Price (Right in RTL)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: course.isFreeAccess
                                ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                : const Color(0xFF667EEA).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            course.isFreeAccess ? 'مجاني' : '${course.priceDzd} دج',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: course.isFreeAccess
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF667EEA),
                            ),
                          ),
                        ),

                        // Rating (Left in RTL)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 3),
                              Text(
                                course.averageRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB45309),
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
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF667EEA).withValues(alpha: 0.1),
                    const Color(0xFF764BA2).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'جاري التحميل...',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667EEA).withValues(alpha: 0.1),
                  const Color(0xFF764BA2).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, size: 36, color: const Color(0xFF667EEA)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        selectedPhaseId: _selectedPhaseId,
        isFreeFilter: _isFreeFilter,
        sortBy: _sortBy,
        onApply: (phaseId, isFree, sort) {
          setState(() {
            _selectedPhaseId = phaseId;
            _isFreeFilter = isFree;
            _sortBy = sort;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _applyFilters() {
    context.read<CoursesBloc>().add(
      LoadCoursesEvent(
        academicPhaseId: _selectedPhaseId,
        isFree: _isFreeFilter,
        sortBy: _sortBy,
      ),
    );
    Navigator.pop(context);
  }

  List<Color> _getGradientColors(String subject) {
    final gradients = {
      'رياضيات': [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      'فيزياء': [const Color(0xFFF093FB), const Color(0xFFF5576C)],
      'كيمياء': [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
      'علوم': [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
      'عربية': [const Color(0xFFFA709A), const Color(0xFFFEE140)],
      'فرنسية': [const Color(0xFF5A67D8), const Color(0xFF9F7AEA)],
      'إنجليزية': [const Color(0xFF38B2AC), const Color(0xFF4FD1C5)],
      'تاريخ': [const Color(0xFF9F7AEA), const Color(0xFFB794F4)],
      'جغرافيا': [const Color(0xFF0BC5EA), const Color(0xFF00B5D8)],
      'فلسفة': [const Color(0xFFD69E2E), const Color(0xFFF6AD55)],
      'إسلامية': [const Color(0xFF48BB78), const Color(0xFF68D391)],
    };

    for (final entry in gradients.entries) {
      if (subject.contains(entry.key)) {
        return entry.value;
      }
    }
    return [const Color(0xFF667EEA), const Color(0xFF764BA2)];
  }
}

/// Filter Bottom Sheet
class _FilterBottomSheet extends StatefulWidget {
  final int? selectedPhaseId;
  final bool? isFreeFilter;
  final String sortBy;
  final Function(int?, bool?, String) onApply;

  const _FilterBottomSheet({
    this.selectedPhaseId,
    this.isFreeFilter,
    required this.sortBy,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late int? _selectedPhaseId;
  late bool? _isFreeFilter;
  late String _sortBy;
  List<AcademicPhase> _phases = [];
  bool _isLoadingPhases = true;

  @override
  void initState() {
    super.initState();
    _selectedPhaseId = widget.selectedPhaseId;
    _isFreeFilter = widget.isFreeFilter;
    _sortBy = widget.sortBy;
    _loadPhases();
  }

  Future<void> _loadPhases() async {
    final useCase = sl<GetAcademicPhasesUseCase>();
    final result = await useCase();

    result.fold(
      (failure) {
        setState(() => _isLoadingPhases = false);
      },
      (response) {
        setState(() {
          _phases = response.phases;
          _isLoadingPhases = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                ),
              ),
              Row(
                children: [
                  const Text(
                    'تصفية الدورات',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.filter_list_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Level Filter (from API)
          _buildPhasesSection(),

          const SizedBox(height: 24),

          // Price Filter
          _buildFilterSection(
            title: 'السعر',
            icon: Icons.payments_rounded,
            options: [
              _FilterOption(label: 'مجانية', value: 'free'),
              _FilterOption(label: 'مدفوعة', value: 'paid'),
            ],
            selectedValue: _isFreeFilter == true
                ? 'free'
                : _isFreeFilter == false
                    ? 'paid'
                    : null,
            onSelect: (value) => setState(() {
              _isFreeFilter = value == 'free'
                  ? true
                  : value == 'paid'
                      ? false
                      : null;
            }),
          ),

          const SizedBox(height: 24),

          // Sort By
          _buildFilterSection(
            title: 'الترتيب',
            icon: Icons.sort_rounded,
            options: [
              _FilterOption(label: 'الأحدث', value: 'created_at'),
              _FilterOption(label: 'الأعلى تقييماً', value: 'average_rating'),
              _FilterOption(label: 'الأكثر التحاقاً', value: 'total_students'),
            ],
            selectedValue: _sortBy,
            onSelect: (value) => setState(() => _sortBy = value ?? 'created_at'),
            allowDeselect: false,
          ),

          const SizedBox(height: 32),

          // Apply Button
          GestureDetector(
            onTap: () {
              widget.onApply(_selectedPhaseId, _isFreeFilter, _sortBy);
            },
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'تطبيق الفلاتر',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPhasesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'المستوى',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.school_rounded, color: Color(0xFF667EEA), size: 22),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingPhases)
          const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
              ),
            ),
          )
        else if (_phases.isEmpty)
          const Text(
            'لا توجد مستويات',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: _phases.map((phase) {
              final isSelected = _selectedPhaseId == phase.id;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedPhaseId = null;
                    } else {
                      _selectedPhaseId = phase.id;
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          )
                        : null,
                    color: isSelected ? null : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    phase.nameAr,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required List<_FilterOption> options,
    String? selectedValue,
    required Function(String?) onSelect,
    bool allowDeselect = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, color: const Color(0xFF667EEA), size: 22),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.end,
          children: options.map((option) {
            final isSelected = selectedValue == option.value;
            return GestureDetector(
              onTap: () {
                if (allowDeselect && isSelected) {
                  onSelect(null);
                } else {
                  onSelect(option.value);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        )
                      : null,
                  color: isSelected ? null : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _FilterOption {
  final String label;
  final String value;

  const _FilterOption({required this.label, required this.value});
}
