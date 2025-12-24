import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../domain/entities/session_history.dart';

/// GitHub-style contribution heatmap calendar for study sessions
class SessionHistoryCalendar extends StatelessWidget {
  final SessionHistory history;
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime)? onDateTapped;

  const SessionHistoryCalendar({
    super.key,
    required this.history,
    required this.startDate,
    required this.endDate,
    this.onDateTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'سجل النشاط',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                _buildLegend(),
              ],
            ),
            const SizedBox(height: 16),

            // Calendar grid
            _buildCalendarGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        // In RTL: "أكثر" (more) should be on the right (start), colors, then "أقل" (less) on the left (end)
        const Text(
          'أكثر',
          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(width: 4),
        // Reverse the color order for RTL (4 to 0 instead of 0 to 4)
        ...[4, 3, 2, 1, 0].map(
          (level) => Padding(
            padding: const EdgeInsetsDirectional.only(start: 2),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getColorForIntensity(level),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          'أقل',
          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    // Generate calendar grid based on startDate and endDate
    final weeks = _generateWeeks();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true, // Start from right for RTL
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: weeks.map((week) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: week.map((date) {
              if (date == null) {
                return _buildEmptyCell();
              }

              final dateKey = DateFormat('yyyy-MM-dd').format(date);
              final intensity = history.intensityMap[dateKey] ?? 0;

              return GestureDetector(
                onTap: () => onDateTapped?.call(date),
                child: _buildCell(intensity, date),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  List<List<DateTime?>> _generateWeeks() {
    final weeks = <List<DateTime?>>[];
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      final week = <DateTime?>[];
      for (int i = 0; i < 7; i++) {
        if (currentDate.isAfter(endDate)) {
          week.add(null);
        } else {
          week.add(currentDate);
          currentDate = currentDate.add(const Duration(days: 1));
        }
      }
      weeks.add(week);
    }

    return weeks;
  }

  Widget _buildEmptyCell() {
    return Container(width: 12, height: 12, margin: const EdgeInsets.all(2));
  }

  Widget _buildCell(int intensity, DateTime date) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _getColorForIntensity(intensity),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 0.5),
      ),
    );
  }

  Color _getColorForIntensity(int level) {
    // GitHub-style green color scheme
    switch (level) {
      case 0:
        return const Color(0xFFEBEDF0);
      case 1:
        return const Color(0xFFC6E48B);
      case 2:
        return const Color(0xFF7BC96F);
      case 3:
        return const Color(0xFF239A3B);
      case 4:
        return const Color(0xFF196127);
      default:
        return const Color(0xFFEBEDF0);
    }
  }
}
