import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/study_session.dart';
import '../bloc/planner_bloc.dart';
import '../bloc/planner_event.dart';

/// Session Action Buttons Widget
///
/// Displays action buttons based on session status
class SessionActionButtons extends StatelessWidget {
  final StudySession session;

  const SessionActionButtons({Key? key, required this.session})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (session.status) {
      case SessionStatus.scheduled:
        return _buildScheduledActions(context);
      case SessionStatus.inProgress:
        return _buildInProgressActions(context);
      case SessionStatus.paused:
        return _buildPausedActions(context);
      default:
        return const SizedBox.shrink();
    }
  }

  /// Build actions for scheduled session
  Widget _buildScheduledActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<PlannerBloc>().add(StartSessionEvent(session.id));
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('بدء', style: TextStyle(fontFamily: 'Cairo')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showSkipDialog(context),
            icon: const Icon(Icons.skip_next),
            label: const Text('تخطي', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ),
      ],
    );
  }

  /// Build actions for in-progress session
  Widget _buildInProgressActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<PlannerBloc>().add(PauseSessionEvent(session.id));
            },
            icon: const Icon(Icons.pause),
            label: const Text(
              'إيقاف مؤقت',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<PlannerBloc>().add(
                CompleteSessionEvent(sessionId: session.id),
              );
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('إتمام', style: TextStyle(fontFamily: 'Cairo')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Build actions for paused session
  Widget _buildPausedActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<PlannerBloc>().add(ResumeSessionEvent(session.id));
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('استئناف', style: TextStyle(fontFamily: 'Cairo')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              context.read<PlannerBloc>().add(
                CompleteSessionEvent(sessionId: session.id),
              );
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('إتمام', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ),
      ],
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
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                session.subjectName,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
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
}
