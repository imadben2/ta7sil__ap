import 'package:flutter/material.dart';

/// Level badge widget matching session priority badge design
/// Displays course difficulty level with color coding
class CourseLevelBadge extends StatelessWidget {
  final String? level;
  final bool compact;

  const CourseLevelBadge({
    super.key,
    this.level,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getLevelConfig(level);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        border: Border.all(
          color: config.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: compact ? 12 : 14,
            color: config.color,
          ),
          SizedBox(width: compact ? 3 : 4),
          Text(
            config.label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }

  _LevelConfig _getLevelConfig(String? level) {
    switch (level?.toLowerCase()) {
      case 'beginner':
      case 'مبتدئ':
        return _LevelConfig(
          color: const Color(0xFF10B981), // Green
          label: 'مبتدئ',
          icon: Icons.school_outlined,
        );
      case 'intermediate':
      case 'متوسط':
        return _LevelConfig(
          color: const Color(0xFFF59E0B), // Amber
          label: 'متوسط',
          icon: Icons.trending_up_rounded,
        );
      case 'advanced':
      case 'متقدم':
        return _LevelConfig(
          color: const Color(0xFFEF4444), // Red
          label: 'متقدم',
          icon: Icons.workspace_premium_rounded,
        );
      case 'bac':
      case 'baccalaureate':
      case 'بكالوريا':
        return _LevelConfig(
          color: const Color(0xFF8B5CF6), // Purple
          label: 'بكالوريا',
          icon: Icons.emoji_events_rounded,
        );
      case 'secondary':
      case 'ثانوي':
        return _LevelConfig(
          color: const Color(0xFF3B82F6), // Blue
          label: 'ثانوي',
          icon: Icons.school_rounded,
        );
      default:
        return _LevelConfig(
          color: const Color(0xFF6366F1), // Indigo
          label: 'عام',
          icon: Icons.auto_awesome_rounded,
        );
    }
  }
}

class _LevelConfig {
  final Color color;
  final String label;
  final IconData icon;

  const _LevelConfig({
    required this.color,
    required this.label,
    required this.icon,
  });
}
