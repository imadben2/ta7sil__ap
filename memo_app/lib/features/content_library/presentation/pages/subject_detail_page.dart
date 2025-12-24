import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/entities/content_entity.dart';
import '../bloc/subject_detail/subject_detail_bloc.dart';
import '../bloc/subject_detail/subject_detail_event.dart';
import '../bloc/subject_detail/subject_detail_state.dart';
import '../widgets/content_list_item.dart';

/// Subject detail page with 4 content type tabs
class SubjectDetailPage extends StatefulWidget {
  final SubjectEntity subject;

  const SubjectDetailPage({super.key, required this.subject});

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTab = _tabController.index;
      });
    });
    // Content loading is handled by the BLoC provider/wrapper
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _currentTabName {
    switch (_currentTab) {
      case 0:
        return 'دروس';
      case 1:
        return 'ملخصات';
      case 2:
        return 'تمارين';
      case 3:
        return 'فروض';
      default:
        return '';
    }
  }

  Color _getSubjectColor() {
    try {
      return Color(int.parse(widget.subject.color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSubjectColor();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom App Bar with subject info
          _buildAppBar(color),

          // Tab Bar
          _buildTabBar(color),

          // Content
          Expanded(
            child: BlocBuilder<SubjectDetailBloc, SubjectDetailState>(
              builder: (context, state) {
                if (state is SubjectDetailLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SubjectDetailError) {
                  return _buildErrorState(state.message);
                }

                if (state is SubjectContentsLoaded) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildContentListFromState(state.lessons),
                      _buildContentListFromState(state.summaries),
                      _buildContentListFromState(state.exercises),
                      _buildContentListFromState(state.tests),
                    ],
                  );
                }

                // Initial state - show loading
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppDesignTokens.spacingLG),
          child: Column(
            children: [
              // Back button and title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: AppDesignTokens.spacingSM),
                  Expanded(
                    child: Text(
                      widget.subject.nameAr,
                      style: TextStyle(
                        fontSize: AppDesignTokens.fontSizeH4,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Coefficient badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDesignTokens.spacingMD,
                      vertical: AppDesignTokens.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        AppDesignTokens.borderRadiusSmall,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: AppDesignTokens.spacingXXS),
                        Text(
                          '${widget.subject.coefficient}',
                          style: TextStyle(
                            fontSize: AppDesignTokens.fontSizeBody,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppDesignTokens.spacingLG),

              // Progress info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatChip(
                    Icons.menu_book_rounded,
                    '${widget.subject.completedContents}/${widget.subject.totalContents}',
                    'محتوى',
                  ),
                  _buildStatChip(
                    Icons.quiz_rounded,
                    '${widget.subject.completedQuizzes}/${widget.subject.totalQuizzes}',
                    'اختبار',
                  ),
                  _buildStatChip(
                    Icons.trending_up,
                    '${(widget.subject.completionPercentage * 100).toStringAsFixed(0)}%',
                    'التقدم',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacingMD,
        vertical: AppDesignTokens.spacingSM,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          SizedBox(width: AppDesignTokens.spacingXS),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSizeBody,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppDesignTokens.fontSizeCaption,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(Color color) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: color,
        indicatorWeight: 3,
        labelColor: color,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(
          fontSize: AppDesignTokens.fontSizeBody,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppDesignTokens.fontSizeBody,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'دروس'),
          Tab(text: 'ملخصات'),
          Tab(text: 'تمارين'),
          Tab(text: 'فروض'),
        ],
      ),
    );
  }

  Widget _buildContentListFromState(List<ContentEntity> contents) {
    if (contents.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SubjectDetailBloc>().add(LoadSubjectContents(widget.subject));
      },
      color: _getSubjectColor(),
      child: ListView.separated(
        padding: EdgeInsets.all(AppDesignTokens.spacingLG),
        itemCount: contents.length,
        separatorBuilder: (context, index) =>
            SizedBox(height: AppDesignTokens.spacingMD),
        itemBuilder: (context, index) {
          final content = contents[index];
          return ContentListItem(
            content: content,
            subject: widget.subject,
            subjectColor: _getSubjectColor(),
            allContents: contents,
            currentIndex: index,
            onRefreshNeeded: () {
              // Refresh contents to update progress/completion status
              context.read<SubjectDetailBloc>().add(LoadSubjectContents(widget.subject));
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error.withOpacity(0.5),
          ),
          SizedBox(height: AppDesignTokens.spacingLG),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSizeH5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingSM),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingXXL),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeBody,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingXXL),
          ElevatedButton.icon(
            onPressed: () {
              context.read<SubjectDetailBloc>().add(LoadSubjectContents(widget.subject));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getSubjectColor(),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppDesignTokens.spacingXXL,
                vertical: AppDesignTokens.spacingMD,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          SizedBox(height: AppDesignTokens.spacingLG),
          Text(
            'لا يوجد $_currentTabName',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSizeBody,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppDesignTokens.spacingSM),
          Text(
            'سيتم إضافة المحتوى قريباً',
            style: TextStyle(
              fontSize: AppDesignTokens.fontSizeBody,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
