import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/planner_bloc.dart';
import '../bloc/planner_state.dart';
import '../widgets/week_calendar_grid.dart';
import '../widgets/empty_schedule_widget.dart';

/// Week View Screen - Calendar grid for the week
///
/// Features:
/// - 7-day horizontal grid
/// - Sessions as colored blocks (by subject)
/// - Tap to see details
/// - Visual density indicator
///
/// Note: Data loading is handled by PlannerMainScreen when tab changes
class WeekViewScreen extends StatelessWidget {
  const WeekViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (context, state) {
        // Loading state
        if (state is PlannerLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (state is PlannerError) {
          return _buildErrorView(context, state);
        }

        // No schedule available
        if (state is NoScheduleAvailable) {
          return EmptyScheduleWidget(
            message: state.message,
          );
        }

        // Schedule deleted - show empty
        if (state is ScheduleDeleted) {
          return const EmptyScheduleWidget(
            message: 'تم حذف الجدول بنجاح.\nقم بإنشاء جدول جديد.',
          );
        }

        // Week schedule loaded - show week view
        if (state is WeekScheduleLoaded) {
          if (state.sessions.isEmpty) {
            return const EmptyScheduleWidget(
              message: 'لا توجد جلسات مجدولة لهذا الأسبوع.',
            );
          }
          return WeekCalendarGrid(
            startDate: state.weekStart,
            sessions: state.sessions,
          );
        }

        // Full schedule loaded - filter for current week
        if (state is FullScheduleLoaded) {
          final now = DateTime.now();
          // Week starts from Saturday (السبت)
          // In Dart: Monday=1, Tuesday=2, ..., Saturday=6, Sunday=7
          // We want Saturday as first day, so calculate days since Saturday
          final daysSinceSaturday = (now.weekday % 7 + 1) % 7;
          final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysSinceSaturday));
          final endOfWeek = startOfWeek.add(const Duration(days: 7));

          final weekSessions = state.sessions.where((session) {
            return session.scheduledDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                   session.scheduledDate.isBefore(endOfWeek);
          }).toList();

          if (weekSessions.isEmpty) {
            return const EmptyScheduleWidget(
              message: 'لا توجد جلسات مجدولة لهذا الأسبوع.',
            );
          }

          return WeekCalendarGrid(
            startDate: startOfWeek,
            sessions: weekSessions,
          );
        }

        // Schedule loaded (today's sessions) - show loading indicator while week data is being fetched
        if (state is ScheduleLoaded) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Default: Show coming soon message
        return _buildComingSoonView(context);
      },
    );
  }

  /// Build coming soon view
  Widget _buildComingSoonView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_view_week, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'عرض الأسبوع',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'قريباً...\n\nسيتم عرض جدول الأسبوع الكامل في تحديث قادم',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Cairo',
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () {
                // Go back to today view
                DefaultTabController.of(context).animateTo(0);
              },
              icon: const Icon(Icons.today),
              label: const Text(
                'العودة إلى جدول اليوم',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error view
  Widget _buildErrorView(BuildContext context, PlannerError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontFamily: 'Cairo'),
            ),
          ],
        ),
      ),
    );
  }
}
