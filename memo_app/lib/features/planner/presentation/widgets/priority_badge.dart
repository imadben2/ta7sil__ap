import 'package:flutter/material.dart';
import '../../domain/entities/prioritized_subject.dart';

/// Priority Badge Widget
///
/// Displays priority level with color-coded badge
/// Used in session cards to show priority based on PrioritizedSubject score
class PriorityBadge extends StatelessWidget {
  final PriorityLevel priority;
  final bool compact;

  const PriorityBadge({Key? key, required this.priority, this.compact = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactBadge(context);
    }
    return _buildFullBadge(context);
  }

  /// Build full badge with text
  Widget _buildFullBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), color: _getIconColor(), size: 16),
          const SizedBox(width: 6),
          Text(
            _getArabicPriorityText(),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _getTextColor(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build compact badge (icon only)
  Widget _buildCompactBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        shape: BoxShape.circle,
        border: Border.all(color: _getBorderColor(), width: 1.5),
      ),
      child: Icon(_getIcon(), color: _getIconColor(), size: 14),
    );
  }

  /// Get Arabic priority text
  String _getArabicPriorityText() {
    switch (priority) {
      case PriorityLevel.critical:
        return 'حرج';
      case PriorityLevel.high:
        return 'عالي';
      case PriorityLevel.medium:
        return 'متوسط';
      case PriorityLevel.low:
        return 'منخفض';
    }
  }

  /// Get priority icon
  IconData _getIcon() {
    switch (priority) {
      case PriorityLevel.critical:
        return Icons.priority_high;
      case PriorityLevel.high:
        return Icons.arrow_upward;
      case PriorityLevel.medium:
        return Icons.remove;
      case PriorityLevel.low:
        return Icons.arrow_downward;
    }
  }

  /// Get background color
  Color _getBackgroundColor() {
    switch (priority) {
      case PriorityLevel.critical:
        return Colors.red.shade50;
      case PriorityLevel.high:
        return Colors.orange.shade50;
      case PriorityLevel.medium:
        return Colors.yellow.shade50;
      case PriorityLevel.low:
        return Colors.green.shade50;
    }
  }

  /// Get border color
  Color _getBorderColor() {
    switch (priority) {
      case PriorityLevel.critical:
        return Colors.red.shade300;
      case PriorityLevel.high:
        return Colors.orange.shade300;
      case PriorityLevel.medium:
        return Colors.yellow.shade700;
      case PriorityLevel.low:
        return Colors.green.shade300;
    }
  }

  /// Get icon color
  Color _getIconColor() {
    switch (priority) {
      case PriorityLevel.critical:
        return Colors.red.shade700;
      case PriorityLevel.high:
        return Colors.orange.shade700;
      case PriorityLevel.medium:
        return Colors.yellow.shade900;
      case PriorityLevel.low:
        return Colors.green.shade700;
    }
  }

  /// Get text color
  Color _getTextColor() {
    switch (priority) {
      case PriorityLevel.critical:
        return Colors.red.shade900;
      case PriorityLevel.high:
        return Colors.orange.shade900;
      case PriorityLevel.medium:
        return Colors.yellow.shade900;
      case PriorityLevel.low:
        return Colors.green.shade900;
    }
  }
}

/// Priority Score Badge
///
/// Displays numeric priority score with color gradient
/// Shows the actual calculated score from the priority algorithm
class PriorityScoreBadge extends StatelessWidget {
  final double score;
  final bool showLabel;

  const PriorityScoreBadge({
    Key? key,
    required this.score,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final priority = _scoreToPriority(score);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getColorForScore(score),
            _getColorForScore(score).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _getColorForScore(score).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            score.toStringAsFixed(1),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Icon(_getIconForPriority(priority), color: Colors.white, size: 14),
          ],
        ],
      ),
    );
  }

  /// Convert score to priority level
  PriorityLevel _scoreToPriority(double score) {
    if (score >= 80) return PriorityLevel.critical;
    if (score >= 60) return PriorityLevel.high;
    if (score >= 40) return PriorityLevel.medium;
    return PriorityLevel.low;
  }

  /// Get color for score
  Color _getColorForScore(double score) {
    if (score >= 80) return Colors.red.shade600;
    if (score >= 60) return Colors.orange.shade600;
    if (score >= 40) return Colors.yellow.shade700;
    return Colors.green.shade600;
  }

  /// Get icon for priority
  IconData _getIconForPriority(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.critical:
        return Icons.local_fire_department;
      case PriorityLevel.high:
        return Icons.trending_up;
      case PriorityLevel.medium:
        return Icons.trending_flat;
      case PriorityLevel.low:
        return Icons.trending_down;
    }
  }
}

/// Priority Legend Widget
///
/// Shows a legend explaining the priority levels
/// Useful for settings or help screens
class PriorityLegend extends StatelessWidget {
  const PriorityLegend({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مستويات الأولوية',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildLegendItem(
              PriorityLevel.critical,
              'مواد حرجة - تحتاج اهتمام فوري',
              '80-100',
            ),
            const SizedBox(height: 12),
            _buildLegendItem(
              PriorityLevel.high,
              'أولوية عالية - مهمة جداً',
              '60-79',
            ),
            const SizedBox(height: 12),
            _buildLegendItem(
              PriorityLevel.medium,
              'أولوية متوسطة - مهمة',
              '40-59',
            ),
            const SizedBox(height: 12),
            _buildLegendItem(
              PriorityLevel.low,
              'أولوية منخفضة - يمكن التأجيل',
              '0-39',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    PriorityLevel priority,
    String description,
    String scoreRange,
  ) {
    return Row(
      children: [
        PriorityBadge(priority: priority),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'النطاق: $scoreRange',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
