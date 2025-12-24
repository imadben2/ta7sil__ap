import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/study_session_entity.dart';

/// Modern widget for displaying a study session item
class SessionItemWidget extends StatelessWidget {
  final StudySessionEntity session;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  const SessionItemWidget({
    super.key,
    required this.session,
    this.onTap,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = session.hasPassed;
    final isNow = session.isNow;
    final isMissed = session.status == SessionStatus.missed;
    final isCompleted = session.status == SessionStatus.completed;
    final color = _parseColor(session.subjectColor);

    double opacity = 1.0;
    if (isPast || isCompleted) {
      opacity = 0.7;
    }

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.20),
                Colors.white.withOpacity(0.12),
              ],
            ),
            border: Border.all(
              color: isNow
                  ? Colors.white.withOpacity(0.5)
                  : Colors.white.withOpacity(0.25),
              width: isNow ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isNow
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.1),
                blurRadius: isNow ? 15 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Time section with modern design
                    Container(
                      width: 70,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withOpacity(0.15),
                            color.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('HH:mm').format(session.startTime),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          Text(
                            DateFormat('HH:mm').format(session.endTime),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              session.formattedDuration,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Content section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Subject name
                          Text(
                            session.subjectName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),

                          // Type and topic
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getTypeIcon(),
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      session.typeLabel,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (session.topic != null) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    session.topic!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Status indicator
                    _buildStatusIndicator(isCompleted, isMissed, isNow, color),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(
    bool isCompleted,
    bool isMissed,
    bool isNow,
    Color color,
  ) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_rounded, color: AppColors.success, size: 20),
      );
    } else if (isMissed) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.close_rounded, color: AppColors.error, size: 20),
      );
    } else if (isNow) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFFFF6B35), const Color(0xFFFF8A5B)],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.play_circle_filled_rounded,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 4),
            Text(
              'الآن',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.schedule_rounded, color: color, size: 20),
      );
    }
  }

  IconData _getTypeIcon() {
    switch (session.type) {
      case SessionType.lesson:
        return Icons.menu_book_rounded;
      case SessionType.review:
        return Icons.replay_rounded;
      case SessionType.quiz:
        return Icons.quiz_rounded;
      case SessionType.homework:
        return Icons.assignment_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }
}
