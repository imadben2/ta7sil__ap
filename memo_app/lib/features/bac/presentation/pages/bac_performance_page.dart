import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/bac_subject_entity.dart';
import '../../domain/entities/bac_simulation_entity.dart';
import '../../domain/entities/bac_enums.dart';
import '../bloc/bac_bloc.dart';
import '../bloc/bac_event.dart';
import '../bloc/bac_state.dart';

/// Performance/statistics page showing user simulation history and progress
class BacPerformancePage extends StatefulWidget {
  final BacSubjectEntity? subject;

  const BacPerformancePage({super.key, this.subject});

  @override
  State<BacPerformancePage> createState() => _BacPerformancePageState();
}

class _BacPerformancePageState extends State<BacPerformancePage> {
  @override
  void initState() {
    super.initState();
    // Load simulation history
    context.read<BacBloc>().add(const LoadSimulationHistoryEvent());
  }

  Color get _subjectColor {
    if (widget.subject != null) {
      final colorStr = widget.subject!.color;
      if (colorStr.isNotEmpty) {
        try {
          return Color(int.parse('0xFF${colorStr.replaceFirst('#', '')}'));
        } catch (_) {
          return AppColors.primary;
        }
      }
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: BlocBuilder<BacBloc, BacState>(
                  builder: (context, state) {
                    if (state is BacLoading) {
                      return _buildLoadingState();
                    }

                    if (state is SimulationHistoryLoaded) {
                      final history = state.history;
                      // Filter by subject if provided
                      final filteredHistory = widget.subject != null
                          ? history
                              .where((s) =>
                                  s.bacSubjectId == widget.subject!.id)
                              .toList()
                          : history;

                      if (filteredHistory.isEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildContent(filteredHistory);
                    }

                    if (state is BacError) {
                      return _buildErrorState(state.message);
                    }

                    return _buildEmptyState();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_subjectColor, _subjectColor.withOpacity(0.8)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: _subjectColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.subject != null
                      ? 'إحصائيات ${widget.subject!.nameAr}'
                      : 'الإحصائيات والأداء',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (widget.subject != null) ...[
            const SizedBox(height: 20),
            // Subject stats
            Row(
              children: [
                Expanded(
                  child: _buildHeaderStat(
                    icon: Icons.timer_outlined,
                    label: 'المدة القياسية',
                    value: '${widget.subject!.duration} د',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHeaderStat(
                    icon: Icons.star_rounded,
                    label: 'المعامل',
                    value: '${widget.subject!.coefficient}',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _subjectColor),
          const SizedBox(height: 16),
          const Text(
            'جاري تحميل الإحصائيات...',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _subjectColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 64,
                color: _subjectColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد محاكاة بعد',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'قم بإجراء محاكاة للامتحان لتظهر إحصائياتك هنا',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(
                'بدء محاكاة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _subjectColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<BacBloc>().add(const LoadSimulationHistoryEvent());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _subjectColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<BacSimulationEntity> history) {
    // Calculate stats
    final totalSimulations = history.length;
    final completedSimulations =
        history.where((s) => s.status == SimulationStatus.completed).length;
    final totalTimeMinutes =
        history.fold<int>(0, (sum, s) => sum + (s.elapsedSeconds ~/ 60));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          _buildStatsSection(
            totalSimulations: totalSimulations,
            completedSimulations: completedSimulations,
            totalTimeMinutes: totalTimeMinutes,
          ),
          const SizedBox(height: 28),

          // History Section
          const Text(
            'سجل المحاكاة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // History List
          ...history.map((simulation) => _buildHistoryCard(simulation)),
        ],
      ),
    );
  }

  Widget _buildStatsSection({
    required int totalSimulations,
    required int completedSimulations,
    required int totalTimeMinutes,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.play_circle_outline_rounded,
            label: 'إجمالي المحاكاة',
            value: '$totalSimulations',
            color: _subjectColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle_outline_rounded,
            label: 'مكتملة',
            value: '$completedSimulations',
            color: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time_rounded,
            label: 'الوقت الإجمالي',
            value: _formatTotalTime(totalTimeMinutes),
            color: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  String _formatTotalTime(int minutes) {
    if (minutes < 60) {
      return '$minutes د';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return '$hours س';
      }
      return '$hours س $mins د';
    }
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BacSimulationEntity simulation) {
    final statusColor = _getStatusColor(simulation.status);
    final dateFormat = DateFormat('d MMM yyyy', 'ar');
    final timeFormat = DateFormat('HH:mm', 'ar');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Status indicator
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(simulation.status),
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      simulation.mode.displayName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dateFormat.format(simulation.startedAt)} - ${timeFormat.format(simulation.startedAt)}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(simulation.status),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Details row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(
                  icon: Icons.timer_outlined,
                  label: 'المدة المحددة',
                  value: '${simulation.durationMinutes} د',
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey[300],
                ),
                _buildDetailItem(
                  icon: Icons.hourglass_bottom_rounded,
                  label: 'الوقت المستغرق',
                  value: simulation.formattedElapsedTime,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(SimulationStatus status) {
    switch (status) {
      case SimulationStatus.completed:
        return const Color(0xFF10B981);
      case SimulationStatus.inProgress:
        return const Color(0xFF3B82F6);
      case SimulationStatus.paused:
        return const Color(0xFFF59E0B);
      case SimulationStatus.notStarted:
        return Colors.grey;
      case SimulationStatus.abandoned:
        return const Color(0xFFEF4444);
    }
  }

  IconData _getStatusIcon(SimulationStatus status) {
    switch (status) {
      case SimulationStatus.completed:
        return Icons.check_circle_rounded;
      case SimulationStatus.inProgress:
        return Icons.play_circle_rounded;
      case SimulationStatus.paused:
        return Icons.pause_circle_rounded;
      case SimulationStatus.notStarted:
        return Icons.circle_outlined;
      case SimulationStatus.abandoned:
        return Icons.cancel_rounded;
    }
  }

  String _getStatusText(SimulationStatus status) {
    switch (status) {
      case SimulationStatus.completed:
        return 'مكتملة';
      case SimulationStatus.inProgress:
        return 'جارية';
      case SimulationStatus.paused:
        return 'متوقفة';
      case SimulationStatus.notStarted:
        return 'لم تبدأ';
      case SimulationStatus.abandoned:
        return 'ملغاة';
    }
  }
}
