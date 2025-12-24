import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/bac_subject_entity.dart';
import '../widgets/bac_pdf_viewer_modal.dart';

/// BAC Simulation Results Page
///
/// Shows completion summary and time statistics after completing a simulation.
/// Features:
/// - Completion celebration with confetti
/// - Time statistics (duration, elapsed, efficiency)
/// - Access to correction PDF
/// - Optional user notes
/// - Retry and home navigation
class BacSimulationResultsPage extends StatefulWidget {
  final BacSubjectEntity subject;
  final int durationMinutes;
  final int elapsedSeconds;
  final int totalSeconds;

  const BacSimulationResultsPage({
    super.key,
    required this.subject,
    required this.durationMinutes,
    required this.elapsedSeconds,
    required this.totalSeconds,
  });

  @override
  State<BacSimulationResultsPage> createState() =>
      _BacSimulationResultsPageState();
}

class _BacSimulationResultsPageState extends State<BacSimulationResultsPage>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Confetti animation
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();

    // Fade in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _fadeController.dispose();
    _notesController.dispose();
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

  int get _elapsedMinutes => widget.elapsedSeconds ~/ 60;
  int get _elapsedSecondsRemainder => widget.elapsedSeconds % 60;
  int get _remainingSeconds => widget.totalSeconds - widget.elapsedSeconds;
  double get _efficiencyPercentage =>
      (widget.elapsedSeconds / widget.totalSeconds * 100).clamp(0, 100);

  bool get _completedOnTime => widget.elapsedSeconds <= widget.totalSeconds;

  String get _formattedElapsedTime {
    if (_elapsedMinutes > 0) {
      return '$_elapsedMinutes دقيقة و $_elapsedSecondsRemainder ثانية';
    }
    return '$_elapsedSecondsRemainder ثانية';
  }

  String get _formattedRemainingTime {
    final remainingMinutes = _remainingSeconds ~/ 60;
    final remainingSecsRemainder = _remainingSeconds % 60;
    if (remainingMinutes > 0) {
      return '$remainingMinutes دقيقة';
    }
    return '$remainingSecsRemainder ثانية';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Stack(
              children: [
                // Confetti overlay
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    particleDrag: 0.05,
                    emissionFrequency: 0.05,
                    numberOfParticles: 30,
                    gravity: 0.3,
                    shouldLoop: false,
                    colors: [
                      _subjectColor,
                      const Color(0xFF10B981),
                      const Color(0xFF3B82F6),
                      const Color(0xFFF59E0B),
                      const Color(0xFFEF4444),
                    ],
                  ),
                ),

                // Main content
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        // Success Header
                        _buildSuccessHeader(),
                        const SizedBox(height: 32),

                        // Time Statistics
                        _buildTimeStatistics(),
                        const SizedBox(height: 24),

                        // Efficiency Card
                        _buildEfficiencyCard(),
                        const SizedBox(height: 24),

                        // Optional Notes
                        _buildNotesSection(),
                        const SizedBox(height: 32),

                        // Correction PDF Button
                        if (widget.subject.hasCorrection) ...[
                          _buildCorrectionButton(),
                          const SizedBox(height: 16),
                        ],

                        // Action Buttons
                        _buildActionButtons(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_subjectColor, _subjectColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _subjectColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'أحسنت! تم إتمام المحاكاة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.subject.nameAr,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeStatistics() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إحصائيات الوقت',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildTimeStatRow(
            icon: Icons.schedule_rounded,
            label: 'المدة المخصصة',
            value: '${widget.durationMinutes} دقيقة',
            color: const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 16),
          _buildTimeStatRow(
            icon: Icons.timer_outlined,
            label: 'الوقت المستغرق',
            value: _formattedElapsedTime,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 16),
          _buildTimeStatRow(
            icon: _completedOnTime ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            label: _completedOnTime ? 'الوقت المتبقي' : 'تجاوز الوقت بـ',
            value: _completedOnTime ? _formattedRemainingTime : _formattedRemainingTime,
            color: _completedOnTime ? const Color(0xFF8B5CF6) : const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEfficiencyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF10B981).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${_efficiencyPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'الفعالية الزمنية',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF059669),
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _efficiencyPercentage / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, color: _subjectColor, size: 24),
              const SizedBox(width: 12),
              const Text(
                'ملاحظاتك (اختياري)',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 4,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'اكتب ملاحظاتك حول الامتحان...',
              hintStyle: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.grey[400],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _subjectColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrectionButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _viewCorrection,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: const Color(0xFF3B82F6).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 24),
            SizedBox(width: 12),
            Text(
              'عرض الحل النموذجي',
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Home button
        Expanded(
          child: SizedBox(
            height: 54,
            child: OutlinedButton(
              onPressed: () => context.go('/bac'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey.shade300, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_rounded, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'الرئيسية',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Retry button
        Expanded(
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _retrySimulation,
              style: ElevatedButton.styleFrom(
                backgroundColor: _subjectColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: _subjectColor.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.replay_rounded, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'إعادة المحاكاة',
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
        ),
      ],
    );
  }

  void _viewCorrection() {
    final correctionUrl = widget.subject.correctionUrl ??
        widget.subject.correctionDownloadUrl;

    if (correctionUrl == null || correctionUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الحل النموذجي غير متوفر حالياً',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => BacPdfViewerModal(
          pdfUrl: correctionUrl,
          title: 'الحل النموذجي - ${widget.subject.nameAr}',
          subjectId: widget.subject.id,
          type: 'correction',
          accentColor: _subjectColor,
        ),
      ),
    );
  }

  void _retrySimulation() {
    // Pop back to subject detail page (2 levels back)
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
