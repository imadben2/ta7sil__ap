import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/leaderboard_entity.dart';

/// Scope filter tabs (Subject / Stream)
class ScopeFilterTabs extends StatelessWidget {
  final LeaderboardScope selectedScope;
  final ValueChanged<LeaderboardScope> onScopeChanged;
  final Color? accentColor;

  const ScopeFilterTabs({
    super.key,
    required this.selectedScope,
    required this.onScopeChanged,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: LeaderboardScope.values.map((scope) {
          return _buildTab(scope, color);
        }).toList(),
      ),
    );
  }

  Widget _buildTab(LeaderboardScope scope, Color color) {
    final isSelected = selectedScope == scope;

    return Expanded(
      child: GestureDetector(
        onTap: () => onScopeChanged(scope),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [color, color.withOpacity(0.85)],
                  )
                : null,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                scope == LeaderboardScope.subject
                    ? Icons.menu_book_rounded
                    : Icons.people_rounded,
                size: 18,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
              Text(
                scope.labelAr,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
