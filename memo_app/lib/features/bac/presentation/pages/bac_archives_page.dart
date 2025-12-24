import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../core/widgets/gradient_subject_card.dart';
import '../bloc/bac_bloc.dart';
import '../bloc/bac_event.dart';
import '../bloc/bac_state.dart';
import '../../domain/entities/bac_year_entity.dart';
import '../../domain/entities/bac_session_entity.dart';
import '../../domain/entities/bac_subject_entity.dart';

/// Modern minimalist BAC archives page (Year → Session → Subject)
class BacArchivesPage extends StatefulWidget {
  const BacArchivesPage({super.key});

  @override
  State<BacArchivesPage> createState() => _BacArchivesPageState();
}

class _BacArchivesPageState extends State<BacArchivesPage>
    with SingleTickerProviderStateMixin {
  BacYearEntity? selectedYear;
  BacSessionEntity? selectedSession;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    // Load BAC years on page load (force refresh to get latest data)
    context.read<BacBloc>().add(const LoadBacYearsEvent(forceRefresh: true));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Handle pull-to-refresh
  Future<void> _onRefresh() async {
    if (selectedSession != null) {
      context.read<BacBloc>().add(LoadBacSubjectsEvent(selectedSession!.slug));
    } else if (selectedYear != null) {
      context.read<BacBloc>().add(LoadBacSessionsEvent(selectedYear!.slug));
    } else {
      context.read<BacBloc>().add(const LoadBacYearsEvent(forceRefresh: true));
    }
    // Wait for state to update
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<BacBloc, BacState>(
          listener: (context, state) {
            // Auto-skip to sessions if there's only one year
            if (state is BacYearsLoaded && state.years.length == 1) {
              final year = state.years.first;
              setState(() {
                selectedYear = year;
              });
              context.read<BacBloc>().add(LoadBacSessionsEvent(year.slug));
            }

            // Auto-skip to subjects if there's only one session
            if (state is BacSessionsLoaded && state.sessions.length == 1) {
              final session = state.sessions.first;
              setState(() {
                selectedSession = session;
              });
              context.read<BacBloc>().add(LoadBacSubjectsEvent(session.slug));
            }
          },
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
                      else if (state is BacSessionsLoaded)
                        _buildSessionsContent(state.sessions)
                      else if (state is BacSubjectsLoaded)
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
              style: TextStyle(fontSize: AppDesignTokens.fontSizeBody, color: Colors.grey[600]),
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
                  borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
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
                  if (selectedSession != null) {
                    setState(() {
                      selectedSession = null;
                    });
                    context.read<BacBloc>().add(
                      LoadBacSessionsEvent(selectedYear!.slug),
                    );
                  } else if (selectedYear != null) {
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
                    _getBreadcrumbText(),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
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

  String _getBreadcrumbText() {
    if (selectedSession != null) {
      return '${selectedYear?.year} / ${selectedSession?.nameAr}';
    } else if (selectedYear != null) {
      return 'باكالوريا ${selectedYear?.year}';
    }
    return 'جميع السنوات';
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
            context.read<BacBloc>().add(LoadBacSessionsEvent(year.slug));
          },
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusCard),
          child: Container(
            padding: EdgeInsets.all(AppDesignTokens.spacingXL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusCard),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        year.descriptionAr ?? 'باكالوريا ${year.year}',
                        style: TextStyle(
                          fontSize: AppDesignTokens.fontSizeH5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (year.totalSessions > 0) ...[
                        SizedBox(height: AppDesignTokens.spacingSM),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDesignTokens.spacingSM,
                                vertical: AppDesignTokens.spacingXXS,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.event,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: AppDesignTokens.spacingXXS),
                                  Text(
                                    '${year.totalSessions} دورة',
                                    style: TextStyle(
                                      fontSize: AppDesignTokens.fontSizeCaption,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (year.totalExams > 0) ...[
                              SizedBox(width: AppDesignTokens.spacingXS),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppDesignTokens.spacingSM,
                                  vertical: AppDesignTokens.spacingXXS,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.description,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: AppDesignTokens.spacingXXS),
                                    Text(
                                      '${year.totalExams} امتحان',
                                      style: TextStyle(
                                        fontSize: AppDesignTokens.fontSizeCaption,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionsContent(List<BacSessionEntity> sessions) {
    if (sessions.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(
          'لا توجد دورات متاحة',
          Icons.event_note_rounded,
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingXXL),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final session = sessions[index];
          return _buildSessionCard(session);
        }, childCount: sessions.length),
      ),
    );
  }

  Widget _buildSessionCard(BacSessionEntity session) {
    final isActive = session.isCurrentlyActive;

    return Container(
      margin: EdgeInsets.only(bottom: AppDesignTokens.spacingLG),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedSession = session;
            });
            context.read<BacBloc>().add(LoadBacSubjectsEvent(session.slug));
          },
          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusCard),
          child: Container(
            padding: EdgeInsets.all(AppDesignTokens.spacingXL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusCard),
              border: Border.all(
                color: isActive ? AppColors.successGreen : Colors.grey[200]!,
                width: isActive ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? LinearGradient(
                            colors: [AppColors.successGreen, AppColors.successGreen.withOpacity(0.7)],
                          )
                        : LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.7),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusLarge),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                SizedBox(width: AppDesignTokens.spacingLG),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              session.nameAr,
                              style: TextStyle(
                                fontSize: AppDesignTokens.fontSizeH5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate900,
                              ),
                            ),
                          ),
                          if (isActive)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDesignTokens.spacingSM,
                                vertical: AppDesignTokens.spacingXXS,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.successGreen,
                                borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
                              ),
                              child: Text(
                                'جارية',
                                style: TextStyle(
                                  fontSize: AppDesignTokens.fontSizeCaption,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (session.descriptionAr != null) ...[
                        SizedBox(height: AppDesignTokens.spacingXXS),
                        Text(
                          session.descriptionAr!,
                          style: TextStyle(
                            fontSize: AppDesignTokens.fontSizeBody,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      SizedBox(height: AppDesignTokens.spacingXS),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDesignTokens.spacingSM,
                          vertical: AppDesignTokens.spacingXXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusSmall),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.subject,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: AppDesignTokens.spacingXXS),
                            Text(
                              '${session.totalSubjects} مادة',
                              style: TextStyle(
                                fontSize: AppDesignTokens.fontSizeSmall,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppDesignTokens.spacingXS),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: AppColors.slate500,
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
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return _buildSubjectCard(subject);
            },
          ),

          const SizedBox(height: 20),

          // Two bottom cards: أدائي and محاكاة امتحان
          Row(
            children: [
              // أدائي card (Performance)
              Expanded(
                child: _buildBottomCard(
                  title: 'أدائي',
                  subtitle: 'تتبع تقدمك',
                  icon: Icons.bar_chart_rounded,
                  gradient: AppColors.successGradient,
                  onTap: () {
                    // Navigate to performance/statistics page
                    context.push('/statistics');
                  },
                ),
              ),
              const SizedBox(width: 12),
              // محاكاة امتحان card (Exam Simulation)
              Expanded(
                child: _buildBottomCard(
                  title: 'محاكاة امتحان',
                  subtitle: 'اختبر نفسك',
                  icon: Icons.quiz_rounded,
                  gradient: AppColors.warningGradient,
                  onTap: () {
                    // Navigate to exam simulation
                    // TODO: Implement navigation to exam simulation
                  },
                ),
              ),
            ],
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
      onTap: () {
        context.push('/bac-subject-detail', extra: subject);
      },
    );
  }

  Widget _buildBottomCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradient[0].withOpacity(0.1), gradient[1].withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: gradient[0].withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              // Text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.slate600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
