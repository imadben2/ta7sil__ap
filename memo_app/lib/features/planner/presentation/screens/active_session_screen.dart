import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/session_content.dart';
import '../../domain/entities/study_session.dart';
import '../bloc/planner_bloc.dart';
import '../bloc/planner_event.dart';
import '../bloc/planner_state.dart';
import '../bloc/session_timer_cubit.dart';
import '../bloc/session_timer_state.dart';
import '../widgets/mood_selector_widget.dart';
import '../widgets/session_content_list.dart';

/// Modern Active Session Screen
///
/// Full-screen view for running study sessions with modern design
/// Features:
/// - Large countdown timer with circular progress
/// - Session controls (pause/resume/complete)
/// - Subject info header
/// - Stats section
/// - Distraction-free interface
class ActiveSessionScreen extends StatefulWidget {
  final StudySession session;

  const ActiveSessionScreen({super.key, required this.session});

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  // Session content state
  List<SessionContent> _sessionContents = [];
  SessionContentMeta? _contentMeta;
  bool _isLoadingContent = true;
  String? _contentError;

  @override
  void initState() {
    super.initState();
    // Lock to portrait orientation for focus
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Pulse animation for timer
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Breathe animation for glow effect
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    // Start timer only if not already running
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerCubit = context.read<SessionTimerCubit>();
      final currentState = timerCubit.state;

      // Only start new timer if not already running or paused
      if (currentState.status != SessionTimerStatus.running &&
          currentState.status != SessionTimerStatus.paused) {
        timerCubit.startTimer(
          duration: widget.session.duration,
          usePomodoro: widget.session.usePomodoroTechnique,
        );
      }

      // Load session content
      _loadSessionContent();
    });
  }

  void _loadSessionContent() {
    final sessionTypeStr = widget.session.sessionType.toString().split('.').last;
    context.read<PlannerBloc>().add(LoadSessionContentEvent(
      subjectId: widget.session.subjectId,
      sessionType: sessionTypeStr,
      durationMinutes: widget.session.duration.inMinutes,
      // Pass the specific content ID from the session to show only that unit's content
      contentId: widget.session.subjectPlannerContentId,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _breatheController.dispose();
    // Restore orientation preferences
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  /// Reload schedule when leaving this screen
  void _onPopInvoked(bool didPop) {
    if (didPop) {
      // Reload today's schedule to restore ScheduleLoaded state for home/planner
      context.read<PlannerBloc>().add(const LoadTodaysScheduleEvent());
    }
  }

  /// Get subject color from session or generate one based on subject name
  Color get _subjectColor {
    // Use the color stored in the session if available
    if (widget.session.subjectColor != null) {
      return widget.session.subjectColor!;
    }

    // Generate a consistent color based on subject name hash
    final hash = widget.session.subjectName.hashCode;
    final colors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF10B981), // Emerald
      const Color(0xFF14B8A6), // Teal
      const Color(0xFFF97316), // Orange
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFEC4899), // Pink
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF84CC16), // Lime
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) => _onPopInvoked(didPop),
      child: MultiBlocListener(
        listeners: [
          BlocListener<SessionTimerCubit, SessionTimerState>(
          listener: (context, state) {
            if (state.status == SessionTimerStatus.completed && !state.isBreak) {
              // Auto-complete the session when timer reaches zero
              context.read<PlannerBloc>().add(
                CompleteSessionEvent(sessionId: widget.session.id),
              );
              // Navigate back to planner
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          'تم إتمام الجلسة بنجاح! 🎉',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          },
        ),
        BlocListener<PlannerBloc, PlannerState>(
          listener: (context, state) {
            if (state is SessionContentLoading) {
              setState(() {
                _isLoadingContent = true;
                _contentError = null;
              });
            } else if (state is SessionContentLoaded) {
              setState(() {
                _sessionContents = state.contents;
                _contentMeta = state.meta;
                _isLoadingContent = false;
                _contentError = null;
              });
            } else if (state is SessionContentError) {
              setState(() {
                _isLoadingContent = false;
                _contentError = state.message;
              });
            }
          },
        ),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Column(
              children: [
                // Modern App Bar
                _buildModernAppBar(context),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        // Subject Header
                        _buildSubjectHeader(),

                        // Timer Section (Main Content)
                        _buildTimerSection(),

                        // Stats Section
                        _buildStatsSection(),

                        // Content Section
                        _buildContentSection(),
                      ],
                    ),
                  ),
                ),

                // Control Buttons - Fixed at bottom
                _buildControlButtons(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Home button
          _buildAppBarButton(
            icon: Icons.home_rounded,
            onPressed: () => _showHomeDialog(context),
          ),

          // Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: _subjectColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'جلسة نشطة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),

          // Close button
          _buildAppBarButton(
            icon: Icons.close_rounded,
            onPressed: () => _showExitDialog(context),
          ),
        ],
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF64748B), size: 22),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildSubjectHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _subjectColor,
            _subjectColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _subjectColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
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
                  widget.session.subjectName,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (widget.session.chapterName != null)
                  Text(
                    widget.session.chapterName!,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
              ],
            ),
          ),
          // Session type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getSessionTypeArabic(widget.session.sessionType),
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return BlocBuilder<SessionTimerCubit, SessionTimerState>(
      builder: (context, state) {
        // Use state values if timer has been started, otherwise use session duration
        int remainingSeconds = state.totalDuration.inSeconds > 0
            ? state.remainingTime.inSeconds
            : widget.session.duration.inSeconds;
        int totalSeconds = state.totalDuration.inSeconds > 0
            ? state.totalDuration.inSeconds
            : widget.session.duration.inSeconds;

        final isRunning = state.status == SessionTimerStatus.running;
        final isBreak = state.isBreak;

        final progress = totalSeconds > 0
            ? (totalSeconds - remainingSeconds) / totalSeconds
            : 0.0;

        final hours = remainingSeconds ~/ 3600;
        final minutes = (remainingSeconds % 3600) ~/ 60;
        final seconds = remainingSeconds % 60;

        final timerColor = isBreak
            ? const Color(0xFFF59E0B) // Orange for break
            : const Color(0xFF10B981); // Green for study

        return Center(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isRunning ? _pulseAnimation.value : 1.0,
                child: AnimatedBuilder(
                  animation: _breatheAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: isRunning
                            ? [
                                BoxShadow(
                                  color: timerColor.withOpacity(_breatheAnimation.value),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background circle
                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                          ),

                          // Progress ring
                          SizedBox(
                            width: 260,
                            height: 260,
                            child: CustomPaint(
                              painter: _ModernCircularProgressPainter(
                                progress: progress,
                                backgroundColor: timerColor.withOpacity(0.1),
                                progressColor: timerColor,
                                strokeWidth: 12,
                              ),
                            ),
                          ),

                          // Inner content
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Status indicator
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: timerColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isBreak ? Icons.coffee : Icons.school_rounded,
                                      color: timerColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isBreak ? 'استراحة' : (isRunning ? 'جاري' : 'متوقف'),
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: timerColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Time display
                              Text(
                                hours > 0
                                    ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
                                    : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: hours > 0 ? 44 : 56,
                                  fontWeight: FontWeight.bold,
                                  color: timerColor,
                                  letterSpacing: 4,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Progress percentage
                              Text(
                                '${(progress * 100).toInt()}% مكتمل',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return BlocBuilder<SessionTimerCubit, SessionTimerState>(
      builder: (context, state) {
        int completedPomodoros = state.completedPomodoros;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          padding: const EdgeInsets.all(20),
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
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.timer_outlined,
                  label: 'المدة المخططة',
                  value: '${widget.session.duration.inMinutes} دقيقة',
                  color: const Color(0xFF3B82F6),
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: const Color(0xFFE2E8F0),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle_outline,
                  label: 'البومودورو',
                  value: '$completedPomodoros مكتمل',
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.library_books_rounded,
                    color: Color(0xFF3B82F6),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'محتوى الجلسة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                // Phase badge if available
                if (_contentMeta != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPhaseColor(_contentMeta!.phaseToComplete).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _contentMeta!.phaseNameAr,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getPhaseColor(_contentMeta!.phaseToComplete),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Content body
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildContentBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBody() {
    if (_isLoadingContent) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(height: 12),
              Text(
                'جاري تحميل المحتوى...',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_contentError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[300],
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                _contentError!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loadSessionContent,
                child: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_contentMeta != null && !_contentMeta!.hasContent) {
      // Content not available for user's stream - show placeholder
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.hourglass_empty_rounded,
                color: Colors.amber[400],
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                _contentMeta!.placeholderMessage ?? 'سيتم اضافة المحتوى قريبا',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_sessionContents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 40,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'لا يوجد محتوى متاح',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: 'Cairo',
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show actual content using SessionContentList
    return SessionContentList(
      contents: _sessionContents,
      meta: _contentMeta!,
      isLoading: false,
      errorMessage: null,
    );
  }

  Color _getPhaseColor(String phase) {
    return switch (phase) {
      'understanding' => const Color(0xFF3B82F6),
      'review' => const Color(0xFF10B981),
      'theory_practice' => const Color(0xFFF59E0B),
      'exercise_practice' => const Color(0xFF8B5CF6),
      _ => const Color(0xFF3B82F6),
    };
  }

  Widget _buildControlButtons() {
    return BlocBuilder<SessionTimerCubit, SessionTimerState>(
      builder: (context, state) {
        final isRunning = state.status == SessionTimerStatus.running;
        final isBreak = state.isBreak;
        final cubit = context.read<SessionTimerCubit>();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Stop button
              Expanded(
                child: _buildControlButton(
                  icon: Icons.stop_rounded,
                  label: 'إيقاف',
                  color: const Color(0xFFEF4444),
                  onPressed: () {
                    cubit.stopTimer();
                    context.read<PlannerBloc>().add(
                      PauseSessionEvent(widget.session.id),
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Play/Pause button
              Expanded(
                flex: 2,
                child: _buildControlButton(
                  icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  label: isRunning ? 'إيقاف مؤقت' : 'استئناف',
                  color: isRunning
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF10B981),
                  isPrimary: true,
                  onPressed: () {
                    if (isRunning) {
                      cubit.pauseTimer();
                    } else {
                      // If timer is paused, resume it. If it's in any other state (initial, completed, etc.), start new timer
                      if (state.status == SessionTimerStatus.paused) {
                        cubit.resumeTimer();
                      } else {
                        cubit.startTimer(
                          duration: widget.session.duration,
                          usePomodoro: widget.session.usePomodoroTechnique,
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Complete/Skip button
              Expanded(
                child: _buildControlButton(
                  icon: isBreak ? Icons.skip_next_rounded : Icons.check_rounded,
                  label: isBreak ? 'تخطي' : 'إتمام',
                  color: const Color(0xFF3B82F6),
                  onPressed: () {
                    if (isBreak) {
                      cubit.skipBreak();
                    } else {
                      _showCompletionDialog(context);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isPrimary ? 18 : 14,
        ),
        decoration: BoxDecoration(
          color: isPrimary ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : color,
              size: isPrimary ? 28 : 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pause_circle_outline,
                  color: Color(0xFFF59E0B),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'إيقاف الجلسة؟',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'سيتم حفظ تقدمك ويمكنك الاستئناف لاحقاً',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(bottomContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'الاستمرار',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<SessionTimerCubit>().stopTimer();
                        context.read<PlannerBloc>().add(
                          PauseSessionEvent(widget.session.id),
                        );
                        Navigator.pop(bottomContext);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'إيقاف',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }

  void _showHomeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.home_rounded,
                  color: Color(0xFF3B82F6),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'العودة للصفحة الرئيسية؟',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'سيتم إيقاف الجلسة وحفظ تقدمك',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(bottomContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'الاستمرار',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<SessionTimerCubit>().stopTimer();
                        context.read<PlannerBloc>().add(
                          PauseSessionEvent(widget.session.id),
                        );
                        Navigator.pop(bottomContext);
                        context.go('/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'الصفحة الرئيسية',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompletionDialog(BuildContext context) {
    String? selectedMood;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (bottomContext) => StatefulBuilder(
        builder: (builderContext, setState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // Success icon with animation
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF10B981),
                        const Color(0xFF10B981).withOpacity(0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.celebration_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'أحسنت! 🎉',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'أكملت الجلسة بنجاح',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                // Mood selector
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'كيف كان شعورك؟',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                MoodSelectorWidget(
                  onMoodSelected: (mood) {
                    setState(() {
                      selectedMood = mood;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Points indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFFF59E0B),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'ستكسب نقاط عند الإتمام',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[800],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Complete button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: selectedMood == null
                        ? null
                        : () {
                            context.read<PlannerBloc>().add(
                              CompleteSessionEvent(
                                sessionId: widget.session.id,
                                mood: selectedMood,
                              ),
                            );
                            Navigator.pop(bottomContext);
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      disabledBackgroundColor: Colors.grey[300],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      selectedMood == null ? 'اختر مزاجك أولاً' : 'إتمام الجلسة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: selectedMood == null
                            ? Colors.grey[500]
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSessionTypeArabic(SessionType type) {
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
        return 'امتحان';
      case SessionType.longRevision:
        return 'مراجعة مطولة';
    }
  }
}

/// Modern circular progress painter
class _ModernCircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  _ModernCircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ModernCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}
