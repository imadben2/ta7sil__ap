import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../injection_container.dart';
import '../bloc/bac_study_bloc.dart';
import '../bloc/bac_study_event.dart';
import '../bloc/bac_study_state.dart';
import '../widgets/bac_progress_header.dart';
import '../widgets/bac_week_selector.dart';
import '../widgets/bac_day_card.dart';
import '../../data/datasources/bac_study_local_datasource.dart';

/// Main page for BAC Study Schedule (98-day planner)
class BacStudyMainPage extends StatefulWidget {
  final int streamId;

  const BacStudyMainPage({
    super.key,
    required this.streamId,
  });

  @override
  State<BacStudyMainPage> createState() => _BacStudyMainPageState();
}

class _BacStudyMainPageState extends State<BacStudyMainPage> {
  @override
  void initState() {
    super.initState();
    // Clear any potentially corrupt cache on first load
    _clearCorruptCache();
  }

  Future<void> _clearCorruptCache() async {
    try {
      final localDataSource = sl<BacStudyLocalDataSource>();
      await localDataSource.clearAllCache();
    } catch (e) {
      // Ignore cache clear errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<BacStudyBloc>()
        ..add(LoadBacStudyStats(streamId: widget.streamId)),
      child: _BacStudyMainPageContent(streamId: widget.streamId),
    );
  }
}

class _BacStudyMainPageContent extends StatelessWidget {
  final int streamId;

  const _BacStudyMainPageContent({required this.streamId});

  @override
  Widget build(BuildContext context) {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: SafeArea(
          child: BlocConsumer<BacStudyBloc, BacStudyState>(
            listener: (context, state) {
              if (state is BacStudyError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is BacStudyLoading) {
                return _buildLoadingState();
              }

              if (state is BacStudyError) {
                return _buildErrorState(context, state.message);
              }

              if (state is BacStudyLoaded) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<BacStudyBloc>().add(
                          RefreshBacStudyData(streamId: streamId),
                        );
                  },
                  child: CustomScrollView(
                    slivers: [
                      // App Bar
                      SliverToBoxAdapter(
                        child: _buildAppBar(context),
                      ),

                      // Progress Header
                      SliverToBoxAdapter(
                        child: BacProgressHeader(stats: state.stats),
                      ),

                      // Week Selector
                      SliverToBoxAdapter(
                        child: BacWeekSelector(
                          selectedWeek: state.selectedWeek,
                          totalWeeks: 14,
                          currentWeek: state.stats.currentWeek,
                          onWeekSelected: (week) {
                            context.read<BacStudyBloc>().add(
                                  LoadBacStudyWeek(
                                    streamId: streamId,
                                    weekNumber: week,
                                  ),
                                );
                          },
                        ),
                      ),

                      // Days section header
                      SliverToBoxAdapter(
                        child: _buildDaysSectionHeader(state),
                      ),

                      // Week Content
                      if (state.isLoadingWeek)
                        SliverToBoxAdapter(
                          child: _buildWeekLoadingState(),
                        )
                      else if (state.weekLoadError != null)
                        SliverToBoxAdapter(
                          child: _buildWeekError(context, state.weekLoadError!),
                        )
                      else if (state.currentWeekData != null)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.82,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final day =
                                    state.currentWeekData!.days[index];
                                return BacDayCard(
                                  day: day,
                                  onTap: () {
                                    context.push(
                                      '/bac-study-schedule/day/${day.dayNumber}',
                                      extra: {'streamId': streamId},
                                    );
                                  },
                                );
                              },
                              childCount: state.currentWeekData!.days.length,
                            ),
                          ),
                        ),

                      // Bottom padding
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
        floatingActionButton: BlocBuilder<BacStudyBloc, BacStudyState>(
          builder: (context, state) {
            if (state is BacStudyLoaded) {
              return Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF59E0B),
                      Color(0xFFFBBF24),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      context.push(
                        '/bac-study-schedule/rewards',
                        extra: {'streamId': streamId},
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: const Center(
                      child: Icon(
                        Icons.card_giftcard_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              color: const Color(0xFF64748B),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<BacStudyBloc>().add(
                      LoadBacStudyStats(streamId: streamId),
                    );
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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

  Widget _buildWeekError(BuildContext context, String message) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF59E0B).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 32,
              color: Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
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

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildAppBar(null)),
        // Shimmer header placeholder
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade200,
                  Colors.grey.shade100,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8B5CF6),
                strokeWidth: 3,
              ),
            ),
          ),
        ),
        // Shimmer week selector placeholder
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  width: 64,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              },
            ),
          ),
        ),
        // Shimmer day cards placeholder
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.82,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(24),
                  ),
                );
              },
              childCount: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.82,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 7,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: const Color(0xFF8B5CF6).withOpacity(0.5),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDaysSectionHeader(BacStudyLoaded state) {
    final daysCount = state.currentWeekData?.days.length ?? 7;
    final completedDays = state.currentWeekData?.days
            .where((d) => d.isFullyCompleted)
            .length ??
        0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.view_week_rounded,
              color: Color(0xFF3B82F6),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'أيام الأسبوع ${state.selectedWeek}',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: completedDays == daysCount
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : const Color(0xFF64748B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$completedDays/$daysCount مكتمل',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: completedDays == daysCount
                    ? const Color(0xFF10B981)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext? context) {
    final canPop = context != null && Navigator.of(context).canPop();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button (only show if we can pop)
          if (canPop)
            _buildAppBarButton(
              icon: Icons.arrow_forward_ios_rounded,
              onPressed: () => context.pop(),
            ),
        ],
      ),
    );
  }
}
