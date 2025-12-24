import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/study_session.dart';
import '../bloc/planner_bloc.dart';
import '../bloc/planner_event.dart';
import 'session_timer_inline.dart';
import 'shared/planner_design_constants.dart';

/// Session Card Widget - Displays a study session
///
/// Features:
/// - Subject name with color indicator
/// - Time and duration
/// - Status badge
/// - Quick action buttons (Start, Skip, etc.)
class SessionCard extends StatelessWidget {
  final StudySession session;
  final VoidCallback? onTap;
  final bool showActions;
  final bool compact;

  const SessionCard({
    Key? key,
    required this.session,
    this.onTap,
    this.showActions = true,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subjectColor = session.subjectColor ?? AppColors.primary;
    final isPastScheduled = _isPastScheduledSession;

    // Use grayed colors for past scheduled sessions
    final displayColor = isPastScheduled ? Colors.grey : subjectColor;

    return Opacity(
      opacity: isPastScheduled ? 0.7 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isPastScheduled ? Colors.grey[100] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isPastScheduled ? 0.02 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Subject and status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subject icon container
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: session.isPrayerTime
                                ? [const Color(0xFF059669), const Color(0xFF047857)] // Dark green for prayer
                                : session.isBreak
                                    ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                    : [displayColor, displayColor.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: session.isPrayerTime
                                  ? const Color(0xFF059669).withOpacity(0.3)
                                  : session.isBreak
                                      ? const Color(0xFF10B981).withOpacity(0.3)
                                      : displayColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          session.isPrayerTime
                              ? Icons.mosque_rounded
                              : session.isBreak
                                  ? Icons.coffee_rounded
                                  : Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    const SizedBox(width: 14),

                    // Subject name and info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.subjectName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                              color: AppColors.slate900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Time, duration, and session type badges row
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.slate600.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 11,
                                      color: AppColors.slate600,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      _formatTime(session.scheduledStartTime),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.slate600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: subjectColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 11,
                                      color: subjectColor,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${session.duration.inMinutes} د',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w600,
                                        color: subjectColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Session type badge (from promt.md algorithm)
                              if (!session.isPrayerTime && !session.isBreak)
                                _buildSessionTypeBadge(),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Status badge
                    _buildStatusBadge(),
                  ],
                ),

                // Chapter and topic (if not prayer/break)
                if (!session.isPrayerTime && !session.isBreak) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: session.hasContent
                          ? AppColors.slateBackground
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: session.hasContent
                            ? const Color(0xFFE5E7EB)
                            : Colors.grey[300]!,
                        style: session.hasContent
                            ? BorderStyle.solid
                            : BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          session.hasContent
                              ? Icons.folder_open_rounded
                              : Icons.pending_outlined,
                          size: 16,
                          color: session.hasContent
                              ? AppColors.slate600
                              : Colors.grey[500],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getContentDisplayText(),
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Cairo',
                              fontStyle: session.hasContent
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                              color: session.hasContent
                                  ? AppColors.slate600
                                  : Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Inline timer for in-progress sessions
                if (session.status == SessionStatus.inProgress) ...[
                  const SizedBox(height: 12),
                  SessionTimerInline(
                    session: session,
                    onTimerComplete: () {
                      // Auto-complete session when timer reaches zero
                      context.read<PlannerBloc>().add(
                        CompleteSessionEvent(sessionId: session.id),
                      );
                    },
                  ),
                ],

                // Action buttons
                if (_shouldShowActions()) ...[
                  const SizedBox(height: 14),
                  Container(
                    height: 1,
                    color: const Color(0xFFE5E7EB),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButtons(context),
                ],
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  /// Build status badge
  Widget _buildStatusBadge() {
    final config = _getStatusConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: config.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: config.color,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  /// Build session type badge (from promt.md algorithm)
  ///
  /// Shows the session type with appropriate color and icon:
  /// - مراجعة (LESSON_REVIEW) - Blue
  /// - تمارين (EXERCISES) - Green
  /// - اختبار (TOPIC_TEST) - Orange
  /// - تثبيت (SPACED_REVIEW) - Purple
  /// - لغة (LANGUAGE_DAILY) - Teal
  /// - اختبار شامل (MOCK_TEST) - Red
  Widget _buildSessionTypeBadge() {
    // Map session type to config
    // For now, infer from session data since PlannerSessionType is not yet in StudySession
    final typeConfig = _getSessionTypeConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: typeConfig.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: typeConfig.color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            typeConfig.icon,
            size: 11,
            color: typeConfig.color,
          ),
          const SizedBox(width: 3),
          Text(
            typeConfig.label,
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
              color: typeConfig.color,
            ),
          ),
        ],
      ),
    );
  }

  /// Get session type configuration (color, icon, label)
  ///
  /// Infers session type from session properties:
  /// - sessionType.practice or contentPhase == 'exercise_practice' → تمارين
  /// - sessionType.exam or contentPhase == 'test' → اختبار
  /// - contentPhase == 'review' → تثبيت
  /// - Default → مراجعة
  ({Color color, IconData icon, String label}) _getSessionTypeConfig() {
    // Check content phase first (from API)
    if (session.contentPhase != null) {
      switch (session.contentPhase) {
        case 'exercise_practice':
        case 'exercises':
          return (
            color: const Color(0xFF10B981), // Green
            icon: Icons.edit_note_rounded,
            label: 'تمارين',
          );
        case 'test':
        case 'topic_test':
          return (
            color: const Color(0xFFF59E0B), // Orange
            icon: Icons.quiz_rounded,
            label: 'اختبار',
          );
        case 'review':
        case 'spaced_review':
          return (
            color: const Color(0xFF8B5CF6), // Purple
            icon: Icons.replay_rounded,
            label: 'تثبيت',
          );
        case 'understanding':
        case 'lesson_review':
          return (
            color: const Color(0xFF3B82F6), // Blue
            icon: Icons.menu_book_rounded,
            label: 'مراجعة',
          );
        case 'mock_test':
          return (
            color: const Color(0xFFEF4444), // Red
            icon: Icons.assignment_rounded,
            label: 'اختبار شامل',
          );
        case 'language_daily':
          return (
            color: const Color(0xFF14B8A6), // Teal
            icon: Icons.language_rounded,
            label: 'لغة',
          );
      }
    }

    // Fallback: infer from sessionType
    switch (session.sessionType) {
      case SessionType.practice:
        return (
          color: const Color(0xFF10B981), // Green
          icon: Icons.edit_note_rounded,
          label: 'تمارين',
        );
      case SessionType.exam:
        return (
          color: const Color(0xFFF59E0B), // Orange
          icon: Icons.quiz_rounded,
          label: 'اختبار',
        );
      case SessionType.revision:
        return (
          color: const Color(0xFF8B5CF6), // Purple
          icon: Icons.replay_rounded,
          label: 'تثبيت',
        );
      case SessionType.longRevision:
        return (
          color: const Color(0xFF8B5CF6), // Purple
          icon: Icons.history_edu_rounded,
          label: 'مراجعة عميقة',
        );
      case SessionType.study:
      case SessionType.regular:
      default:
        return (
          color: const Color(0xFF3B82F6), // Blue
          icon: Icons.menu_book_rounded,
          label: 'مراجعة',
        );
    }
  }

  /// Build action buttons based on session status
  Widget _buildActionButtons(BuildContext context) {
    final buttons = <Widget>[];

    // Start button (scheduled sessions)
    if (session.status == SessionStatus.scheduled) {
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _showStartSessionDialog(context);
            },
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('بدء', style: TextStyle(fontFamily: 'Cairo')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald500,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      );

      buttons.add(const SizedBox(width: 8));

      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _showSkipDialog(context);
            },
            icon: const Icon(Icons.skip_next, size: 18),
            label: const Text('تخطي', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ),
      );
    }

    // Pause and Complete buttons (in progress sessions)
    if (session.status == SessionStatus.inProgress) {
      // Pause button
      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              context.read<PlannerBloc>().add(
                PauseSessionEvent(session.id),
              );
            },
            icon: const Icon(Icons.pause, size: 18),
            label: const Text('إيقاف', style: TextStyle(fontFamily: 'Cairo')),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
            ),
          ),
        ),
      );

      buttons.add(const SizedBox(width: 8));

      // Complete button
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<PlannerBloc>().add(
                CompleteSessionEvent(sessionId: session.id),
              );
            },
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('إتمام', style: TextStyle(fontFamily: 'Cairo')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue500,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      );
    }

    // Resume button (paused sessions)
    if (session.status == SessionStatus.paused) {
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<PlannerBloc>().add(
                ResumeSessionEvent(session.id),
              );
            },
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('استئناف', style: TextStyle(fontFamily: 'Cairo')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald500,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      );

      buttons.add(const SizedBox(width: 8));

      // Skip button for paused sessions
      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _showSkipDialog(context);
            },
            icon: const Icon(Icons.skip_next, size: 18),
            label: const Text('تخطي', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ),
      );
    }

    // Reschedule button (missed sessions - NOT for breaks or prayer times)
    if (session.status == SessionStatus.missed &&
        !session.isBreak &&
        !session.isPrayerTime) {
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _showRescheduleDialog(context);
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('إعادة جدولة', style: TextStyle(fontFamily: 'Cairo')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      );
    }

    // Add Details button for all actionable statuses
    if (buttons.isNotEmpty) {
      buttons.add(const SizedBox(width: 8));
      buttons.add(
        IconButton(
          onPressed: () {
            context.push('/planner/session/${session.id}', extra: session);
          },
          icon: const Icon(Icons.info_outline, size: 22),
          tooltip: 'تفاصيل',
          color: Colors.grey[600],
        ),
      );
    }

    return Row(children: buttons);
  }

  /// Show start session dialog
  void _showStartSessionDialog(BuildContext context) {
    final now = TimeOfDay.now();
    final scheduledTime = session.scheduledStartTime;

    // Check if current time matches scheduled time (within 5 minutes tolerance)
    final nowMinutes = now.hour * 60 + now.minute;
    final scheduledMinutes = scheduledTime.hour * 60 + scheduledTime.minute;
    final timeDifference = (nowMinutes - scheduledMinutes).abs();

    // If within 5 minutes of scheduled time, start immediately
    if (timeDifference <= 5) {
      context.read<PlannerBloc>().add(StartSessionEvent(session.id));
      return;
    }

    // Otherwise, show dialog asking what to do
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withOpacity(0.1),
                        Colors.orange.withOpacity(0.05),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.schedule_rounded,
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
                              'الموعد مختلف',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate900,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'يوجد فرق في التوقيت',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: AppColors.slate600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Time comparison cards
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.08),
                              AppColors.primaryLight.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Scheduled time
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.event_note_rounded,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'الموعد المجدول',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.slate600,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _formatTime(scheduledTime),
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.slate900,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Divider
                            Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    const Color(
                                      0xFF6366F1,
                                    ).withOpacity(0.2),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Current time
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.access_time_rounded,
                                    size: 20,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'الوقت الحالي',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.slate600,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF10B981),
                                        Color(0xFF059669),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF10B981,
                                        ).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _formatTime(now),
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Question text
                      const Text(
                        'كيف تريد المتابعة؟',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      // Start now button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            context.read<PlannerBloc>().add(
                              StartSessionEvent(session.id),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald500,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_arrow_rounded, size: 22),
                              const SizedBox(width: 8),
                              const Text(
                                'ابدأ الآن',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Reschedule button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _showRegenerateConfirmation(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.refresh_rounded, size: 22),
                              const SizedBox(width: 8),
                              const Text(
                                'إعادة جدولة الجلسات',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Cancel button
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF9CA3AF),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show regenerate confirmation dialog
  void _showRegenerateConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primaryLight.withOpacity(0.05),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF6366F1,
                              ).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
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
                              'إعادة جدولة',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate900,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'تحديث الجدول الدراسي',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: AppColors.slate600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Info icon with animation feel
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.08),
                              AppColors.primaryLight.withOpacity(0.08),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Main message
                      const Text(
                        'سيتم إعادة جدولة جميع الجلسات المتبقية',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Description with bullet points
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              Icons.calendar_today_rounded,
                              'يبدأ من اليوم',
                              AppColors.primary,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.schedule_rounded,
                              'من الوقت الحالي',
                              const Color(0xFF10B981),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.cached_rounded,
                              'مدة 30 يوم',
                              AppColors.amber500,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Confirmation question
                      const Text(
                        'هل تريد المتابعة؟',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      // Confirm button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            final today = DateTime.now();
                            final endOfSchedule = today.add(
                              const Duration(days: 30),
                            );

                            context.read<PlannerBloc>().add(
                              GenerateScheduleEvent(
                                startDate: today,
                                endDate: endOfSchedule,
                                startFromNow: true,
                              ),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'جاري إعادة جدولة الجلسات...',
                                        style: TextStyle(fontFamily: 'Cairo'),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_rounded, size: 22),
                              const SizedBox(width: 8),
                              const Text(
                                'نعم، أعد الجدولة',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Cancel button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF9CA3AF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build info row for regenerate dialog
  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  /// Show reschedule dialog for missed sessions
  void _showRescheduleDialog(BuildContext context) {
    final blocContext = context;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primaryLight.withOpacity(0.05),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'إعادة جدولة الجلسة',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              session.subjectName,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: AppColors.slate600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Warning icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFEF4444).withOpacity(0.1),
                              const Color(0xFFF59E0B).withOpacity(0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFEF4444).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          size: 40,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Info text
                      const Text(
                        'هذه الجلسة فائتة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'سيتم البحث عن أقرب وقت متاح لإعادة جدولة هذه الجلسة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Session info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 18,
                              color: session.subjectColor ?? AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'المدة: ${session.duration.inMinutes} دقيقة',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: AppColors.slate900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      // Reschedule button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            blocContext.read<PlannerBloc>().add(
                              RescheduleMissedSessionEvent(sessionId: session.id),
                            );

                            ScaffoldMessenger.of(blocContext).showSnackBar(
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
                                    Expanded(
                                      child: Text(
                                        'جاري إعادة جدولة الجلسة...',
                                        style: TextStyle(fontFamily: 'Cairo'),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_rounded, size: 20),
                          label: const Text(
                            'إعادة جدولة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Cancel button
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF6B7280),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show skip dialog
  void _showSkipDialog(BuildContext context) {
    final reasons = [
      (icon: Icons.battery_1_bar_rounded, text: 'متعب', color: const Color(0xFFEF4444)),
      (icon: Icons.access_time_rounded, text: 'ليس لدي وقت', color: const Color(0xFFF59E0B)),
      (icon: Icons.warning_amber_rounded, text: 'ظروف طارئة', color: const Color(0xFFEC4899)),
      (icon: Icons.school_rounded, text: 'درست المحتوى مسبقاً', color: const Color(0xFF10B981)),
      (icon: Icons.more_horiz_rounded, text: 'سبب آخر', color: const Color(0xFF6B7280)),
    ];

    String? selectedReason;

    // Capture the original context that has access to PlannerBloc
    final blocContext = context;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with gradient
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFF59E0B).withValues(alpha: 0.1),
                          const Color(0xFFEF4444).withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.skip_next_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'تخطي الجلسة',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.slate900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                session.subjectName,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  color: AppColors.slate600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'لماذا تريد تخطي هذه الجلسة؟',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Modern reason cards
                        ...reasons.map((reason) {
                          final isSelected = selectedReason == reason.text;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              onTap: () {
                                setState(() => selectedReason = reason.text);
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            reason.color.withValues(alpha: 0.15),
                                            reason.color.withValues(alpha: 0.08),
                                          ],
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                        )
                                      : null,
                                  color: isSelected ? null : const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? reason.color.withValues(alpha: 0.5)
                                        : const Color(0xFFE5E7EB),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: reason.color.withValues(alpha: 0.15),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? LinearGradient(
                                                colors: [
                                                  reason.color,
                                                  reason.color.withValues(alpha: 0.8),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                            : null,
                                        color: isSelected
                                            ? null
                                            : reason.color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        reason.icon,
                                        size: 20,
                                        color: isSelected
                                            ? Colors.white
                                            : reason.color,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        reason.text,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 15,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? reason.color
                                              : const Color(0xFF374151),
                                        ),
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: isSelected
                                            ? LinearGradient(
                                                colors: [
                                                  reason.color,
                                                  reason.color.withValues(alpha: 0.8),
                                                ],
                                              )
                                            : null,
                                        color: isSelected
                                            ? null
                                            : Colors.white,
                                        border: Border.all(
                                          color: isSelected
                                              ? reason.color
                                              : const Color(0xFFD1D5DB),
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check_rounded,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      children: [
                        // Cancel button
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF6B7280),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'إلغاء',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Skip button
                        Expanded(
                          flex: 2,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: ElevatedButton(
                              onPressed: selectedReason == null
                                  ? null
                                  : () {
                                      Navigator.pop(dialogContext);
                                      blocContext.read<PlannerBloc>().add(
                                        SkipSessionEvent(
                                          sessionId: session.id,
                                          reason: selectedReason!,
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedReason != null
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFE5E7EB),
                                foregroundColor: selectedReason != null
                                    ? Colors.white
                                    : const Color(0xFF9CA3AF),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.skip_next_rounded,
                                    size: 20,
                                    color: selectedReason != null
                                        ? Colors.white
                                        : const Color(0xFF9CA3AF),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'تخطي الجلسة',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Check if action buttons should be shown
  bool _shouldShowActions() {
    // Don't show actions if explicitly disabled
    if (!showActions) {
      return false;
    }
    // Don't show actions for previous day scheduled sessions (they should appear as missed)
    if (_isPastScheduledSession) {
      return false;
    }
    return session.status == SessionStatus.scheduled ||
        session.status == SessionStatus.inProgress ||
        session.status == SessionStatus.paused ||
        session.status == SessionStatus.missed;
  }

  /// Check if session is from previous day and still scheduled (should show as missed)
  bool get _isPastScheduledSession {
    return session.isPreviousDay && session.status == SessionStatus.scheduled;
  }

  /// Get status configuration (color, icon, label)
  ({Color color, IconData icon, String label}) _getStatusConfig() {
    // If session is from previous day and still scheduled, show as missed
    if (_isPastScheduledSession) {
      return (color: Colors.red, icon: Icons.cancel, label: 'فائتة');
    }

    switch (session.status) {
      case SessionStatus.scheduled:
        return (color: Colors.blue, icon: Icons.schedule, label: 'مجدولة');
      case SessionStatus.inProgress:
        return (color: Colors.green, icon: Icons.play_circle, label: 'جارية');
      case SessionStatus.completed:
        return (color: Colors.green, icon: Icons.check_circle, label: 'مكتملة');
      case SessionStatus.skipped:
        return (
          color: Colors.orange,
          icon: Icons.skip_next,
          label: 'تم التخطي',
        );
      case SessionStatus.missed:
        return (color: Colors.red, icon: Icons.cancel, label: 'فائتة');
      case SessionStatus.paused:
        return (color: Colors.amber, icon: Icons.pause_circle, label: 'موقوفة');
    }
  }

  /// Format time to Arabic
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get chapter and topic text, handling nulls
  String _getChapterTopicText(String? chapterName, String? topicName) {
    if (chapterName != null && topicName != null) {
      return '$chapterName - $topicName';
    } else if (chapterName != null) {
      return chapterName;
    } else if (topicName != null) {
      return topicName;
    }
    return '';
  }

  /// Get content display text based on hasContent flag
  String _getContentDisplayText() {
    // If no content available, show placeholder message
    if (!session.hasContent) {
      return 'سيتم اضافة المحتوى قريبا';
    }

    // Show content title or topic name
    if (session.contentTitle != null && session.contentTitle!.isNotEmpty) {
      return session.contentTitle!;
    }

    // Fallback to chapter/topic text
    return _getChapterTopicText(session.chapterName, session.topicName);
  }
}
