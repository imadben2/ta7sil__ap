import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../core/widgets/gradient_subject_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/bac_bloc.dart';
import '../bloc/bac_event.dart';
import '../bloc/bac_state.dart';
import '../../domain/entities/bac_year_entity.dart';
import '../../domain/entities/bac_subject_entity.dart';

/// Simplified BAC archives page: Year → Subjects (without sessions)
class BacArchivesByYearPage extends StatefulWidget {
  const BacArchivesByYearPage({super.key});

  @override
  State<BacArchivesByYearPage> createState() => _BacArchivesByYearPageState();
}

class _BacArchivesByYearPageState extends State<BacArchivesByYearPage>
    with SingleTickerProviderStateMixin {
  BacYearEntity? selectedYear;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    // Load BAC years on page load
    context.read<BacBloc>().add(const LoadBacYearsEvent(forceRefresh: true));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Get user's academic stream ID from auth state
  int? _getUserStreamId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      return authState.user.academicProfile?.streamId;
    }
    return null;
  }

  /// Handle pull-to-refresh
  Future<void> _onRefresh() async {
    if (selectedYear != null) {
      final streamId = _getUserStreamId();
      context.read<BacBloc>().add(LoadSubjectsByYearEvent(
        selectedYear!.slug,
        streamId: streamId,
      ));
    } else {
      context.read<BacBloc>().add(const LoadBacYearsEvent(forceRefresh: true));
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<BacBloc, BacState>(
          builder: (context, state) {
            if (state is BacLoading) {
              return _buildLoadingState();
            }

            if (state is BacError) {
              return _buildErrorState(state.message);
            }

            return FadeTransition(
              opacity: _animationController,
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppColors.primary,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    _buildAppBar(context),

                    if (state is BacYearsLoaded)
                      _buildYearsContent(state.years)
                    else if (state is BacSubjectsByYearLoaded)
                      _buildSubjectsContent(state.subjects)
                    else
                      const SliverToBoxAdapter(
                        child: Center(child: Text('لا توجد بيانات')),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'جاري التحميل...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDesignTokens.spacingXXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red,
              ),
            ),
            SizedBox(height: AppDesignTokens.spacingXXL),
            Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeH4,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            SizedBox(height: AppDesignTokens.spacingXS),
            Text(
              message,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeBody,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDesignTokens.spacingXXL),
            ElevatedButton(
              onPressed: () {
                context.read<BacBloc>().add(const LoadBacYearsEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppDesignTokens.spacingXXXL,
                  vertical: AppDesignTokens.spacingMD,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
                ),
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          children: [
            // Back button
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_forward, size: 20),
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (selectedYear != null) {
                    setState(() {
                      selectedYear = null;
                    });
                    context.read<BacBloc>().add(const LoadBacYearsEvent());
                  } else {
                    context.pop();
                  }
                },
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedYear != null
                        ? 'باكالوريا ${selectedYear?.year}'
                        : 'جميع السنوات',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'أرشيف الباكالوريا',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                ],
              ),
            ),
            // Home button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.home_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                padding: EdgeInsets.zero,
                onPressed: () {
                  context.go('/home');
                },
                tooltip: 'الصفحة الرئيسية',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearsContent(List<BacYearEntity> years) {
    if (years.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(
          'لا توجد سنوات متاحة',
          Icons.calendar_today_rounded,
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingXXL),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final year = years[index];
          return _buildYearCard(year, index);
        }, childCount: years.length),
      ),
    );
  }

  Widget _buildYearCard(BacYearEntity year, int index) {
    final colors = [
      [AppColors.primary, AppColors.primaryLight],
      [AppColors.primaryLight, AppColors.purpleLight],
      AppColors.successGradient,
      [AppColors.red500, AppColors.error],
      AppColors.warningGradient,
    ];

    final gradient = colors[index % colors.length];

    return Container(
      margin: EdgeInsets.only(bottom: AppDesignTokens.spacingLG),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedYear = year;
            });
            // Load subjects directly by year, filtered by user's academic stream
            final streamId = _getUserStreamId();
            context.read<BacBloc>().add(LoadSubjectsByYearEvent(
              year.slug,
              streamId: streamId,
            ));
          },
          borderRadius:
              BorderRadius.circular(AppDesignTokens.borderRadiusCard),
          child: Container(
            padding: EdgeInsets.all(AppDesignTokens.spacingXL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.circular(AppDesignTokens.borderRadiusCard),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    year.descriptionAr ?? 'باكالوريا ${year.year}',
                    style: TextStyle(
                      fontSize: AppDesignTokens.fontSizeH5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectsContent(List<BacSubjectEntity> subjects) {
    if (subjects.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState('لا توجد مواد متاحة', Icons.book_rounded),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Subjects grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return _buildSubjectCard(subject);
            },
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _buildSubjectCard(BacSubjectEntity subject) {
    final color = subject.color.isNotEmpty
        ? Color(int.parse('0xFF${subject.color.replaceFirst('#', '')}'))
        : null;

    return GradientSubjectCard(
      nameAr: subject.nameAr,
      coefficient: subject.coefficient,
      color: color,
      onTap: () async {
        await context.push('/bac-subject-detail', extra: subject);
        // Reload subjects when returning from detail page
        if (selectedYear != null && mounted) {
          final streamId = _getUserStreamId();
          context.read<BacBloc>().add(LoadSubjectsByYearEvent(
            selectedYear!.slug,
            streamId: streamId,
          ));
        }
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDesignTokens.spacingXXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: Colors.grey[400]),
            ),
            SizedBox(height: AppDesignTokens.spacingXXL),
            Text(
              message,
              style: TextStyle(
                fontSize: AppDesignTokens.fontSizeBody,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
