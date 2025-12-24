import 'package:flutter/material.dart';

/// Modern Stat Card - matches session_detail_screen design
/// Shows icon, value, and label in a vertical layout with white background
///
/// Example usage:
/// ```dart
/// ModernStatCard(
///   icon: Icons.emoji_events_rounded,
///   iconColor: Color(0xFFFFD700),
///   value: '1250',
///   label: 'النقاط',
/// )
/// ```
class ModernStatCard extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Icon color
  final Color iconColor;

  /// Main value to display
  final String value;

  /// Label below the value
  final String label;

  /// Optional callback when tapped
  final VoidCallback? onTap;

  const ModernStatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            // Value
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 2),
            // Label
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Row of 3 Modern Stat Cards
/// Convenience widget for displaying stats in a horizontal row
class ModernStatsRow extends StatelessWidget {
  /// List of stat data (icon, color, value, label)
  final List<ModernStatData> stats;

  /// Spacing between cards
  final double spacing;

  const ModernStatsRow({
    super.key,
    required this.stats,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: stats.asMap().entries.map((entry) {
          final index = entry.key;
          final stat = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index > 0 ? spacing / 2 : 0,
                right: index < stats.length - 1 ? spacing / 2 : 0,
              ),
              child: ModernStatCard(
                icon: stat.icon,
                iconColor: stat.iconColor,
                value: stat.value,
                label: stat.label,
                onTap: stat.onTap,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Data class for ModernStatCard
class ModernStatData {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const ModernStatData({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.onTap,
  });
}
