import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  int _selectedTabIndex = 0;
  final PageController _featuredPageController = PageController(viewportFraction: 0.85);
  int _currentFeaturedPage = 0;

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

            // Tab Selector
            SliverToBoxAdapter(child: _buildTabSelector()),

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
            onTap: () => context.push('/courses'),
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
                Icons.tune_rounded,
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

  Widget _buildTabSelector() {
    final tabs = ['الكل', 'المميزة', 'المجانية', 'المدفوعة'];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedTabIndex = index);
              _onTabChanged(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF667EEA).withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onTabChanged(int index) {
    switch (index) {
      case 0:
        context.read<CoursesBloc>().add(const LoadCoursesEvent());
        break;
      case 1:
        context.read<CoursesBloc>().add(const LoadFeaturedCoursesEvent(limit: 10));
        break;
      case 2:
        context.read<CoursesBloc>().add(const LoadCoursesEvent(isFree: true));
        break;
      case 3:
        context.read<CoursesBloc>().add(const LoadCoursesEvent(isFree: false));
        break;
    }
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
              // Background Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                ),
              ),

              // Image if available
              if (course.thumbnailUrl != null)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: course.thumbnailUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const SizedBox(),
                    errorWidget: (context, url, error) => const SizedBox(),
                  ),
                ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        gradientColors[1].withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Featured Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'دورة مميزة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.star_rounded, size: 14, color: Colors.white),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

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

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
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

                        // Rating & Lessons
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
                                  Text(
                                    '${course.totalLessons}',
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.play_lesson_rounded, size: 14, color: Colors.white),
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
                                  Text(
                                    course.averageRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFBBF24)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Play Button
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: gradientColors[0],
                    size: 30,
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

                  // Play Icon
                  Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: gradientColors[0],
                        size: 26,
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
