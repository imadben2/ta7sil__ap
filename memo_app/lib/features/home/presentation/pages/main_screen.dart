import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_design_tokens.dart';
import '../../../../core/services/tab_order_service.dart';
import '../../../../core/widgets/category_chips.dart';
import '../../../../core/widgets/main_app_bar.dart';
import '../../../../core/widgets/modern_bottom_nav.dart';
import '../../../../injection_container.dart';

// Feature imports
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../courses/presentation/pages/my_courses_page.dart';
import '../../../courses/presentation/bloc/subscription/subscription_bloc.dart';
import '../../../courses/presentation/bloc/subscription/subscription_event.dart';
import '../../../courses/presentation/bloc/courses/courses_bloc.dart';
import '../../../courses/presentation/bloc/courses/courses_event.dart';
import '../../../planner/presentation/bloc/planner_bloc.dart';
import '../../../planner/presentation/bloc/planner_event.dart';
import '../../../planner/presentation/screens/planner_main_screen.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../profile/presentation/bloc/profile/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile/profile_event.dart';
import '../../../bac_study_schedule/presentation/bloc/bac_study_bloc.dart';
import '../../../bac_study_schedule/presentation/pages/bac_study_main_page.dart';
import '../../../notifications/presentation/bloc/notifications_bloc.dart';
import '../../../notifications/presentation/bloc/notifications_event.dart';
import '../../../notifications/presentation/bloc/notifications_state.dart';

// Category page views
import 'home_content_view.dart';
import 'planner_preview_view.dart';
import 'content_library_view.dart';
import 'bac_archives_view.dart';
import 'quiz_list_view.dart';
import 'courses_view.dart';

/// Main screen with tab navigation and swipe support
/// Following app_template architecture
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedNavIndex = 0;
  int _selectedCategoryIndex = 0;

  // PageController for swipe navigation between categories
  late PageController _pageController;

  // Tab order service for custom category ordering
  late TabOrderService _tabOrderService;

  // Current category order (enabled tabs only)
  List<int> _categoryOrder = [0, 1, 2, 3, 4, 5];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedCategoryIndex);

    // Initialize tab order service
    _tabOrderService = sl<TabOrderService>();
    _categoryOrder = _tabOrderService.enabledTabsInOrder;

    // Listen for order changes
    _tabOrderService.addListener(_onTabOrderChanged);

    // Load unread notification count
    _loadUnreadNotificationCount();
  }

  /// Load unread notification count for badge
  void _loadUnreadNotificationCount() {
    try {
      context.read<NotificationsBloc>().add(const RefreshUnreadCount());
    } catch (e) {
      // NotificationsBloc might not be available yet
    }
  }

  void _onTabOrderChanged() {
    if (mounted) {
      setState(() {
        _categoryOrder = _tabOrderService.enabledTabsInOrder;
        // Reset to first category when order changes
        _selectedCategoryIndex = 0;
        // Only jump to page if controller is attached
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      });
    }
  }

  @override
  void dispose() {
    _tabOrderService.removeListener(_onTabOrderChanged);
    _pageController.dispose();
    super.dispose();
  }

  /// Handle category selection from chips
  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
    // Animate to the selected page
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Handle page swipe
  void _onPageChanged(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
  }

  /// Handle bottom nav tap
  void _onNavItemTapped(int index) {
    // If tapping home while already on home, reset to first category
    if (index == 0 && _selectedNavIndex == 0) {
      if (_selectedCategoryIndex != 0) {
        setState(() {
          _selectedCategoryIndex = 0;
        });
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
      return;
    }

    // Switching to home from another tab
    if (index == 0 && _selectedNavIndex != 0) {
      setState(() {
        _selectedCategoryIndex = 0;
        _selectedNavIndex = index;
      });
      // Reset PageController position after state update
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients && _pageController.page != 0) {
          _pageController.jumpToPage(0);
        }
      });
      return;
    }

    setState(() {
      _selectedNavIndex = index;
    });
  }

  /// Get user info from auth state
  String? _getUserName(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      return authState.user.firstName;
    }
    return null;
  }

  /// Build the home content with PageView for swipe support
  Widget _buildHomeContent() {
    // Check if user is BAC student
    final authState = context.read<AuthBloc>().state;
    final isBacStudent = authState is Authenticated &&
        authState.user.academicProfile?.phaseId == 3;

    // Build pages using enabled tabs order from _categoryOrder
    List<int> pageIndices = List<int>.from(_categoryOrder);

    // For BAC students, insert category 6 (BAC Study Schedule) if not already present
    if (isBacStudent && !pageIndices.contains(6)) {
      // Find position after بكالوريات (index 3) or at end
      final bacIndex = pageIndices.indexOf(3);
      if (bacIndex != -1) {
        pageIndices.insert(bacIndex + 1, 6);
      } else {
        pageIndices.add(6);
      }
    }

    final pages = pageIndices.map((categoryIndex) {
      return _getCategoryPage(categoryIndex);
    }).toList();

    return PageView(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      // RTL: swipe right to go to previous, swipe left to go to next
      children: pages,
    );
  }

  /// Get the page widget for a specific category index
  Widget _getCategoryPage(int categoryIndex) {
    switch (categoryIndex) {
      case 0:
        return const HomeContentView(); // الرئيسية (Home)
      case 1:
        return const PlannerPreviewView(); // بلانر (Planner preview)
      case 2:
        return const ContentLibraryView(); // ملخصات و دروس (Content Library)
      case 3:
        return const BacArchivesView(); // بكالوريات (BAC Archives)
      case 4:
        return const QuizListView(); // كويز (Quiz)
      case 5:
        // دوراتنا (Our Courses) - with BlocProvider
        return BlocProvider(
          create: (context) => sl<CoursesBloc>()
            ..add(const LoadAllCoursesDataEvent()),
          child: const CoursesView(),
        );
      case 6:
        // جدول البكالوريا (BAC Study Schedule) - Only for Terminale students
        return _buildBacStudySchedulePage();
      default:
        return const HomeContentView();
    }
  }

  /// Build BAC Study Schedule page
  Widget _buildBacStudySchedulePage() {
    final authState = context.read<AuthBloc>().state;
    int streamId = 0;
    if (authState is Authenticated &&
        authState.user.academicProfile?.streamId != null) {
      streamId = authState.user.academicProfile!.streamId!;
    }

    // Use regular BlocProvider instead of BlocProvider.value
    // This ensures each instance gets its own bloc
    return BacStudyMainPage(streamId: streamId);
  }

  /// Build the body based on selected nav index
  Widget _buildBody() {
    switch (_selectedNavIndex) {
      case 0:
        // Home with category swipe
        return _buildHomeContent();
      case 1:
        // دوراتي - My Courses (subscribed courses only)
        return BlocProvider(
          create: (context) => sl<SubscriptionBloc>()
            ..add(const LoadMySubscriptionsEvent()),
          child: const MyCoursesPage(showAppBar: false),
        );
      case 2:
        // الدورات - Courses (browse all courses)
        return BlocProvider(
          create: (context) => sl<CoursesBloc>()
            ..add(const LoadAllCoursesDataEvent()),
          child: const CoursesView(),
        );
      case 3:
        // بلانر - Full Planner (use BlocProvider.value since PlannerBloc is singleton)
        sl<PlannerBloc>().add(const LoadTodaysScheduleEvent());
        return BlocProvider.value(
          value: sl<PlannerBloc>(),
          child: const PlannerMainScreen(showAppBar: false),
        );
      case 4:
        // حسابي - Profile
        return BlocProvider(
          create: (context) => sl<ProfileBloc>()..add(LoadProfile()),
          child: const ProfilePage(showAppBar: false),
        );
      default:
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = _getUserName(context);

    // Check if user is BAC student
    final authState = context.watch<AuthBloc>().state;
    final isBacStudent = authState is Authenticated &&
        authState.user.academicProfile?.phaseId == 3;

    // Build categories list using enabled tabs in order
    // _categoryOrder contains only enabled tab indices from TabOrderService
    List<CategoryItem> displayedCategories = _categoryOrder.map((index) {
      return AppCategories.getCategoryAt(index);
    }).toList();

    // For BAC students, insert category 6 (BAC Study Schedule) if not already present
    if (isBacStudent && !_categoryOrder.contains(6)) {
      // Find position after بكالوريات (index 3) or at end
      final bacIndex = _categoryOrder.indexOf(3);
      if (bacIndex != -1) {
        displayedCategories.insert(bacIndex + 1, AppCategories.getCategoryAt(6));
      } else {
        displayedCategories.add(AppCategories.getCategoryAt(6));
      }
    }

    // Get unread notification count
    int unreadNotificationCount = 0;
    try {
      final notificationsState = context.watch<NotificationsBloc>().state;
      if (notificationsState is NotificationsLoaded) {
        unreadNotificationCount = notificationsState.unreadCount;
      }
    } catch (e) {
      // NotificationsBloc might not be available
    }

    return Scaffold(
      // Only show custom app bar on home tab (index 0)
      appBar: _selectedNavIndex == 0
          ? MainAppBar(
              categories: displayedCategories,
              selectedCategoryIndex: _selectedCategoryIndex,
              onCategorySelected: _onCategorySelected,
              userName: userName,
              streakCount: 0,
              unreadNotificationCount: unreadNotificationCount,
              onProfileTap: () {
                setState(() {
                  _selectedNavIndex = 4; // Go to profile
                });
              },
              onNotificationTap: () {
                context.push('/notifications');
              },
              onHelpTap: () {
                context.push('/user-manual');
              },
            )
          : null,
      body: _buildBody(),
      bottomNavigationBar: ModernBottomNavigationBar(
        selectedIndex: _selectedNavIndex,
        onItemTapped: _onNavItemTapped,
      ),
      // FAB for دوراتنا (Our Courses) - quick access
      // Controlled by AppDesignTokens.enableCourseFAB (default: false)
      floatingActionButton: AppDesignTokens.enableCourseFAB && _selectedNavIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                context.push('/courses');
              },
              backgroundColor: Theme.of(context).primaryColor,
              icon: const Icon(Icons.play_circle_outline, color: Colors.white),
              label: const Text(
                'دوراتنا',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}
