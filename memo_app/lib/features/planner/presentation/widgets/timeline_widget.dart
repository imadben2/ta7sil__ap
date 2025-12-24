import 'package:flutter/material.dart';
import '../../domain/entities/study_session.dart';
import 'session_card.dart';
import '../../../../core/constants/app_colors.dart';

/// Timeline Widget - Vertical timeline of sessions
///
/// Modern design matching session_detail_screen.dart
/// Features:
/// - Vertical timeline with time markers
/// - Current time indicator (green pulse)
/// - Sessions positioned at correct times
/// - Modern styling with shadows
class TimelineWidget extends StatelessWidget {
  final List<StudySession> sessions;

  const TimelineWidget({Key? key, required this.sessions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: sessions.asMap().entries.map((entry) {
          final index = entry.key;
          final session = entry.value;
          final sessionMinutes =
              session.scheduledStartTime.hour * 60 +
              session.scheduledStartTime.minute;
          final isPast = sessionMinutes < currentMinutes;
          final isCurrent = session.status == SessionStatus.inProgress;
          final isLast = index == sessions.length - 1;

          return _buildTimelineItem(
            context: context,
            session: session,
            isPast: isPast,
            isCurrent: isCurrent,
            isLast: isLast,
          );
        }).toList(),
      ),
    );
  }

  /// Build single timeline item
  Widget _buildTimelineItem({
    required BuildContext context,
    required StudySession session,
    required bool isPast,
    required bool isCurrent,
    required bool isLast,
  }) {
    final subjectColor = session.subjectColor ?? AppColors.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
          SizedBox(
            width: 70,
            child: Column(
              children: [
                // Time label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.emerald500.withOpacity(0.1)
                        : isPast
                            ? AppColors.slate600.withOpacity(0.1)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.emerald500.withOpacity(0.3)
                          : isPast
                              ? AppColors.slate600.withOpacity(0.2)
                              : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    _formatTime(session.scheduledStartTime),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                      fontFamily: 'Cairo',
                      color: isCurrent
                          ? AppColors.emerald500
                          : isPast
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF1F2937),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Timeline dot with animation for current
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse animation for current session
                    if (isCurrent)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.emerald500.withOpacity(0.2),
                        ),
                      ),
                    // Main dot
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrent
                            ? AppColors.emerald500
                            : isPast
                                ? const Color(0xFFD1D5DB)
                                : subjectColor,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isCurrent
                                ? AppColors.emerald500.withOpacity(0.4)
                                : subjectColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Timeline line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            isPast
                                ? const Color(0xFFD1D5DB)
                                : subjectColor.withOpacity(0.5),
                            const Color(0xFFE5E7EB),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Session card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Opacity(
                opacity: isPast && session.status != SessionStatus.completed
                    ? 0.7
                    : 1.0,
                child: SessionCard(session: session),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Format time
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
