import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/bac_subject_entity.dart';
import '../../domain/entities/bac_enums.dart';
import '../cubit/simulation_timer_cubit.dart';
import '../widgets/bac_pdf_viewer_modal.dart';
import 'bac_simulation_results_page.dart';

/// Active BAC Simulation Screen
///
/// Full-screen view for running BAC exam simulations with PDF-based exams.
/// Features:
/// - Large countdown timer with circular progress
/// - Timer controls (pause/resume/stop/complete)
/// - PDF viewer modal access
/// - Subject info and stats
/// - Timer alerts at intervals
class BacActiveSimulationPage extends StatefulWidget {
  final BacSubjectEntity subject;
  final SimulationMode mode;
  final int durationMinutes;

  const BacActiveSimulationPage({
    super.key,
    required this.subject,
    required this.mode,
    required this.durationMinutes,
  });

  @override
  State<BacActiveSimulationPage> createState() =>
      _BacActiveSimulationPageState();
}

class _BacActiveSimulationPageState extends State<BacActiveSimulationPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;
  late SimulationTimerCubit _timerCubit;

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

    // Initialize timer
    _timerCubit = SimulationTimerCubit();
    _timerCubit.initialize(widget.durationMinutes);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _breatheController.dispose();
    _timerCubit.close();
    // Restore orientation preferences
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Color get _subjectColor {
    final colorStr = widget.subject.color;
    if (colorStr.isNotEmpty) {
      try {
        return Color(int.parse('0xFF${colorStr.replaceFirst('#', '')}'));
      } catch (_) {
        return AppColors.primary;
      }
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _timerCubit,
      child: BlocListener<SimulationTimerCubit, SimulationTimerState>(
        listener: (context, state) {
          // Handle timer alerts
          if (state.currentAlert != null) {
            _showTimerAlert(state.currentAlert!);
          }

          // Handle timer completion
          if (state.isTimeUp && !state.isPaused) {
            _completeSimulation();
          }
        },
        child: PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) return;
            _showExitConfirmationDialog();
          },
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              body: SafeArea(
                child: Column(
                  children: [
                    // Modern App Bar
                    _buildModernAppBar(),

                    // Subject Header
                    _buildSubjectHeader(),

                    // Timer Section (Main Content)
                    Expanded(
                      child: _buildTimerSection(),
                    ),

                    // Stats Section
                    _buildStatsSection(),

                    // PDF Viewer Button
                    _buildPdfViewerButton(),

                    // Control Buttons
                    _buildControlButtons(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (with confirmation)
          _buildAppBarButton(
            icon: Icons.arrow_back_ios_rounded,
            onPressed: _showExitConfirmationDialog,
          ),
          // Title
          const Text(
            'محاكاة امتحان',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          // Settings/Menu button
          _buildAppBarButton(
            icon: Icons.more_vert_rounded,
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarButton({required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildSubjectHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_subjectColor.withOpacity(0.1), _subjectColor.withOpacity(0.05)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _subjectColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _subjectColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.book_outlined, color: _subjectColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.subject.nameAr,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  widget.subject.bacYear != null
                      ? 'بكالوريا ${widget.subject.bacYear} - ${widget.subject.bacSessionName ?? "الدورة الرئيسية"}'
                      : 'بكالوريا',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return BlocBuilder<SimulationTimerCubit, SimulationTimerState>(
      builder: (context, state) {
        return Center(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: state.isRunning ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _subjectColor.withOpacity(
                          state.isRunning ? _breatheAnimation.value * 0.4 : 0.2,
                        ),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _CircularTimerPainter(
                      progress: state.progress,
                      color: _subjectColor,
                      backgroundColor: Colors.grey.shade200,
                      strokeWidth: 12,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.formattedRemainingTime,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: _subjectColor,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor().withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getStatusText(state),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BlocBuilder<SimulationTimerCubit, SimulationTimerState>(
        builder: (context, state) {
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.timer_outlined,
                  label: 'المدة',
                  value: '${widget.durationMinutes} د',
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.flag_outlined,
                  label: 'الحالة',
                  value: state.isRunning
                      ? 'جارية'
                      : state.isPaused
                          ? 'متوقفة'
                          : 'مجدولة',
                  color: _getStatusColor(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.schedule_rounded,
                  label: 'منقضي',
                  value: state.formattedElapsedTime,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
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
    );
  }

  Widget _buildPdfViewerButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _openPdfViewer,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _subjectColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shadowColor: _subjectColor.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: _subjectColor.withOpacity(0.3), width: 2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf_rounded, size: 24, color: _subjectColor),
            const SizedBox(width: 12),
            const Text(
              'فتح ملف الامتحان',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return BlocBuilder<SimulationTimerCubit, SimulationTimerState>(
      builder: (context, state) {
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
                  onPressed: _showExitConfirmationDialog,
                ),
              ),
              const SizedBox(width: 12),
              // Pause/Resume button
              Expanded(
                flex: 2,
                child: _buildControlButton(
                  icon: state.isRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  label: state.isRunning ? 'إيقاف مؤقت' : 'استئناف',
                  color: _subjectColor,
                  onPressed: () {
                    if (state.isRunning) {
                      _timerCubit.pause();
                    } else if (state.isPaused) {
                      _timerCubit.resume();
                    } else {
                      _timerCubit.start();
                    }
                  },
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              // Complete button
              Expanded(
                child: _buildControlButton(
                  icon: Icons.check_rounded,
                  label: 'إتمام',
                  color: const Color(0xFF10B981),
                  onPressed: _showCompleteConfirmationDialog,
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
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? color : Colors.white,
          foregroundColor: isPrimary ? Colors.white : color,
          elevation: 0,
          shadowColor: color.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: isPrimary ? BorderSide.none : BorderSide(color: color, width: 2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isPrimary ? 24 : 20),
            if (isPrimary) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    final state = _timerCubit.state;
    if (state.isRunning) return const Color(0xFF10B981);
    if (state.isPaused) return const Color(0xFFF59E0B);
    return const Color(0xFF6B7280);
  }

  String _getStatusText(SimulationTimerState state) {
    if (state.isRunning) return 'جارية';
    if (state.isPaused) return 'متوقفة مؤقتاً';
    return 'مجدولة';
  }

  void _openPdfViewer() {
    final pdfUrl = widget.subject.fileUrl ?? widget.subject.downloadUrl;
    if (pdfUrl == null || pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ملف الامتحان غير متوفر',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Open PDF in modal - timer continues in background
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => BacPdfViewerModal(
          pdfUrl: pdfUrl,
          title: widget.subject.nameAr,
          subjectId: widget.subject.id,
          type: 'subject',
          accentColor: _subjectColor,
        ),
      ),
    );
  }

  void _showTimerAlert(TimerAlert alert) {
    String message;
    IconData icon;
    Color color;

    switch (alert) {
      case TimerAlert.thirtyMinutes:
        message = 'تبقى 30 دقيقة على انتهاء الوقت';
        icon = Icons.access_time_rounded;
        color = const Color(0xFF3B82F6);
        break;
      case TimerAlert.tenMinutes:
        message = 'تبقى 10 دقائق فقط!';
        icon = Icons.timer_rounded;
        color = const Color(0xFFF59E0B);
        break;
      case TimerAlert.fiveMinutes:
        message = 'احذر! تبقى 5 دقائق';
        icon = Icons.warning_rounded;
        color = const Color(0xFFFF9800);
        break;
      case TimerAlert.oneMinute:
        message = 'دقيقة واحدة متبقية!';
        icon = Icons.alarm_rounded;
        color = const Color(0xFFEF4444);
        break;
      case TimerAlert.timeUp:
        message = 'انتهى الوقت!';
        icon = Icons.alarm_off_rounded;
        color = const Color(0xFF991B1B);
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'هل أنت متأكد؟',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'سيتم إنهاء المحاكاة وفقدان التقدم الحالي',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'إلغاء',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'إنهاء',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'إتمام المحاكاة',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'هل أنت متأكد من إتمام المحاكاة الآن؟',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'إلغاء',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _completeSimulation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'إتمام',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.info_outline_rounded, color: _subjectColor),
                title: const Text(
                  'معلومات الامتحان',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  // TODO: Show exam info dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline_rounded, color: Color(0xFF3B82F6)),
                title: const Text(
                  'المساعدة',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  // TODO: Show help dialog
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _completeSimulation() {
    final elapsedSeconds = _timerCubit.state.elapsedSeconds;
    final totalSeconds = widget.durationMinutes * 60;

    // Stop timer
    _timerCubit.stop();

    // Navigate to results page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BacSimulationResultsPage(
          subject: widget.subject,
          durationMinutes: widget.durationMinutes,
          elapsedSeconds: elapsedSeconds,
          totalSeconds: totalSeconds,
        ),
      ),
    );
  }
}

/// Custom painter for circular timer progress
class _CircularTimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularTimerPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    this.strokeWidth = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw from top (270 degrees in radians)
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
