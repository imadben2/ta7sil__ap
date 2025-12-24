import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

/// Planner Shell with Bottom Navigation
///
/// Provides unified navigation for planner ecosystem:
/// - Schedule (الجدول)
/// - Subjects (المواد)
/// - Exams (الاختبارات)
/// - Analytics (التحليلات)
class PlannerShell extends StatelessWidget{
  final StatefulNavigationShell navigationShell;

  const PlannerShell({
    Key? key,
    required this.navigationShell,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: Colors.white,
          elevation: 0,
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            // Tab 1: Schedule (الجدول)
            NavigationDestination(
              icon: Icon(
                Icons.calendar_today_outlined,
                color: _getIconColor(0, context),
              ),
              selectedIcon: Icon(
                Icons.calendar_today,
                color: AppColors.primary,
              ),
              label: 'الجدول',
            ),

            // Tab 2: Subjects (المواد)
            NavigationDestination(
              icon: Icon(
                Icons.book_outlined,
                color: _getIconColor(1, context),
              ),
              selectedIcon: Icon(
                Icons.book,
                color: AppColors.primary,
              ),
              label: 'المواد',
            ),

            // Tab 3: Exams (الاختبارات)
            NavigationDestination(
              icon: Icon(
                Icons.assignment_outlined,
                color: _getIconColor(2, context),
              ),
              selectedIcon: Icon(
                Icons.assignment,
                color: AppColors.primary,
              ),
              label: 'الاختبارات',
            ),

            // Tab 4: Analytics (التحليلات)
            NavigationDestination(
              icon: Icon(
                Icons.analytics_outlined,
                color: _getIconColor(3, context),
              ),
              selectedIcon: Icon(
                Icons.analytics,
                color: AppColors.primary,
              ),
              label: 'التحليلات',
            ),
          ],
        ),
      ),
    );
  }

  Color _getIconColor(int index, BuildContext context) {
    return navigationShell.currentIndex == index
        ? AppColors.primary
        : Colors.grey.shade600;
  }

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
