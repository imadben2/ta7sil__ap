import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../bloc/planner_bloc.dart';
import '../bloc/planner_event.dart';
import '../bloc/planner_state.dart';
import '../../domain/entities/study_session.dart';
import 'today_view_screen.dart';
import 'week_view_screen.dart';
import 'full_schedule_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/pdf_font_loader.dart';
import '../../../../core/services/pdf_upload_service.dart';

/// Modern Planner Screen with enhanced UI and segmented tab navigation
///
/// Three views:
/// 1. Today View - Timeline of today's sessions
/// 2. Week View - Calendar grid for the week
/// 3. Full Schedule - List view of all sessions
class PlannerMainScreen extends StatefulWidget {
  final bool showAppBar;

  const PlannerMainScreen({
    Key? key,
    this.showAppBar = true,
  }) : super(key: key);

  @override
  State<PlannerMainScreen> createState() => _PlannerMainScreenState();
}

class _PlannerMainScreenState extends State<PlannerMainScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  int _currentTabIndex = 0;
  bool _hasLoadedInitially = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Load sessions only once on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasLoadedInitially) {
        _hasLoadedInitially = true;
        _loadSessionsForCurrentTab();
      }
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return; // Ignore during animation

    final newIndex = _tabController.index;
    if (newIndex != _currentTabIndex) {
      setState(() {
        _currentTabIndex = newIndex;
      });
      // Load appropriate data for the new tab
      _loadSessionsForCurrentTab();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload sessions when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _loadSessionsForCurrentTab();
    }
  }

  void _loadSessionsForCurrentTab() {
    if (!mounted) return;

    final bloc = context.read<PlannerBloc>();
    final currentState = bloc.state;

    // Only reload if not already loading or generating
    if (currentState is PlannerLoading || currentState is GeneratingSchedule) {
      return;
    }

    debugPrint('[PlannerMainScreen] Loading sessions for tab $_currentTabIndex...');

    // First, check and mark past sessions as missed (including breaks and prayer times)
    bloc.add(const CheckSessionLifecycleEvent());

    switch (_currentTabIndex) {
      case 0: // Today view
        bloc.add(const LoadTodaysScheduleEvent());
        break;
      case 1: // Week view
        final now = DateTime.now();
        // Week starts from Saturday (السبت)
        // In Dart: Monday=1, ..., Saturday=6, Sunday=7
        final daysSinceSaturday = (now.weekday % 7 + 1) % 7;
        final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysSinceSaturday));
        bloc.add(LoadWeekScheduleEvent(weekStart));
        break;
      case 2: // Full schedule view
        bloc.add(const LoadFullScheduleEvent());
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // RTL for Arabic
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        body: SafeArea(
          child: Column(
            children: [
              // Modern Header
              _buildModernHeader(context),

              // Segmented Tab Selector
              _buildModernTabSelector(),

              const SizedBox(height: 16),

              // Content Area
              Expanded(
                child: BlocConsumer<PlannerBloc, PlannerState>(
                  listener: (context, state) {
                    debugPrint('[PlannerMainScreen] State changed: ${state.runtimeType}');

                    // Show success messages
                    if (state is ScheduleGenerated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(state.message)),
                            ],
                          ),
                          backgroundColor: AppColors.emerald500,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );

                      // Reload today's schedule
                      context.read<PlannerBloc>().add(
                        const LoadTodaysScheduleEvent(),
                      );
                    }

                    // Reload schedule when session content is loaded (coming back from detail screen)
                    if (state is SessionContentLoaded || state is SessionContentError) {
                      // Small delay to let the pop animation finish
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          _loadSessionsForCurrentTab();
                        }
                      });
                    }

                    // Show error messages
                    if (state is PlannerError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(state.message)),
                            ],
                          ),
                          backgroundColor: AppColors.red500,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          action: state.canRetry
                              ? SnackBarAction(
                                  label: 'إعادة المحاولة',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    context.read<PlannerBloc>().add(
                                      const RefreshScheduleEvent(),
                                    );
                                  },
                                )
                              : null,
                        ),
                      );
                    }

                    // Show session completion success with confetti
                    if (state is SessionCompleted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.celebration_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  state.message,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.emerald500,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }

                    // Show schedule deleted success
                    // Note: NoScheduleAvailable is emitted directly after ScheduleDeleted in bloc
                    if (state is ScheduleDeleted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(state.message)),
                            ],
                          ),
                          backgroundColor: AppColors.emerald500,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                      // NoScheduleAvailable is emitted by bloc, no need to reload
                    }
                  },
                  builder: (context, state) {
                    // Show schedule generation progress
                    if (state is GeneratingSchedule) {
                      return _buildGeneratingProgress(state.progress);
                    }

                    // Show tabs with content
                    return TabBarView(
                      controller: _tabController,
                      children: const [
                        TodayViewScreen(),
                        WeekViewScreen(),
                        FullScheduleScreen(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title with icon
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.go('/home'),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Flexible(
                  child: Text(
                    'المخطط الذكي',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Action dropdown menu
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 22,
              ),
              padding: EdgeInsets.zero,
              tooltip: 'القائمة',
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              offset: const Offset(0, 50),
              elevation: 8,
              onSelected: (value) {
                switch (value) {
                  case 'home':
                    context.go('/home');
                    break;
                  case 'generate':
                    _navigateToScheduleWizard(context);
                    break;
                  case 'export':
                    _exportScheduleToPdf(context);
                    break;
                  case 'delete':
                    _showDeleteConfirmDialog(context);
                    break;
                  case 'settings':
                    context.push('/planner/settings');
                    break;
                  case 'statistics':
                    context.push('/planner/statistics');
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'home',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'الصفحة الرئيسية',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'generate',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'إنشاء جدول جديد',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'export',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Color(0xFF3B82F6),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'تصدير إلى PDF',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.red500.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_rounded,
                          color: AppColors.red500,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'حذف الجدول',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'إعدادات المخطط',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'statistics',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06B6D4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.bar_chart_rounded,
                          color: Color(0xFF06B6D4),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'إحصائيات الجدول',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabButton(
            index: 0,
            icon: Icons.today_rounded,
            label: 'اليوم',
            badge: _getTodayBadgeCount(),
          ),
          _buildTabButton(
            index: 1,
            icon: Icons.calendar_view_week_rounded,
            label: 'الأسبوع',
          ),
          _buildTabButton(
            index: 2,
            icon: Icons.view_list_rounded,
            label: 'الجدول الكامل',
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required String label,
    int? badge,
  }) {
    final isSelected = _currentTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Colors.white : AppColors.slate600,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.slate600,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (badge != null && badge > 0)
                Positioned(
                  top: 0,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.red500,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    constraints: const BoxConstraints(minWidth: 20),
                    child: Text(
                      badge.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  int? _getTodayBadgeCount() {
    final state = context.read<PlannerBloc>().state;
    if (state is ScheduleLoaded) {
      final pending = state.sessions
          .where((s) => s.status.toString().contains('scheduled'))
          .length;
      return pending > 0 ? pending : null;
    }
    return null;
  }

  /// Build modern schedule generation progress indicator
  Widget _buildGeneratingProgress(int progress) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: progress / 100,
                    strokeWidth: 10,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.primary,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$progress%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'جاري إنشاء الجدول الدراسي...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getProgressMessage(progress),
              style: const TextStyle(fontSize: 15, color: AppColors.slate600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Get progress message based on percentage
  String _getProgressMessage(int progress) {
    if (progress < 30) return 'تحميل الإعدادات والمواد الدراسية...';
    if (progress < 60) return 'حساب الأولويات وتحليل البيانات...';
    if (progress < 90) return 'توزيع الجلسات وتحسين الجدول...';
    return 'حفظ الجدول والمزامنة...';
  }

  /// Navigate to schedule wizard screen
  void _navigateToScheduleWizard(BuildContext context) async {
    final result = await context.push<bool>('/planner/wizard');
    // If schedule was created (result == true), refresh the schedule
    if (result == true && mounted) {
      context.read<PlannerBloc>().add(const LoadTodaysScheduleEvent());
    }
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.red[400], size: 28),
              const SizedBox(width: 12),
              const Text(
                'تأكيد الحذف',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'هل أنت متأكد من حذف الجدول الدراسي بالكامل؟',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                'سيتم حذف جميع الجلسات المجدولة ولا يمكن التراجع عن هذا الإجراء.',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'إلغاء',
                style: TextStyle(fontFamily: 'Cairo', color: AppColors.slate600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<PlannerBloc>().add(const DeleteScheduleEvent());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.delete_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text('جاري حذف الجدول...'),
                      ],
                    ),
                    backgroundColor: AppColors.red500,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'حذف الجدول',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Export schedule to PDF - All sessions in Arabic (RTL)
  Future<void> _exportScheduleToPdf(BuildContext context) async {
    final bloc = context.read<PlannerBloc>();

    // Show loading message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('جاري تحميل الجلسات...', style: TextStyle(fontFamily: 'Cairo')),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Load ALL sessions from the full schedule
    bloc.add(const LoadFullScheduleEvent());

    // Wait for state to update (give it more time to load all sessions)
    await Future.delayed(const Duration(milliseconds: 1000));

    final state = bloc.state;
    List<StudySession> sessions = [];

    if (state is FullScheduleLoaded) {
      sessions = state.sessions;
      print('📋 FullScheduleLoaded: ${sessions.length} sessions');
    } else if (state is WeekScheduleLoaded) {
      sessions = state.sessions;
      print('📋 WeekScheduleLoaded: ${sessions.length} sessions');
    } else if (state is ScheduleLoaded) {
      sessions = state.sessions;
      print('📋 ScheduleLoaded: ${sessions.length} sessions');
    } else {
      print('📋 State type: ${state.runtimeType}');
    }

    if (sessions.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('لا توجد جلسات للتصدير', style: TextStyle(fontFamily: 'Cairo')),
              ],
            ),
            backgroundColor: AppColors.slate600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return;
    }

    try {
      // Show PDF generation message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text('جاري إنشاء ملف PDF (${sessions.length} جلسة)...', style: const TextStyle(fontFamily: 'Cairo')),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Load Arabic fonts for PDF
      final fontsLoaded = await PdfFontLoader.loadFonts();
      if (!fontsLoaded) {
        print('⚠️ Arabic fonts not loaded - PDF may not display Arabic correctly');
      }

      // Get Arabic theme with Cairo font
      final arabicTheme = PdfFontLoader.getArabicTheme();

      // Create PDF document
      final pdf = pw.Document();

      // Get today's date (start of day)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Filter sessions for TODAY only (exclude breaks and prayer times)
      final todaySessions = sessions.where((session) {
        if (session.isBreak || session.isPrayerTime) return false;
        final sessionDate = DateTime(
          session.scheduledDate.year,
          session.scheduledDate.month,
          session.scheduledDate.day,
        );
        return sessionDate.isAtSameMomentAs(today);
      }).toList();

      // Sort today's sessions by time
      todaySessions.sort((a, b) =>
        a.scheduledStartTime.hour * 60 + a.scheduledStartTime.minute -
        (b.scheduledStartTime.hour * 60 + b.scheduledStartTime.minute)
      );

      // Calculate statistics for today only
      final totalSessions = todaySessions.length;
      final completedSessions = todaySessions.where((s) => s.isCompleted).length;
      final totalMinutes = todaySessions.fold<int>(0, (sum, s) => sum + s.duration.inMinutes);
      final totalHours = (totalMinutes / 60).toStringAsFixed(1);

      // Format dates with Western numbers (use 'en' locale for numbers)
      final dateFormatter = DateFormat('dd/MM/yyyy', 'en');
      final timeFormatter = DateFormat('HH:mm', 'en');

      // Add pages with Arabic fonts (RTL)
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,  // Right-to-left for Arabic
          theme: arabicTheme,
          build: (context) => [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'جدول الدراسة - المخطط الذكي',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'تاريخ التصدير: ${dateFormatter.format(now)}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '${_getArabicDayName(today)} - ${dateFormatter.format(today)}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),

            // Statistics summary
            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'الإحصائيات',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('الجلسات المكتملة: $completedSessions'),
                      pw.Text('إجمالي الجلسات: $totalSessions'),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('عدد الأيام: 1'),
                      pw.Text('إجمالي الساعات: $totalHours س'),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // Today's sessions table
            if (todaySessions.isNotEmpty) ...[
              // Date header
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      '$totalSessions جلسة',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      '${_getArabicDayName(today)} - ${dateFormatter.format(today)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),

              // Sessions table (columns ordered for RTL display: الحالة، النوع، المدة، الوقت، المادة)
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Header row (reversed order for RTL)
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey100,
                    ),
                    children: [
                      _buildPdfTableCell('الحالة', isHeader: true),
                      _buildPdfTableCell('النوع', isHeader: true),
                      _buildPdfTableCell('المدة', isHeader: true),
                      _buildPdfTableCell('الوقت', isHeader: true),
                      _buildPdfTableCell('المادة', isHeader: true),
                    ],
                  ),
                  // Data rows (reversed order for RTL)
                  ...todaySessions.map((session) => pw.TableRow(
                    children: [
                      _buildPdfTableCell(_getStatusTextAr(session.status)),
                      _buildPdfTableCell(_getSessionTypeTextAr(session.sessionType, session.rawSessionType)),
                      _buildPdfTableCell('${session.duration.inMinutes} د'),
                      _buildPdfTableCell(
                        '${_formatTimeOfDay(session.scheduledStartTime)} - ${_formatTimeOfDay(session.scheduledEndTime)}',
                      ),
                      _buildPdfTableCell(session.subjectName),
                    ],
                  )),
                ],
              ),
            ] else ...[
              pw.Center(
                child: pw.Text(
                  'لا توجد جلسات لهذا اليوم',
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ),
            ],

            // Footer
            pw.SizedBox(height: 32),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                'تم إنشاء التقرير بواسطة تطبيق MEMO - ${dateFormatter.format(now)} ${timeFormatter.format(now)}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey,
                ),
              ),
            ),
          ],
        ),
      );

      // Save PDF locally first using temp directory (always works)
      final tempDir = await getTemporaryDirectory();

      // Use dashes in filename to avoid path issues (not slashes!)
      final safeDate = DateFormat('dd-MM-yyyy').format(now);
      final fileName = 'MEMO_Schedule_$safeDate.pdf';
      final file = File('${tempDir.path}/$fileName');

      // Save PDF bytes to temp file
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);
      print('✅ PDF saved locally: ${file.path}');

      // Upload PDF to server (memo_api/public/planner/)
      String? serverUrl;
      try {
        print('📤 Uploading PDF to server...');
        print('   File: ${file.path}');
        print('   FileName: $fileName');

        final uploadService = PdfUploadService();
        final uploadResponse = await uploadService.uploadPdf(
          filePath: file.path,
          fileName: fileName,
          type: 'schedule',
        );
        serverUrl = uploadResponse.data.url;
        print('✅ PDF uploaded to server: $serverUrl');
      } catch (e, stackTrace) {
        print('❌ Failed to upload PDF to server: $e');
        print('   Stack: $stackTrace');
        // Continue anyway - PDF is saved locally
      }

      if (mounted) {
        // Show success dialog with option to share (Arabic)
        showDialog(
          context: context,
          builder: (dialogContext) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.emerald500.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.emerald500,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'تم إنشاء ملف PDF بنجاح!',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تم تصدير جدول اليوم ($totalSessions جلسة)',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.picture_as_pdf_rounded,
                              color: Color(0xFFDC2626),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                fileName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (serverUrl != null) ...[
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Icon(
                                Icons.cloud_done_rounded,
                                color: Color(0xFF10B981),
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'تم الرفع على الخادم',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'إغلاق',
                    style: TextStyle(fontFamily: 'Cairo', color: AppColors.slate600),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    // Share the file
                    await Share.shareXFiles(
                      [XFile(file.path)],
                      subject: 'جدول الدراسة MEMO',
                      text: serverUrl != null
                          ? 'جدول دراستي من تطبيق MEMO\n\nالرابط: $serverUrl'
                          : 'جدول دراستي من تطبيق MEMO',
                    );
                  },
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text(
                    'مشاركة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
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
    } catch (e) {
      print('❌ PDF export error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('خطأ في التصدير: ${e.toString()}', style: const TextStyle(fontFamily: 'Cairo'))),
              ],
            ),
            backgroundColor: AppColors.red500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  /// Helper to build PDF table cell (Arabic version - RTL)
  pw.Widget _buildPdfTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// Format TimeOfDay to string
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get session type text in Arabic for PDF
  /// Uses rawSessionType if available for more accurate display
  String _getSessionTypeTextAr(SessionType type, [String? rawSessionType]) {
    // If we have the raw API session type, use it for more accurate labels
    if (rawSessionType != null) {
      switch (rawSessionType) {
        case 'lesson_review':
          return 'درس';
        case 'exercises':
          return 'تمارين';
        case 'topic_test':
          return 'اختبار';
        case 'unit_test':
          return 'اختبار وحدة';
        case 'spaced_review':
          return 'مراجعة';
        case 'language_daily':
          return 'لغة';
        case 'mock_test':
          return 'اختبار تجريبي';
        case 'break':
          return 'استراحة';
        case 'study':
          return 'دراسة';
      }
    }

    // Fallback to SessionType enum
    switch (type) {
      case SessionType.study:
        return 'دراسة';
      case SessionType.regular:
        return 'عادية';
      case SessionType.revision:
        return 'مراجعة';
      case SessionType.practice:
        return 'تمارين';
      case SessionType.exam:
        return 'اختبار';
      case SessionType.longRevision:
        return 'مراجعة شاملة';
    }
  }

  /// Get status text in Arabic for PDF
  String _getStatusTextAr(SessionStatus status) {
    switch (status) {
      case SessionStatus.scheduled:
        return 'مجدولة';
      case SessionStatus.inProgress:
        return 'جارية';
      case SessionStatus.paused:
        return 'متوقفة';
      case SessionStatus.completed:
        return 'مكتملة';
      case SessionStatus.missed:
        return 'فائتة';
      case SessionStatus.skipped:
        return 'متخطاة';
    }
  }

  /// Get Arabic day name from date
  String _getArabicDayName(DateTime date) {
    const arabicDays = {
      1: 'الإثنين',
      2: 'الثلاثاء',
      3: 'الأربعاء',
      4: 'الخميس',
      5: 'الجمعة',
      6: 'السبت',
      7: 'الأحد',
    };
    return arabicDays[date.weekday] ?? '';
  }
}
