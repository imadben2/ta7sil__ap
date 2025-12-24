import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/leaderboard_entity.dart';

/// Period filter tabs (Weekly / Monthly / All-time)
class PeriodFilterTabs extends StatelessWidget {
  final LeaderboardPeriod selectedPeriod;
  final ValueChanged<LeaderboardPeriod> onPeriodChanged;
  final Color? accentColor;

  const PeriodFilterTabs({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: LeaderboardPeriod.values.map((period) {
          return _buildTab(period, color);
        }).toList(),
      ),
    );
  }

  Widget _buildTab(LeaderboardPeriod period, Color color) {
    final isSelected = selectedPeriod == period;

    return Expanded(
      child: GestureDetector(
        onTap: () => onPeriodChanged(period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            period.labelAr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.slate600,
            ),
          ),
        ),
      ),
    );
  }
}
