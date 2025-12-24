import 'dart:io';
import 'dart:ui' as ui show TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../cubit/session_history_cubit.dart';
import '../cubit/session_history_state.dart';
import '../../domain/entities/session_history.dart';
import '../../../../injection_container.dart' as di;
import '../widgets/shared/planner_design_constants.dart';
import '../../../../core/utils/pdf_font_loader.dart';
import '../../../../core/services/pdf_upload_service.dart';

/// Session History Screen with heatmap calendar and detailed session list
/// Shows user's study session history with visual heatmap and filtering
///
/// Modern design matching session_detail_screen.dart
class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final List<String> _filterOptions = ['الكل', 'مكتملة', 'محذوفة', 'متخطية'];
  String _selectedFilter = 'الكل';
  String? _selectedSubject; // For subject filter
  DateTime? _startDateFilter; // For date range filter
  DateTime? _endDateFilter;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // History loaded automatically by BlocProvider
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (context) => di.sl<SessionHistoryCubit>()..loadHistory(),
        child: Scaffold(
          backgroundColor: PlannerDesignConstants.slateBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF1F2937),
                  size: 20,
                ),
              ),
            ),
            title: const Text(
              'سجل الجلسات',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            centerTitle: true,
            actions: [
              Container(
                margin: const EdgeInsetsDirectional.only(end: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.filter_list_rounded,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                  onPressed: _showFilterOptions,
                  tooltip: 'تصفية',
                ),
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(end: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.file_download_rounded,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                  onPressed: _exportHistory,
                  tooltip: 'تصدير',
                ),
              ),
            ],
          ),
          body: BlocBuilder<SessionHistoryCubit, SessionHistoryState>(
            builder: (context, state) {
              if (state is SessionHistoryLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message ?? 'جاري تحميل السجل...',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is SessionHistoryError) {
                return _buildErrorView(context, state);
              }

              if (state is SessionHistoryLoaded) {
                return Column(
                  children: [
                    // Statistics Summary
                    _buildStatisticsSummary(state.history.statistics),

                    // Heatmap Calendar
                    _buildCalendarCard(state),

                    // Filter chips
                    _buildFilterChips(),

                    // Session list for selected day
                    Expanded(child: _buildSessionList(state)),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  /// Build error view
  Widget _buildErrorView(BuildContext context, SessionHistoryError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: PlannerDesignConstants.modernCardDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'حدث خطأ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Cairo',
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<SessionHistoryCubit>().refresh();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'إعادة المحاولة',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSummary(HistoryStatistics stats) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.calendar_today_rounded,
              value: '${stats.totalSessions}',
              label: 'جلسة',
              color: const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.access_time_rounded,
              value: '${stats.totalHours.toStringAsFixed(1)}',
              label: 'ساعة',
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.star_rounded,
              value: '${stats.totalPoints}',
              label: 'نقطة',
              color: const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PlannerDesignConstants.modernCardDecoration(),
      child: Column(
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
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  /// Build calendar card
  Widget _buildCalendarCard(SessionHistoryLoaded state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: PlannerDesignConstants.modernCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCalendar(state),
            const SizedBox(height: 16),
            _buildIntensityLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(SessionHistoryLoaded state) {
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now(),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: _calendarFormat,
      startingDayOfWeek: StartingDayOfWeek.saturday,
      headerStyle: const HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonShowsNext: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
        ),
        formatButtonTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: Color(0xFF6366F1),
        ),
        formatButtonDecoration: BoxDecoration(
          border: Border.fromBorderSide(
            BorderSide(color: Color(0xFF6366F1)),
          ),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: Color(0xFF6366F1),
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: Color(0xFF10B981),
          shape: BoxShape.circle,
        ),
        defaultTextStyle: const TextStyle(
          fontFamily: 'Cairo',
          color: Color(0xFF1F2937),
        ),
        weekendTextStyle: const TextStyle(
          fontFamily: 'Cairo',
          color: Color(0xFF6B7280),
        ),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, state);
        },
        todayBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, state, isToday: true);
        },
        selectedBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, state, isSelected: true);
        },
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        context.read<SessionHistoryCubit>().selectDate(selectedDay);
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }

  Widget _buildDayCell(
    DateTime day,
    SessionHistoryLoaded state, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    final dateKey =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final intensity = state.history.intensityMap[dateKey] ?? 0;
    final color = _getIntensityColor(intensity);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF6366F1)
            : (isToday ? const Color(0xFF6366F1).withOpacity(0.3) : color),
        shape: BoxShape.circle,
        border: isToday && !isSelected
            ? Border.all(color: const Color(0xFF6366F1), width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: isSelected
                ? Colors.white
                : (intensity > 2 ? Colors.white : const Color(0xFF1F2937)),
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Color _getIntensityColor(int intensity) {
    // Intensity scale: 0 = no sessions, 1-4 = increasing intensity
    switch (intensity) {
      case 0:
        return Colors.transparent;
      case 1:
        return const Color(0xFF10B981).withOpacity(0.2);
      case 2:
        return const Color(0xFF10B981).withOpacity(0.4);
      case 3:
        return const Color(0xFF10B981).withOpacity(0.6);
      case 4:
        return const Color(0xFF10B981).withOpacity(0.8);
      default:
        return Colors.transparent;
    }
  }

  Widget _buildIntensityLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'أقل',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _getIntensityColor(index),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
        const SizedBox(width: 8),
        const Text(
          'أكثر',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: _filterOptions.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF4B5563),
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF6366F1),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
                // TODO: Apply filter
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSessionList(SessionHistoryLoaded state) {
    // Get sessions for selected day
    final selectedDate = state.selectedDate ?? _selectedDay ?? DateTime.now();
    var sessions = state.getSessionsForDate(selectedDate);

    // Apply filters
    sessions = _applyFilters(sessions);

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                size: 48,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter != 'الكل'
                ? 'لا توجد جلسات $_selectedFilter في هذا اليوم'
                : 'لا توجد جلسات في هذا اليوم',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _buildSessionCardFromEntity(session);
      },
    );
  }

  Widget _buildSessionCardFromEntity(HistoricalSession session) {
    final subjectColor = Color(
      int.parse(session.subjectColor.replaceFirst('#', '0xFF')),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: PlannerDesignConstants.modernCardDecoration(),
      child: InkWell(
        onTap: () {
          // Navigate to session details if needed
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Subject icon container
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      subjectColor,
                      subjectColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: subjectColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.book_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.subjectName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Duration badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: Color(0xFF3B82F6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${session.durationMinutes} دقيقة',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: Color(0xFF3B82F6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Points badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '+${session.pointsEarned}',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: Color(0xFFF59E0B),
                                  fontWeight: FontWeight.w500,
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
              _buildMoodIcon(session.mood),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodIcon(String? mood) {
    if (mood == null) return const SizedBox.shrink();

    String emoji;
    switch (mood) {
      case 'happy':
        emoji = '😊';
        break;
      case 'neutral':
        emoji = '😐';
        break;
      case 'sad':
        emoji = '😟';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Text(emoji, style: const TextStyle(fontSize: 24));
  }

  /// Apply filters to session list
  List<HistoricalSession> _applyFilters(List<HistoricalSession> sessions) {
    var filtered = sessions;

    // Apply status filter
    if (_selectedFilter != 'الكل') {
      String statusFilter;
      switch (_selectedFilter) {
        case 'مكتملة':
          statusFilter = 'completed';
          break;
        case 'محذوفة':
          statusFilter = 'deleted';
          break;
        case 'متخطية':
          statusFilter = 'skipped';
          break;
        default:
          statusFilter = '';
      }

      if (statusFilter.isNotEmpty) {
        filtered = filtered.where((s) => s.status == statusFilter).toList();
      }
    }

    // Apply subject filter
    if (_selectedSubject != null) {
      filtered = filtered.where((s) => s.subjectId == _selectedSubject).toList();
    }

    // Apply date range filter
    if (_startDateFilter != null && _endDateFilter != null) {
      filtered = filtered.where((s) {
        final sessionDate = s.scheduledDate;
        return sessionDate.isAfter(_startDateFilter!.subtract(const Duration(days: 1))) &&
               sessionDate.isBefore(_endDateFilter!.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'تصفية الجلسات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 24),

                // Status filter
                const Text(
                  'الحالة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _filterOptions.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return FilterChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF6B7280),
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                        Navigator.pop(context);
                      },
                      backgroundColor: const Color(0xFFF3F4F6),
                      selectedColor: const Color(0xFF6366F1),
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFFE5E7EB),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Clear filters button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'الكل';
                        _selectedSubject = null;
                        _startDateFilter = null;
                        _endDateFilter = null;
                      });
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'مسح التصفية',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exportHistory() async {
    final cubit = context.read<SessionHistoryCubit>();
    final state = cubit.state;

    if (state is! SessionHistoryLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد بيانات للتصدير'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('جاري إنشاء ملف PDF...'),
          duration: Duration(seconds: 2),
        ),
      );

      // No need to load fonts for French - standard PDF fonts work fine

      // Create PDF document
      final pdf = pw.Document();

      // Get filtered sessions for current day
      final selectedDate = state.selectedDate ?? _selectedDay ?? DateTime.now();
      final sessions = _applyFilters(state.getSessionsForDate(selectedDate));

      // Get statistics
      final stats = state.history.statistics;

      // Format date in French
      final dateFormatter = DateFormat('dd/MM/yyyy', 'fr');
      final formattedDate = dateFormatter.format(selectedDate);

      // Add page with standard fonts (French)
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.ltr,  // Left-to-right for French
          build: (context) => [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Historique des Séances d\'Étude',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Date: $formattedDate',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Filtre: $_selectedFilter',
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
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Statistiques',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total des séances: ${stats.totalSessions}'),
                      pw.Text('Total d\'heures: ${stats.totalHours.toStringAsFixed(1)} h'),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Points gagnés: ${stats.totalPoints}'),
                      pw.Text('Durée moyenne: ${stats.averageSessionDuration} min'),
                    ],
                  ),
                ],
              ),
            ),

            // Sessions list
            pw.SizedBox(height: 24),
            pw.Text(
              'Séances (${sessions.length})',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),

            // Sessions table
            if (sessions.isEmpty)
              pw.Center(
                child: pw.Text(
                  'لا توجد جلسات في هذا اليوم',
                  style: const pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey,
                  ),
                ),
              )
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      _buildTableCell('المادة', isHeader: true),
                      _buildTableCell('الوقت', isHeader: true),
                      _buildTableCell('المدة', isHeader: true),
                      _buildTableCell('الحالة', isHeader: true),
                      _buildTableCell('النقاط', isHeader: true),
                    ],
                  ),
                  // Data rows
                  ...sessions.map((session) => pw.TableRow(
                    children: [
                      _buildTableCell(session.subjectName),
                      _buildTableCell(
                        '${session.scheduledStartTime} - ${session.scheduledEndTime}',
                      ),
                      _buildTableCell('${session.durationMinutes} دقيقة'),
                      _buildTableCell(_getStatusText(session.status)),
                      _buildTableCell('${session.pointsEarned}'),
                    ],
                  )),
                ],
              ),

            // Footer
            pw.SizedBox(height: 32),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                'تم إنشاء التقرير بواسطة تطبيق MEMO - ${DateFormat('yyyy-MM-dd HH:mm', 'ar').format(DateTime.now())}',
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
      final safeDate = formattedDate.replaceAll('/', '-');
      final fileName = 'MEMO_History_$safeDate.pdf';
      final file = File('${tempDir.path}/$fileName');

      // Save PDF bytes to temp file
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);
      print('✅ PDF saved locally: ${file.path}');

      // Upload PDF to server (public/planner folder)
      String? serverUrl;
      try {
        final uploadService = PdfUploadService();
        final uploadResponse = await uploadService.uploadPdf(
          filePath: file.path,
          fileName: fileName,
          type: 'history',
        );
        serverUrl = uploadResponse.data.url;
        print('PDF uploaded to server: $serverUrl');
      } catch (e) {
        print('Failed to upload PDF to server: $e');
        // Continue anyway - PDF is saved locally
      }

      // Share the PDF file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'سجل الجلسات الدراسية - $formattedDate',
        text: serverUrl != null
            ? 'سجل جلساتي الدراسية من تطبيق MEMO\n\nرابط التحميل: $serverUrl'
            : 'سجل جلساتي الدراسية من تطبيق MEMO',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(serverUrl != null
                ? 'تم الحفظ على الخادم والجهاز!'
                : 'تم إنشاء ملف PDF بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء التصدير: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Helper to build table cell
  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// Get status text in Arabic
  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'مكتملة';
      case 'skipped':
        return 'متخطية';
      case 'deleted':
        return 'محذوفة';
      case 'missed':
        return 'فائتة';
      default:
        return status;
    }
  }
}
