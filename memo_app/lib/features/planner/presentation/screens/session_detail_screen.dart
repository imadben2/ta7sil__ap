import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/study_session.dart';
import '../../domain/entities/prioritized_subject.dart';
import '../../domain/entities/session_content.dart';
import '../bloc/planner_bloc.dart';
import '../bloc/planner_event.dart';
import '../bloc/planner_state.dart';
import '../widgets/session_content_list.dart';

/// Modern Session Detail Screen
///
/// Shows comprehensive information about a study session with modern design
class SessionDetailScreen extends StatefulWidget {
  final StudySession session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  late Duration _remainingTime;
  late Duration _totalDuration;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Session content state
  List<SessionContent> _sessionContents = [];
  SessionContentMeta? _contentMeta;
  bool _isLoadingContent = false;
  String? _contentError;

  @override
  void initState() {
    super.initState();
    _initializeTimer();

    // Pulse animation for active timer
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.session.status == SessionStatus.inProgress) {
      _startTimer();
    }

    // Load session content
    _loadSessionContent();
  }

  void _loadSessionContent() {
    final sessionTypeStr = widget.session.sessionType.toString().split('.').last;
    debugPrint('[SessionDetailScreen] Loading content for session ${widget.session.id}');
    debugPrint('[SessionDetailScreen] subjectPlannerContentId: ${widget.session.subjectPlannerContentId}');
    debugPrint('[SessionDetailScreen] contentTitle: ${widget.session.contentTitle}');
    context.read<PlannerBloc>().add(LoadSessionContentEvent(
      subjectId: widget.session.subjectId,
      sessionType: sessionTypeStr,
      durationMinutes: widget.session.duration.inMinutes,
      // Pass the specific content ID from the session to show only that unit's content
      contentId: widget.session.subjectPlannerContentId,
    ));
  }

  void _handlePhaseComplete(String contentId, String phase) {
    context.read<PlannerBloc>().add(MarkContentPhaseCompleteEvent(
      contentId: contentId,
      phase: phase,
      durationMinutes: 0,
    ));
    // Refresh content list after marking complete
    _loadSessionContent();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  /// Reload schedule when leaving this screen
  void _onPopInvoked(bool didPop) {
    if (didPop) {
      // Reload today's schedule to restore ScheduleLoaded state for home/planner
      context.read<PlannerBloc>().add(const LoadTodaysScheduleEvent());
    }
  }

  void _initializeTimer() {
    _totalDuration = widget.session.duration;

    if (widget.session.actualStartTime != null &&
        widget.session.status == SessionStatus.inProgress) {
      final elapsed = DateTime.now().difference(widget.session.actualStartTime!);
      _remainingTime = _totalDuration - elapsed;
      if (_remainingTime.isNegative) {
        _remainingTime = Duration.zero;
      }
    } else {
      _remainingTime = _totalDuration;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  String get _formattedTime {
    final hours = _remainingTime.inHours;
    final minutes = _remainingTime.inMinutes.remainder(60);
    final seconds = _remainingTime.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (_totalDuration.inSeconds == 0) return 0;
    // Calculate elapsed progress (0% at start → 100% at end)
    return 1.0 - (_remainingTime.inSeconds / _totalDuration.inSeconds);
  }

  Color get _subjectColor {
    // Break sessions use green color
    if (widget.session.isBreak) {
      return const Color(0xFF10B981);
    }

    final colors = {
      'رياضيات': const Color(0xFF3B82F6),
      'فيزياء': const Color(0xFF8B5CF6),
      'كيمياء': const Color(0xFF10B981),
      'علوم': const Color(0xFF14B8A6),
      'فلسفة': const Color(0xFFF97316),
      'عربية': const Color(0xFF78716C),
      'فرنسية': const Color(0xFF6366F1),
      'إنجليزية': const Color(0xFF06B6D4),
      'اللغة الفرنسية': const Color(0xFF6366F1),
      'اللغة العربية': const Color(0xFF78716C),
      'اللغة الإنجليزية': const Color(0xFF06B6D4),
    };
    return colors[widget.session.subjectName] ?? const Color(0xFF64748B);
  }

  @override
  Widget build(BuildContext context) {
    final isInProgress = widget.session.status == SessionStatus.inProgress;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) => _onPopInvoked(didPop),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocListener<PlannerBloc, PlannerState>(
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
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: CustomScrollView(
          slivers: [
            // Modern App Bar with Timer
            _buildModernAppBar(context, isInProgress),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Subject Card
                    _buildSubjectCard(),
                    const SizedBox(height: 20),

                    // Quick Stats Row
                    _buildQuickStatsRow(),
                    const SizedBox(height: 20),

                    // Content to Review (hide for break sessions)
                    if (!widget.session.isBreak) ...[
                      _buildContentCard(),
                      const SizedBox(height: 20),

                      // TODO: Progress Card - uncomment when real progress data is available from API
                      // _buildProgressCard(),
                      // const SizedBox(height: 20),
                    ],

                    // Session Info
                    _buildSessionInfoCard(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),

          // Floating Action Buttons
          bottomNavigationBar: _buildBottomActions(context, isInProgress),
        ),
      ),
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context, bool isInProgress) {
    // Only show large header with timer for scheduled/inProgress sessions
    final showTimer = isInProgress || widget.session.status == SessionStatus.scheduled;

    return SliverAppBar(
      expandedHeight: showTimer ? 320 : 100,
      pinned: true,
      stretch: true,
      backgroundColor: _subjectColor,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.session.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () {
            context.read<PlannerBloc>().add(
              PinSessionEvent(
                sessionId: widget.session.id,
                isPinned: !widget.session.isPinned,
              ),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
          ),
          onSelected: (value) {
            if (value == 'reschedule') {
              _showRescheduleDialog(context);
            } else if (value == 'delete') {
              _showDeleteDialog(context);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'reschedule',
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 20),
                  SizedBox(width: 12),
                  Text('إعادة جدولة', style: TextStyle(fontFamily: 'Cairo')),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  SizedBox(width: 12),
                  Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _subjectColor,
                _subjectColor.withOpacity(0.8),
              ],
            ),
          ),
          // Only show timer section for scheduled/inProgress sessions
          child: (isInProgress || widget.session.status == SessionStatus.scheduled)
              ? SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      // Timer Section
                      _buildTimerWidget(isInProgress),
                    ],
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildTimerWidget(bool isInProgress) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isInProgress ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              boxShadow: isInProgress ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ] : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress Ring
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CustomPaint(
                    painter: _CircularProgressPainter(
                      progress: isInProgress ? _progress : 1.0,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      progressColor: Colors.white,
                    ),
                  ),
                ),

                // Time Display
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isInProgress ? _formattedTime : _formatDurationMinutes(widget.session.duration),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isInProgress ? Icons.play_circle_filled : Icons.schedule,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isInProgress ? 'جلسة نشطة' : 'مجدولة',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
        );
      },
    );
  }

  Widget _buildSubjectCard() {
    final isBreak = widget.session.isBreak;

    return Container(
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isBreak
                    ? [const Color(0xFF10B981), const Color(0xFF059669)]
                    : [_subjectColor, _subjectColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isBreak ? Icons.coffee_rounded : Icons.menu_book_rounded,
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
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (!isBreak && widget.session.chapterName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.session.chapterName!,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                if (isBreak) ...[
                  const SizedBox(height: 4),
                  Text(
                    'وقت للراحة والاسترخاء',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isBreak) _buildPriorityBadge(),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge() {
    final priority = _getPriorityLevel(widget.session.priorityScore);
    final config = _getPriorityConfig(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time_rounded,
            label: 'وقت البدء',
            value: _formatTimeOfDay(widget.session.scheduledStartTime),
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.timer_outlined,
            label: 'المدة',
            value: '${widget.session.duration.inMinutes} د',
            color: const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.flag_rounded,
            label: 'الحالة',
            value: _getStatusArabic(widget.session.status),
            color: _getStatusColor(widget.session.status),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard() {
    // Use the SessionContentList widget with real data from API
    if (_contentMeta != null) {
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
        child: SessionContentList(
          contents: _sessionContents,
          meta: _contentMeta!,
          isLoading: _isLoadingContent,
          errorMessage: _contentError,
        ),
      );
    }

    // Loading or error state with fallback UI
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const Text(
                'محتوى الجلسة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_isLoadingContent) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
          ] else if (_contentError != null) ...[
            Center(
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
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (_contentMeta != null && !_contentMeta!.hasContent) ...[
            // Content not available for user's stream - show placeholder
            Center(
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
            ),
          ] else if (_sessionContents.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'لا يوجد محتوى متاح',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ),
          ] else ...[
            // Show actual content list
            SessionContentList(
              contents: _sessionContents,
              meta: _contentMeta!,
              onPhaseComplete: _handlePhaseComplete,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLessonTile(String title, bool isCompleted, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFF10B981).withOpacity(0.08)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF10B981).withOpacity(0.3)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF10B981)
                  : Colors.white,
              shape: BoxShape.circle,
              border: isCompleted
                  ? null
                  : Border.all(color: const Color(0xFFCBD5E1), width: 2),
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Center(
                    child: Text(
                      '$index',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'درس $index: $title',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isCompleted ? Colors.grey[600] : const Color(0xFF1E293B),
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    const completedLessons = 7;
    const totalLessons = 20;
    const progressPercentage = completedLessons / totalLessons;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.1),
            const Color(0xFFA78BFA).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'تقدمك في ${widget.session.subjectName}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Text(
                '${(progressPercentage * 100).toInt()}%',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPercentage,
              minHeight: 10,
              backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            '$completedLessons من $totalLessons درس مكتمل',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfoCard() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.info_outline_rounded, color: Colors.grey[600], size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'تفاصيل الجلسة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildInfoTile(Icons.calendar_today_rounded, 'التاريخ', _formatDate(widget.session.scheduledDate)),
          _buildInfoTile(Icons.category_rounded, 'نوع الجلسة', _getSessionTypeDisplay()),
          if (widget.session.actualStartTime != null)
            _buildInfoTile(Icons.play_circle_rounded, 'بدأت فعلياً', _formatTime(widget.session.actualStartTime!)),
          if (widget.session.actualEndTime != null)
            _buildInfoTile(Icons.check_circle_rounded, 'انتهت فعلياً', _formatTime(widget.session.actualEndTime!)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, bool isInProgress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary Action
            if (widget.session.status == SessionStatus.scheduled ||
                widget.session.status == SessionStatus.paused)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/planner/session/${widget.session.id}/active', extra: widget.session);
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 24),
                  label: Text(
                    widget.session.status == SessionStatus.paused
                        ? 'استئناف الجلسة'
                        : 'بدء الجلسة النشطة',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

            if (widget.session.status == SessionStatus.scheduled ||
                widget.session.status == SessionStatus.paused)
              const SizedBox(height: 12),

            // Secondary Actions
            Row(
              children: [
                if (widget.session.status != SessionStatus.completed &&
                    widget.session.status != SessionStatus.skipped &&
                    widget.session.status != SessionStatus.missed)
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => _showSkipDialog(context),
                        icon: const Icon(Icons.skip_next_rounded, size: 20),
                        label: const Text(
                          'تخطي',
                          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),

                if (widget.session.status != SessionStatus.completed &&
                    widget.session.status != SessionStatus.skipped &&
                    widget.session.status != SessionStatus.missed)
                  const SizedBox(width: 12),

                if (isInProgress)
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.read<PlannerBloc>().add(
                            PauseSessionEvent(widget.session.id),
                          );
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.pause_rounded, size: 20),
                        label: const Text(
                          'إيقاف مؤقت',
                          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF59E0B),
                          side: const BorderSide(color: Color(0xFFF59E0B)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),

                if (isInProgress)
                  const SizedBox(width: 12),

                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Mark session as complete
                        context.read<PlannerBloc>().add(
                          CompleteSessionEvent(sessionId: widget.session.id),
                        );

                        // Auto-mark content phases as complete based on session type
                        if (_sessionContents.isNotEmpty) {
                          final sessionTypeStr = widget.session.sessionType.toString().split('.').last;
                          context.read<PlannerBloc>().add(
                            MarkSessionContentCompleteEvent(
                              contentIds: _sessionContents.map((c) => c.id).toList(),
                              sessionType: sessionTypeStr,
                              totalDurationMinutes: widget.session.duration.inMinutes,
                            ),
                          );
                        }

                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 20),
                      label: const Text(
                        'إتمام',
                        style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSkipDialog(BuildContext context) {
    final reasons = [
      'متعب',
      'ليس لدي وقت',
      'ظروف طارئة',
      'درست المحتوى مسبقاً',
      'سبب آخر',
    ];

    String? selectedReason;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'تخطي الجلسة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'اختر سبب التخطي',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                ...reasons.map((reason) => InkWell(
                  onTap: () => setState(() => selectedReason = reason),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selectedReason == reason
                          ? const Color(0xFF3B82F6).withOpacity(0.1)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedReason == reason
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFE2E8F0),
                        width: selectedReason == reason ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedReason == reason
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selectedReason == reason
                              ? const Color(0xFF3B82F6)
                              : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          reason,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: selectedReason == reason
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: selectedReason == null
                        ? null
                        : () {
                            Navigator.pop(bottomContext);
                            context.read<PlannerBloc>().add(
                              SkipSessionEvent(
                                sessionId: widget.session.id,
                                reason: selectedReason!,
                              ),
                            );
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'تأكيد التخطي',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
              const SizedBox(height: 20),
              Icon(Icons.schedule, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'إعادة جدولة الجلسة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'سيتم إضافة هذه الميزة قريباً',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'حسناً',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 12),
              Text('حذف الجلسة', style: TextStyle(fontFamily: 'Cairo')),
            ],
          ),
          content: const Text(
            'هل أنت متأكد من حذف هذه الجلسة؟',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _formatDurationMinutes(Duration duration) {
    final minutes = duration.inMinutes;
    return '$minutes د';
  }

  /// Get session type display text with special handling for prayer and break sessions
  String _getSessionTypeDisplay() {
    // Special handling for prayer sessions
    if (widget.session.isPrayerTime) {
      return 'صلاة';
    }

    // Special handling for break sessions
    if (widget.session.isBreak) {
      return 'استراحة';
    }

    // Regular session types
    return _getSessionTypeArabic(widget.session.sessionType);
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

  String _getStatusArabic(SessionStatus status) {
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

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.scheduled:
        return const Color(0xFF3B82F6);
      case SessionStatus.inProgress:
        return const Color(0xFF10B981);
      case SessionStatus.paused:
        return const Color(0xFFF59E0B);
      case SessionStatus.completed:
        return const Color(0xFF10B981);
      case SessionStatus.missed:
        return const Color(0xFFEF4444);
      case SessionStatus.skipped:
        return const Color(0xFF64748B);
    }
  }

  PriorityLevel _getPriorityLevel(int score) {
    if (score >= 80) return PriorityLevel.critical;
    if (score >= 60) return PriorityLevel.high;
    if (score >= 40) return PriorityLevel.medium;
    return PriorityLevel.low;
  }

  ({Color color, IconData icon, String label}) _getPriorityConfig(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.critical:
        return (color: const Color(0xFFEF4444), icon: Icons.priority_high, label: 'حرج');
      case PriorityLevel.high:
        return (color: const Color(0xFFF59E0B), icon: Icons.arrow_upward, label: 'عالي');
      case PriorityLevel.medium:
        return (color: const Color(0xFF3B82F6), icon: Icons.remove, label: 'متوسط');
      case PriorityLevel.low:
        return (color: const Color(0xFF10B981), icon: Icons.arrow_downward, label: 'منخفض');
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final days = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    return '${days[date.weekday % 7]} ${date.day}/${date.month}';
  }
}

/// Custom painter for circular progress
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
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
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
