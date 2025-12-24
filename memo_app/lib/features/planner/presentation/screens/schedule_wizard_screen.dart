import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/schedule.dart';
import '../bloc/planner_bloc.dart';
import '../bloc/planner_event.dart';
import '../bloc/planner_state.dart';
import '../bloc/subjects_bloc.dart';
import '../bloc/subjects_state.dart';
import '../bloc/subjects_event.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';

/// Modern Schedule Generation Wizard
///
/// Beautiful, step-by-step interface for creating study schedules
class ScheduleWizardScreen extends StatefulWidget {
  /// Optional pre-selected subject IDs (e.g., when starting from exam preparation)
  final List<String>? preSelectedSubjectIds;

  /// Optional exam date to focus preparation around
  final DateTime? examDate;

  const ScheduleWizardScreen({
    Key? key,
    this.preSelectedSubjectIds,
    this.examDate,
  }) : super(key: key);

  @override
  State<ScheduleWizardScreen> createState() => _ScheduleWizardScreenState();
}

class _ScheduleWizardScreenState extends State<ScheduleWizardScreen>
    with SingleTickerProviderStateMixin {
  DateTime? _startDate;
  DateTime? _endDate;
  final Set<String> _selectedSubjectIds = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _startFromNow = true; // New option: start from current time
  bool _isGenerating = false;
  int _generationProgress = 0;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();

    // If exam date provided, set end date to exam date, otherwise 30 days
    _endDate = widget.examDate ?? DateTime.now().add(const Duration(days: 30));

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    // Trigger subjects loading and settings loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectsBloc>().add(const LoadSubjectsEvent());
      context.read<SettingsCubit>().loadSettings();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PlannerBloc, PlannerState>(
          listener: (context, state) {
            if (state is GeneratingSchedule) {
              setState(() {
                _generationProgress = state.progress;
              });
            }
            if (state is ScheduleGenerated) {
              // Schedule generated successfully, go back to planner with refresh flag
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
              // Pop back to planner and pass true to indicate refresh needed
              if (context.canPop()) {
                context.pop(true); // Return true to indicate schedule was created
              } else {
                context.go('/planner?refresh=true');
              }
            }
            if (state is PlannerError) {
              setState(() {
                _isGenerating = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<SettingsCubit, SettingsState>(
          listener: (context, state) {
            // Load previously selected subjects from settings when settings are loaded
            if (state.hasSettings && _selectedSubjectIds.isEmpty) {
              setState(() {
                _selectedSubjectIds.addAll(state.settings!.selectedSubjectIds);
              });
              debugPrint('[Wizard] Loaded ${_selectedSubjectIds.length} selected subjects from settings');
            }
          },
        ),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              body: CustomScrollView(
                slivers: [
                  _buildModernAppBar(),
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: BlocBuilder<SubjectsBloc, SubjectsState>(
                        builder: (context, state) {
                          if (state is SubjectsLoading) {
                            return _buildLoadingState();
                          }

                          if (state is SubjectsError) {
                            return _buildErrorState(state.message);
                          }

                          if (state is SubjectsLoaded) {
                            return _buildWizardContent(state.subjects);
                          }

                          // Initial state - show loading
                          return _buildLoadingState();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: _buildModernGenerateButton(),
            ),
            // Loading overlay
            if (_isGenerating) _buildGeneratingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
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
                      value: _generationProgress / 100,
                      strokeWidth: 10,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF6366F1),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFF6366F1),
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_generationProgress%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
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
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getProgressMessage(int progress) {
    if (progress < 30) return 'تحميل الإعدادات والمواد الدراسية...';
    if (progress < 60) return 'حساب الأولويات وتحليل البيانات...';
    if (progress < 90) return 'توزيع الجلسات وتحسين الجدول...';
    return 'حفظ الجدول والمزامنة...';
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home_rounded, color: Colors.white),
          onPressed: () => context.go('/home'),
          tooltip: 'الصفحة الرئيسية',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 60,
                right: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                right: 24,
                left: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'إنشاء جدول دراسي',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'خطط لنجاحك الدراسي',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          const Text(
            'جاري تحميل المواد...',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWizardContent(List<Subject> subjects) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicator
          _buildStepIndicator(),
          const SizedBox(height: 32),

          // Date Selection Section
          _buildModernSectionHeader(
            'الفترة الزمنية',
            'حدد متى تريد أن يبدأ جدولك وينتهي',
            Icons.calendar_month_rounded,
          ),
          const SizedBox(height: 16),
          _buildModernDateSelection(),
          const SizedBox(height: 16),

          // Start Time Option
          _buildStartTimeOption(),
          const SizedBox(height: 32),

          // Subject Selection Section
          _buildModernSectionHeader(
            'المواد الدراسية',
            'اختر المواد التي تريد التركيز عليها',
            Icons.school_rounded,
          ),
          const SizedBox(height: 4),
          _buildSelectAllButton(subjects),
          const SizedBox(height: 12),
          _buildModernSubjectsList(subjects),
          const SizedBox(height: 100), // Space for bottom button
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خطوات بسيطة لجدول ممتاز',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'اختر التواريخ والمواد، ثم دعنا نقوم بالباقي',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSectionHeader(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernDateSelection() {
    final days = _startDate != null && _endDate != null
        ? _endDate!.difference(_startDate!).inDays
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildModernDateField(
            label: 'تاريخ البداية',
            date: _startDate,
            icon: Icons.play_circle_outline_rounded,
            color: const Color(0xFF10B981),
            onTap: () async {
              final picked = await _showModernDatePicker(
                initialDate: _startDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  _startDate = picked;
                  if (_endDate != null && _endDate!.isBefore(_startDate!)) {
                    _endDate = _startDate!.add(const Duration(days: 7));
                  }
                });
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: Colors.grey[200]),
          ),
          _buildModernDateField(
            label: 'تاريخ النهاية',
            date: _endDate,
            icon: Icons.stop_circle_outlined,
            color: const Color(0xFFEF4444),
            onTap: () async {
              final picked = await _showModernDatePicker(
                initialDate:
                    _endDate ?? DateTime.now().add(const Duration(days: 30)),
                firstDate: _startDate ?? DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                if (_startDate != null && picked.isBefore(_startDate!)) {
                  // Show error if end date is before start date
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تاريخ النهاية يجب أن يكون بعد تاريخ البداية',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  setState(() => _endDate = picked);
                }
              }
            },
          ),
          if (days > 0)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'المدة الإجمالية: $days يوم',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Build start time option widget
  Widget _buildStartTimeOption() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _startFromNow = !_startFromNow;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _startFromNow
                        ? Icons.access_time_rounded
                        : Icons.schedule_rounded,
                    color: const Color(0xFF6366F1),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _startFromNow
                            ? 'البدء من الوقت الحالي'
                            : 'البدء من بداية اليوم',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _startFromNow
                            ? 'سيبدأ الجدول من الوقت الحالي'
                            : 'سيبدأ من وقت البداية المحدد في الإعدادات',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Cairo',
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Switch
                Switch(
                  value: _startFromNow,
                  onChanged: (value) {
                    setState(() {
                      _startFromNow = value;
                    });
                  },
                  activeColor: const Color(0xFF6366F1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildModernDateField({
    required String label,
    required DateTime? date,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null ? _formatDate(date) : 'اختر التاريخ',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_left_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _showModernDatePicker({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
              ),
            ),
            child: child!,
          ),
        );
      },
    );
  }

  Widget _buildSelectAllButton(List<Subject> subjects) {
    final allSelected = _selectedSubjectIds.length == subjects.length;

    return TextButton.icon(
      onPressed: () {
        setState(() {
          if (allSelected) {
            _selectedSubjectIds.clear();
          } else {
            _selectedSubjectIds.addAll(subjects.map((s) => s.id));
          }
        });
      },
      icon: Icon(
        allSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
        size: 20,
      ),
      label: Text(
        allSelected ? 'إلغاء تحديد الكل' : 'تحديد الكل',
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
      ),
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
    );
  }

  Widget _buildModernSubjectsList(List<Subject> subjects) {
    if (subjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'لا توجد مواد دراسية',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: subjects.asMap().entries.map((entry) {
        final index = entry.key;
        final subject = entry.value;
        final isSelected = _selectedSubjectIds.contains(subject.id);

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _buildModernSubjectCard(subject, isSelected),
        );
      }).toList(),
    );
  }

  Widget _buildModernSubjectCard(Subject subject, bool isSelected) {
    final color = _parseColor(subject.colorHex);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? color : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedSubjectIds.remove(subject.id);
            } else {
              _selectedSubjectIds.add(subject.id);
            }
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.8), color],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getIcon(subject.iconName),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.nameAr,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.grade_rounded, size: 14, color: color),
                              const SizedBox(width: 4),
                              Text(
                                'المعامل: ${subject.coefficient}',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 18,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernGenerateButton() {
    // Validate date range
    final isDateRangeValid = _startDate != null &&
        _endDate != null &&
        !_endDate!.isBefore(_startDate!);

    // Require at least one subject to be selected
    final hasSelectedSubjects = _selectedSubjectIds.isNotEmpty;

    final canGenerate = isDateRangeValid && hasSelectedSubjects;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: canGenerate ? _generateSchedule : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canGenerate ? AppColors.primary : Colors.grey[300],
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[500],
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: canGenerate ? 4 : 0,
            shadowColor: AppColors.primary.withOpacity(0.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 24),
              const SizedBox(width: 12),
              Text(
                canGenerate
                    ? 'إنشاء الجدول (${_selectedSubjectIds.length} ${_selectedSubjectIds.length == 1 ? 'مادة' : 'مواد'})'
                    : _selectedSubjectIds.isEmpty && isDateRangeValid
                        ? 'يرجى اختيار مادة واحدة على الأقل'
                        : !isDateRangeValid && _startDate != null && _endDate != null
                            ? 'تاريخ النهاية يجب أن يكون بعد تاريخ البداية'
                            : 'أكمل اختيار التواريخ',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateSchedule() {
    if (_startDate != null && _endDate != null) {
      setState(() {
        _isGenerating = true;
        _generationProgress = 0;
      });

      // Calculate schedule type based on duration
      final days = _endDate!.difference(_startDate!).inDays;
      ScheduleType scheduleType;
      if (days <= 1) {
        scheduleType = ScheduleType.daily;
      } else if (days <= 7) {
        scheduleType = ScheduleType.weekly;
      } else {
        scheduleType = ScheduleType.full;
      }

      debugPrint('[Wizard] Generating schedule:');
      debugPrint('[Wizard] startDate: $_startDate');
      debugPrint('[Wizard] endDate: $_endDate');
      debugPrint('[Wizard] days: $days');
      debugPrint('[Wizard] scheduleType: ${scheduleType.name}');
      debugPrint('[Wizard] selectedSubjectIds: $_selectedSubjectIds');

      // Only generate if we have selected subjects
      if (_selectedSubjectIds.isNotEmpty) {
        // Save selected subjects to settings for persistence
        context.read<SettingsCubit>().updateSelectedSubjectIds(
          _selectedSubjectIds.toList(),
        );

        // Generate schedule
        context.read<PlannerBloc>().add(
          GenerateScheduleEvent(
            startDate: _startDate!,
            endDate: _endDate!,
            startFromNow: _startFromNow,
            scheduleType: scheduleType,
            selectedSubjectIds: _selectedSubjectIds.toList(),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    const arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'إبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${date.day} ${arabicMonths[date.month - 1]} ${date.year}';
  }

  Color _parseColor(String colorHex) {
    try {
      final hex = colorHex.replaceAll('#', '');
      final colorValue = hex.length == 6 ? 'FF$hex' : hex;
      return Color(int.parse(colorValue, radix: 16));
    } catch (e) {
      return AppColors.primary;
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'calculator':
        return Icons.calculate_rounded;
      case 'atom':
        return Icons.science_rounded;
      case 'leaf':
        return Icons.eco_rounded;
      case 'book':
        return Icons.menu_book_rounded;
      case 'language':
        return Icons.translate_rounded;
      case 'globe':
        return Icons.public_rounded;
      case 'brain':
        return Icons.psychology_rounded;
      case 'map':
        return Icons.map_rounded;
      case 'mosque':
        return Icons.mosque_rounded;
      default:
        return Icons.book_rounded;
    }
  }
}
