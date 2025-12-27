import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/course_entity.dart';
import '../bloc/courses/courses_bloc.dart';
import '../bloc/courses/courses_event.dart';
import '../bloc/courses/courses_state.dart';
import '../widgets/course_card_shimmer.dart';

/// Modern Courses Page - صفحة الدورات الحديثة
class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  Timer? _debounceTimer;
  String? _selectedLevel;
  bool? _isFreeFilter;
  String _sortBy = 'created_at';
  bool _hasLoadedData = false; // Prevent duplicate API calls

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Load courses only once - prevent duplicate calls on widget rebuild
    if (!_hasLoadedData) {
      _hasLoadedData = true;
      // Use addPostFrameCallback to ensure context is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final bloc = context.read<CoursesBloc>();
          // Check if data is already loaded to avoid unnecessary API calls
          if (bloc.state is CoursesInitial || bloc.state is CoursesError) {
            // OPTIMIZED: Single API call for both featured and all courses
            bloc.add(const LoadAllCoursesDataEvent());
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isEmpty) {
        // Reset to full data when search is cleared
        context.read<CoursesBloc>().add(const LoadAllCoursesDataEvent());
      } else {
        context.read<CoursesBloc>().add(SearchCoursesEvent(query: query));
      }
    });
  }

  void _applyFilters() {
    context.read<CoursesBloc>().add(
      LoadCoursesEvent(
        level: _selectedLevel,
        isFree: _isFreeFilter,
        sortBy: _sortBy,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // OPTIMIZED: Single API call for refresh
            context.read<CoursesBloc>().add(const LoadAllCoursesDataEvent());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: AppColors.blue500,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Modern Header
              SliverToBoxAdapter(child: _buildModernHeader()),

              // Search Bar
              SliverToBoxAdapter(child: _buildSearchBar()),

              // Content
              BlocBuilder<CoursesBloc, CoursesState>(
                builder: (context, state) {
                  if (state is CoursesLoading) {
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: const CourseCardShimmer(),
                          ),
                          childCount: 5,
                        ),
                      ),
                    );
                  }

                  if (state is CoursesError) {
                    return SliverFillRemaining(
                      child: _buildErrorState(state.message),
                    );
                  }

                  return _buildContent(state);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          _buildIconButton(
            icon: Icons.arrow_forward_ios_rounded,
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Filter Button
          _buildIconButton(
            icon: Icons.tune_rounded,
            onTap: _showFilterSheet,
            isGradient: true,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isGradient = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: isGradient
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          color: isGradient ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isGradient
                  ? const Color(0xFF667EEA).withOpacity(0.3)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: isGradient ? Colors.white : const Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15,
          color: Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          hintText: 'ابحث عن دورة...',
          hintTextDirection: TextDirection.rtl,
          hintStyle: TextStyle(
            fontFamily: 'Cairo',
            color: const Color(0xFF94A3B8),
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(14),
            child: const Icon(
              Icons.search_rounded,
              color: Color(0xFF94A3B8),
              size: 22,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                      size: 14,
                    ),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                    setState(() {});
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Color(0xFF667EEA),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(CoursesState state) {
    if (state is CoursesLoaded) {
      // Show both featured and all courses sections
      return _buildBothSections(state);
    } else if (state is FeaturedCoursesLoaded) {
      return _buildFeaturedCoursesGrid(state.courses);
    } else if (state is CoursesSearchResultsLoaded) {
      return _buildSearchResults(state);
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  /// Build both Featured Courses and All Courses sections
  Widget _buildBothSections(CoursesLoaded state) {
    return SliverList(
      delegate: SliverChildListDelegate([
        // Featured Courses Section
        if (state.featuredCourses.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'الدورات المميزة',
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFF59E0B),
            onViewAll: () {
              // Navigate to featured courses view
            },
          ),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.featuredCourses.length,
              itemBuilder: (context, index) {
                final course = state.featuredCourses[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: SizedBox(
                    width: 180,
                    child: _ModernCourseCard(
                      course: course,
                      onTap: () => context.push('/courses/${course.id}'),
                      isFeatured: true,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],

        // All Courses Section
        _buildSectionHeader(
          title: 'جميع الدورات',
          icon: Icons.grid_view_rounded,
          iconColor: const Color(0xFF667EEA),
          onViewAll: () {
            // Already showing all
          },
        ),

        // All Courses List
        if (state.courses.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildEmptyState(),
          )
        else
          ...state.courses.map((course) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _ModernCourseListItem(
                  course: course,
                  onTap: () => context.push('/courses/${course.id}'),
                ),
              )),

        const SizedBox(height: 100),
      ]),
    );
  }

  /// Build section header with title and view all button
  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // View All Button
          GestureDetector(
            onTap: onViewAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 12,
                    color: const Color(0xFF667EEA),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'عرض الكل',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF667EEA),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Title
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCoursesGrid(List<CourseEntity> courses) {
    if (courses.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final course = courses[index];
            return _ModernCourseCard(
              course: course,
              onTap: () => context.push('/courses/${course.id}'),
              isFeatured: true,
            );
          },
          childCount: courses.length,
        ),
      ),
    );
  }

  Widget _buildCoursesList(List<CourseEntity> courses) {
    if (courses.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final course = courses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ModernCourseListItem(
                course: course,
                onTap: () => context.push('/courses/${course.id}'),
              ),
            );
          },
          childCount: courses.length,
        ),
      ),
    );
  }

  Widget _buildSearchResults(CoursesSearchResultsLoaded state) {
    return SliverList(
      delegate: SliverChildListDelegate([
        // Search Info
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF667EEA).withOpacity(0.1),
                const Color(0xFF764BA2).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF667EEA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'نتائج البحث عن "${state.query}"',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF667EEA),
                      ),
                    ),
                    Text(
                      '${state.courses.length} نتيجة',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (state.courses.isEmpty)
          _buildEmptyState(
            icon: Icons.search_off_rounded,
            title: 'لم يتم العثور على نتائج',
            subtitle: 'جرّب كلمات بحث مختلفة',
          )
        else
          ...state.courses.map((course) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _ModernCourseListItem(
                  course: course,
                  onTap: () => context.push('/courses/${course.id}'),
                ),
              )),

        const SizedBox(height: 100),
      ]),
    );
  }

  Widget _buildEmptyState({
    IconData icon = Icons.school_rounded,
    String title = 'لا توجد دورات متاحة حالياً',
    String subtitle = 'جرّب تغيير معايير البحث',
  }) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667EEA).withOpacity(0.1),
                  const Color(0xFF764BA2).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              size: 48,
              color: const Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                context.read<CoursesBloc>().add(const LoadAllCoursesDataEvent());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'إعادة المحاولة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
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
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        selectedLevel: _selectedLevel,
        isFreeFilter: _isFreeFilter,
        sortBy: _sortBy,
        onApply: (level, isFree, sort) {
          setState(() {
            _selectedLevel = level;
            _isFreeFilter = isFree;
            _sortBy = sort;
          });
          _applyFilters();
        },
      ),
    );
  }
}

/// Modern Course Card Widget
class _ModernCourseCard extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onTap;
  final bool isFeatured;

  const _ModernCourseCard({
    required this.course,
    required this.onTap,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _getGradientColors(),
                        ),
                      ),
                      child: course.thumbnailUrl != null
                          ? CachedNetworkImage(
                              imageUrl: course.thumbnailUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => _buildPlaceholder(),
                              errorWidget: (context, url, error) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                    ),
                  ),

                  // Featured Badge
                  if (isFeatured)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'مميز',
                              style: TextStyle(
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

            // Content Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        height: 1.3,
                      ),
                    ),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                course.averageRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Price
                        Text(
                          course.isFreeAccess ? 'مجاني' : '${course.priceDzd} دج',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: course.isFreeAccess
                                ? const Color(0xFF10B981)
                                : const Color(0xFF667EEA),
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

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.school_rounded,
        size: 40,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }

  List<Color> _getGradientColors() {
    final subject = course.subjectNameAr;
    final gradients = {
      'رياضيات': [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      'فيزياء': [const Color(0xFFF093FB), const Color(0xFFF5576C)],
      'كيمياء': [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
      'علوم': [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
      'عربية': [const Color(0xFFFA709A), const Color(0xFFFEE140)],
    };

    for (final entry in gradients.entries) {
      if (subject.contains(entry.key)) {
        return entry.value;
      }
    }
    return [const Color(0xFF667EEA), const Color(0xFF764BA2)];
  }
}

/// Modern Course List Item Widget
class _ModernCourseListItem extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onTap;

  const _ModernCourseListItem({
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              // Image Section (now on the right in RTL)
              Container(
                width: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getGradientColors(),
                  ),
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(24),
                  ),
                ),
                child: Stack(
                  children: [
                    if (course.thumbnailUrl != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(24),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: course.thumbnailUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => _buildPlaceholder(),
                          errorWidget: (context, url, error) => _buildPlaceholder(),
                        ),
                      )
                    else
                      _buildPlaceholder(),

                    // Lessons Count
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${course.totalLessons}',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.play_lesson_rounded,
                              color: Colors.white,
                              size: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
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

                    // Instructor
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            course.instructorName,
                            textDirection: TextDirection.rtl,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.person_rounded,
                          size: 14,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating & Duration
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 12,
                                    color: Color(0xFFF59E0B),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    course.averageRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatDuration(course.totalDurationMinutes),
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 10,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 12,
                                  color: Color(0xFF94A3B8),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Price
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: course.isFreeAccess
                                ? const Color(0xFF10B981).withOpacity(0.1)
                                : const Color(0xFF667EEA).withOpacity(0.1),
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
                      ],
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

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.school_rounded,
        size: 36,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes د';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '$hours س';
    return '$hours:${mins.toString().padLeft(2, '0')}';
  }

  List<Color> _getGradientColors() {
    final subject = course.subjectNameAr;
    final gradients = {
      'رياضيات': [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      'فيزياء': [const Color(0xFFF093FB), const Color(0xFFF5576C)],
      'كيمياء': [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
      'علوم': [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
      'عربية': [const Color(0xFFFA709A), const Color(0xFFFEE140)],
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
  final String? selectedLevel;
  final bool? isFreeFilter;
  final String sortBy;
  final Function(String?, bool?, String) onApply;

  const _FilterBottomSheet({
    this.selectedLevel,
    this.isFreeFilter,
    required this.sortBy,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String? _selectedLevel;
  late bool? _isFreeFilter;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.selectedLevel;
    _isFreeFilter = widget.isFreeFilter;
    _sortBy = widget.sortBy;
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
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Level Filter
          _buildFilterSection(
            title: 'المستوى',
            icon: Icons.school_rounded,
            options: [
              _FilterOption(label: 'ثانوي', value: 'secondary'),
              _FilterOption(label: 'بكالوريا', value: 'bac'),
            ],
            selectedValue: _selectedLevel,
            onSelect: (value) => setState(() => _selectedLevel = value),
          ),

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
              widget.onApply(_selectedLevel, _isFreeFilter, _sortBy);
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
                    color: const Color(0xFF667EEA).withOpacity(0.3),
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
