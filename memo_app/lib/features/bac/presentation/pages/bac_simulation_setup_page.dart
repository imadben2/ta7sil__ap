import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/bac_subject_entity.dart';
import '../../domain/entities/bac_enums.dart';
import 'bac_active_simulation_page.dart';

/// Pre-Simulation Setup Page - Modern Design
///
/// Allows user to configure simulation before starting:
/// - Select duration (standard, quick, or custom)
/// - View subject information
/// - Start simulation with chosen settings
///
/// Design: Matches planner_settings_screen.dart modern design system
class BacSimulationSetupPage extends StatefulWidget {
  final BacSubjectEntity subject;
  final SimulationMode mode;

  const BacSimulationSetupPage({
    super.key,
    required this.subject,
    required this.mode,
  });

  @override
  State<BacSimulationSetupPage> createState() => _BacSimulationSetupPageState();
}

class _BacSimulationSetupPageState extends State<BacSimulationSetupPage> {
  late int _selectedDurationMinutes;
  DurationPreset _selectedPreset = DurationPreset.standard;

  @override
  void initState() {
    super.initState();
    // Default to subject's standard duration (usually 180 minutes for BAC exams)
    _selectedDurationMinutes = widget.subject.duration;
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

  String get _modeTitle {
    switch (widget.mode) {
      case SimulationMode.exam:
        return 'محاكاة امتحان';
      case SimulationMode.practice:
        return 'وضع التمرين';
      case SimulationMode.quick:
        return 'اختبار سريع';
    }
  }

  IconData get _modeIcon {
    switch (widget.mode) {
      case SimulationMode.exam:
        return Icons.timer_outlined;
      case SimulationMode.practice:
        return Icons.edit_note_rounded;
      case SimulationMode.quick:
        return Icons.flash_on_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.slateBackground,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Subject Info Card - Gradient Hero Card
                _buildSubjectHeroCard(),
                const SizedBox(height: 20),

                // Duration Selection Section
                _buildDurationSelectionSection(),
                const SizedBox(height: 24),

                // Info Note Card
                _buildInfoNoteCard(),
                const SizedBox(height: 28),

                // Start Button
                _buildStartButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
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
            color: AppColors.slate900,
            size: 20,
          ),
        ),
      ),
      title: const Text(
        'إعداد المحاكاة',
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.slate900,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSubjectHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_subjectColor, _subjectColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _subjectColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mode Badge + Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_modeIcon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _modeTitle,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subject.nameAr,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Divider(color: Colors.white.withOpacity(0.25), thickness: 1),
          const SizedBox(height: 14),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatBadge(
                  icon: Icons.calendar_today_rounded,
                  label: widget.subject.bacYear != null
                      ? 'بكالوريا ${widget.subject.bacYear}'
                      : 'بكالوريا',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBadge(
                  icon: Icons.star_rounded,
                  label: 'معامل ${widget.subject.coefficient}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBadge(
                  icon: Icons.schedule_rounded,
                  label: '${widget.subject.duration} د',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelectionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _subjectColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.timer_outlined, color: _subjectColor, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'اختر مدة المحاكاة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Duration Preset Buttons
          Row(
            children: [
              Expanded(
                child: _buildDurationPresetButton(
                  preset: DurationPreset.standard,
                  label: 'قياسي',
                  minutes: widget.subject.duration,
                  icon: Icons.timer_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDurationPresetButton(
                  preset: DurationPreset.quick,
                  label: 'سريع',
                  minutes: 60,
                  icon: Icons.flash_on_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDurationPresetButton(
                  preset: DurationPreset.custom,
                  label: 'مخصص',
                  minutes: null,
                  icon: Icons.tune_rounded,
                ),
              ),
            ],
          ),

          // Custom Duration Input
          if (_selectedPreset == DurationPreset.custom) ...[
            const SizedBox(height: 20),
            _buildCustomDurationInput(),
          ],
        ],
      ),
    );
  }

  Widget _buildDurationPresetButton({
    required DurationPreset preset,
    required String label,
    required int? minutes,
    required IconData icon,
  }) {
    final isSelected = _selectedPreset == preset;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPreset = preset;
          if (minutes != null) {
            _selectedDurationMinutes = minutes;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? _subjectColor : AppColors.slateBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _subjectColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _subjectColor.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.slate600,
              size: 26,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.slate600,
              ),
            ),
            if (minutes != null) ...[
              const SizedBox(height: 4),
              Text(
                '$minutes د',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : _subjectColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDurationInput() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.slateBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _subjectColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Decrement Button
          _buildAdjustButton(
            icon: Icons.remove_rounded,
            onPressed: () {
              if (_selectedDurationMinutes > 10) {
                setState(() => _selectedDurationMinutes -= 10);
              }
            },
          ),

          // Duration Display
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '$_selectedDurationMinutes دقيقة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _subjectColor,
                ),
              ),
            ),
          ),

          // Increment Button
          _buildAdjustButton(
            icon: Icons.add_rounded,
            onPressed: () {
              setState(() => _selectedDurationMinutes += 10);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustButton({required IconData icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _subjectColor.withOpacity(0.2)),
          ),
          child: Icon(icon, color: _subjectColor, size: 24),
        ),
      ),
    );
  }

  Widget _buildInfoNoteCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFF9E6),
            const Color(0xFFFFF9E6).withOpacity(0.5),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB020).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB020).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: Color(0xFFE67E00),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'يمكنك فتح ملف الامتحان أثناء العد التنازلي والعودة للتحقق من الوقت المتبقي',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: Color(0xFF92400E),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _startSimulation,
        style: ElevatedButton.styleFrom(
          backgroundColor: _subjectColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: _subjectColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, size: 28),
            const SizedBox(width: 12),
            Text(
              'بدء المحاكاة ($_selectedDurationMinutes د)',
              style: const TextStyle(
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

  void _startSimulation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BacActiveSimulationPage(
          subject: widget.subject,
          mode: widget.mode,
          durationMinutes: _selectedDurationMinutes,
        ),
      ),
    );
  }
}

/// Duration preset options
enum DurationPreset {
  standard, // Subject's default duration (e.g., 180 min)
  quick,    // 60 minutes
  custom,   // User-defined
}
