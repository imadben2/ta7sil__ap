import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/course_module_entity.dart';
import '../../domain/entities/course_review_entity.dart';
import '../bloc/courses/courses_bloc.dart';
import '../bloc/courses/courses_event.dart';
import '../bloc/courses/courses_state.dart';
import '../bloc/subscription/subscription_bloc.dart';
import '../bloc/subscription/subscription_state.dart';
import '../widgets/subscription_code_dialog.dart';
import '../widgets/payment_options_bottom_sheet.dart';

/// صفحة تفاصيل الدورة - Simple Clean Design
class CourseDetailPage extends StatefulWidget {
  final int courseId;

  const CourseDetailPage({super.key, required this.courseId});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CourseEntity? _course;
  List<CourseModuleEntity>? _modules;
  List<CourseReviewEntity>? _reviews;
  bool _hasAccess = false;
  String? _errorMessage;
  bool _isLoading = true;
  int _expandedModuleIndex = 0;

  // Colors - Using AppColors for consistency
  static const _primaryPurple = AppColors.primary;
  static const _secondaryPurple = AppColors.primaryLight;
  static const _lightPurple = AppColors.purpleLight;
  static const _bgColor = AppColors.slateBackground;
  static const _cardColor = AppColors.surface;
  static const _textPrimary = AppColors.slate900;
  static const _textSecondary = AppColors.slate600;
  static const _textMuted = AppColors.slate500;
  static const _borderColor = AppColors.borderLight;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  void _loadData() {
    final bloc = context.read<CoursesBloc>();
    bloc.add(LoadCourseDetailsEvent(courseId: widget.courseId));
    bloc.add(LoadCourseModulesEvent(courseId: widget.courseId));
    bloc.add(CheckCourseAccessEvent(courseId: widget.courseId));
    bloc.add(LoadCourseReviewsEvent(courseId: widget.courseId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              debugPrint('=== COURSE LOADED ===');
              debugPrint('thumbnailUrl: ${state.course.thumbnailUrl}');
              debugPrint('=====================');
              setState(() {
                _course = state.course;
                _isLoading = false;
                _errorMessage = null;
              });
            } else if (state is CourseModulesLoaded) {
              setState(() => _modules = state.modules);
            } else if (state is CourseAccessChecked) {
              setState(() => _hasAccess = state.hasAccess);
            } else if (state is CourseReviewsLoaded) {
              setState(() => _reviews = state.reviews);
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

    if (_isLoading || _course == null) {
      return _buildLoadingState();
    }

    return Stack(
      children: [
        NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildImageHeader(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildCourseInfo(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // Sticky Tab Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  child: Container(
                    color: _bgColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Colors.white,
                        unselectedLabelColor: _textSecondary,
                        indicator: BoxDecoration(
                          gradient: LinearGradient(colors: [_primaryPurple, _secondaryPurple]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelStyle: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: const [
                          Tab(text: 'نظرة عامة'),
                          Tab(text: 'المحتوى'),
                          Tab(text: 'التقييمات'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Container(
            color: _bgColor,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildContentTab(),
                _buildReviewsTab(),
              ],
            ),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildImageHeader() {
    return SliverAppBar(
      expandedHeight: 220,
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
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
          ),
        ),
      ),
      actions: const [
        SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Course Image - Using CachedNetworkImage for better connection handling
            if (_course!.thumbnailUrl != null && _course!.thumbnailUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: _course!.thumbnailUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => _buildPlaceholderImage(),
                errorWidget: (context, url, error) {
                  debugPrint('Course thumbnail error: $error');
                  debugPrint('URL was: $url');
                  return _buildPlaceholderImage();
                },
              )
            else
              _buildPlaceholderImage(),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Play button for trailer
            if (_course!.trailerVideoUrl != null)
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Play trailer
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: _primaryPurple,
                      size: 32,
                    ),
                  ),
                ),
              ),

            // Bottom info overlay
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                children: [
                  // Stats chips
                  _buildOverlayChip(Icons.play_circle_outline_rounded, '${_course!.totalLessons} درس'),
                  const SizedBox(width: 8),
                  _buildOverlayChip(Icons.schedule_rounded, _course!.formattedDuration),
                  const SizedBox(width: 8),
                  _buildOverlayChip(Icons.star_rounded, _course!.averageRating.toStringAsFixed(1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [_primaryPurple, _secondaryPurple, _lightPurple],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          color: Colors.white,
          size: 64,
        ),
      ),
    );
  }

  Widget _buildOverlayChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges row
          Row(
            children: [
              _buildBadge(_course!.subjectNameAr, _primaryPurple),
              const SizedBox(width: 8),
              if (_course!.levelText.isNotEmpty)
                _buildBadge(_course!.levelText, _secondaryPurple),
              const Spacer(),
              if (_hasAccess)
                _buildBadge('مشترك', const Color(0xFF10B981), filled: true),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            _course!.titleAr,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          if (_course!.descriptionAr.isNotEmpty)
            Text(
              _course!.descriptionAr,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: _textSecondary,
                height: 1.6,
              ),
            ),
          const SizedBox(height: 16),

          // Price
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _primaryPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [_primaryPurple, _secondaryPurple]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _course!.isFreeAccess ? Icons.card_giftcard_rounded : Icons.local_offer_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _course!.isFreeAccess ? 'دورة مجانية' : 'سعر الدورة',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: _textMuted,
                        ),
                      ),
                      Text(
                        _course!.isFreeAccess ? 'مجاني' : _course!.formattedPrice,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_course!.hasDiscount && _course!.formattedOriginalPrice != null)
                  Text(
                    _course!.formattedOriginalPrice!,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: _textMuted,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color, {bool filled = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? color : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: filled ? null : Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: filled ? Colors.white : color,
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    // Get learning items from API or use defaults
    final whatYouWillLearn = _course!.whatYouWillLearn ?? [
      'فهم المفاهيم الأساسية بشكل عميق ومفصّل',
      'تطبيق المعرفة في حل المسائل والتمارين',
      'الاستعداد الجيد للامتحانات بثقة',
      'تطوير مهارات التفكير النقدي والتحليلي',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('عن الدورة'),
          const SizedBox(height: 12),
          Text(
            _course!.descriptionAr.isNotEmpty
                ? _course!.descriptionAr
                : 'لا يوجد وصف متاح لهذه الدورة',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: _textSecondary,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 24),

          // What you will learn section - dynamic from API
          if (whatYouWillLearn.isNotEmpty) ...[
            _buildSectionTitle('ماذا ستتعلم'),
            const SizedBox(height: 12),
            ...whatYouWillLearn.map((item) => _buildLearningItem(item)),
            const SizedBox(height: 24),
          ],

          // Requirements section - if available from API
          if (_course!.requirements != null && _course!.requirements!.isNotEmpty) ...[
            _buildSectionTitle('المتطلبات الأساسية'),
            const SizedBox(height: 12),
            ..._course!.requirements!.map((item) => _buildRequirementItem(item)),
            const SizedBox(height: 24),
          ],

          // Target audience section - if available from API
          if (_course!.targetAudience != null && _course!.targetAudience!.isNotEmpty) ...[
            _buildSectionTitle('لمن هذه الدورة'),
            const SizedBox(height: 12),
            ..._course!.targetAudience!.map((item) => _buildTargetAudienceItem(item)),
            const SizedBox(height: 24),
          ],

          _buildSectionTitle('مميزات الدورة'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeatureChip(Icons.play_circle_outline_rounded, '${_course!.totalLessons} فيديو'),
              _buildFeatureChip(Icons.smartphone_rounded, 'متاح على الجوال'),
              _buildFeatureChip(Icons.all_inclusive_rounded, 'وصول دائم'),
              if (_course!.certificateAvailable)
                _buildFeatureChip(Icons.workspace_premium_rounded, 'شهادة إتمام'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_primaryPurple, _lightPurple],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLearningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.check_rounded, color: Color(0xFF059669), size: 12),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: _textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 12),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: _textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetAudienceItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.person_outline_rounded, color: _primaryPurple, size: 12),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: _textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _primaryPurple),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    if (_modules == null) {
      return const Center(child: CircularProgressIndicator(color: _primaryPurple));
    }

    if (_modules!.isEmpty) {
      return _buildEmptyState(
        icon: Icons.folder_open_rounded,
        title: 'لا يوجد محتوى',
        subtitle: 'سيتم إضافة المحتوى قريباً',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
      physics: const BouncingScrollPhysics(),
      itemCount: _modules!.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildCourseInfoHeader();
        }
        return _buildModuleCard(index - 1);
      },
    );
  }

  Widget _buildCourseInfoHeader() {
    if (_course == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course title
          Text(
            _course!.titleAr,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          // Course description
          Text(
            _course!.descriptionAr,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
              height: 1.6,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          // Divider
          Container(
            height: 1,
            color: _borderColor,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildModuleCard(int index) {
    final module = _modules![index];
    final isExpanded = _expandedModuleIndex == index;
    final lessonsCount = module.lessons?.length ?? 0;
    final isLastModule = index == _modules!.length - 1;

    // Calculate module duration
    int moduleDuration = 0;
    for (var lesson in module.lessons ?? []) {
      moduleDuration += (lesson.videoDurationSeconds as num).toInt();
    }

    return Column(
      children: [
        // Module header with timeline
        InkWell(
          onTap: () => setState(() {
            _expandedModuleIndex = isExpanded ? -1 : index;
          }),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isExpanded ? _cardColor : _bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isExpanded ? _primaryPurple.withOpacity(0.3) : _borderColor,
                width: isExpanded ? 1.5 : 1,
              ),
              boxShadow: isExpanded
                  ? [
                      BoxShadow(
                        color: _primaryPurple.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Module number with ring
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isExpanded
                        ? LinearGradient(colors: [_primaryPurple, _secondaryPurple])
                        : null,
                    color: isExpanded ? null : _primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isExpanded ? Colors.white : _primaryPurple,
                            height: 1,
                          ),
                        ),
                        Text(
                          'وحدة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isExpanded ? Colors.white.withOpacity(0.8) : _primaryPurple.withOpacity(0.7),
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isExpanded ? _primaryPurple.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: isExpanded ? _primaryPurple : _textMuted,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Lessons list with timeline connector
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: isExpanded && module.lessons != null
              ? Container(
                  margin: const EdgeInsets.only(right: 23, top: 0),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: _primaryPurple.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Column(
                    children: List.generate(module.lessons!.length, (lessonIndex) {
                      final lesson = module.lessons![lessonIndex];
                      final isLastLesson = lessonIndex == module.lessons!.length - 1;
                      return _buildLessonTile(lesson, lessonIndex, isLastLesson);
                    }),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // Spacing between modules
        if (!isLastModule && !isExpanded) const SizedBox(height: 12),
        if (!isLastModule && isExpanded) const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLessonTile(dynamic lesson, int lessonIndex, bool isLastLesson) {
    final isAccessible = _hasAccess || lesson.isFreePreview;

    return InkWell(
      onTap: isAccessible
          ? () => context.push('/courses/${widget.courseId}/lessons/${lesson.id}')
          : null,
      child: Container(
        margin: EdgeInsets.only(right: 20, top: lessonIndex == 0 ? 8 : 0, bottom: isLastLesson ? 8 : 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline dot
            Container(
              margin: const EdgeInsets.only(top: 18),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isAccessible ? _primaryPurple : _borderColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (isAccessible)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Lesson card
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isAccessible ? _primaryPurple.withOpacity(0.15) : _borderColor,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Play/Lock icon
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: isAccessible
                            ? LinearGradient(
                                colors: [
                                  _primaryPurple.withOpacity(0.15),
                                  _secondaryPurple.withOpacity(0.1),
                                ],
                              )
                            : null,
                        color: isAccessible ? null : _bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isAccessible ? Icons.play_arrow_rounded : Icons.lock_outline_rounded,
                        color: isAccessible ? _primaryPurple : _textMuted,
                        size: 22,
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
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isAccessible ? _textPrimary : _textMuted,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (lesson.videoDurationSeconds > 0) ...[
                                Icon(
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
                              ],
                              if (lesson.isFreePreview) ...[
                                if (lesson.videoDurationSeconds > 0) const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF10B981), Color(0xFF34D399)],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.play_circle_filled_rounded, size: 12, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'معاينة مجانية',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Arrow
                    if (isAccessible)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _bgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 14,
                          color: _textMuted,
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

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '$minutes دقيقة';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '$hours ساعة';
    return '$hours:${remainingMinutes.toString().padLeft(2, '0')}';
  }

  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Rating summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      _course!.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < _course!.averageRating.round()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 18,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_course!.totalReviews} تقييم',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: List.generate(5, (index) {
                      final rating = 5 - index;
                      final percentage = _calculateRatingPercentage(rating);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 14,
                              child: Text(
                                '$rating',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: _textMuted,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _borderColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerRight,
                                  widthFactor: percentage,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (_reviews == null)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: _primaryPurple),
            )
          else if (_reviews!.isEmpty)
            _buildEmptyState(
              icon: Icons.rate_review_outlined,
              title: 'لا توجد تقييمات',
              subtitle: 'كن أول من يقيّم هذه الدورة',
            )
          else
            ...(_reviews!.take(5).map((review) => _buildReviewCard(review))),
        ],
      ),
    );
  }

  double _calculateRatingPercentage(int rating) {
    if (_reviews == null || _reviews!.isEmpty) return 0;
    final count = _reviews!.where((r) => r.rating == rating).length;
    return count / _reviews!.length;
  }

  Widget _buildReviewCard(CourseReviewEntity review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    review.displayName[0].toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _primaryPurple,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.displayName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 12,
                          );
                        }),
                        const SizedBox(width: 6),
                        Text(
                          review.createdAtText,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.hasReviewText) ...[
            const SizedBox(height: 10),
            Text(
              review.reviewTextAr!,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: _textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 36, color: _primaryPurple.withOpacity(0.5)),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: _textMuted,
              ),
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
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: _cardColor.withOpacity(0.95),
              border: Border(top: BorderSide(color: _borderColor)),
            ),
            child: SafeArea(
              top: false,
              child: _hasAccess ? _buildContinueButton() : _buildEnrollButtons(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_primaryPurple, _secondaryPurple]),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, size: 22, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'الوصول إلى المحتوى',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollButtons() {
    return Row(
      children: [
        // QR code button removed - now integrated in payment options
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_primaryPurple, _secondaryPurple]),
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
              onPressed: _showPaymentOptions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rocket_launch_rounded, size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'اشترك الآن',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Show payment options bottom sheet
  void _showPaymentOptions() {
    PaymentOptionsBottomSheet.show(
      context,
      courseId: widget.courseId,
      onCodeRedeemed: _navigateToCourseModules,
    );
  }

  /// Navigate to course modules after successful subscription
  void _navigateToCourseModules() {
    // Wait for dialog to close first
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      // Refresh course access status
      context.read<CoursesBloc>().add(CheckCourseAccessEvent(courseId: widget.courseId));

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'تم تفعيل الاشتراك بنجاح! يمكنك الآن الوصول إلى محتوى الدورة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate to first lesson after a short delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;

        if (_modules != null && _modules!.isNotEmpty) {
          final lessons = _modules!.first.lessons;
          if (lessons != null && lessons.isNotEmpty) {
            context.push('/courses/${widget.courseId}/lessons/${lessons.first.id}');
          }
        }
      });
    });
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: _primaryPurple),
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
              child: Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.withOpacity(0.7)),
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
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryPurple,
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
}

/// Delegate for sticky tab bar header
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 64;

  @override
  double get minExtent => 64;

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
