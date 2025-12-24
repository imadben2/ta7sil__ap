import 'package:flutter/material.dart';
import '../../domain/entities/study_session.dart';

/// Week Calendar Grid Widget - Clean, Simple & Modern
///
/// Design Principles:
/// - Horizontal day selector at top (tap to switch days)
/// - Large, clear time slots
/// - Minimal visual clutter
/// - Instant recognition of schedule density
class WeekCalendarGrid extends StatefulWidget {
  final DateTime startDate;
  final List<StudySession> sessions;

  const WeekCalendarGrid({
    Key? key,
    required this.startDate,
    required this.sessions,
  }) : super(key: key);

  @override
  State<WeekCalendarGrid> createState() => _WeekCalendarGridState();
}

class _WeekCalendarGridState extends State<WeekCalendarGrid> {
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    // Auto-select today if it's in the current week
    for (int i = 0; i < 7; i++) {
      final date = widget.startDate.add(Duration(days: i));
      if (_isToday(date)) {
        _selectedDayIndex = i;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Horizontal day selector
        _buildDaySelector(),

        // Selected day content
        Expanded(child: _buildDayContent()),
      ],
    );
  }

  /// Horizontal day selector with pills
  Widget _buildDaySelector() {
    // Week starts from Saturday (السبت) - RTL order for Arabic
    const arabicDays = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Week indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الأسبوع',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                    color: Color(0xFF6B7280),
                  ),
                ),
                Text(
                  '${_getTotalSessionsForWeek()} جلسة',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Cairo',
                    color: Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Day pills - RTL layout (Saturday on the right)
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              reverse: true, // RTL: Saturday (first day) appears on the right
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 7,
              itemBuilder: (context, index) {
                // Reverse the index for RTL display
                final dayIndex = 6 - index;
                final date = widget.startDate.add(Duration(days: dayIndex));
                final isToday = _isToday(date);
                final isSelected = _selectedDayIndex == dayIndex;
                final daySessions = _getSessionsForDay(dayIndex);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = dayIndex;
                    });
                  },
                  child: Container(
                    width: 52,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : null,
                      color: isSelected ? null : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: isToday && !isSelected
                          ? Border.all(color: const Color(0xFF6366F1), width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Day letter
                        Text(
                          arabicDays[dayIndex],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Cairo',
                            color: isSelected
                                ? Colors.white
                                : isToday
                                ? const Color(0xFF6366F1)
                                : const Color(0xFF6B7280),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Date number
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 2),

                        // Session count indicator
                        if (daySessions.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.3)
                                  : const Color(
                                      0xFF6366F1,
                                    ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${daySessions.length}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF6366F1),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getTotalSessionsForWeek() {
    return widget.sessions.length;
  }

  /// Content for selected day
  Widget _buildDayContent() {
    final daySessions = _getSessionsForDay(_selectedDayIndex);

    if (daySessions.isEmpty) {
      return _buildEmptyDay();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: daySessions.length,
      itemBuilder: (context, index) {
        return _buildSessionCard(context, daySessions[index]);
      },
    );
  }

  Widget _buildEmptyDay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available_outlined,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد جلسات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Cairo',
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'يوم راحة',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Cairo',
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, StudySession session) {
    final color = session.subjectColor ?? const Color(0xFF6366F1);
    final statusColor = _getStatusColor(session.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle tap
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time block
                Container(
                  width: 64,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        session.scheduledStartTime.format(context),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${session.duration.inMinutes}د',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo',
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // Content
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
                          fontFamily: 'Cairo',
                          color: Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (session.chapterName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          session.chapterName!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Cairo',
                            color: Color(0xFF6B7280),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Session type tag
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getSessionTypeText(session.sessionType),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Cairo',
                                color: color,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Status indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(session.status),
                                  size: 14,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getStatusText(session.status),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Cairo',
                                    color: statusColor,
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
      ),
    );
  }

  String _getSessionTypeText(SessionType type) {
    switch (type) {
      case SessionType.study:
        return 'دراسة';
      case SessionType.regular:
        return 'عادية';
      case SessionType.revision:
        return 'مراجعة';
      case SessionType.practice:
        return 'تمرين';
      case SessionType.exam:
        return 'امتحان';
      case SessionType.longRevision:
        return 'مراجعة شاملة';
    }
  }

  String _getStatusText(SessionStatus status) {
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

  List<StudySession> _getSessionsForDay(int dayIndex) {
    final targetDate = widget.startDate.add(Duration(days: dayIndex));
    return widget.sessions.where((session) {
      final sessionDate = session.scheduledDate;
      return sessionDate.year == targetDate.year &&
          sessionDate.month == targetDate.month &&
          sessionDate.day == targetDate.day;
    }).toList()..sort((a, b) {
      final aMinutes =
          a.scheduledStartTime.hour * 60 + a.scheduledStartTime.minute;
      final bMinutes =
          b.scheduledStartTime.hour * 60 + b.scheduledStartTime.minute;
      return aMinutes.compareTo(bMinutes);
    });
  }

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.completed:
        return const Color(0xFF10B981);
      case SessionStatus.inProgress:
        return const Color(0xFF6366F1);
      case SessionStatus.paused:
        return const Color(0xFF8B5CF6);
      case SessionStatus.skipped:
        return const Color(0xFFF59E0B);
      case SessionStatus.missed:
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(SessionStatus status) {
    switch (status) {
      case SessionStatus.completed:
        return Icons.check_circle;
      case SessionStatus.inProgress:
        return Icons.play_circle_filled;
      case SessionStatus.paused:
        return Icons.pause_circle_filled;
      case SessionStatus.skipped:
        return Icons.skip_next;
      case SessionStatus.missed:
        return Icons.cancel;
      default:
        return Icons.schedule;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
