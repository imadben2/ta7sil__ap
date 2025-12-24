import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../planner/presentation/bloc/planner_bloc.dart';
import '../../../planner/presentation/bloc/planner_event.dart';
import '../../../planner/presentation/bloc/planner_state.dart';
import '../../../planner/presentation/widgets/session_card.dart' as planner;

/// Planner preview view - بلانر category
/// Shows quick view of today's sessions with option to view full planner
class PlannerPreviewView extends StatefulWidget {
  const PlannerPreviewView({super.key});

  @override
  State<PlannerPreviewView> createState() => _PlannerPreviewViewState();
}

class _PlannerPreviewViewState extends State<PlannerPreviewView> {
  @override
  void initState() {
    super.initState();
    // Load today's schedule when this view is initialized
    sl<PlannerBloc>().add(const LoadTodaysScheduleEvent());
  }

  // Note: Don't close the PlannerBloc here since it's a singleton
  // that persists across the app lifecycle

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<PlannerBloc>(),
      child: BlocListener<PlannerBloc, PlannerState>(
        listener: (context, state) {
          // Reload schedule when session content is loaded (coming back from detail screen)
          if (state is SessionContentLoaded || state is SessionContentError) {
            sl<PlannerBloc>().add(const LoadTodaysScheduleEvent());
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            sl<PlannerBloc>().add(const LoadTodaysScheduleEvent());
            await Future.delayed(const Duration(seconds: 1));
          },
          color: AppColors.primary,
          child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildHeader(context)),

            // Quick Stats
            SliverToBoxAdapter(child: _buildQuickStats()),

            // Today's Sessions Title
            SliverToBoxAdapter(child: _buildSectionTitle('جلسات اليوم')),

            // Sessions List
            SliverToBoxAdapter(child: _buildSessionsList()),

            // View Full Planner Button
            SliverToBoxAdapter(child: _buildViewFullPlannerButton(context)),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final dayName = _getArabicDayName(now.weekday);
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/planner'),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.calendar_month, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'عرض الخطة الكاملة',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (context, state) {
        int totalSessions = 0;
        int completedSessions = 0;
        int upcomingSessions = 0;

        if (state is ScheduleLoaded) {
          totalSessions = state.sessions.length;
          completedSessions = state.sessions.where((s) => s.isCompleted).length;
          upcomingSessions = state.sessions.where((s) => s.isScheduled).length;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.event_note,
                  value: '$totalSessions',
                  label: 'إجمالي الجلسات',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  value: '$completedSessions',
                  label: 'مكتملة',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.schedule,
                  value: '$upcomingSessions',
                  label: 'قادمة',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSessionsList() {
    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (context, state) {
        if (state is PlannerLoading) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ScheduleLoaded) {
          final todaySessions = state.sessions.where((s) => s.isToday).toList();

          if (todaySessions.isEmpty) {
            return _buildEmptyState();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: todaySessions.take(5).map((session) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: planner.SessionCard(
                    session: session,
                    onTap: () {
                      context.push('/planner/session/${session.id}', extra: session);
                    },
                  ),
                );
              }).toList(),
            ),
          );
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد جلسات لليوم',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'قم بإنشاء جدول دراسي جديد',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/planner/wizard');
              },
              icon: const Icon(Icons.add),
              label: const Text('إنشاء جدول جديد'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewFullPlannerButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: OutlinedButton(
        onPressed: () {
          // This will be handled by bottom nav tap to planner
          context.push('/planner');
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_view_week, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'عرض الجدول الكامل',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getArabicDayName(int weekday) {
    const days = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return days[weekday - 1];
  }
}
