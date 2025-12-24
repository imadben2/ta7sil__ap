import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';
import '../../../../core/widgets/cards/modern_stat_card.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../bloc/sponsors/sponsors_bloc.dart';
import '../bloc/sponsors/sponsors_event.dart';
import '../bloc/sponsors/sponsors_state.dart';
import '../bloc/promo/promo_bloc.dart';
import '../bloc/promo/promo_event.dart';
import '../bloc/promo/promo_state.dart';
import '../../domain/usecases/get_dashboard_data_usecase.dart';
import '../../../leaderboard/presentation/bloc/leaderboard_bloc.dart';
import '../../../leaderboard/presentation/bloc/leaderboard_event.dart';
import '../../../leaderboard/presentation/bloc/leaderboard_state.dart';
import '../../../leaderboard/domain/entities/leaderboard_entity.dart';
import '../widgets/sponsors_carousel_widget.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/weekly_progress_widget.dart';
import '../widgets/leaderboard_preview_widget.dart';
import '../widgets/promo_slider_widget.dart';
import '../widgets/section_header.dart';

/// Home content view - الرئيسية category
/// Modern design with glassmorphism, gradients, and gamification
class HomeContentView extends StatefulWidget {
  const HomeContentView({super.key});

  @override
  State<HomeContentView> createState() => _HomeContentViewState();
}

class _HomeContentViewState extends State<HomeContentView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    // Load data if not already loaded
    final homeState = context.read<HomeBloc>().state;
    if (homeState is HomeInitial) {
      context.read<HomeBloc>().add(const DashboardLoadRequested());
    }

    // Load sponsors
    final sponsorsState = context.read<SponsorsBloc>().state;
    if (sponsorsState is SponsorsInitial) {
      context.read<SponsorsBloc>().add(const LoadSponsors());
    }

    // Load promos
    _loadPromosIfAvailable();

    // Load leaderboard if bloc is available
    _loadLeaderboardIfAvailable();

    // Start animations
    _animationController.forward();
  }

  void _loadPromosIfAvailable() {
    final promoBloc = context.read<PromoBloc?>();
    if (promoBloc != null && promoBloc.state is PromoInitial) {
      promoBloc.add(const LoadPromos());
    }
  }

  void _loadLeaderboardIfAvailable() {
    final leaderboardBloc = context.read<LeaderboardBloc?>();
    if (leaderboardBloc != null && leaderboardBloc.state is LeaderboardInitial) {
      // Load stream leaderboard with weekly period
      leaderboardBloc.add(const LoadStreamLeaderboard(
        period: LeaderboardPeriod.week,
        limit: 10,
      ));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slateBackground,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<HomeBloc>().add(const DashboardLoadRequested());
          context.read<SponsorsBloc>().add(const LoadSponsors());
          context.read<PromoBloc?>()?.add(const RefreshPromos());
          _loadLeaderboardIfAvailable();
          await Future.delayed(const Duration(seconds: 1));
        },
        color: AppColors.primary,
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, homeState) {
            if (homeState is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (homeState is HomeError && !homeState.hasCachedData) {
              return _buildErrorState(homeState.message);
            }

            return _buildContent(context, homeState);
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<HomeBloc>().add(const DashboardLoadRequested());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeState state) {
    final data = state is HomeLoaded
        ? state.data
        : state is HomeRefreshing
            ? state.currentData
            : state is HomeSessionUpdating
                ? state.currentData
                : null;

    if (data == null) {
      return const Center(
        child: Text(
          'لا توجد بيانات',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 16),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Section 1: Promo Slider (Pub/Advertising)
            SliverToBoxAdapter(
              key: const ValueKey('promo_slider_section'),
              child: _buildPromoSliderSection(),
            ),

            const SliverToBoxAdapter(
              key: ValueKey('spacer_1'),
              child: SizedBox(height: 20),
            ),

            // Section 2: Quick Stats Row (3 columns)
            SliverToBoxAdapter(
              key: const ValueKey('stats_section'),
              child: _buildQuickStatsRow(data),
            ),

            const SliverToBoxAdapter(
              key: ValueKey('spacer_2'),
              child: SizedBox(height: 24),
            ),

            // Section 3: Weekly Progress Chart
            SliverToBoxAdapter(
              key: const ValueKey('weekly_progress_section'),
              child: _buildWeeklyProgressSection(data),
            ),

            const SliverToBoxAdapter(
              key: ValueKey('spacer_3'),
              child: SizedBox(height: 24),
            ),

            // Section 4: Quick Actions Grid (2x2)
            SliverToBoxAdapter(
              key: const ValueKey('quick_actions_section'),
              child: _buildQuickActionsSection(),
            ),

            const SliverToBoxAdapter(
              key: ValueKey('spacer_4'),
              child: SizedBox(height: 24),
            ),

            // Section 5: Today's Sessions (Horizontal)
            SliverToBoxAdapter(
              key: const ValueKey('sessions_section'),
              child: _buildSessionsSection(data),
            ),

            const SliverToBoxAdapter(
              key: ValueKey('spacer_5'),
              child: SizedBox(height: 24),
            ),

            // Section 6: Leaderboard Preview
            SliverToBoxAdapter(
              key: const ValueKey('leaderboard_section'),
              child: _buildLeaderboardSection(),
            ),

            const SliverToBoxAdapter(
              key: ValueKey('spacer_6'),
              child: SizedBox(height: 24),
            ),

            // Section 7: Sponsors Carousel
            SliverToBoxAdapter(
              key: const ValueKey('sponsors_section'),
              child: _buildSponsorsSection(),
            ),

            const SliverToBoxAdapter(
              key: ValueKey('spacer_bottom'),
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  /// Section 1: Promo Slider for promotions and ads
  Widget _buildPromoSliderSection() {
    final promoBloc = context.read<PromoBloc?>();

    // If no PromoBloc available, show default items
    if (promoBloc == null) {
      return PromoSliderWidget(
        items: PromoItem.defaultItems,
        height: 130,
        autoPlayDuration: const Duration(seconds: 5),
      );
    }

    return BlocBuilder<PromoBloc, PromoState>(
      bloc: promoBloc,
      builder: (context, state) {
        List<PromoItem> items;

        if (state is PromoLoaded && state.promos.isNotEmpty) {
          // Convert entities to PromoItems
          items = PromoItem.fromEntities(
            state.promos,
            onItemTap: (entity) => _handlePromoTap(entity),
          );
        } else if (state is PromoError && state.hasCachedData) {
          // Show cached data on error
          items = PromoItem.fromEntities(
            state.cachedPromos!,
            onItemTap: (entity) => _handlePromoTap(entity),
          );
        } else {
          // Loading, initial, or error without cache - show defaults
          items = PromoItem.defaultItems;
        }

        return PromoSliderWidget(
          items: items,
          height: 130,
          autoPlayDuration: const Duration(seconds: 5),
        );
      },
    );
  }

  /// Handle promo item tap - navigate or record click
  void _handlePromoTap(dynamic entity) {
    // Record click for analytics
    if (entity.id != null) {
      context.read<PromoBloc?>()?.add(RecordPromoClick(promoId: entity.id));
    }

    // Handle navigation based on action type
    if (entity.actionType == 'route' && entity.actionValue != null) {
      context.go(entity.actionValue);
    } else if (entity.actionType == 'url' && entity.actionValue != null) {
      // TODO: Open URL in browser
    }
  }

  /// Section 2: Quick Stats Row (Points, Streak, Study Time)
  Widget _buildQuickStatsRow(DashboardData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ModernStatCard(
              icon: Icons.emoji_events_rounded,
              iconColor: const Color(0xFFFFD700),
              value: '${data.stats.totalPoints}',
              label: 'النقاط',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ModernStatCard(
              icon: Icons.local_fire_department_rounded,
              iconColor: const Color(0xFFEF4444),
              value: '${data.stats.streak}',
              label: 'يوم متتالي',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ModernStatCard(
              icon: Icons.timer_outlined,
              iconColor: const Color(0xFF10B981),
              value: data.stats.formattedStudyTime,
              label: 'وقت الدراسة',
            ),
          ),
        ],
      ),
    );
  }

  /// Section 3: Weekly Progress Chart
  Widget _buildWeeklyProgressSection(DashboardData data) {
    // Generate week data from dashboard stats
    // For now, using placeholder data - this should come from backend
    final weekData = DailyProgress.generateWeek({});
    final totalMinutes = data.stats.studyTimeToday;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'تقدمك هذا الأسبوع',
            icon: Icons.bar_chart_rounded,
          ),
          const SizedBox(height: 12),
          WeeklyProgressWidget(
            key: const ValueKey('weekly_progress_chart'),
            weekData: weekData,
            totalMinutesThisWeek: totalMinutes,
          ),
        ],
      ),
    );
  }

  /// Section 4: Quick Actions Grid (2x2)
  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'الإجراءات السريعة',
            icon: Icons.flash_on_rounded,
          ),
          const SizedBox(height: 12),
          QuickActionsGrid(
            onContinueStudy: () => context.push('/content-library'),
            onQuickQuiz: () => context.push('/quiz'),
            onViewPlanner: () => context.push('/planner'),
            onBacSimulation: () => context.push('/bac-archives-by-year'),
            onFlashcards: () => context.push('/flashcards'),
          ),
        ],
      ),
    );
  }

  /// Section 5: Today's Sessions (Horizontal Scroll)
  Widget _buildSessionsSection(DashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(
            title: 'جلسات اليوم',
            icon: Icons.calendar_today_rounded,
            actionLabel: data.todaySessions.isNotEmpty ? 'عرض الكل' : null,
            onActionTap: data.todaySessions.isNotEmpty
                ? () => context.push('/planner')
                : null,
          ),
        ),
        const SizedBox(height: 12),
        if (data.todaySessions.isEmpty)
          _buildEmptySessionsState()
        else
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: data.todaySessions.length,
              itemBuilder: (context, index) {
                final session = data.todaySessions[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < data.todaySessions.length - 1 ? 12 : 0,
                  ),
                  child: _buildHorizontalSessionCard(session),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEmptySessionsState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              size: 40,
              color: Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد جلسات لليوم',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف جلسة دراسية جديدة من البلانر',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push('/planner/wizard'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'إنشاء جدول',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalSessionCard(dynamic session) {
    final subjectName = session.subjectName ?? '';
    final topic = session.topic ?? session.typeLabel ?? '';
    final startTime = session.startTime;
    final timeStr =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final subjectColor = _getSubjectColor(subjectName);

    return GestureDetector(
      onTap: () {
        context.push('/planner/session/${session.id}', extra: session);
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [subjectColor, subjectColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getSubjectIcon(subjectName),
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: subjectColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    timeStr,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: subjectColor,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subjectName,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  topic,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Section 6: Leaderboard Preview
  Widget _buildLeaderboardSection() {
    // Check if LeaderboardBloc is available in the context
    final leaderboardBloc = context.read<LeaderboardBloc?>();
    if (leaderboardBloc == null) {
      // LeaderboardBloc not provided - show empty widget
      return const SizedBox.shrink();
    }

    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      bloc: leaderboardBloc,
      builder: (context, state) {
        if (state is StreamLeaderboardLoaded) {
          final topThree = state.data.podium.take(3).toList();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LeaderboardPreviewWidget(
              key: const ValueKey('leaderboard_preview'),
              topThree: topThree,
              currentUserRank: state.data.currentUser,
              streamName: null, // Stream name can be fetched from user profile
              onViewAll: () => context.push('/leaderboard'),
            ),
          );
        }

        if (state is LeaderboardLoading) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusCard),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF59E0B),
              ),
            ),
          );
        }

        // Fallback - show empty state or nothing
        return const SizedBox.shrink();
      },
    );
  }

  /// Section 7: Sponsors carousel - هاد التطبيق برعاية
  Widget _buildSponsorsSection() {
    return BlocBuilder<SponsorsBloc, SponsorsState>(
      builder: (context, state) {
        if (state is SponsorsLoading) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7C3AED),
              ),
            ),
          );
        }

        if (state is SponsorsLoaded) {
          // Check if section is enabled from admin settings
          if (!state.sectionEnabled) {
            return const SizedBox.shrink();
          }

          if (state.sponsors.isNotEmpty) {
            return SponsorsCarouselWidget(
              sponsors: state.sponsors,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              itemSize: 75,
              onSponsorClick: (sponsorId, platform) {
                context.read<SponsorsBloc>().add(
                      RecordSponsorClick(sponsorId, platform: platform),
                    );
              },
            );
          }
        }

        // Hide section if no sponsors or error
        return const SizedBox.shrink();
      },
    );
  }

  // Helper methods
  IconData _getSubjectIcon(String subjectName) {
    final name = subjectName.toLowerCase();
    if (name.contains('رياضيات') || name.contains('math')) {
      return Icons.calculate_rounded;
    }
    if (name.contains('فيزياء') || name.contains('physics')) {
      return Icons.science_rounded;
    }
    if (name.contains('علوم') || name.contains('science') || name.contains('طبيع')) {
      return Icons.biotech_rounded;
    }
    if (name.contains('عربي') || name.contains('arabic')) {
      return Icons.text_fields_rounded;
    }
    if (name.contains('فرنس') || name.contains('french')) {
      return Icons.language_rounded;
    }
    if (name.contains('انجليز') || name.contains('english')) {
      return Icons.translate_rounded;
    }
    if (name.contains('تاريخ') || name.contains('جغرافيا') || name.contains('history')) {
      return Icons.public_rounded;
    }
    if (name.contains('فلسف') || name.contains('philosophy')) {
      return Icons.psychology_rounded;
    }
    if (name.contains('إسلام') || name.contains('islamic')) {
      return Icons.mosque_rounded;
    }
    return Icons.school_rounded;
  }

  Color _getSubjectColor(String subjectName) {
    final name = subjectName.toLowerCase();
    if (name.contains('رياضيات') || name.contains('math')) {
      return const Color(0xFF3B82F6);
    }
    if (name.contains('فيزياء') || name.contains('physics')) {
      return const Color(0xFF8B5CF6);
    }
    if (name.contains('علوم') || name.contains('science') || name.contains('طبيع')) {
      return const Color(0xFF10B981);
    }
    if (name.contains('عربي') || name.contains('arabic')) {
      return const Color(0xFF78716C);
    }
    if (name.contains('فرنس') || name.contains('french')) {
      return const Color(0xFF6366F1);
    }
    if (name.contains('انجليز') || name.contains('english')) {
      return const Color(0xFF06B6D4);
    }
    if (name.contains('تاريخ') || name.contains('جغرافيا') || name.contains('history')) {
      return const Color(0xFFF97316);
    }
    if (name.contains('فلسف') || name.contains('philosophy')) {
      return const Color(0xFFF59E0B);
    }
    if (name.contains('إسلام') || name.contains('islamic')) {
      return const Color(0xFF059669);
    }
    return const Color(0xFF64748B);
  }

}
