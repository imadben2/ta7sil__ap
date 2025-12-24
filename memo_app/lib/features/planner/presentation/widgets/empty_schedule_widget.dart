import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/planner_bloc.dart';
import '../bloc/planner_event.dart';
import 'shared/planner_design_constants.dart';

/// Empty Schedule Widget - Shown when no schedule is available
///
/// Modern design matching session_detail_screen.dart
/// Features:
/// - Gradient icon container
/// - Modern card with shadow
/// - Gradient button
class EmptyScheduleWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onGenerateSchedule;

  const EmptyScheduleWidget({
    Key? key,
    required this.message,
    this.onGenerateSchedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: PlannerDesignConstants.modernCardDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Modern gradient icon container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.1),
                      const Color(0xFF8B5CF6).withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 48,
                  color: Color(0xFF6366F1),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                'لا يوجد جدول دراسي',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),

              const SizedBox(height: 12),

              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Cairo',
                  color: Color(0xFF6B7280),
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 28),

              // Modern gradient button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateToWizard(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'إنشاء جدول جديد',
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
              ),

              const SizedBox(height: 20),

              // Hint text in modern style
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.tips_and_updates_rounded,
                        size: 16,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'سيتم إنشاء جدول مخصص بناءً على إعداداتك',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Cairo',
                          color: Color(0xFF6B7280),
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
    );
  }

  /// Navigate to wizard and refresh on return
  Future<void> _navigateToWizard(BuildContext context) async {
    if (onGenerateSchedule != null) {
      onGenerateSchedule!();
      return;
    }

    // Default behavior: navigate to wizard and refresh on return
    final result = await context.push<bool>('/planner/wizard');
    if (result == true && context.mounted) {
      // Refresh the schedule after creation
      context.read<PlannerBloc>().add(const LoadTodaysScheduleEvent());
    }
  }
}
