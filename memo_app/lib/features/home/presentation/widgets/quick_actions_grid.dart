import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_design_tokens.dart';

/// Quick action item configuration
class QuickActionItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const QuickActionItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });
}

/// 2x3 Grid of quick action buttons for the home page
/// Provides fast access to main app features
class QuickActionsGrid extends StatelessWidget {
  /// Callback when "Continue Study" is tapped
  final VoidCallback onContinueStudy;

  /// Callback when "Quick Quiz" is tapped
  final VoidCallback onQuickQuiz;

  /// Callback when "View Planner" is tapped
  final VoidCallback onViewPlanner;

  /// Callback when "BAC Simulation" is tapped
  final VoidCallback onBacSimulation;

  /// Callback when "Flashcards" is tapped
  final VoidCallback onFlashcards;

  /// Number of today's sessions (shown as badge)
  final int? todaySessionsCount;

  /// Number of pending quizzes (shown as badge)
  final int? pendingQuizzesCount;

  /// Number of flashcards due for review (shown as badge)
  final int? flashcardsDueCount;

  const QuickActionsGrid({
    super.key,
    required this.onContinueStudy,
    required this.onQuickQuiz,
    required this.onViewPlanner,
    required this.onBacSimulation,
    required this.onFlashcards,
    this.todaySessionsCount,
    this.pendingQuizzesCount,
    this.flashcardsDueCount,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      QuickActionItem(
        icon: Icons.menu_book_rounded,
        label: 'استمر الدراسة',
        subtitle: 'أكمل من حيث توقفت',
        gradientColors: [const Color(0xFF10B981), const Color(0xFF059669)],
        onTap: onContinueStudy,
      ),
      QuickActionItem(
        icon: Icons.quiz_rounded,
        label: 'اختبار سريع',
        subtitle: pendingQuizzesCount != null ? '$pendingQuizzesCount اختبار' : 'اختبر معلوماتك',
        gradientColors: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
        onTap: onQuickQuiz,
      ),
      QuickActionItem(
        icon: Icons.calendar_month_rounded,
        label: 'جدول اليوم',
        subtitle: todaySessionsCount != null ? '$todaySessionsCount جلسات' : 'عرض الجدول',
        gradientColors: [AppColors.primary, AppColors.primaryDark],
        onTap: onViewPlanner,
      ),
      QuickActionItem(
        icon: Icons.school_rounded,
        label: 'محاكاة الباك',
        subtitle: 'تدرب على الامتحان',
        gradientColors: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        onTap: onBacSimulation,
      ),
      QuickActionItem(
        icon: Icons.style_rounded,
        label: 'البطاقات التعليمية',
        subtitle: flashcardsDueCount != null ? '$flashcardsDueCount بطاقة للمراجعة' : 'مراجعة بالتكرار المتباعد',
        gradientColors: [const Color(0xFFEC4899), const Color(0xFFDB2777)],
        onTap: onFlashcards,
      ),
    ];

    // Use a custom layout for 5 items: 3 on top row, 2 on bottom row
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // First row: 3 items
          Row(
            children: [
              Expanded(child: _QuickActionButton(action: actions[0])),
              const SizedBox(width: 12),
              Expanded(child: _QuickActionButton(action: actions[1])),
              const SizedBox(width: 12),
              Expanded(child: _QuickActionButton(action: actions[2])),
            ],
          ),
          const SizedBox(height: 12),
          // Second row: 2 items (centered with padding)
          Row(
            children: [
              Expanded(child: _QuickActionButton(action: actions[3])),
              const SizedBox(width: 12),
              Expanded(child: _QuickActionButton(action: actions[4])),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  final QuickActionItem action;

  const _QuickActionButton({required this.action});

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        HapticFeedback.lightImpact();
        widget.action.onTap();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDesignTokens.borderRadiusCard),
            boxShadow: [
              BoxShadow(
                color: widget.action.gradientColors.first.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: widget.action.gradientColors.first.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon with gradient background
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.action.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.action.gradientColors.first.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.action.icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),

                // Label and subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        widget.action.label,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                      ),
                    ),
                    if (widget.action.subtitle != null)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          widget.action.subtitle!,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
